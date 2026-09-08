import 'package:currency_tracker_axis/core/utils/date_utils.dart';
import 'package:currency_tracker_axis/features/exchange_rates/data/datasources/remote/exchange_rates_remote_datasource.dart';
import 'package:currency_tracker_axis/features/exchange_rates/data/mappers/rate_mapper.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/historical_point.dart';

// Named public ctor params are intentional for DI readability.
// ignore_for_file: prefer_initializing_formals

/// Parallel historical fetch helper (null entry = missing/failed day).
abstract class HistoricalRatesRemoteDataSource {
  /// Fetches the last [days] UTC calendar days (oldest → newest, includes today).
  ///
  /// Failed or missing days are represented as `null` so callers can keep a
  /// partial series.
  Future<List<HistoricalPoint?>> fetchLastDays({
    required String currencyCode,
    required int days,
  });
}

/// Thin wrapper around [ExchangeRatesRemoteDataSource] — no second Dio stack.
class HistoricalRatesRemoteDataSourceImpl
    implements HistoricalRatesRemoteDataSource {
  // Named public ctor params are intentional for DI readability.
  HistoricalRatesRemoteDataSourceImpl({
    required ExchangeRatesRemoteDataSource ratesRemote,
    required RateMapper mapper,
  })  : _ratesRemote = ratesRemote,
        _mapper = mapper;

  final ExchangeRatesRemoteDataSource _ratesRemote;
  final RateMapper _mapper;

  @override
  Future<List<HistoricalPoint?>> fetchLastDays({
    required String currencyCode,
    required int days,
  }) async {
    final code = currencyCode.toUpperCase();
    final dates = AppDateUtils.lastNUtcDays(days);

    return Future.wait(
      dates.map((date) async {
        try {
          final response = await _ratesRemote.getHistoricalRates(date);
          final rate = _mapper.invertedRateFor(response, code);
          if (rate == null) return null;
          return HistoricalPoint(date: date, rate: rate);
        } catch (_) {
          return null;
        }
      }),
    );
  }
}
