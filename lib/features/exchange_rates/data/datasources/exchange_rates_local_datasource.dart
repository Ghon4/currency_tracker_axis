import 'package:currency_tracker_axis/core/cache/cache_models.dart';

/// Local cache data source contract for rates and historical series.
abstract class ExchangeRatesLocalDataSource {
  Future<void> cacheRates(CachedRates rates);

  CachedRates? readCachedRates();

  Future<void> cacheHistorical(CachedHistorical historical);

  CachedHistorical? readCachedHistorical(String currencyCode);

  Future<void> clearCache();
}
