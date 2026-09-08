import 'package:currency_tracker_axis/features/exchange_rates/data/datasources/local/exchange_rates_local_datasource.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/cached_rates.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/currency_rate.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/historical_point.dart';

// Named public ctor params are intentional for DI readability.
// ignore_for_file: prefer_initializing_formals

/// Local helpers for the currency detail feature (header rate + chart cache).
abstract class CurrencyDetailLocalDataSource {
  Future<CurrencyRate?> getCachedRate(String currencyCode);

  Future<List<HistoricalPoint>?> getCachedHistory(String currencyCode);
}

/// Adapts [ExchangeRatesLocalDataSource] for detail-screen lookups.
class CurrencyDetailLocalDataSourceImpl
    implements CurrencyDetailLocalDataSource {
  // Named public ctor params are intentional for DI readability.
  CurrencyDetailLocalDataSourceImpl({
    required ExchangeRatesLocalDataSource ratesLocal,
    required List<CurrencyRate> Function(CachedRates) mapCachedRates,
  })  : _ratesLocal = ratesLocal,
        _mapCachedRates = mapCachedRates;

  final ExchangeRatesLocalDataSource _ratesLocal;
  final List<CurrencyRate> Function(CachedRates) _mapCachedRates;

  @override
  Future<CurrencyRate?> getCachedRate(String currencyCode) async {
    final cached = await _ratesLocal.getCachedRates();
    if (cached == null) return null;
    final rates = _mapCachedRates(cached);
    final code = currencyCode.toUpperCase();
    for (final rate in rates) {
      if (rate.code == code) return rate;
    }
    return null;
  }

  @override
  Future<List<HistoricalPoint>?> getCachedHistory(String currencyCode) {
    return _ratesLocal.getCachedHistorical(currencyCode.toUpperCase());
  }
}
