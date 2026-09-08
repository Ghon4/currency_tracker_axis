import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shimmer/shimmer.dart';

import 'package:currency_tracker_axis/features/currency_detail/presentation/widgets/chart_shimmer.dart';

void main() {
  testWidgets('ChartShimmer uses shimmer and has no spinner', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 240,
            child: ChartShimmer(),
          ),
        ),
      ),
    );

    expect(find.byType(Shimmer), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
