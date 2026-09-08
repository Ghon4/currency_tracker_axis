import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:currency_tracker_axis/core/connectivity/connectivity_status.dart';
import 'package:currency_tracker_axis/core/connectivity/usecases/watch_connectivity.dart';
import 'package:currency_tracker_axis/core/error/failures.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/cached_rates.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/currency_rate.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/usecases/get_cached_rates.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/usecases/get_latest_rates_with_change.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/usecases/save_rates_to_cache.dart';
import 'package:currency_tracker_axis/features/exchange_rates/presentation/bloc/exchange_rates_bloc.dart';
import 'package:currency_tracker_axis/features/exchange_rates/presentation/mappers/cached_rates_presenter.dart';

class _MockGetLatest extends Mock implements GetLatestRatesWithChange {}

class _MockGetCached extends Mock implements GetCachedRates {}

class _MockSaveCache extends Mock implements SaveRatesToCache {}

class _MockWatchConnectivity extends Mock implements WatchConnectivity {}

void main() {
  late _MockGetLatest getLatest;
  late _MockGetCached getCached;
  late _MockSaveCache saveCache;
  late _MockWatchConnectivity watchConnectivity;
  late StreamController<ConnectivityStatus> connectivityController;

  final now = DateTime.utc(2026, 3, 20, 12);
  final liveRates = [
    CurrencyRate(
      code: 'USD',
      name: 'US Dollar',
      rate: 50,
      change: 0.5,
      changePercentage: 1,
      lastUpdated: now,
    ),
  ];
  final cachedSnapshot = CachedRates(
    rates: const {'USD': 49.5, 'EUR': 53},
    yesterdayRates: const {'USD': 49, 'EUR': 52.5},
    timestamp: now.subtract(const Duration(hours: 2)),
    apiDate: '2026-03-20',
  );

  ExchangeRatesBloc buildBloc() => ExchangeRatesBloc(
        getLatestRatesWithChange: getLatest,
        getCachedRates: getCached,
        saveRatesToCache: saveCache,
        watchConnectivity: watchConnectivity,
        mapCachedRates: CachedRatesPresenter.map,
      );

  setUp(() {
    getLatest = _MockGetLatest();
    getCached = _MockGetCached();
    saveCache = _MockSaveCache();
    watchConnectivity = _MockWatchConnectivity();
    connectivityController = StreamController<ConnectivityStatus>.broadcast();

    when(() => watchConnectivity()).thenAnswer(
      (_) async* {
        yield ConnectivityStatus.online;
        yield* connectivityController.stream;
      },
    );
  });

  tearDown(() async {
    await connectivityController.close();
  });

  group('LoadRates', () {
    blocTest<ExchangeRatesBloc, ExchangeRatesState>(
      'cache then network → Success isFromCache false',
      build: () {
        when(() => getCached()).thenAnswer((_) async => Right(cachedSnapshot));
        when(() => getLatest()).thenAnswer((_) async => Right(liveRates));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadRates()),
      expect: () => [
        const ExchangeRatesLoading(),
        isA<ExchangeRatesSuccess>()
            .having((s) => s.isFromCache, 'isFromCache', true)
            .having((s) => s.rates, 'rates', isNotEmpty),
        ExchangeRatesSuccess(
          rates: liveRates,
          isFromCache: false,
          lastUpdated: now,
        ),
      ],
    );

    blocTest<ExchangeRatesBloc, ExchangeRatesState>(
      'network fail with cache → keeps Success from cache',
      build: () {
        when(() => getCached()).thenAnswer((_) async => Right(cachedSnapshot));
        when(() => getLatest()).thenAnswer(
          (_) async => const Left(Failure.network()),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadRates()),
      expect: () => [
        const ExchangeRatesLoading(),
        isA<ExchangeRatesSuccess>()
            .having((s) => s.isFromCache, 'isFromCache', true),
      ],
    );

    blocTest<ExchangeRatesBloc, ExchangeRatesState>(
      'no cache + network fail → Error',
      build: () {
        when(() => getCached()).thenAnswer((_) async => const Right(null));
        when(() => getLatest()).thenAnswer(
          (_) async => const Left(Failure.network()),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadRates()),
      expect: () => [
        const ExchangeRatesLoading(),
        isA<ExchangeRatesError>()
            .having((s) => s.retryable, 'retryable', true),
      ],
    );
  });

  group('RefreshRates', () {
    blocTest<ExchangeRatesBloc, ExchangeRatesState>(
      'emits Loading then Success',
      build: () {
        when(() => getLatest()).thenAnswer((_) async => Right(liveRates));
        return buildBloc();
      },
      seed: () => ExchangeRatesSuccess(
        rates: liveRates,
        isFromCache: false,
        lastUpdated: now,
      ),
      act: (bloc) => bloc.add(const RefreshRates()),
      expect: () => [
        ExchangeRatesLoading(previousRates: liveRates),
        ExchangeRatesSuccess(
          rates: liveRates,
          isFromCache: false,
          lastUpdated: now,
        ),
      ],
    );
  });

  group('ConnectivityRestored', () {
    blocTest<ExchangeRatesBloc, ExchangeRatesState>(
      'refreshes when showing cached Success',
      build: () {
        when(() => getLatest()).thenAnswer((_) async => Right(liveRates));
        return buildBloc();
      },
      seed: () => ExchangeRatesSuccess(
        rates: liveRates.map((r) => CurrencyRate(
              code: r.code,
              name: r.name,
              rate: r.rate,
              change: r.change,
              changePercentage: r.changePercentage,
              lastUpdated: r.lastUpdated,
              isFromCache: true,
            )).toList(),
        isFromCache: true,
        lastUpdated: now,
      ),
      act: (bloc) => bloc.add(const ConnectivityRestored()),
      expect: () => [
        ExchangeRatesSuccess(
          rates: liveRates,
          isFromCache: false,
          lastUpdated: now,
        ),
      ],
    );

    blocTest<ExchangeRatesBloc, ExchangeRatesState>(
      'does not refresh when Success is live',
      build: buildBloc,
      seed: () => ExchangeRatesSuccess(
        rates: liveRates,
        isFromCache: false,
        lastUpdated: now,
      ),
      act: (bloc) => bloc.add(const ConnectivityRestored()),
      expect: () => <ExchangeRatesState>[],
    );
  });
}
