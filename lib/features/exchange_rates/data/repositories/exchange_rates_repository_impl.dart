import 'package:currency_tracker_axis/features/exchange_rates/data/datasources/exchange_rates_local_datasource.dart';
import 'package:currency_tracker_axis/features/exchange_rates/data/datasources/exchange_rates_remote_datasource.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/currency_rate.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/historical_point.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/repositories/exchange_rates_repository.dart';

/// Foundation stub repository — orchestration lands in the next module.
class ExchangeRatesRepositoryImpl implements ExchangeRatesRepository {
  ExchangeRatesRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  /// Remote source (stubbed in foundation).
  final ExchangeRatesRemoteDataSource remoteDataSource;

  /// Local Hive-backed cache source.
  final ExchangeRatesLocalDataSource localDataSource;

  @override
  Future<List<CurrencyRate>> getLatestRates({bool forceRefresh = false}) {
    throw UnimplementedError(
      'ExchangeRatesRepository.getLatestRates is not implemented yet.',
    );
  }

  @override
  Future<List<HistoricalPoint>> getHistoricalRates(
    String currencyCode, {
    int days = 7,
  }) {
    throw UnimplementedError(
      'ExchangeRatesRepository.getHistoricalRates is not implemented yet.',
    );
  }
}
