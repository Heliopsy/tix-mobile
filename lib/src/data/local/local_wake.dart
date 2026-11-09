// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:dio/dio.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/data/events/event_poll.dart';

/// Wakes a local instance's engine before each request and sends the
/// request to wherever it serves now: an engine stopped while idle starts
/// again without the caller noticing. Requests do not keep the connection
/// alive: a pooled socket to an engine that stopped and came back on the
/// same port would be dead, and a fresh loopback connection costs nothing.
class LocalWakeInterceptor extends Interceptor {
  /// Calls [wake] for the engine's base URL before a request, and [done]
  /// when it finishes; [background] picks the requests that are not
  /// activity, event polls by default.
  LocalWakeInterceptor({
    required this.wake,
    required this.done,
    this.background = isEventPoll,
  });

  /// Starts the engine if needed and answers its base URL, and whether it
  /// is held awake until [done]. A background request must not start it.
  final Future<(String, bool)> Function({required bool background}) wake;

  /// Lets the engine rest again once no request needs it.
  final void Function() done;

  /// Whether a request is background work rather than activity.
  final bool Function(RequestOptions options) background;

  static const _held = 'tix.local_held';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final (baseUrl, held) = await wake(background: background(options));
      options
        ..baseUrl = baseUrl
        ..persistentConnection = false
        ..extra[_held] = held;
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
    _release(response.requestOptions);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _release(err.requestOptions);
    handler.next(err);
  }

  void _release(RequestOptions options) {
    if (options.extra.remove(_held) == true) done();
  }
}
