import 'package:dartz/dartz.dart';

import 'package:currency_tracker_axis/core/constants/app_constants.dart';
import 'package:currency_tracker_axis/core/error/failures.dart';
import 'package:currency_tracker_axis/features/currency_detail/domain/repositories/historical_rates_repository.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/historical_point.dart';

/// Loads a 7-day historical series for a currency (partial days OK).
class GetSevenDayHistory {
  const GetSevenDayHistory(this._repository);

  final HistoricalRatesRepository _repository;

  Future<Either<Failure, List<HistoricalPoint>>> call(String currencyCode) {
    return _repository.fetchHistory(
      currencyCode,
      AppConstants.historicalDays,
    );
  }
}
