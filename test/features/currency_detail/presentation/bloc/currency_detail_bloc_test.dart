import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:currency_tracker_axis/core/error/error_messages.dart';
import 'package:currency_tracker_axis/core/error/failures.dart';
import 'package:currency_tracker_axis/features/currency_detail/presentation/bloc/currency_detail_bloc.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/currency_rate.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/historical_point.dart';
import 'package:currency_tracker_axis/features/exchange_rates/presentation/mappers/cached_rates_presenter.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockGetSevenDayHistory getHistory;
  late MockGetCachedRates getCached;
  late MockGetCachedHistorical getCachedHistorical;
  late MockGetLatestRatesWithChange getLatest;

  final now = DateTime.utc(2026, 3, 20, 12);
  final seed = CurrencyRate(
    code: 'USD',
    name: 'US Dollar',
    rate: 52.01,
    change: 0.2,
    changePercentage: 0.4,
    lastUpdated: now,
  );
  final points = [
    HistoricalPoint(date: DateTime.utc(2026, 3, 14), rate: 51),
    HistoricalPoint(date: DateTime.utc(2026, 3, 15), rate: 51.5),
    HistoricalPoint(date: DateTime.utc(2026, 3, 16), rate: 52),
  ];
  final cachedPoints = [
    HistoricalPoint(date: DateTime.utc(2026, 3, 14), rate: 50.5),
    HistoricalPoint(date: DateTime.utc(2026, 3, 15), rate: 50.8),
  ];

  CurrencyDetailBloc buildBloc() => CurrencyDetailBloc(
        getSevenDayHistory: getHistory,
        getCachedRates: getCached,
        getCachedHistorical: getCachedHistorical,
        getLatestRatesWithChange: getLatest,
        mapCachedRates: CachedRatesPresenter.map,
      );

  setUp(() {
    getHistory = MockGetSevenDayHistory();
    getCached = MockGetCachedRates();
    getCachedHistorical = MockGetCachedHistorical();
    getLatest = MockGetLatestRatesWithChange();
    when(() => getCachedHistorical(any())).thenAnswer(
      (_) async => const Right(null),
    );
  });

  group('LoadDetail', () {
    blocTest<CurrencyDetailBloc, CurrencyDetailState>(
      'seed → HeaderLoaded then Success',
      build: () {
        when(() => getHistory(any())).thenAnswer((_) async => Right(points));
        return buildBloc();
      },
      act: (bloc) => bloc.add(LoadDetail(currencyCode: 'USD', seedRate: seed)),
      expect: () => [
        const CurrencyDetailLoading(currencyCode: 'USD'),
        CurrencyDetailHeaderLoaded(
          header: CurrencyDetailHeaderData(
            rate: seed,
            isFromCache: false,
            lastUpdated: now,
          ),
        ),
        CurrencyDetailSuccess(
          header: CurrencyDetailHeaderData(
            rate: seed,
            isFromCache: false,
            lastUpdated: now,
          ),
          points: points,
        ),
      ],
    );

    blocTest<CurrencyDetailBloc, CurrencyDetailState>(
      'cached chart shown then replaced by network',
      build: () {
        when(() => getCachedHistorical(any())).thenAnswer(
          (_) async => Right(cachedPoints),
        );
        when(() => getHistory(any())).thenAnswer((_) async => Right(points));
        return buildBloc();
      },
      act: (bloc) => bloc.add(LoadDetail(currencyCode: 'USD', seedRate: seed)),
      expect: () => [
        const CurrencyDetailLoading(currencyCode: 'USD'),
        CurrencyDetailHeaderLoaded(
          header: CurrencyDetailHeaderData(
            rate: seed,
            isFromCache: false,
            lastUpdated: now,
          ),
        ),
        CurrencyDetailSuccess(
          header: CurrencyDetailHeaderData(
            rate: seed,
            isFromCache: false,
            lastUpdated: now,
          ),
          points: cachedPoints,
        ),
        CurrencyDetailSuccess(
          header: CurrencyDetailHeaderData(
            rate: seed,
            isFromCache: false,
            lastUpdated: now,
          ),
          points: points,
        ),
      ],
    );

    blocTest<CurrencyDetailBloc, CurrencyDetailState>(
      'network chart fail keeps cached chart',
      build: () {
        when(() => getCachedHistorical(any())).thenAnswer(
          (_) async => Right(cachedPoints),
        );
        when(() => getHistory(any())).thenAnswer(
          (_) async => const Left(Failure.network('offline')),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(LoadDetail(currencyCode: 'USD', seedRate: seed)),
      expect: () => [
        const CurrencyDetailLoading(currencyCode: 'USD'),
        CurrencyDetailHeaderLoaded(
          header: CurrencyDetailHeaderData(
            rate: seed,
            isFromCache: false,
            lastUpdated: now,
          ),
        ),
        CurrencyDetailSuccess(
          header: CurrencyDetailHeaderData(
            rate: seed,
            isFromCache: false,
            lastUpdated: now,
          ),
          points: cachedPoints,
        ),
      ],
    );

    blocTest<CurrencyDetailBloc, CurrencyDetailState>(
      'chart failure → ChartError with header intact',
      build: () {
        when(() => getHistory(any())).thenAnswer(
          (_) async => const Left(Failure.network('offline')),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(LoadDetail(currencyCode: 'USD', seedRate: seed)),
      expect: () => [
        const CurrencyDetailLoading(currencyCode: 'USD'),
        CurrencyDetailHeaderLoaded(
          header: CurrencyDetailHeaderData(
            rate: seed,
            isFromCache: false,
            lastUpdated: now,
          ),
        ),
        CurrencyDetailChartError(
          header: CurrencyDetailHeaderData(
            rate: seed,
            isFromCache: false,
            lastUpdated: now,
          ),
          message: 'offline',
        ),
      ],
    );

    blocTest<CurrencyDetailBloc, CurrencyDetailState>(
      'no seed + empty cache + network fail → FullError',
      build: () {
        when(() => getCached()).thenAnswer((_) async => const Right(null));
        when(() => getLatest()).thenAnswer(
          (_) async => const Left(Failure.network()),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const LoadDetail(currencyCode: 'USD')),
      expect: () => [
        const CurrencyDetailLoading(currencyCode: 'USD'),
        const CurrencyDetailFullError(
          currencyCode: 'USD',
          message: ErrorMessages.rateUnavailable,
        ),
      ],
      verify: (_) {
        verifyNever(() => getHistory(any()));
      },
    );
  });
}
