import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'package:currency_tracker_axis/app/theme/app_theme.dart';
import 'package:currency_tracker_axis/core/constants/app_constants.dart';
import 'package:currency_tracker_axis/core/widgets/offline_banner.dart';

void main() {
  testWidgets('shows Last updated timestamp', (tester) async {
    final lastUpdated = DateTime(2026, 3, 20, 14, 5);
    final formatted = DateFormat(AppConstants.displayDateTimeFormat)
        .format(lastUpdated.toLocal());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: OfflineBanner(lastUpdated: lastUpdated),
        ),
      ),
    );

    expect(
      find.text('Offline — Last updated: $formatted'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.cloud_off), findsOneWidget);
  });

  testWidgets('stale cache shows warning indicator', (tester) async {
    final lastUpdated = DateTime(2026, 3, 18, 10);
    final formatted = DateFormat(AppConstants.displayDateTimeFormat)
        .format(lastUpdated.toLocal());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: OfflineBanner(lastUpdated: lastUpdated, isStale: true),
        ),
      ),
    );

    expect(
      find.text('Offline — Stale data. Last updated: $formatted'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
  });
}
