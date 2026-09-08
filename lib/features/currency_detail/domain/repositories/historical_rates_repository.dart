import 'package:dartz/dartz.dart';

import 'package:currency_tracker_axis/core/error/failures.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/historical_point.dart';

/// Contract for multi-day historical rate series (detail feature).
abstract class HistoricalRatesRepository {
  /// Fetches up to [days] of history for [currencyCode] (partial success OK).
  Future<Either<Failure, List<HistoricalPoint>>> fetchHistory(
    String currencyCode,
    int days,
  );
}
