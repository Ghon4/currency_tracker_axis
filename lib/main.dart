import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:currency_tracker_axis/app/app.dart';
import 'package:currency_tracker_axis/app/di/dependency_injection.dart';
import 'package:currency_tracker_axis/core/error/global_error_handler.dart';

Future<void> main() async {
  await GlobalErrorHandler.runGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    GlobalErrorHandler.install();

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Hive init + adapter registration happen inside configureDependencies
    // via HiveService.init().
    await configureDependencies();

    runApp(const CurrencyTrackerApp());
  });
}
