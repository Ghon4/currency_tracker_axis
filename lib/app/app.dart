import 'package:flutter/material.dart';

import 'package:currency_tracker_axis/app/router.dart';
import 'package:currency_tracker_axis/app/theme/app_theme.dart';

/// Root application widget.
class CurrencyTrackerApp extends StatelessWidget {
  const CurrencyTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Currency Tracker',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
