import 'dart:async';

// Named public ctor params are intentional for DI readability.
// ignore_for_file: prefer_initializing_formals

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:currency_tracker_axis/core/connectivity/connectivity_status.dart';
import 'package:currency_tracker_axis/core/connectivity/usecases/watch_connectivity.dart';
import 'package:currency_tracker_axis/core/constants/app_constants.dart';
import 'package:currency_tracker_axis/core/error/error_messages.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/cached_rates.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/currency_rate.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/usecases/get_cached_rates.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/usecases/get_latest_rates_with_change.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/usecases/is_cache_valid.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/usecases/save_rates_to_cache.dart';

part 'exchange_rates_event.dart';
part 'exchange_rates_state.dart';

/// Cache-first list BLoC with pull-to-refresh and connectivity auto-refresh.
class ExchangeRatesBloc extends Bloc<ExchangeRatesEvent, ExchangeRatesState> {
  ExchangeRatesBloc({
    required GetLatestRatesWithChange getLatestRatesWithChange,
    required GetCachedRates getCachedRates,
    required SaveRatesToCache saveRatesToCache,
    required WatchConnectivity watchConnectivity,
    required IsCacheValid isCacheValid,
    required List<CurrencyRate> Function(CachedRates cached) mapCachedRates,
  })  : _getLatestRatesWithChange = getLatestRatesWithChange,
        _getCachedRates = getCachedRates,
        _saveRatesToCache = saveRatesToCache,
        _isCacheValid = isCacheValid,
        _mapCachedRates = mapCachedRates,
        super(const ExchangeRatesInitial()) {
    on<LoadRates>(_onLoadRates);
    on<RefreshRates>(_onRefreshRates);
    on<ConnectivityRestored>(_onConnectivityRestored);

    // Skip the immediate current-status yield; [LoadRates] owns the first fetch.
    _connectivitySub = watchConnectivity().skip(1).listen((status) {
      if (status != ConnectivityStatus.online) return;
      _reconnectDebounce?.cancel();
      _reconnectDebounce = Timer(
        AppConstants.reconnectRefreshDebounce,
        () {
          if (!isClosed) add(const ConnectivityRestored());
        },
      );
    });
  }

  final GetLatestRatesWithChange _getLatestRatesWithChange;
  final GetCachedRates _getCachedRates;
  // Repository already persists on network success; retained for DI parity.
  // ignore: unused_field
  final SaveRatesToCache _saveRatesToCache;
  final IsCacheValid _isCacheValid;
  final List<CurrencyRate> Function(CachedRates cached) _mapCachedRates;
  StreamSubscription<ConnectivityStatus>? _connectivitySub;
  Timer? _reconnectDebounce;
  CancelToken? _cancelToken;

  Future<void> _onLoadRates(
    LoadRates event,
    Emitter<ExchangeRatesState> emit,
  ) async {
    emit(const ExchangeRatesLoading());

    // 1) Stale-while-revalidate: show cache immediately if present.
    final cachedEither = await _getCachedRates();
    cachedEither.fold(
      (_) {},
      (cached) {
        if (cached != null) {
          final rates = _mapCachedRates(cached);
          if (rates.isNotEmpty) {
            emit(
              ExchangeRatesSuccess(
                rates: rates,
                isFromCache: true,
                lastUpdated: cached.timestamp,
                isCacheStale: !_isFresh(cached.timestamp),
              ),
            );
          }
        }
      },
    );

    // 2) Network (repository also writes cache on success).
    final keep = state is ExchangeRatesSuccess
        ? state as ExchangeRatesSuccess
        : null;
    await _fetchAndEmit(emit, keepOnFail: keep);
  }

  Future<void> _onRefreshRates(
    RefreshRates event,
    Emitter<ExchangeRatesState> emit,
  ) async {
    final previous = state is ExchangeRatesSuccess
        ? state as ExchangeRatesSuccess
        : null;
    emit(ExchangeRatesLoading(previousRates: previous?.rates));
    await _fetchAndEmit(
      emit,
      keepOnFail: previous,
      softFailMessage: previous != null ? ErrorMessages.offlineSoft : null,
    );
  }

  Future<void> _onConnectivityRestored(
    ConnectivityRestored event,
    Emitter<ExchangeRatesState> emit,
  ) async {
    final valid = await _isCacheValid();
    final showingCache = state is ExchangeRatesSuccess &&
        (state as ExchangeRatesSuccess).isFromCache;
    final needsRefresh = !valid ||
        showingCache ||
        state is ExchangeRatesError ||
        state is ExchangeRatesEmpty;
    if (!needsRefresh) return;

    final keep = state is ExchangeRatesSuccess
        ? state as ExchangeRatesSuccess
        : null;
    await _fetchAndEmit(emit, keepOnFail: keep);
  }

  Future<void> _fetchAndEmit(
    Emitter<ExchangeRatesState> emit, {
    ExchangeRatesSuccess? keepOnFail,
    String? softFailMessage,
  }) async {
    _cancelToken?.cancel('Superseded by a new request');
    _cancelToken = CancelToken();

    final result = await _getLatestRatesWithChange();
    result.fold(
      (failure) {
        if (keepOnFail != null) {
          if (softFailMessage != null) {
            emit(
              keepOnFail.copyWith(
                userMessage: softFailMessage,
                isFromCache: true,
                isCacheStale: !_isFresh(keepOnFail.lastUpdated),
              ),
            );
          }
          // Silent keep when softFailMessage is null (background refresh).
          return;
        }
        // Prefer currently displayed success (stale-while-revalidate path).
        if (state is ExchangeRatesSuccess) {
          return;
        }
        emit(
          ExchangeRatesError(
            message: failure.userMessage,
            retryable: true,
          ),
        );
      },
      (rates) {
        if (rates.isEmpty) {
          emit(const ExchangeRatesEmpty());
          return;
        }
        final lastUpdated = rates.first.lastUpdated;
        final fromCache = rates.any((r) => r.isFromCache);
        emit(
          ExchangeRatesSuccess(
            rates: rates,
            isFromCache: fromCache,
            lastUpdated: lastUpdated,
            isCacheStale: fromCache && !_isFresh(lastUpdated),
          ),
        );
      },
    );
  }

  bool _isFresh(DateTime timestamp) =>
      DateTime.now().toUtc().difference(timestamp.toUtc()) <
      AppConstants.cacheTtl;

  @override
  Future<void> close() {
    _reconnectDebounce?.cancel();
    _connectivitySub?.cancel();
    _cancelToken?.cancel('Bloc closed');
    return super.close();
  }
}
