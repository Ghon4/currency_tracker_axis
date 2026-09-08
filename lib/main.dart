import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:currency_tracker_axis/app/app.dart';
import 'package:currency_tracker_axis/app/di/dependency_injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Hive init + adapter registration happen inside configureDependencies
  // via HiveService.init().
  await configureDependencies();

  runApp(const CurrencyTrackerApp());
}
