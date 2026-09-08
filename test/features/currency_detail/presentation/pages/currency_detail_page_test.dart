import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:currency_tracker_axis/app/theme/app_theme.dart';
import 'package:currency_tracker_axis/features/currency_detail/presentation/bloc/currency_detail_bloc.dart';
import 'package:currency_tracker_axis/features/currency_detail/presentation/pages/currency_detail_page.dart';
import 'package:currency_tracker_axis/features/currency_detail/presentation/widgets/chart_error_widget.dart';
import 'package:currency_tracker_axis/features/currency_detail/presentation/widgets/chart_shimmer.dart';
import 'package:currency_tracker_axis/features/currency_detail/presentation/widgets/currency_header.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/currency_rate.dart';

class _MockCurrencyDetailBloc
    extends MockBloc<CurrencyDetailEvent, CurrencyDetailState>
    implements CurrencyDetailBloc {}

void main() {
  late _MockCurrencyDetailBloc bloc;

  final header = CurrencyDetailHeaderData(
    rate: CurrencyRate(
      code: 'USD',
      name: 'US Dollar',
      rate: 52.01,
      change: 0.2,
      changePercentage: 0.4,
      lastUpdated: DateTime.utc(2026, 3, 20),
    ),
    isFromCache: false,
    lastUpdated: DateTime.utc(2026, 3, 20),
  );

  setUp(() {
    bloc = _MockCurrencyDetailBloc();
  });

  Widget wrap(CurrencyDetailState state) {
    when(() => bloc.state).thenReturn(state);
    whenListen(bloc, Stream<CurrencyDetailState>.empty(), initialState: state);
    return MaterialApp(
      theme: AppTheme.light,
      home: BlocProvider<CurrencyDetailBloc>.value(
        value: bloc,
        child: const CurrencyDetailPage(currencyCode: 'USD'),
      ),
    );
  }

  testWidgets('HeaderLoaded shows header + chart shimmer', (tester) async {
    await tester.pumpWidget(
      wrap(CurrencyDetailHeaderLoaded(header: header)),
    );

    expect(find.byType(CurrencyHeader), findsOneWidget);
    expect(find.byType(ChartShimmer), findsOneWidget);
    expect(find.text('1 USD = 52.01 EGP'), findsOneWidget);
  });

  testWidgets('ChartError shows retry', (tester) async {
    await tester.pumpWidget(
      wrap(
        CurrencyDetailChartError(
          header: header,
          message: 'No historical data available.',
        ),
      ),
    );

    expect(find.byType(CurrencyHeader), findsOneWidget);
    expect(find.byType(ChartErrorView), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
