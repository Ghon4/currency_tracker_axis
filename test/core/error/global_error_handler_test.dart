import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:currency_tracker_axis/core/error/global_error_handler.dart';

void main() {
  group('GlobalErrorHandler', () {
    test('install sets FlutterError.onError', () {
      final previous = FlutterError.onError;
      addTearDown(() => FlutterError.onError = previous);

      GlobalErrorHandler.install();
      expect(FlutterError.onError, isNotNull);
      expect(FlutterError.onError, isNot(previous));
    });

    test('runGuarded completes successful body', () async {
      var ran = false;
      await GlobalErrorHandler.runGuarded(() async {
        ran = true;
      });
      expect(ran, isTrue);
    });

    test('runGuarded swallows zone errors without rethrowing', () async {
      await GlobalErrorHandler.runGuarded(() async {
        throw StateError('boom');
      });
      // If we get here, the error was handled by the zone.
      expect(true, isTrue);
    });
  });
}
