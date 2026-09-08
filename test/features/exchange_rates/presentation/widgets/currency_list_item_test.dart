import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:currency_tracker_axis/app/theme/app_theme.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/currency_rate.dart';
import 'package:currency_tracker_axis/features/exchange_rates/presentation/widgets/currency_list_item.dart';

void main() {
  testWidgets('shows name, code, and formatted rate', (tester) async {
    final rate = CurrencyRate(
      code: 'USD',
      name: 'US Dollar',
      rate: 52.01,
      change: 0.5,
      changePercentage: 0.96,
      lastUpdated: DateTime.utc(2026, 3, 20),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: CurrencyListItem(rate: rate),
        ),
      ),
    );

    expect(find.text('US Dollar'), findsOneWidget);
    expect(find.text('USD'), findsOneWidget);
    expect(find.text('1 USD = 52.01 EGP'), findsOneWidget);
  });
}
