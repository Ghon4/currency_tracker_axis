import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:currency_tracker_axis/app/theme/app_theme.dart';
import 'package:currency_tracker_axis/features/exchange_rates/presentation/widgets/rate_change_indicator.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: child),
    );
  }

  testWidgets('negative change uses strengthening (green) arrow down',
      (tester) async {
    await tester.pumpWidget(
      wrap(
        const RateChangeIndicator(
          change: -0.5,
          changePercentage: -0.96,
        ),
      ),
    );

    expect(find.textContaining('▼'), findsOneWidget);
    expect(find.textContaining('-0.50'), findsOneWidget);
    expect(find.textContaining('0.96%'), findsOneWidget);

    final text = tester.widget<Text>(find.textContaining('-0.50'));
    expect(text.style?.color, RateColors.light.egpStrengthening);
  });

  testWidgets('positive change uses weakening (red) arrow up', (tester) async {
    await tester.pumpWidget(
      wrap(
        const RateChangeIndicator(
          change: 0.5,
          changePercentage: 0.96,
        ),
      ),
    );

    expect(find.textContaining('▲'), findsOneWidget);
    final text = tester.widget<Text>(find.textContaining('+0.50'));
    expect(text.style?.color, RateColors.light.egpWeakening);
  });

  testWidgets('null change shows dash', (tester) async {
    await tester.pumpWidget(
      wrap(
        const RateChangeIndicator(
          change: null,
          changePercentage: null,
        ),
      ),
    );

    expect(find.text('—'), findsOneWidget);
  });
}
