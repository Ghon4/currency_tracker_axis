import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:currency_tracker_axis/core/error/error_mapper.dart';
import 'package:currency_tracker_axis/core/error/exceptions.dart';
import 'package:currency_tracker_axis/core/error/failures.dart';
import 'package:currency_tracker_axis/features/currency_detail/data/datasources/remote/historical_rates_remote_datasource.dart';
import 'package:currency_tracker_axis/features/exchange_rates/data/datasources/local/exchange_rates_local_datasource.dart';
import 'package:currency_tracker_axis/features/exchange_rates/data/datasources/remote/exchange_rates_remote_datasource.dart';
import 'package:currency_tracker_axis/features/exchange_rates/data/mappers/rate_mapper.dart';
import 'package:currency_tracker_axis/features/exchange_rates/data/models/exchange_rates_response.dart';
import 'package:currency_tracker_axis/features/exchange_rates/data/repositories/exchange_rates_repository_impl.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/cached_rates.dart';

class _MockRemote extends Mock implements ExchangeRatesRemoteDataSource {}

class _MockLocal extends Mock implements ExchangeRatesLocalDataSource {}

void main() {
  late _MockRemote remote;
  late _MockLocal local;
  late ExchangeRatesRepositoryImpl repository;

  final todayResponse = ExchangeRatesResponse(
    date: '2024-01-15',
    egp: const {
      'usd': 0.02,
      'eur': 0.025,
      'gbp': 0.015,
      'sar': 0.075,
      'jpy': 3.0,
    },
  );

  final yesterdayResponse = ExchangeRatesResponse(
    date: '2024-01-14',
    egp: const {
      'usd': 0.025, // inverted 40 vs today 50
      'eur': 0.025,
      'gbp': 0.015,
      'sar': 0.075,
      'jpy': 3.0,
    },
  );

  setUpAll(() {
    registerFallbackValue(DateTime.utc(2024, 1, 1));
    registerFallbackValue(<String, double>{});
  });

  setUp(() {
    remote = _MockRemote();
    local = _MockLocal();
    repository = ExchangeRatesRepositoryImpl(
      remote: remote,
      local: local,
      errorMapper: const ErrorMapper(),
      rateMapper: const RateMapper(),
      historicalRemote: HistoricalRatesRemoteDataSourceImpl(
        ratesRemote: remote,
        mapper: const RateMapper(),
      ),
    );

    when(
      () => local.saveRates(
        any(),
        any(),
        any(),
        apiDate: any(named: 'apiDate'),
      ),
    ).thenAnswer((_) async {});
  });

  group('ExchangeRatesRepositoryImpl.getRatesWithChange', () {
    test('network success caches and returns rates with change', () async {
      when(() => remote.getLatestRates())
          .thenAnswer((_) async => todayResponse);
      when(() => remote.getHistoricalRates(any()))
          .thenAnswer((_) async => yesterdayResponse);

      final result = await repository.getRatesWithChange();

      expect(result.isRight(), isTrue);
      final rates = result.getOrElse(() => []);
      expect(rates, isNotEmpty);
      expect(rates.every((r) => r.isFromCache == false), isTrue);

      final usd = rates.firstWhere((r) => r.code == 'USD');
      expect(usd.change, isNotNull);
      expect(usd.hasChange, isTrue);

      verify(
        () => local.saveRates(
          any(),
          any(),
          any(),
          apiDate: '2024-01-15',
        ),
      ).called(1);
    });

    test('yesterday fail → rates with null change still succeed', () async {
      when(() => remote.getLatestRates())
          .thenAnswer((_) async => todayResponse);
      when(() => remote.getHistoricalRates(any()))
          .thenThrow(const NetworkException(message: 'timeout'));
      when(() => local.getCachedRates()).thenAnswer((_) async => null);

      final result = await repository.getRatesWithChange();

      expect(result.isRight(), isTrue);
      final rates = result.getOrElse(() => []);
      expect(rates.every((r) => r.change == null), isTrue);
      expect(rates.every((r) => r.changePercentage == null), isTrue);
    });

    test('network fail returns cache when present', () async {
      when(() => remote.getLatestRates())
          .thenThrow(const NetworkException(message: 'offline'));
      when(() => local.getCachedRates()).thenAnswer(
        (_) async => CachedRates(
          rates: const {'USD': 50.0, 'EUR': 40.0},
          yesterdayRates: const {'USD': 40.0},
          timestamp: DateTime.utc(2024, 1, 15),
          apiDate: '2024-01-15',
        ),
      );

      final result = await repository.getRatesWithChange();

      expect(result.isRight(), isTrue);
      final rates = result.getOrElse(() => []);
      expect(rates.every((r) => r.isFromCache), isTrue);
      final usd = rates.firstWhere((r) => r.code == 'USD');
      expect(usd.change, 10.0);
    });

    test('network fail with no cache returns Left', () async {
      when(() => remote.getLatestRates())
          .thenThrow(const NetworkException(message: 'offline'));
      when(() => local.getCachedRates()).thenAnswer((_) async => null);

      final result = await repository.getRatesWithChange();

      expect(result, const Left(Failure.network('offline')));
    });
  });
}
