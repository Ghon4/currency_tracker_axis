import 'package:dartz/dartz.dart';

import 'package:currency_tracker_axis/core/error/failures.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/currency_rate.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/repositories/exchange_rates_repository.dart';

/// Loads latest rates with day-over-day change (cache fallback on network fail).
class GetLatestRatesWithChange {
  const GetLatestRatesWithChange(this._repository);

  final ExchangeRatesRepository _repository;

  Future<Either<Failure, List<CurrencyRate>>> call() {
    return _repository.getRatesWithChange();
  }
}
