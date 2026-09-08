import 'package:flutter_test/flutter_test.dart';

import 'package:currency_tracker_axis/app/app.dart';

void main() {
  testWidgets('CurrencyTrackerApp shows foundation exchange rates page',
      (tester) async {
    await tester.pumpWidget(const CurrencyTrackerApp());
    await tester.pumpAndSettle();

    expect(find.text('Foundation — exchange rates'), findsOneWidget);
    expect(find.text('Currency Tracker'), findsOneWidget);
  });
}
