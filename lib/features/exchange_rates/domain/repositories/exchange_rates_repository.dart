import 'package:dartz/dartz.dart';

import 'package:currency_tracker_axis/core/error/failures.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/cached_rates.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/currency_rate.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/historical_point.dart';

/// Contract for exchange-rate data access (remote + cache orchestration).
abstract class ExchangeRatesRepository {
  /// Latest inverted rates for target currencies (change fields null).
  Future<Either<Failure, List<CurrencyRate>>> getLatestRates();

  /// Today + yesterday; change null if yesterday unavailable.
  Future<Either<Failure, List<CurrencyRate>>> getRatesWithChange();

  /// Historical inverted rates for [currencyCode] over [days] (partial OK).
  Future<Either<Failure, List<HistoricalPoint>>> getHistoricalRates(
    String currencyCode, {
    required int days,
  });

  /// Persists inverted today/yesterday rate maps derived from [rates].
  Future<Either<Failure, Unit>> cacheRates(
    List<CurrencyRate> rates,
    List<CurrencyRate> yesterdayRates,
  );

  /// Reads the domain cache snapshot, or `null` when empty.
  Future<Either<Failure, CachedRates?>> getCachedRates();

  /// Persists historical points for [currencyCode].
  Future<Either<Failure, Unit>> cacheHistorical(
    String currencyCode,
    List<HistoricalPoint> points,
  );

  /// Reads cached historical points, or `null` when missing.
  Future<Either<Failure, List<HistoricalPoint>?>> getCachedHistorical(
    String currencyCode,
  );
}
