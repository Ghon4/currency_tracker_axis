import 'package:dartz/dartz.dart';

import 'package:currency_tracker_axis/core/error/failures.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/cached_rates.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/repositories/exchange_rates_repository.dart';

/// Reads the local rates cache snapshot (or `null` when empty).
class GetCachedRates {
  const GetCachedRates(this._repository);

  final ExchangeRatesRepository _repository;

  Future<Either<Failure, CachedRates?>> call() =>
      _repository.getCachedRates();
}
