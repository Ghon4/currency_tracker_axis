import 'package:hive/hive.dart';

import 'package:currency_tracker_axis/core/cache/cache_models.dart';
import 'package:currency_tracker_axis/core/cache/hive_service.dart';
import 'package:currency_tracker_axis/core/error/exceptions.dart';
import 'package:currency_tracker_axis/core/utils/date_utils.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/cached_rates.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/historical_point.dart';

/// Local cache data source contract for rates and historical series.
abstract class ExchangeRatesLocalDataSource {
  /// Persists inverted today/yesterday rate maps with a [timestamp].
  Future<void> saveRates(
    Map<String, double> rates,
    Map<String, double> yesterdayRates,
    DateTime timestamp, {
    String? apiDate,
  });

  /// Reads the domain cache snapshot, or `null` when missing.
  Future<CachedRates?> getCachedRates();

  /// Persists historical [points] for [currencyCode].
  Future<void> saveHistorical(
    String currencyCode,
    List<HistoricalPoint> points,
  );

  /// Reads cached historical points for [currencyCode], or `null`.
  Future<List<HistoricalPoint>?> getCachedHistorical(String currencyCode);

  /// Valid when cached timestamp is the same UTC calendar day as now.
  Future<bool> isCacheValid();
}

/// Hive-backed implementation of [ExchangeRatesLocalDataSource].
class ExchangeRatesLocalDataSourceImpl
    implements ExchangeRatesLocalDataSource {
  ExchangeRatesLocalDataSourceImpl(this._hive);

  final HiveService _hive;

  @override
  Future<void> saveRates(
    Map<String, double> rates,
    Map<String, double> yesterdayRates,
    DateTime timestamp, {
    String? apiDate,
  }) async {
    try {
      await _hive.saveRates(
        HiveCachedRates(
          rates: Map<String, double>.from(rates),
          yesterdayRates: Map<String, double>.from(yesterdayRates),
          timestamp: timestamp.toUtc(),
          apiDate: apiDate,
        ),
      );
    } on CacheException {
      rethrow;
    } on HiveError catch (e) {
      throw CacheException(message: e.message);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<CachedRates?> getCachedRates() async {
    try {
      final hive = _hive.readRates();
      if (hive == null) return null;
      return CachedRates(
        rates: Map<String, double>.from(hive.rates),
        yesterdayRates: Map<String, double>.from(hive.yesterdayRates),
        timestamp: hive.timestamp,
        apiDate: hive.apiDate,
      );
    } on CacheException {
      rethrow;
    } on HiveError catch (e) {
      throw CacheException(message: e.message);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> saveHistorical(
    String currencyCode,
    List<HistoricalPoint> points,
  ) async {
    try {
      final code = currencyCode.toUpperCase();
      await _hive.saveHistorical(
        HiveCachedHistorical(
          currencyCode: code,
          points: points
              .map(
                (p) => HiveCachedHistoricalPoint(
                  date: p.date.toUtc(),
                  rate: p.rate,
                ),
              )
              .toList(growable: false),
          timestamp: DateTime.now().toUtc(),
        ),
      );
    } on CacheException {
      rethrow;
    } on HiveError catch (e) {
      throw CacheException(message: e.message);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<List<HistoricalPoint>?> getCachedHistorical(
    String currencyCode,
  ) async {
    try {
      final hive = _hive.readHistorical(currencyCode.toUpperCase());
      if (hive == null) return null;
      return hive.points
          .map(
            (p) => HistoricalPoint(
              date: p.date.toUtc(),
              rate: p.rate,
            ),
          )
          .toList(growable: false);
    } on CacheException {
      rethrow;
    } on HiveError catch (e) {
      throw CacheException(message: e.message);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<bool> isCacheValid() async {
    final cached = await getCachedRates();
    if (cached == null) return false;
    final today = AppDateUtils.utcToday();
    final cachedDay = DateTime.utc(
      cached.timestamp.toUtc().year,
      cached.timestamp.toUtc().month,
      cached.timestamp.toUtc().day,
    );
    return cachedDay == today;
  }
}
