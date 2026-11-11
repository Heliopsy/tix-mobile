// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:tix_mobile/src/data/api/transport.dart';

/// Runs [send] over a transport sharing [transport]'s connection, and
/// returns its result with the JSON object tix answered its last request
/// with, null when there was none.
Future<(T, Map<String, dynamic>?)> withAnswer<T>(
  TixTransport transport,
  Future<T> Function(TixTransport transport) send,
) async {
  final keeping = _Keeping(transport.dio);
  final result = await send(keeping);
  return (result, keeping.answer);
}

class _Keeping extends TixTransport {
  _Keeping(super.dio);

  Map<String, dynamic>? answer;

  @override
  Future<Map<String, dynamic>> json(
    String method,
    String path, {
    Map<String, Object?>? query,
    Object? body,
    String? contentType,
    Map<String, String?>? headers,
  }) async => answer = await super.json(
    method,
    path,
    query: query,
    body: body,
    contentType: contentType,
    headers: headers,
  );
}
