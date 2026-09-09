import 'package:currency_tracker_axis/core/error/exceptions.dart';
import 'package:currency_tracker_axis/features/exchange_rates/data/datasources/local/cache_operations.dart';
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

  /// Valid when cached timestamp is within the 24-hour TTL.
  Future<bool> isCacheValid();

  /// Timestamp of the cached rates snapshot, if any.
  Future<DateTime?> getCacheTimestamp();

  /// Clears memory + Hive cache.
  Future<void> clearCache();
}

/// Delegates all cache IO to [CacheOperations] (single write path).
class ExchangeRatesLocalDataSourceImpl
    implements ExchangeRatesLocalDataSource {
  ExchangeRatesLocalDataSourceImpl(this._cache);

  final CacheOperations _cache;

  @override
  Future<void> saveRates(
    Map<String, double> rates,
    Map<String, double> yesterdayRates,
    DateTime timestamp, {
    String? apiDate,
  }) async {
    try {
      await _cache.saveRates(
        rates: rates,
        yesterdayRates: yesterdayRates,
        timestamp: timestamp,
        apiDate: apiDate,
      );
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<CachedRates?> getCachedRates() async {
    try {
      return await _cache.getCachedRates();
    } on CacheException {
      rethrow;
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
      await _cache.saveHistorical(currencyCode, points);
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<List<HistoricalPoint>?> getCachedHistorical(
    String currencyCode,
  ) async {
    try {
      return await _cache.getCachedHistorical(currencyCode);
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<bool> isCacheValid() async {
    try {
      return await _cache.isCacheValid();
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<DateTime?> getCacheTimestamp() async {
    try {
      return await _cache.getCacheTimestamp();
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _cache.clearCache();
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }
}
