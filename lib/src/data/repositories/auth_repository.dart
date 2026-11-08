// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:tix_mobile/src/core/config/server_url.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/models/actor.dart';
import 'package:tix_mobile/src/data/models/auth.dart';

/// Checking servers, signing in and switching tenant.
class AuthRepository {
  /// Builds clients with [_build].
  AuthRepository(this._build);

  final TixApiFactory _build;

  /// The surface sessions are minted for: tix's session policy and the
  /// tenant's second factor rule for the command line fit an app best.
  static const Surface _surface = Surface.cli;

  /// The server root for [input], once `GET /healthz` answers like tix.
  Future<String> checkServer(String input) async {
    final baseUrl = normalizeServerUrl(input);
    if (baseUrl == null) throw const TixException(TixErrorKind.badUrl);
    try {
      await _build(baseUrl, null).server.health();
    } on TixException catch (e) {
      if (e.kind == TixErrorKind.notFound) {
        throw TixException(TixErrorKind.notTix, status: e.status);
      }
      rethrow;
    }
    return baseUrl;
  }

  /// Who [credential] is at [baseUrl], with the tenant's key and name.
  ///
  /// tix names the tenant in `whoami` for a person's session only; an API
  /// token answers as an agent with the tenant's id alone. The key and name
  /// are then read from `GET /tenants/{id}`, which a token with
  /// `tenant:admin` (or `*`) may read; any other token stays unnamed.
  Future<Actor> whoami(String baseUrl, Credential credential) async {
    final api = _build(baseUrl, credential);
    final me = await api.identity.whoami();
    if (me.tenantKey.isNotEmpty || me.tenantId.isEmpty) return me;
    try {
      final t = await api.tenant.show(me.tenantId);
      return me.copyWith(tenantKey: t.key, tenantName: t.name);
    } on TixException catch (e) {
      if (e.kind != TixErrorKind.forbidden && e.kind != TixErrorKind.notFound) {
        rethrow;
      }
      return me;
    }
  }

  /// The first step of a sign-in.
  Future<LoginResult> login(
    String baseUrl, {
    required String email,
    required String password,
    String? tenant,
  }) async {
    final address = email.trim();
    if (address.isEmpty) throw const TixException(TixErrorKind.emailRequired);
    if (password.isEmpty) {
      throw const TixException(TixErrorKind.passwordRequired);
    }
    return await _complete(
      _build(baseUrl, null, tenant: tenant).session.login(
        LoginRequest(email: address, password: password, surface: _surface),
      ),
    );
  }

  /// The second step of a sign-in: [code] for the challenge [ticket].
  Future<LoginResult> loginCode(
    String baseUrl, {
    required String ticket,
    required String code,
  }) async {
    final value = code.trim();
    if (value.isEmpty) throw const TixException(TixErrorKind.codeRequired);
    return await _complete(
      _build(baseUrl, null).session.login(
        LoginRequest(ticket: ticket, code: value, surface: _surface),
      ),
    );
  }

  /// A session in [tenant] for the session [session], which tix ends.
  Future<LoginResult> switchTenant(
    String baseUrl, {
    required String session,
    required String tenant,
    String? code,
  }) => _complete(
    _build(baseUrl, SessionCredential(session)).session.switchTenant(
      SwitchTenantInput(tenant: tenant, code: code?.trim(), surface: _surface),
    ),
    signingIn: false,
  );

  /// Ends [session] on the server.
  Future<void> logout(String baseUrl, String session) =>
      _build(baseUrl, SessionCredential(session)).session.logout();

  Future<LoginResult> _complete(
    Future<LoginResult> call, {
    bool signingIn = true,
  }) async {
    final LoginResult result;
    try {
      result = await call;
    } on TixException catch (e) {
      if (e.details['reason'] == 'second_factor_required') {
        throw const TixException(TixErrorKind.secondFactorSetup);
      }
      if (signingIn && e.kind == TixErrorKind.unauthenticated) {
        throw TixException(
          TixErrorKind.badCredentials,
          message: e.message,
          status: e.status,
          requestId: e.requestId,
        );
      }
      rethrow;
    }
    final challenge = result.challenge;
    if (challenge == null) return result;
    return switch (challenge.kind) {
      TOTPChallengeKind.code => result,
      TOTPChallengeKind.passwordChange => throw const TixException(
        TixErrorKind.passwordChange,
      ),
      _ => throw const TixException(TixErrorKind.secondFactorSetup),
    };
  }
}
