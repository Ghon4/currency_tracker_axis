import 'package:dio/dio.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:currency_tracker_axis/core/error/exceptions.dart';
import 'package:currency_tracker_axis/core/error/retry_policy.dart';

void main() {
  const policy = RetryPolicy();

  group('RetryPolicy', () {
    test('network retries up to 3 attempts then succeeds', () {
      fakeAsync((async) {
        var attempts = 0;
        Object? result;
        Object? error;
        policy
            .execute(
              () async {
                attempts++;
                if (attempts < 3) {
                  throw const NetworkException(message: 'offline');
                }
                return 'ok';
              },
              category: RetryCategory.network,
            )
            .then((value) => result = value, onError: (Object e) {
              error = e;
            });

        async.flushMicrotasks();
        async.elapse(const Duration(milliseconds: 300));
        async.flushMicrotasks();
        async.elapse(const Duration(milliseconds: 600));
        async.flushMicrotasks();

        expect(error, isNull);
        expect(result, 'ok');
        expect(attempts, 3);
      });
    });

    test('server retries up to 2 attempts', () {
      fakeAsync((async) {
        var attempts = 0;
        Object? error;
        policy
            .execute<void>(
              () async {
                attempts++;
                throw const ServerException(message: '500', statusCode: 500);
              },
              category: RetryCategory.server,
            )
            .then((_) {})
            .catchError((Object e) {
              error = e;
            });

        async.flushMicrotasks();
        async.elapse(const Duration(milliseconds: 300));
        async.flushMicrotasks();

        expect(error, isA<ServerException>());
        expect(attempts, 2);
      });
    });

    test('cache errors fail fast', () async {
      var attempts = 0;
      await expectLater(
        () => policy.execute(
          () async {
            attempts++;
            throw const CacheException(message: 'hive');
          },
          category: RetryCategory.none,
        ),
        throwsA(isA<CacheException>()),
      );
      expect(attempts, 1);
    });

    test('parse errors are not retried even under network category', () async {
      var attempts = 0;
      await expectLater(
        () => policy.execute(
          () async {
            attempts++;
            throw const ParseException(message: 'bad json');
          },
          category: RetryCategory.network,
        ),
        throwsA(isA<ParseException>()),
      );
      expect(attempts, 1);
    });

    test('4xx server errors are not retried', () async {
      var attempts = 0;
      await expectLater(
        () => policy.execute(
          () async {
            attempts++;
            throw const ServerException(message: '404', statusCode: 404);
          },
          category: RetryCategory.server,
        ),
        throwsA(isA<ServerException>()),
      );
      expect(attempts, 1);
    });

    test('Dio connection errors are retryable for network', () {
      fakeAsync((async) {
        var attempts = 0;
        Object? result;
        policy
            .execute(
              () async {
                attempts++;
                if (attempts == 1) {
                  throw DioException(
                    requestOptions: RequestOptions(path: '/'),
                    type: DioExceptionType.connectionError,
                  );
                }
                return 42;
              },
              category: RetryCategory.network,
            )
            .then((value) => result = value);

        async.flushMicrotasks();
        async.elapse(const Duration(milliseconds: 300));
        async.flushMicrotasks();

        expect(result, 42);
        expect(attempts, 2);
      });
    });
  });
}
