import 'dart:async';

import 'package:flutter/foundation.dart';

/// Installs Flutter / zone handlers for uncaught errors.
class GlobalErrorHandler {
  GlobalErrorHandler._();

  /// Hooks [FlutterError.onError] and [PlatformDispatcher.onError].
  static void install() {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      _log(details.exceptionAsString(), details.stack);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      _log(error.toString(), stack);
      return true;
    };
  }

  /// Runs [body] inside a guarded zone that logs uncaught async errors.
  ///
  /// Errors are logged and swallowed so app startup / callers are not aborted.
  static Future<void> runGuarded(Future<void> Function() body) async {
    final done = Completer<void>();

    runZonedGuarded(() async {
      try {
        await body();
      } catch (error, stack) {
        _log(error.toString(), stack);
      } finally {
        if (!done.isCompleted) done.complete();
      }
    }, (error, stack) {
      _log(error.toString(), stack);
      if (!done.isCompleted) done.complete();
    });

    await done.future;
  }

  static void _log(String message, StackTrace? stack) {
    // Simple crash reporting hook (print in debug; replace with reporter later).
    debugPrint('[GlobalError] $message');
    if (stack != null) {
      debugPrint('$stack');
    }
  }
}
