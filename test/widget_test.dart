import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:currency_tracker_axis/app/theme/app_theme.dart';

void main() {
  testWidgets('AppTheme exposes RateColors extension', (tester) async {
    late RateColors colors;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) {
            colors = AppTheme.rateColors(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(colors.egpStrengthening, RateColors.light.egpStrengthening);
    expect(colors.egpWeakening, RateColors.light.egpWeakening);
  });
}
