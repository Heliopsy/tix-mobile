// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:tix_mobile/src/data/api/gen/models.gen.dart' show LoginResult;
import 'package:tix_mobile/src/data/api/transport.dart';
import 'package:tix_mobile/src/data/models/sso.dart';

/// The single sign-on routes a native app uses. Written by hand until the
/// vendored OpenAPI document has them; `just gen` then replaces this group.
class SsoOps {
  /// Sends through [_t].
  const SsoOps(this._t);

  final TixTransport _t;

  /// What the tenant's sign-in screen offers, read without a credential.
  ///
  /// `GET /api/v1/auth/sso/options` (`sso.options`).
  Future<SignInOptions> options() async =>
      SignInOptions.fromJson(await _t.json('GET', '/api/v1/auth/sso/options'));

  /// Trades the one-time code an app redirect carried, with the PKCE
  /// verifier it was bound to, for what a completed login answers.
  ///
  /// `POST /api/v1/auth/sso/exchange` (`sso.exchange`).
  Future<LoginResult> exchange(SsoExchangeInput body) async =>
      LoginResult.fromJson(
        await _t.json('POST', '/api/v1/auth/sso/exchange', body: body.toJson()),
      );
}
