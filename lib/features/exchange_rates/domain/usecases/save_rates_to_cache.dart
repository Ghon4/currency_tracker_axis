import 'package:dartz/dartz.dart';

import 'package:currency_tracker_axis/core/error/failures.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/currency_rate.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/repositories/exchange_rates_repository.dart';

/// Persists today and yesterday rate lists into local cache.
class SaveRatesToCache {
  const SaveRatesToCache(this._repository);

  final ExchangeRatesRepository _repository;

  Future<Either<Failure, Unit>> call({
    required List<CurrencyRate> rates,
    required List<CurrencyRate> yesterdayRates,
  }) {
    return _repository.cacheRates(rates, yesterdayRates);
  }
}
