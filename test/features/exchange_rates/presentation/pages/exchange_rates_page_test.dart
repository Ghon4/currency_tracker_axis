import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:currency_tracker_axis/app/theme/app_theme.dart';
import 'package:currency_tracker_axis/core/widgets/error_view.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/currency_rate.dart';
import 'package:currency_tracker_axis/features/exchange_rates/presentation/bloc/exchange_rates_bloc.dart';
import 'package:currency_tracker_axis/features/exchange_rates/presentation/pages/exchange_rates_page.dart';
import 'package:currency_tracker_axis/features/exchange_rates/presentation/widgets/currency_list_item.dart';

class _MockExchangeRatesBloc
    extends MockBloc<ExchangeRatesEvent, ExchangeRatesState>
    implements ExchangeRatesBloc {}

void main() {
  late _MockExchangeRatesBloc bloc;

  final rates = [
    CurrencyRate(
      code: 'USD',
      name: 'US Dollar',
      rate: 52.01,
      change: -0.5,
      changePercentage: -0.96,
      lastUpdated: DateTime.utc(2026, 3, 20, 12),
    ),
  ];

  setUpAll(() {
    registerFallbackValue(const LoadRates());
  });

  setUp(() {
    bloc = _MockExchangeRatesBloc();
  });

  Widget buildPage() {
    return MaterialApp(
      theme: AppTheme.light,
      home: BlocProvider<ExchangeRatesBloc>.value(
        value: bloc,
        child: const ExchangeRatesPage(),
      ),
    );
  }

  testWidgets('Success shows list items', (tester) async {
    when(() => bloc.state).thenReturn(
      ExchangeRatesSuccess(
        rates: rates,
        isFromCache: false,
        lastUpdated: rates.first.lastUpdated,
      ),
    );

    await tester.pumpWidget(buildPage());
    await tester.pump();

    expect(find.byType(CurrencyListItem), findsOneWidget);
    expect(find.text('US Dollar'), findsOneWidget);
  });

  testWidgets('Error shows Retry and tapping dispatches LoadRates',
      (tester) async {
    when(() => bloc.state).thenReturn(
      const ExchangeRatesError(message: 'No internet connection.'),
    );

    await tester.pumpWidget(buildPage());
    await tester.pump();

    expect(find.byType(AppErrorView), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();

    verify(() => bloc.add(const LoadRates())).called(1);
  });

  testWidgets('Success from cache shows offline banner', (tester) async {
    final updated = DateTime.utc(2026, 3, 20, 10, 30);
    when(() => bloc.state).thenReturn(
      ExchangeRatesSuccess(
        rates: rates,
        isFromCache: true,
        lastUpdated: updated,
      ),
    );

    await tester.pumpWidget(buildPage());
    await tester.pump();

    expect(find.textContaining('Offline'), findsOneWidget);
    expect(find.textContaining('cached data'), findsOneWidget);
  });
}
