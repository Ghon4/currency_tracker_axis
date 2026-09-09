import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:currency_tracker_axis/core/error/error_mapper.dart';
import 'package:currency_tracker_axis/core/error/exceptions.dart';
import 'package:currency_tracker_axis/core/error/failures.dart';

void main() {
  const mapper = ErrorMapper();

  group('ErrorMapper', () {
    test('maps domain exceptions', () {
      expect(
        mapper.map(const NetworkException(message: 'offline')),
        const Failure.network('offline'),
      );
      expect(
        mapper.map(const ServerException(message: 'bad', statusCode: 500)),
        const Failure.server('bad', 500),
      );
      expect(
        mapper.map(const CacheException(message: 'hive')),
        const Failure.cache('hive'),
      );
      expect(
        mapper.map(const ParseException(message: 'json')),
        const Failure.parse('json'),
      );
      expect(
        mapper.map(const EmptyDataException(message: 'empty')),
        const Failure.empty('empty'),
      );
    });

    test('passes through Failure', () {
      const failure = Failure.network('x');
      expect(mapper.map(failure), failure);
    });

    test('maps DioException types to Failure variants', () {
      Failure fromType(DioExceptionType type, {int? status}) {
        return mapper.map(
          DioException(
            requestOptions: RequestOptions(path: '/'),
            type: type,
            message: 'dio',
            response: status == null
                ? null
                : Response(
                    requestOptions: RequestOptions(path: '/'),
                    statusCode: status,
                  ),
          ),
        );
      }

      expect(fromType(DioExceptionType.connectionTimeout), isA<TimeoutFailure>());
      expect(fromType(DioExceptionType.sendTimeout), isA<TimeoutFailure>());
      expect(fromType(DioExceptionType.receiveTimeout), isA<TimeoutFailure>());
      expect(fromType(DioExceptionType.connectionError), isA<NetworkFailure>());
      expect(fromType(DioExceptionType.badCertificate), isA<NetworkFailure>());
      expect(fromType(DioExceptionType.unknown), isA<NetworkFailure>());
      expect(
        fromType(DioExceptionType.badResponse, status: 503),
        const Failure.server('dio', 503),
      );
      expect(
        fromType(DioExceptionType.cancel),
        const Failure.unknown('Request cancelled'),
      );
    });

    test('maps nested Dio error from interceptor', () {
      final failure = mapper.map(
        DioException(
          requestOptions: RequestOptions(path: '/'),
          type: DioExceptionType.badResponse,
          error: const ServerException(message: 'wrapped', statusCode: 404),
        ),
      );
      expect(failure, const Failure.server('wrapped', 404));
    });

    test('maps HiveError and FormatException', () {
      expect(
        mapper.map(HiveError('box closed')),
        const Failure.cache('box closed'),
      );
      expect(
        mapper.map(const FormatException('bad date')),
        const Failure.parse('bad date'),
      );
    });

    test('maps unknown errors', () {
      expect(
        mapper.map(StateError('boom')),
        isA<UnknownFailure>(),
      );
    });
  });
}
