import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:currency_tracker_axis/app/theme/app_theme.dart';

/// Pumps [child] under a themed [MaterialApp], optionally with [providers].
Future<void> pumpApp(
  WidgetTester tester,
  Widget child, {
  List<BlocProvider>? providers,
}) async {
  Widget tree = child;
  if (providers != null && providers.isNotEmpty) {
    tree = MultiBlocProvider(providers: providers, child: child);
  }

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: tree,
    ),
  );
}
