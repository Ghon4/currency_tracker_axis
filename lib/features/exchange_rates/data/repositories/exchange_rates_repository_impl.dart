import 'package:dartz/dartz.dart';

import 'package:currency_tracker_axis/core/error/error_mapper.dart';
import 'package:currency_tracker_axis/core/error/failures.dart';
import 'package:currency_tracker_axis/core/utils/date_utils.dart';
import 'package:currency_tracker_axis/features/exchange_rates/data/datasources/local/exchange_rates_local_datasource.dart';
import 'package:currency_tracker_axis/features/exchange_rates/data/datasources/remote/exchange_rates_remote_datasource.dart';
import 'package:currency_tracker_axis/features/exchange_rates/data/mappers/rate_mapper.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/cached_rates.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/currency_rate.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/historical_point.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/repositories/exchange_rates_repository.dart';

/// Cache-first / network-fallback exchange rates repository.
class ExchangeRatesRepositoryImpl implements ExchangeRatesRepository {
  ExchangeRatesRepositoryImpl({
    required this.remote,
    required this.local,
    required this.errorMapper,
    required this.rateMapper,
  });

  final ExchangeRatesRemoteDataSource remote;
  final ExchangeRatesLocalDataSource local;
  final ErrorMapper errorMapper;
  final RateMapper rateMapper;

  @override
  Future<Either<Failure, List<CurrencyRate>>> getLatestRates() async {
    try {
      final latest = await remote.getLatestRates();
      final rates = rateMapper.toCurrencyRates(
        latest,
        yesterdayInverted: null,
        isFromCache: false,
      );
      if (rates.isEmpty) {
        return const Left(Failure.empty());
      }

      try {
        await local.saveRates(
          rateMapper.invertedMap(latest),
          const {},
          DateTime.now().toUtc(),
          apiDate: latest.date,
        );
      } catch (_) {
        // Cache write failure should not fail a successful remote read.
      }

      return Right(rates);
    } catch (e, st) {
      return _fallbackToCachedRates(e, st);
    }
  }

  @override
  Future<Either<Failure, List<CurrencyRate>>> getRatesWithChange() async {
    try {
      final latest = await remote.getLatestRates();

      Map<String, double>? yesterdayInverted;
      try {
        final yesterdayResponse =
            await remote.getHistoricalRates(AppDateUtils.utcYesterday());
        yesterdayInverted = rateMapper.invertedMap(yesterdayResponse);
      } catch (_) {
        yesterdayInverted = null;
      }

      final rates = rateMapper.toCurrencyRates(
        latest,
        yesterdayInverted: yesterdayInverted,
        isFromCache: false,
      );
      if (rates.isEmpty) {
        return const Left(Failure.empty());
      }

      try {
        // Prefer previous cached yesterday when today's yesterday fetch failed.
        var yesterdayToStore = yesterdayInverted ?? const <String, double>{};
        if (yesterdayInverted == null) {
          final previous = await local.getCachedRates();
          if (previous != null && previous.yesterdayRates.isNotEmpty) {
            yesterdayToStore = previous.yesterdayRates;
          }
        }

        await local.saveRates(
          rateMapper.invertedMap(latest),
          yesterdayToStore,
          DateTime.now().toUtc(),
          apiDate: latest.date,
        );
      } catch (_) {
        // Cache write failure should not fail a successful remote read.
      }

      return Right(rates);
    } catch (e, st) {
      return _fallbackToCachedRates(e, st);
    }
  }

  Future<Either<Failure, List<CurrencyRate>>> _fallbackToCachedRates(
    Object error,
    StackTrace stackTrace,
  ) async {
    try {
      final cached = await local.getCachedRates();
      if (cached == null) {
        return Left(errorMapper.map(error, stackTrace));
      }
      final rates = rateMapper.fromCached(cached, isFromCache: true);
      if (rates.isEmpty) {
        return Left(errorMapper.map(error, stackTrace));
      }
      return Right(rates);
    } catch (cacheError, cacheSt) {
      return Left(errorMapper.map(cacheError, cacheSt));
    }
  }

  @override
  Future<Either<Failure, List<HistoricalPoint>>> getHistoricalRates(
    String currencyCode, {
    required int days,
  }) async {
    final code = currencyCode.toUpperCase();
    final dates = AppDateUtils.lastNUtcDays(days);

    final results = await Future.wait(
      dates.map((d) async {
        try {
          final response = await remote.getHistoricalRates(d);
          final rate = rateMapper.invertedRateFor(response, code);
          if (rate == null) return null;
          return HistoricalPoint(date: d, rate: rate);
        } catch (_) {
          return null;
        }
      }),
    );

    final points =
        results.whereType<HistoricalPoint>().toList(growable: false);

    if (points.isEmpty) {
      try {
        final cached = await local.getCachedHistorical(code);
        if (cached != null && cached.isNotEmpty) {
          return Right(cached);
        }
      } catch (e, st) {
        return Left(errorMapper.map(e, st));
      }
      return const Left(Failure.empty('No historical data available.'));
    }

    try {
      await local.saveHistorical(code, points);
    } catch (_) {
      // Ignore cache write errors after a successful partial fetch.
    }

    return Right(points);
  }

  @override
  Future<Either<Failure, Unit>> cacheRates(
    List<CurrencyRate> rates,
    List<CurrencyRate> yesterdayRates,
  ) async {
    try {
      await local.saveRates(
        rateMapper.invertedMapFromRates(rates),
        rateMapper.invertedMapFromRates(yesterdayRates),
        DateTime.now().toUtc(),
        apiDate: rates.isNotEmpty
            ? AppDateUtils.toApiDate(rates.first.lastUpdated)
            : null,
      );
      return const Right(unit);
    } catch (e, st) {
      return Left(errorMapper.map(e, st));
    }
  }

  @override
  Future<Either<Failure, CachedRates?>> getCachedRates() async {
    try {
      return Right(await local.getCachedRates());
    } catch (e, st) {
      return Left(errorMapper.map(e, st));
    }
  }

  @override
  Future<Either<Failure, Unit>> cacheHistorical(
    String currencyCode,
    List<HistoricalPoint> points,
  ) async {
    try {
      await local.saveHistorical(currencyCode.toUpperCase(), points);
      return const Right(unit);
    } catch (e, st) {
      return Left(errorMapper.map(e, st));
    }
  }

  @override
  Future<Either<Failure, List<HistoricalPoint>?>> getCachedHistorical(
    String currencyCode,
  ) async {
    try {
      return Right(await local.getCachedHistorical(currencyCode.toUpperCase()));
    } catch (e, st) {
      return Left(errorMapper.map(e, st));
    }
  }
}
