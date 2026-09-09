import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:currency_tracker_axis/app/theme/app_theme.dart';
import 'package:currency_tracker_axis/core/widgets/error_view.dart';

void main() {
  testWidgets('AppErrorView shows message and retry callback', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: AppErrorView(
            message: 'Something failed',
            onRetry: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Something failed'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('AppErrorView hides retry when onRetry is null', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppErrorView(message: 'Fatal'),
        ),
      ),
    );

    expect(find.text('Retry'), findsNothing);
  });
}
