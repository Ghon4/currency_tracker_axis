import 'package:flutter_test/flutter_test.dart';

import 'package:currency_tracker_axis/core/error/error_messages.dart';
import 'package:currency_tracker_axis/core/error/failures.dart';

void main() {
  group('Failure.userMessage defaults', () {
    test('network', () {
      expect(const Failure.network().userMessage, ErrorMessages.network);
    });

    test('server', () {
      expect(const Failure.server().userMessage, ErrorMessages.server);
    });

    test('cache', () {
      expect(const Failure.cache().userMessage, ErrorMessages.cache);
    });

    test('parse', () {
      expect(const Failure.parse().userMessage, ErrorMessages.parse);
    });

    test('empty', () {
      expect(const Failure.empty().userMessage, ErrorMessages.empty);
    });

    test('timeout', () {
      expect(const Failure.timeout().userMessage, ErrorMessages.timeout);
    });

    test('unknown', () {
      expect(const Failure.unknown().userMessage, ErrorMessages.unexpected);
    });

    test('custom message wins', () {
      expect(
        const Failure.network('custom').userMessage,
        'custom',
      );
    });
  });
}
