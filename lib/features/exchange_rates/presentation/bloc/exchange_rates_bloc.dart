import 'dart:async';

// Named public ctor params are intentional for DI readability.
// ignore_for_file: prefer_initializing_formals

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:currency_tracker_axis/core/connectivity/connectivity_status.dart';
import 'package:currency_tracker_axis/core/connectivity/usecases/watch_connectivity.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/cached_rates.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/currency_rate.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/usecases/get_cached_rates.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/usecases/get_latest_rates_with_change.dart';
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
    required List<CurrencyRate> Function(CachedRates cached) mapCachedRates,
  })  : _getLatestRatesWithChange = getLatestRatesWithChange,
        _getCachedRates = getCachedRates,
        _saveRatesToCache = saveRatesToCache,
        _mapCachedRates = mapCachedRates,
        super(const ExchangeRatesInitial()) {
    on<LoadRates>(_onLoadRates);
    on<RefreshRates>(_onRefreshRates);
    on<ConnectivityRestored>(_onConnectivityRestored);

    // Skip the immediate current-status yield; [LoadRates] owns the first fetch.
    _connectivitySub = watchConnectivity().skip(1).listen((status) {
      if (status == ConnectivityStatus.online) {
        add(const ConnectivityRestored());
      }
    });
  }

  final GetLatestRatesWithChange _getLatestRatesWithChange;
  final GetCachedRates _getCachedRates;
  // Repository already persists on network success; retained for DI parity.
  // ignore: unused_field
  final SaveRatesToCache _saveRatesToCache;
  final List<CurrencyRate> Function(CachedRates cached) _mapCachedRates;
  StreamSubscription<ConnectivityStatus>? _connectivitySub;

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
              ),
            );
          }
        }
      },
    );

    // 2) Network (repository also writes cache on success).
    await _fetchAndEmit(emit, preferKeepSuccessOnFail: true);
  }

  Future<void> _onRefreshRates(
    RefreshRates event,
    Emitter<ExchangeRatesState> emit,
  ) async {
    final previous = state is ExchangeRatesSuccess
        ? (state as ExchangeRatesSuccess).rates
        : null;
    emit(ExchangeRatesLoading(previousRates: previous));
    await _fetchAndEmit(emit, preferKeepSuccessOnFail: false);
  }

  Future<void> _onConnectivityRestored(
    ConnectivityRestored event,
    Emitter<ExchangeRatesState> emit,
  ) async {
    final shouldRefresh = state is ExchangeRatesError ||
        state is ExchangeRatesEmpty ||
        (state is ExchangeRatesSuccess &&
            (state as ExchangeRatesSuccess).isFromCache);

    if (!shouldRefresh) return;
    await _fetchAndEmit(emit, preferKeepSuccessOnFail: true);
  }

  Future<void> _fetchAndEmit(
    Emitter<ExchangeRatesState> emit, {
    required bool preferKeepSuccessOnFail,
  }) async {
    final result = await _getLatestRatesWithChange();
    result.fold(
      (failure) {
        if (preferKeepSuccessOnFail && state is ExchangeRatesSuccess) {
          // Keep showing cache; silent failure during background refresh.
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
          ),
        );
      },
    );
  }

  @override
  Future<void> close() {
    _connectivitySub?.cancel();
    return super.close();
  }
}
