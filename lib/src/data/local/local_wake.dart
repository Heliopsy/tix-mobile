// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:dio/dio.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';

/// Wakes a local instance's engine before each request and sends the
/// request to wherever it serves now: an engine stopped while idle starts
/// again without the caller noticing.
class LocalWakeInterceptor extends Interceptor {
  /// Calls [wake] for the engine's base URL before a request, and [touch]
  /// when one finishes.
  LocalWakeInterceptor({required this.wake, required this.touch});

  /// Starts the engine if needed and answers its base URL.
  final Future<String> Function() wake;

  /// Marks the engine as just used.
  final void Function() touch;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      options.baseUrl = await wake();
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
    touch();
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    touch();
    handler.next(err);
  }
}
