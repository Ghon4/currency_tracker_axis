import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:currency_tracker_axis/features/currency_detail/presentation/widgets/historical_chart.dart';
import 'package:currency_tracker_axis/features/exchange_rates/domain/entities/historical_point.dart';

void main() {
  testWidgets('HistoricalChart renders LineChart for 7 points', (tester) async {
    final points = List.generate(
      7,
      (i) => HistoricalPoint(
        date: DateTime.utc(2026, 3, 14 + i),
        rate: 50 + i * 0.25,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 240,
            child: HistoricalChart(points: points),
          ),
        ),
      ),
    );

    expect(find.byType(LineChart), findsOneWidget);
  });
}
