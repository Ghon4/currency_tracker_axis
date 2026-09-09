import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:currency_tracker_axis/app/theme/app_theme.dart';
import 'package:currency_tracker_axis/core/connectivity/connectivity_status.dart';
import 'package:currency_tracker_axis/core/error/failures.dart';
import 'package:currency_tracker_axis/features/currency_detail/presentation/bloc/currency_detail_bloc.dart';
import 'package:currency_tracker_axis/features/currency_detail/presentation/pages/currency_detail_page.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/cached_rates.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/currency_rate.dart';
import 'package:currency_tracker_axis/features/exchange_rates/presentation/bloc/exchange_rates_bloc.dart';
import 'package:currency_tracker_axis/features/exchange_rates/presentation/mappers/cached_rates_presenter.dart';
import 'package:currency_tracker_axis/features/exchange_rates/presentation/pages/exchange_rates_page.dart';
import 'package:currency_tracker_axis/features/exchange_rates/presentation/widgets/currency_list_item.dart';

import '../helpers/mock_cache_data.dart';
import '../helpers/mocks.dart';

/// Flow-level widget tests covering offline→online, refresh, and navigation.
void main() {
  late MockGetLatestRatesWithChange getLatest;
  late MockGetCachedRates getCached;
  late MockSaveRatesToCache saveCache;
  late MockWatchConnectivity watchConnectivity;
  late MockIsCacheValid isCacheValid;
  late MockGetSevenDayHistory getHistory;
  late MockGetCachedHistorical getCachedHistorical;
  late StreamController<ConnectivityStatus> connectivity;

  final now = DateTime.utc(2026, 3, 20, 12);
  final liveRates = [
    sampleUsdRate(lastUpdated: now),
    CurrencyRate(
      code: 'EUR',
      name: 'Euro',
      rate: 56,
      change: 0.1,
      changePercentage: 0.2,
      lastUpdated: now,
    ),
  ];

  setUp(() {
    getLatest = MockGetLatestRatesWithChange();
    getCached = MockGetCachedRates();
    saveCache = MockSaveRatesToCache();
    watchConnectivity = MockWatchConnectivity();
    isCacheValid = MockIsCacheValid();
    getHistory = MockGetSevenDayHistory();
    getCachedHistorical = MockGetCachedHistorical();
    connectivity = StreamController<ConnectivityStatus>.broadcast();

    when(() => watchConnectivity()).thenAnswer(
      (_) => Stream<ConnectivityStatus>.fromIterable([
        ConnectivityStatus.online,
      ]),
    );
    when(() => isCacheValid()).thenAnswer((_) async => true);
    when(() => getCachedHistorical(any())).thenAnswer(
      (_) async => const Right(null),
    );
  });

  tearDown(() async {
    await connectivity.close();
  });

  ExchangeRatesBloc buildListBloc() => ExchangeRatesBloc(
        getLatestRatesWithChange: getLatest,
        getCachedRates: getCached,
        saveRatesToCache: saveCache,
        watchConnectivity: watchConnectivity,
        isCacheValid: isCacheValid,
        mapCachedRates: CachedRatesPresenter.map,
      );

  testWidgets('offline → online: cache shown then live refresh',
      (tester) async {
    final cached = CachedRates(
      rates: const {'USD': 49.5, 'EUR': 53},
      yesterdayRates: const {'USD': 49, 'EUR': 52.5},
      timestamp: now.subtract(const Duration(hours: 2)),
      apiDate: '2026-03-20',
    );

    var call = 0;
    when(() => getCached()).thenAnswer((_) async => Right(cached));
    when(() => getLatest()).thenAnswer((_) async {
      call++;
      if (call == 1) return const Left(Failure.network());
      return Right(liveRates);
    });

    final bloc = buildListBloc();
    addTearDown(bloc.close);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: BlocProvider.value(
          value: bloc,
          child: const ExchangeRatesPage(),
        ),
      ),
    );

    bloc.add(const LoadRates());
    await tester.pump(); // Loading
    await tester.pump(); // cache Success + network settle

    expect(find.byType(CurrencyListItem), findsWidgets);
    expect(find.textContaining('Offline'), findsOneWidget);

    bloc.add(const ConnectivityRestored());
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('Offline'), findsNothing);
    expect(find.text('US Dollar'), findsOneWidget);
  });

  testWidgets('pull-to-refresh flow reloads rates', (tester) async {
    when(() => getCached()).thenAnswer((_) async => const Right(null));
    when(() => getLatest()).thenAnswer((_) async => Right(liveRates));

    final bloc = buildListBloc();
    addTearDown(bloc.close);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: BlocProvider.value(
          value: bloc,
          child: const ExchangeRatesPage(),
        ),
      ),
    );

    bloc.add(const LoadRates());
    await tester.pump();
    await tester.pump();

    expect(find.byType(RefreshIndicator), findsOneWidget);

    bloc.add(const RefreshRates());
    await tester.pump();
    await tester.pump();

    verify(() => getLatest()).called(greaterThanOrEqualTo(2));
  });

  testWidgets('navigation list → detail → back', (tester) async {
    when(() => getHistory(any())).thenAnswer(
      (_) async => Right(sampleHistoryPoints(count: 6)),
    );

    final seed = sampleUsdRate(lastUpdated: now);
    final detailBloc = CurrencyDetailBloc(
      getSevenDayHistory: getHistory,
      getCachedRates: getCached,
      getCachedHistorical: getCachedHistorical,
      getLatestRatesWithChange: getLatest,
      mapCachedRates: CachedRatesPresenter.map,
    );
    addTearDown(detailBloc.close);

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: ListTile(
              title: const Text('Open USD'),
              onTap: () => context.push('/detail/USD'),
            ),
          ),
        ),
        GoRoute(
          path: '/detail/:code',
          builder: (context, state) {
            detailBloc.add(LoadDetail(currencyCode: 'USD', seedRate: seed));
            return BlocProvider.value(
              value: detailBloc,
              child: CurrencyDetailPage(
                currencyCode: state.pathParameters['code']!,
              ),
            );
          },
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: router,
      ),
    );

    await tester.tap(find.text('Open USD'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Last 7 days'), findsOneWidget);

    router.pop();
    await tester.pump();
    await tester.pump();
    expect(find.text('Open USD'), findsOneWidget);
  });

  testWidgets('cache persistence: second load still shows cached list',
      (tester) async {
    final snapshot = freshCachedRates(timestamp: now);
    when(() => getCached()).thenAnswer((_) async => Right(snapshot));
    when(() => getLatest()).thenAnswer(
      (_) async => const Left(Failure.network()),
    );

    final bloc = buildListBloc();
    addTearDown(bloc.close);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: BlocProvider.value(
          value: bloc,
          child: const ExchangeRatesPage(),
        ),
      ),
    );

    bloc.add(const LoadRates());
    await tester.pump();
    await tester.pump();
    expect(find.textContaining('Offline'), findsOneWidget);

    bloc.add(const LoadRates());
    await tester.pump();
    await tester.pump();
    expect(find.byType(CurrencyListItem), findsWidgets);
  });
}
