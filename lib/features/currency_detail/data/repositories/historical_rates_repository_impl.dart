import 'package:dartz/dartz.dart';

import 'package:currency_tracker_axis/core/error/failures.dart';
import 'package:currency_tracker_axis/features/currency_detail/domain/repositories/historical_rates_repository.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/historical_point.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/repositories/exchange_rates_repository.dart';

/// Historical rates repository that reuses [ExchangeRatesRepository] helpers.
class HistoricalRatesRepositoryImpl implements HistoricalRatesRepository {
  HistoricalRatesRepositoryImpl(this._exchangeRatesRepository);

  final ExchangeRatesRepository _exchangeRatesRepository;

  @override
  Future<Either<Failure, List<HistoricalPoint>>> fetchHistory(
    String currencyCode,
    int days,
  ) {
    return _exchangeRatesRepository.getHistoricalRates(
      currencyCode,
      days: days,
    );
  }
}
