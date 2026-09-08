import 'package:currency_tracker_axis/features/exchange_rates/data/models/exchange_rates_response.dart';

/// Remote data source contract for currency API calls.
abstract class ExchangeRatesRemoteDataSource {
  /// Fetches the latest rates snapshot for the base currency.
  Future<ExchangeRatesResponse> fetchLatestRates();

  /// Fetches rates for a specific UTC API date (`yyyy-MM-dd`).
  Future<ExchangeRatesResponse> fetchHistoricalRates(String yyyyMmDd);
}
