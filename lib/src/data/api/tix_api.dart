// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:dio/dio.dart';
import 'package:tix_mobile/src/core/config/config.dart';
import 'package:tix_mobile/src/core/config/server_url.dart';
import 'package:tix_mobile/src/core/logging/log.dart';
import 'package:tix_mobile/src/data/api/credential.dart';
import 'package:tix_mobile/src/data/api/gen/client.gen.dart';
import 'package:tix_mobile/src/data/api/transport.dart';

export 'package:tix_mobile/src/data/api/credential.dart';
export 'package:tix_mobile/src/data/api/gen/client.gen.dart';
export 'package:tix_mobile/src/data/api/transport.dart';

/// Builds a client for a server and the credential it presents. [tenant]
/// names the tenant in `X-Tix-Tenant`, which only a sign-in on a host that
/// serves several tenants needs.
typedef TixApiFactory = TixApi Function(
  String baseUrl,
  Credential? credential, {
  String? tenant,
});

/// The tix HTTP API of one connection: the generated [TixClient] over a Dio
/// that carries the server's address and the connection's credential.
class TixApi extends TixClient {
  /// Talks to the server at [baseUrl], presenting [credential].
  TixApi({
    required String baseUrl,
    Credential? credential,
    String? tenant,
    HttpClientAdapter? adapter,
  }) : super(
         TixTransport(
           connectionDio(
             baseUrl: baseUrl,
             credential: credential,
             tenant: tenant,
             adapter: adapter,
           ),
         ),
       );

  /// The Dio every request of one connection goes through.
  ///
  /// No `X-Tix-Client` is sent: tix defines only `cli` and `mcp`, and a
  /// session is recorded as `web` whatever the header says.
  static Dio connectionDio({
    required String baseUrl,
    Credential? credential,
    String? tenant,
    HttpClientAdapter? adapter,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: withoutTrailingSlash(baseUrl),
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        listFormat: ListFormat.multi,
        headers: {
          'Accept': 'application/json',
          if (credential != null && credential.secret.isNotEmpty)
            ...credential.headers,
          if (tenant != null && tenant.isNotEmpty) 'X-Tix-Tenant': tenant,
        },
      ),
    );
    if (adapter != null) dio.httpClientAdapter = adapter;
    dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (r, h) {
          log(
            '${r.requestOptions.method} ${r.requestOptions.path} '
            '${r.statusCode}',
          );
          h.next(r);
        },
        onError: (e, h) {
          log(
            '${e.requestOptions.method} ${e.requestOptions.path} '
            '${e.response?.statusCode ?? e.type.name}',
          );
          h.next(e);
        },
      ),
    );
    return dio;
  }
}
