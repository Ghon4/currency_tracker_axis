import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'package:currency_tracker_axis/app/theme/app_theme.dart';
import 'package:currency_tracker_axis/core/constants/app_constants.dart';
import 'package:currency_tracker_axis/core/widgets/offline_banner.dart';

void main() {
  testWidgets('formats timestamp in offline banner text', (tester) async {
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
      find.text('Offline — Showing cached data from $formatted'),
      findsOneWidget,
    );
  });
}
