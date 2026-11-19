// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/data/api/refusals.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';

export 'package:tix_mobile/src/data/api/tix_api.dart' show TixApiFactory;

part 'api.g.dart';

/// How bare API clients are built; tests swap in one with a fake adapter.
@Riverpod(keepAlive: true)
TixApiFactory tixClientFactory(Ref ref) =>
    (baseUrl, credential, {tenant}) =>
        TixApi(baseUrl: baseUrl, credential: credential, tenant: tenant);

/// The credentials servers answered `401` to, as each request presented them.
class CredentialRefusals {
  final _refused = StreamController<Credential>.broadcast(sync: true);

  /// Every refusal, in the order the answers arrived.
  Stream<Credential> get stream => _refused.stream;

  /// Records that a server refused [credential].
  void report(Credential credential) {
    if (!_refused.isClosed) _refused.add(credential);
  }

  /// Stops reporting.
  Future<void> close() => _refused.close();
}

/// Where every client built by [tixApiFactory] reports a `401`.
@Riverpod(keepAlive: true)
CredentialRefusals credentialRefusals(Ref ref) {
  final refusals = CredentialRefusals();
  ref.onDispose(refusals.close);
  return refusals;
}

/// How API clients are built. Each one presenting a credential reports the
/// `401`s it gets to [credentialRefusals], so a refused session is noticed
/// once, whichever screen or background job sent the request.
@Riverpod(keepAlive: true)
TixApiFactory tixApiFactory(Ref ref) {
  final build = ref.watch(tixClientFactoryProvider);
  final refusals = ref.watch(credentialRefusalsProvider);
  return (baseUrl, credential, {tenant}) {
    final api = build(baseUrl, credential, tenant: tenant);
    if (credential != null && credential.secret.isNotEmpty) {
      api.transport.dio.interceptors.add(
        RefusalInterceptor(credential, refusals.report),
      );
    }
    return api;
  };
}
