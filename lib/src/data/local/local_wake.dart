// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:dio/dio.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';

/// Wakes a local instance's engine before each request and sends the
/// request to wherever it serves now: an engine stopped while idle starts
/// again without the caller noticing. Requests do not keep the connection
/// alive: a pooled socket to an engine that stopped and came back on the
/// same port would be dead, and a fresh loopback connection costs nothing.
class LocalWakeInterceptor extends Interceptor {
  /// Calls [wake] for the engine's base URL before a request, and [done]
  /// when it finishes.
  LocalWakeInterceptor({required this.wake, required this.done});

  /// Starts the engine if needed, holds it awake and answers its base URL.
  final Future<String> Function() wake;

  /// Lets the engine rest again once no request needs it.
  final void Function() done;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      options
        ..baseUrl = await wake()
        ..persistentConnection = false;
      handler.next(options);
    } on TixException catch (e) {
      handler.reject(DioException(requestOptions: options, error: e));
    }
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    done();
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    done();
    handler.next(err);
  }
}
