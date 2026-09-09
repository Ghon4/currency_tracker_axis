import 'package:dartz/dartz.dart';

import 'package:currency_tracker_axis/core/error/failures.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/historical_point.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/repositories/exchange_rates_repository.dart';

/// Reads cached historical points for a currency code.
class GetCachedHistorical {
  const GetCachedHistorical(this._repository);

  final ExchangeRatesRepository _repository;

  Future<Either<Failure, List<HistoricalPoint>?>> call(String currencyCode) {
    return _repository.getCachedHistorical(currencyCode);
  }
}
