// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:tix_mobile/src/core/platform/sso_browser.dart';
import 'package:tix_mobile/src/data/models/sso.dart';

import 'fake_tix.dart';

/// A browser that answers each provider sign-in with [answer], or waits for
/// [cancel] when there is none.
class FakeSsoBrowser implements SsoBrowser {
  FakeSsoBrowser({this.isSupported = true, this.answer, this.left});

  /// What [supported] answers.
  final bool isSupported;

  /// The redirect for each opened address; null cancels.
  FutureOr<Uri?> Function(Uri url)? answer;

  /// What [leftOver] hands over once.
  Uri? left;

  /// Every address opened.
  final opened = <Uri>[];

  /// How many times the sign-in was given up from the app.
  int cancels = 0;

  Completer<Uri?>? _held;

  @override
  Future<bool> supported() async => isSupported;

  @override
  Future<Uri?> authenticate(SsoAttempt attempt) async {
    final url = attempt.url;
    opened.add(url);
    final reply = answer;
    if (reply != null) return await reply(url);
    final held = _held = Completer<Uri?>();
    return await held.future;
  }

  @override
  Future<void> cancel() async {
    cancels++;
    final held = _held;
    _held = null;
    if (held != null && !held.isCompleted) held.complete(null);
  }

  @override
  Future<Uri?> leftOver() async {
    final taken = left;
    left = null;
    return taken;
  }
}

/// The redirect [server] sends back after the browser sign-in [url] opened,
/// for [email], carrying [state] in place of the one sent when given.
Uri ssoRedirectFor(
  FakeTix server,
  Uri url, {
  String email = 'ana@example.com',
  String? state,
}) {
  final q = url.queryParameters;
  final code = server.grantSso(q['code_challenge']!, email: email);
  return Uri.parse(
    ssoRedirect,
  ).replace(queryParameters: {'code': code, 'state': state ?? q['app_state']!});
}

/// Options as a tix that allows app sign-in answers them.
Map<String, Object?> ssoOptionsJson({
  bool? appSignIn = true,
  String passwordLogin = 'allowed',
}) => {
  'password_login': passwordLogin,
  'providers': [
    {'key': 'acme', 'display_name': 'Acme', 'kind': 'oidc'},
    {'key': 'github', 'display_name': 'GitHub', 'kind': 'github'},
  ],
  'app_sign_in': ?appSignIn,
};
