import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:currency_tracker_axis/features/currency_detail/domain/usecases/get_seven_day_history.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/cached_rates.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/currency_rate.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/historical_point.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/usecases/get_cached_rates.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/usecases/get_latest_rates_with_change.dart';

// Named public ctor params are intentional for DI readability.
// ignore_for_file: prefer_initializing_formals

part 'currency_detail_event.dart';
part 'currency_detail_state.dart';

/// Detail BLoC with independent header / chart loading.
class CurrencyDetailBloc
    extends Bloc<CurrencyDetailEvent, CurrencyDetailState> {
  CurrencyDetailBloc({
    required GetSevenDayHistory getSevenDayHistory,
    required GetCachedRates getCachedRates,
    required GetLatestRatesWithChange getLatestRatesWithChange,
    required List<CurrencyRate> Function(CachedRates) mapCachedRates,
  })  : _getSevenDayHistory = getSevenDayHistory,
        _getCachedRates = getCachedRates,
        _getLatestRatesWithChange = getLatestRatesWithChange,
        _mapCachedRates = mapCachedRates,
        super(const CurrencyDetailInitial()) {
    on<LoadDetail>(_onLoadDetail);
    on<RefreshDetail>(_onRefreshDetail);
  }

  final GetSevenDayHistory _getSevenDayHistory;
  final GetCachedRates _getCachedRates;
  final GetLatestRatesWithChange _getLatestRatesWithChange;
  final List<CurrencyRate> Function(CachedRates) _mapCachedRates;

  String? _code;

  Future<void> _onLoadDetail(
    LoadDetail event,
    Emitter<CurrencyDetailState> emit,
  ) async {
    _code = event.currencyCode.toUpperCase();
    emit(CurrencyDetailLoading(currencyCode: _code!));

    final header = await _resolveHeader(_code!, seed: event.seedRate);
    if (header == null) {
      emit(
        CurrencyDetailFullError(
          currencyCode: _code!,
          message: 'Could not load rate for $_code.',
        ),
      );
      return;
    }

    emit(CurrencyDetailHeaderLoaded(header: header));
    await _loadChart(emit, header);
  }

  Future<void> _onRefreshDetail(
    RefreshDetail event,
    Emitter<CurrencyDetailState> emit,
  ) async {
    final code = _code;
    if (code == null) return;

    final previousHeader = switch (state) {
      CurrencyDetailSuccess(:final header) => header,
      CurrencyDetailHeaderLoaded(:final header) => header,
      CurrencyDetailChartError(:final header) => header,
      _ => null,
    };

    emit(CurrencyDetailLoading(currencyCode: code));

    CurrencyDetailHeaderData? header;
    final fresh = await _getLatestRatesWithChange();
    header = fresh.fold(
      (_) => previousHeader,
      (rates) {
        CurrencyRate? match;
        for (final rate in rates) {
          if (rate.code == code) {
            match = rate;
            break;
          }
        }
        if (match == null) return previousHeader;
        return CurrencyDetailHeaderData(
          rate: match,
          isFromCache: match.isFromCache,
          lastUpdated: match.lastUpdated,
        );
      },
    );

    header ??= await _resolveHeader(code, seed: previousHeader?.rate);
    if (header == null) {
      emit(
        CurrencyDetailFullError(
          currencyCode: code,
          message: 'Could not refresh rate for $code.',
        ),
      );
      return;
    }

    emit(CurrencyDetailHeaderLoaded(header: header));
    await _loadChart(emit, header);
  }

  Future<CurrencyDetailHeaderData?> _resolveHeader(
    String code, {
    CurrencyRate? seed,
  }) async {
    if (seed != null && seed.code.toUpperCase() == code) {
      return CurrencyDetailHeaderData(
        rate: seed,
        isFromCache: seed.isFromCache,
        lastUpdated: seed.lastUpdated,
      );
    }

    final cached = await _getCachedRates();
    final fromCache = cached.fold<CurrencyDetailHeaderData?>(
      (_) => null,
      (c) {
        if (c == null) return null;
        final rates = _mapCachedRates(c);
        CurrencyRate? match;
        for (final rate in rates) {
          if (rate.code == code) {
            match = rate;
            break;
          }
        }
        if (match == null) return null;
        return CurrencyDetailHeaderData(
          rate: match,
          isFromCache: true,
          lastUpdated: c.timestamp,
        );
      },
    );
    if (fromCache != null) return fromCache;

    final network = await _getLatestRatesWithChange();
    return network.fold(
      (_) => null,
      (rates) {
        CurrencyRate? match;
        for (final rate in rates) {
          if (rate.code == code) {
            match = rate;
            break;
          }
        }
        if (match == null) return null;
        return CurrencyDetailHeaderData(
          rate: match,
          isFromCache: match.isFromCache,
          lastUpdated: match.lastUpdated,
        );
      },
    );
  }

  Future<void> _loadChart(
    Emitter<CurrencyDetailState> emit,
    CurrencyDetailHeaderData header,
  ) async {
    final result = await _getSevenDayHistory(header.rate.code);
    result.fold(
      (failure) => emit(
        CurrencyDetailChartError(
          header: header,
          message: failure.userMessage,
        ),
      ),
      (points) {
        if (points.isEmpty) {
          emit(
            CurrencyDetailChartError(
              header: header,
              message: 'No historical data available.',
            ),
          );
          return;
        }
        emit(CurrencyDetailSuccess(header: header, points: points));
      },
    );
  }
}
