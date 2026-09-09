import 'package:currency_tracker_axis/core/cache/cache_models.dart';
import 'package:currency_tracker_axis/core/cache/hive_service.dart';
import 'package:currency_tracker_axis/core/cache/memory_rates_cache.dart';
import 'package:currency_tracker_axis/core/constants/app_constants.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/cached_rates.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/historical_point.dart';

// Named public ctor params are intentional for DI readability.
// ignore_for_file: prefer_initializing_formals

/// Two-tier cache (memory → Hive) with 24-hour TTL helpers.
class CacheOperations {
  CacheOperations({
    required HiveService hive,
    required MemoryRatesCache memory,
  })  : _hive = hive,
        _memory = memory;

  final HiveService _hive;
  final MemoryRatesCache _memory;

  static const ttl = AppConstants.cacheTtl;

  /// Writes rates to memory and Hive.
  Future<void> saveRates({
    required Map<String, double> rates,
    required Map<String, double> yesterdayRates,
    required DateTime timestamp,
    String? apiDate,
  }) async {
    final cached = CachedRates(
      rates: Map<String, double>.from(rates),
      yesterdayRates: Map<String, double>.from(yesterdayRates),
      timestamp: timestamp.toUtc(),
      apiDate: apiDate,
    );
    _memory.saveRates(cached);
    await _hive.saveRates(
      HiveCachedRates(
        rates: Map<String, double>.from(rates),
        yesterdayRates: Map<String, double>.from(yesterdayRates),
        timestamp: timestamp.toUtc(),
        apiDate: apiDate,
      ),
    );
  }

  /// Memory first, then Hive (hydrating memory on disk hit).
  Future<CachedRates?> getCachedRates() async {
    final mem = _memory.getRates();
    if (mem != null) return mem;

    final disk = _hive.readRates();
    if (disk == null) return null;

    final domain = CachedRates(
      rates: Map<String, double>.from(disk.rates),
      yesterdayRates: Map<String, double>.from(disk.yesterdayRates),
      timestamp: disk.timestamp,
      apiDate: disk.apiDate,
    );
    _memory.saveRates(domain);
    return domain;
  }

  /// True when a snapshot exists and is younger than [ttl].
  Future<bool> isCacheValid() async {
    final cached = await getCachedRates();
    if (cached == null) return false;
    return DateTime.now().toUtc().difference(cached.timestamp) < ttl;
  }

  /// Timestamp of the current rates snapshot, if any.
  Future<DateTime?> getCacheTimestamp() async =>
      (await getCachedRates())?.timestamp;

  /// Clears memory and Hive (schema version is preserved by [HiveService]).
  Future<void> clearCache() async {
    _memory.clear();
    await _hive.clearAll();
  }

  /// Writes historical points to memory and Hive.
  Future<void> saveHistorical(
    String code,
    List<HistoricalPoint> points,
  ) async {
    final upper = code.toUpperCase();
    _memory.saveHistorical(upper, points);
    await _hive.saveHistorical(
      HiveCachedHistorical(
        currencyCode: upper,
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
  }

  /// Memory first, then Hive for historical series.
  Future<List<HistoricalPoint>?> getCachedHistorical(String code) async {
    final upper = code.toUpperCase();
    final mem = _memory.getHistorical(upper);
    if (mem != null) return mem;

    final disk = _hive.readHistorical(upper);
    if (disk == null) return null;

    final points = disk.points
        .map(
          (p) => HistoricalPoint(
            date: p.date.toUtc(),
            rate: p.rate,
          ),
        )
        .toList(growable: false);
    _memory.saveHistorical(upper, points);
    return points;
  }
}
