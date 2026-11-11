// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';

void main() {
  final options = RequestOptions(path: '/x');

  Response<dynamic> response(int status, [Object? data]) =>
      Response(requestOptions: options, statusCode: status, data: data);

  test('every envelope code maps to its kind', () {
    const codes = {
      'invalid': TixErrorKind.invalid,
      'unauthenticated': TixErrorKind.unauthenticated,
      'forbidden': TixErrorKind.forbidden,
      'not_found': TixErrorKind.notFound,
      'no_task_available': TixErrorKind.noTaskAvailable,
      'conflict': TixErrorKind.conflict,
      'lease_expired': TixErrorKind.leaseExpired,
      'precondition_failed': TixErrorKind.preconditionFailed,
      'upstream': TixErrorKind.upstream,
      'internal': TixErrorKind.internal,
    };
    for (final MapEntry(key: code, value: kind) in codes.entries) {
      final e = TixException.fromResponse(
        response(418, {
          'error': {'code': code, 'message': 'm'},
        }),
      );
      expect(e.kind, kind, reason: code);
    }
  });

  test('without an envelope the status decides', () {
    const statuses = {
      400: TixErrorKind.invalid,
      401: TixErrorKind.unauthenticated,
      403: TixErrorKind.forbidden,
      404: TixErrorKind.notFound,
      409: TixErrorKind.conflict,
      413: TixErrorKind.invalid,
      415: TixErrorKind.invalid,
      422: TixErrorKind.preconditionFailed,
      500: TixErrorKind.internal,
      502: TixErrorKind.upstream,
      503: TixErrorKind.upstream,
      418: TixErrorKind.unknown,
    };
    for (final MapEntry(key: status, value: kind) in statuses.entries) {
      expect(
        TixException.fromResponse(response(status, 'oops')).kind,
        kind,
        reason: '$status',
      );
    }
  });

  test('an unknown code falls back to the status', () {
    final e = TixException.fromResponse(
      response(403, {
        'error': {'code': 'brand_new', 'message': 1},
      }),
    );
    expect(e.kind, TixErrorKind.forbidden);
    expect(e.message, isEmpty);
  });

  test('transport failures map by type', () {
    TixErrorKind kind(DioExceptionType type, [Object? error]) =>
        TixException.fromDio(
          DioException(requestOptions: options, type: type, error: error),
        ).kind;
    expect(kind(DioExceptionType.connectionTimeout), TixErrorKind.timeout);
    expect(kind(DioExceptionType.receiveTimeout), TixErrorKind.timeout);
    expect(kind(DioExceptionType.sendTimeout), TixErrorKind.timeout);
    expect(kind(DioExceptionType.connectionError), TixErrorKind.network);
    expect(kind(DioExceptionType.badCertificate), TixErrorKind.network);
    expect(
      kind(DioExceptionType.unknown, const FormatException('html')),
      TixErrorKind.notTix,
    );
    expect(
      TixException.fromDio(
        DioException.badResponse(
          statusCode: 404,
          requestOptions: options,
          response: response(404),
        ),
      ).kind,
      TixErrorKind.notFound,
    );
  });

  test('an error raised before the request is carried as it is', () {
    const carried = TixException(TixErrorKind.localAccessDenied);
    expect(
      TixException.fromDio(
        DioException(requestOptions: options, error: carried),
      ),
      same(carried),
    );
  });

  test('toString names the kind, status and message', () {
    expect(
      const TixException(
        TixErrorKind.invalid,
        message: 'bad',
        status: 400,
      ).toString(),
      'TixException(invalid, 400: bad)',
    );
    expect(
      const TixException(TixErrorKind.network).toString(),
      'TixException(network)',
    );
  });

  test('reads the engine error object', () {
    final e = TixException.fromEngine({
      'code': 'not_found',
      'message': 'no such file',
    });
    expect(e.kind, TixErrorKind.notFound);
    expect(e.message, 'no such file');
    expect(
      TixException.fromEngine({'code': 'weird'}).kind,
      TixErrorKind.unknown,
    );
    expect(TixException.fromEngine(const {}).message, '');
  });

  test('a missing route is told from a missing record', () {
    TixException e(int status, [String message = '']) =>
        TixException(TixErrorKind.notFound, status: status, message: message);
    expect(e(405).missingRoute, isTrue);
    expect(e(404).missingRoute, isTrue);
    expect(e(404, 'no such route').missingRoute, isTrue);
    expect(e(404, 'comment "c1"').missingRoute, isFalse);
    expect(e(403).missingRoute, isFalse);
  });
}
