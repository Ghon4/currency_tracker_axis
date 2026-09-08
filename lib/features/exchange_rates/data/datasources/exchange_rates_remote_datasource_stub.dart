import 'package:currency_tracker_axis/features/exchange_rates/data/datasources/exchange_rates_remote_datasource.dart';
import 'package:currency_tracker_axis/features/exchange_rates/data/models/exchange_rates_response.dart';

/// Foundation stub — real Dio implementation lands in the next module.
class ExchangeRatesRemoteDataSourceStub
    implements ExchangeRatesRemoteDataSource {
  @override
  Future<ExchangeRatesResponse> fetchLatestRates() {
    throw UnimplementedError(
      'ExchangeRatesRemoteDataSource.fetchLatestRates is not implemented yet.',
    );
  }

  @override
  Future<ExchangeRatesResponse> fetchHistoricalRates(String yyyyMmDd) {
    throw UnimplementedError(
      'ExchangeRatesRemoteDataSource.fetchHistoricalRates is not implemented yet.',
    );
  }
}
