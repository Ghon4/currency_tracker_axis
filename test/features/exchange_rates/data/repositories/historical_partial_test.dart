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
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/historical_point.dart';

class _MockRemote extends Mock implements ExchangeRatesRemoteDataSource {}

class _MockLocal extends Mock implements ExchangeRatesLocalDataSource {}

void main() {
  late _MockRemote remote;
  late _MockLocal local;
  late ExchangeRatesRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(DateTime.utc(2024, 1, 1));
    registerFallbackValue(<HistoricalPoint>[]);
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

    when(() => local.saveHistorical(any(), any())).thenAnswer((_) async {});
  });

  group('getHistoricalRates partial success', () {
    test('3/7 days fail still returns Right with 4 points', () async {
      var call = 0;
      when(() => remote.getHistoricalRates(any())).thenAnswer((_) async {
        call++;
        if (call <= 3) {
          throw const NetworkException(message: 'fail');
        }
        return ExchangeRatesResponse(
          date: '2024-01-0$call',
          egp: const {'usd': 0.02},
        );
      });

      final result = await repository.getHistoricalRates('USD', days: 7);

      expect(result.isRight(), isTrue);
      final points = result.getOrElse(() => []);
      expect(points.length, 4);
      verify(() => local.saveHistorical('USD', any())).called(1);
    });

    test('0 points + cache returns cached points', () async {
      when(() => remote.getHistoricalRates(any()))
          .thenThrow(const NetworkException(message: 'offline'));
      when(() => local.getCachedHistorical('USD')).thenAnswer(
        (_) async => [
          HistoricalPoint(date: DateTime.utc(2024, 1, 10), rate: 50),
          HistoricalPoint(date: DateTime.utc(2024, 1, 11), rate: 51),
        ],
      );

      final result = await repository.getHistoricalRates('USD', days: 7);

      expect(result.isRight(), isTrue);
      expect(result.getOrElse(() => []).length, 2);
    });

    test('0 points + no cache returns Left empty', () async {
      when(() => remote.getHistoricalRates(any()))
          .thenThrow(const NetworkException(message: 'offline'));
      when(() => local.getCachedHistorical('USD'))
          .thenAnswer((_) async => null);

      final result = await repository.getHistoricalRates('USD', days: 7);

      expect(
        result,
        const Left(Failure.empty('No historical data available.')),
      );
    });
  });
}
