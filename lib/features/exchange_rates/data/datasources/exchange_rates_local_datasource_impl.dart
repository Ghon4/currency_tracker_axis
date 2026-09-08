import 'package:currency_tracker_axis/core/cache/cache_models.dart';
import 'package:currency_tracker_axis/core/cache/hive_service.dart';
import 'package:currency_tracker_axis/features/exchange_rates/data/datasources/exchange_rates_local_datasource.dart';

/// Hive-backed local data source for exchange rates.
class ExchangeRatesLocalDataSourceImpl
    implements ExchangeRatesLocalDataSource {
  ExchangeRatesLocalDataSourceImpl(this._hive);

  final HiveService _hive;

  @override
  Future<void> cacheRates(CachedRates rates) => _hive.saveRates(rates);

  @override
  CachedRates? readCachedRates() => _hive.readRates();

  @override
  Future<void> cacheHistorical(CachedHistorical historical) =>
      _hive.saveHistorical(historical);

  @override
  CachedHistorical? readCachedHistorical(String currencyCode) =>
      _hive.readHistorical(currencyCode);

  @override
  Future<void> clearCache() => _hive.clearAll();
}
