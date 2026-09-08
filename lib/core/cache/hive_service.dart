import 'package:hive_flutter/hive_flutter.dart';

import 'package:currency_tracker_axis/core/cache/cache_models.dart';
import 'package:currency_tracker_axis/core/constants/app_constants.dart';
import 'package:currency_tracker_axis/core/error/exceptions.dart';

/// Hive-backed local cache for rates and historical series.
class HiveService {
  Box<HiveCachedRates>? _ratesBox;
  Box<HiveCachedHistorical>? _historicalBox;
  Box<dynamic>? _metaBox;
  bool _initialized = false;

  /// Initializes Flutter Hive, registers adapters, opens boxes, and migrates
  /// schema when [AppConstants.cacheSchemaVersion] changes.
  Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();
    registerCacheAdapters();

    _ratesBox =
        await Hive.openBox<HiveCachedRates>(AppConstants.ratesBoxName);
    _historicalBox = await Hive.openBox<HiveCachedHistorical>(
      AppConstants.historicalBoxName,
    );
    _metaBox = await Hive.openBox<dynamic>(AppConstants.metaBoxName);

    await _migrateSchemaIfNeeded();
    _initialized = true;
  }

  Future<void> _migrateSchemaIfNeeded() async {
    final meta = _requireMetaBox();
    final storedVersion =
        meta.get(AppConstants.cacheSchemaVersionKey) as int?;

    if (storedVersion == AppConstants.cacheSchemaVersion) return;

    await _requireRatesBox().clear();
    await _requireHistoricalBox().clear();
    await meta.put(
      AppConstants.cacheSchemaVersionKey,
      AppConstants.cacheSchemaVersion,
    );
  }

  /// Persists the latest rates snapshot.
  Future<void> saveRates(HiveCachedRates rates) async {
    try {
      await _requireRatesBox().put(AppConstants.cachedRatesKey, rates);
    } catch (error) {
      throw CacheException(message: 'Failed to save rates: $error');
    }
  }

  /// Reads the cached rates snapshot, or `null` if missing.
  HiveCachedRates? readRates() {
    try {
      return _requireRatesBox().get(AppConstants.cachedRatesKey);
    } catch (error) {
      throw CacheException(message: 'Failed to read rates: $error');
    }
  }

  /// Persists historical points for [historical.currencyCode].
  Future<void> saveHistorical(HiveCachedHistorical historical) async {
    try {
      await _requireHistoricalBox().put(
        historical.currencyCode.toUpperCase(),
        historical,
      );
    } catch (error) {
      throw CacheException(message: 'Failed to save historical data: $error');
    }
  }

  /// Reads cached historical data for [currencyCode], or `null`.
  HiveCachedHistorical? readHistorical(String currencyCode) {
    try {
      return _requireHistoricalBox().get(currencyCode.toUpperCase());
    } catch (error) {
      throw CacheException(message: 'Failed to read historical data: $error');
    }
  }

  /// Clears rates, historical, and resets schema metadata.
  Future<void> clearAll() async {
    try {
      await _requireRatesBox().clear();
      await _requireHistoricalBox().clear();
      await _requireMetaBox().put(
        AppConstants.cacheSchemaVersionKey,
        AppConstants.cacheSchemaVersion,
      );
    } catch (error) {
      throw CacheException(message: 'Failed to clear cache: $error');
    }
  }

  Box<HiveCachedRates> _requireRatesBox() {
    final box = _ratesBox;
    if (box == null || !box.isOpen) {
      throw const CacheException(message: 'Rates box is not open.');
    }
    return box;
  }

  Box<HiveCachedHistorical> _requireHistoricalBox() {
    final box = _historicalBox;
    if (box == null || !box.isOpen) {
      throw const CacheException(message: 'Historical box is not open.');
    }
    return box;
  }

  Box<dynamic> _requireMetaBox() {
    final box = _metaBox;
    if (box == null || !box.isOpen) {
      throw const CacheException(message: 'Meta box is not open.');
    }
    return box;
  }
}
