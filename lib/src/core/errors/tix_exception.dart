// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:dio/dio.dart';

/// What went wrong, from the tix error envelope's `code` or the transport.
enum TixErrorKind {
  invalid,
  unauthenticated,
  forbidden,
  notFound,
  noTaskAvailable,
  conflict,
  leaseExpired,
  preconditionFailed,
  upstream,
  internal,
  network,
  timeout,
  notTix,
  badUrl,
  tokenRequired,
  badCredentials,
  emailRequired,
  passwordRequired,
  codeRequired,
  secondFactorSetup,
  newPasswordRequired,
  passwordMismatch,
  tenantRequired,
  engineUnavailable,
  localNotUsable,
  localAccessDenied,
  badInviteLink,
  secretStorageUnavailable,
  unknown,
}

const Map<String, TixErrorKind> _codes = {
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

TixErrorKind _kindForStatus(int? status) => switch (status) {
  400 || 413 || 415 => TixErrorKind.invalid,
  401 => TixErrorKind.unauthenticated,
  403 => TixErrorKind.forbidden,
  404 => TixErrorKind.notFound,
  409 => TixErrorKind.conflict,
  422 => TixErrorKind.preconditionFailed,
  502 || 503 || 504 => TixErrorKind.upstream,
  final int s when s >= 500 => TixErrorKind.internal,
  _ => TixErrorKind.unknown,
};

/// A failed call to a tix server, carrying the envelope's code and message.
class TixException implements Exception {
  /// Creates an exception of [kind].
  const TixException(
    this.kind, {
    this.message = '',
    this.status,
    this.requestId,
    this.details = const {},
    this.cause,
  });

  /// Maps a [DioException] to the tix error it carries.
  factory TixException.fromDio(DioException e) {
    if (e.error case final TixException carried) return carried;
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return TixException(TixErrorKind.timeout, cause: e.error ?? e.type);
      case DioExceptionType.connectionError:
        return TixException(
          TixErrorKind.network,
          message: e.message ?? '',
          cause: e.error,
        );
      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
      case DioExceptionType.unknown:
        if (e.error is FormatException) {
          return const TixException(TixErrorKind.notTix);
        }
        return TixException(
          TixErrorKind.network,
          message: e.message ?? e.error?.toString() ?? '',
          cause: e.error ?? e.type,
        );
      case DioExceptionType.badResponse:
        return TixException.fromResponse(e.response);
    }
  }

  /// Reads the `{"error": {...}}` envelope of [response], if it has one.
  factory TixException.fromResponse(Response<dynamic>? response) {
    final status = response?.statusCode;
    final requestId = response?.headers.value('x-request-id');
    final data = response?.data;
    if (data is Map && data['error'] is Map) {
      final body = data['error'] as Map;
      final code = body['code'];
      final message = body['message'];
      final details = body['details'];
      return TixException(
        _codes[code] ?? _kindForStatus(status),
        message: message is String ? message : '',
        status: status,
        requestId: requestId,
        details: details is Map
            ? details.map((k, v) => MapEntry(k.toString(), v))
            : const {},
      );
    }
    return TixException(
      _kindForStatus(status),
      status: status,
      requestId: requestId,
    );
  }

  /// Reads the engine's `{"code", "message"}` error object.
  factory TixException.fromEngine(Map<String, Object?> error) {
    final message = error['message'];
    return TixException(
      _codes[error['code']] ?? TixErrorKind.unknown,
      message: message is String ? message : '',
    );
  }

  /// The error's classification.
  final TixErrorKind kind;

  /// The server's message, empty when there was none.
  final String message;

  /// The HTTP status, null when no response arrived.
  final int? status;

  /// The server's `X-Request-Id`, for matching a server log line.
  final String? requestId;

  /// The envelope's `details` object.
  final Map<String, Object?> details;

  /// What the transport threw underneath, such as a `SocketException`, or
  /// the Dio failure type when it threw nothing: for diagnostics only.
  final Object? cause;

  /// Whether this is how a server without the route answers: 405, or 404 with
  /// no envelope or tix's `no such route`. A missing record is a 404 that
  /// names it.
  bool get missingRoute =>
      status == 405 ||
      (status == 404 && (message.isEmpty || message == 'no such route'));

  @override
  String toString() =>
      'TixException(${kind.name}${status == null ? '' : ', $status'}'
      '${message.isEmpty ? '' : ': $message'})';
}
