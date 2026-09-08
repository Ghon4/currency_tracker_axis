import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/currency_rate.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/historical_point.dart';

/// Contract for exchange-rate data access (remote + cache orchestration).
abstract class ExchangeRatesRepository {
  /// Latest rates for tracked currencies with day-over-day change.
  Future<List<CurrencyRate>> getLatestRates({bool forceRefresh = false});

  /// Historical inverted rates for [currencyCode] over the chart window.
  Future<List<HistoricalPoint>> getHistoricalRates(
    String currencyCode, {
    int days = 7,
  });
}
