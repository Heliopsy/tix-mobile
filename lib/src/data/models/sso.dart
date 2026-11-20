// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sso.freezed.dart';
part 'sso.g.dart';

// Written by hand until the vendored OpenAPI document carries `app_sign_in`
// and `sso.exchange`; `just gen` then produces both and these go.

/// One provider a tenant's sign-in screen offers.
@freezed
abstract class SsoProviderOption with _$SsoProviderOption {
  /// Creates a provider option.
  const factory SsoProviderOption({
    required String key,
    @Default('') String displayName,
    @Default('') String kind,
  }) = _SsoProviderOption;

  const SsoProviderOption._();

  /// Reads `sso.options`' provider entry.
  factory SsoProviderOption.fromJson(Map<String, dynamic> json) =>
      _$SsoProviderOptionFromJson(json);

  /// The name to show, the key when the server sent none.
  String get label => displayName.isEmpty ? key : displayName;
}

/// What a tenant's sign-in screen offers (`GET /api/v1/auth/sso/options`).
@freezed
abstract class SignInOptions with _$SignInOptions {
  /// Creates options.
  const factory SignInOptions({
    @Default('allowed') String passwordLogin,
    @Default(<SsoProviderOption>[]) List<SsoProviderOption> providers,
    @Default(false) bool appSignIn,
  }) = _SignInOptions;

  const SignInOptions._();

  /// Reads `sso.options`; a missing `app_sign_in` counts as false.
  factory SignInOptions.fromJson(Map<String, dynamic> json) =>
      _$SignInOptionsFromJson(json);

  /// What a server without the route offers: passwords and nothing else.
  static const none = SignInOptions();

  /// Whether the email and password form is offered.
  bool get passwordAllowed => passwordLogin != 'disabled';

  /// The providers an app may sign in with.
  List<SsoProviderOption> get appProviders => appSignIn ? providers : const [];
}

/// The body of `POST /api/v1/auth/sso/exchange`.
@freezed
abstract class SsoExchangeInput with _$SsoExchangeInput {
  /// Creates the body.
  const factory SsoExchangeInput({
    required String code,
    required String codeVerifier,
  }) = _SsoExchangeInput;

  /// Reads the body.
  factory SsoExchangeInput.fromJson(Map<String, dynamic> json) =>
      _$SsoExchangeInputFromJson(json);
}

/// The scheme the server redirects a native sign-in to.
const ssoScheme = 'red.tix.mobile';

/// The redirect the app asks the server for.
const ssoRedirect = '$ssoScheme:/sso';

/// The S256 challenge of a PKCE [verifier] (RFC 7636, 4.2).
String pkceChallenge(String verifier) =>
    _base64Url(sha256.convert(ascii.encode(verifier)).bytes);

/// [bytes] as unpadded base64url.
String _base64Url(List<int> bytes) =>
    base64Url.encode(bytes).replaceAll('=', '');

/// One provider sign-in under way: where the browser goes and the secrets
/// only this attempt knows.
@immutable
class SsoAttempt {
  /// An attempt at [baseUrl] through [provider].
  const SsoAttempt({
    required this.baseUrl,
    required this.provider,
    required this.verifier,
    required this.state,
  });

  /// Starts an attempt with a 32-byte verifier and a 16-byte state from
  /// [random].
  factory SsoAttempt.start(
    String baseUrl,
    String provider, {
    required Random random,
  }) {
    List<int> bytes(int n) => [for (var i = 0; i < n; i++) random.nextInt(256)];
    return SsoAttempt(
      baseUrl: baseUrl,
      provider: provider,
      verifier: _base64Url(bytes(32)),
      state: _base64Url(bytes(16)),
    );
  }

  /// The server.
  final String baseUrl;

  /// The provider's key.
  final String provider;

  /// The PKCE verifier, sent only to the exchange.
  final String verifier;

  /// The `app_state` the redirect must carry back.
  final String state;

  /// The address to open in the browser.
  Uri get url {
    final base = Uri.parse(baseUrl);
    final prefix = base.path.endsWith('/')
        ? base.path.substring(0, base.path.length - 1)
        : base.path;
    return base.replace(
      path: '$prefix/login/sso/${Uri.encodeComponent(provider)}',
      queryParameters: {
        'app_redirect': ssoRedirect,
        'code_challenge': pkceChallenge(verifier),
        'code_challenge_method': 'S256',
        'app_state': state,
      },
    );
  }
}
