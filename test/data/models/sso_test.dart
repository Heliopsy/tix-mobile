// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/data/models/sso.dart';

void main() {
  group('SignInOptions', () {
    test('a server that allows app sign-in offers its providers', () {
      final o = SignInOptions.fromJson({
        'password_login': 'allowed',
        'providers': [
          {'key': 'acme', 'display_name': 'Acme', 'kind': 'oidc'},
          {'key': 'gh', 'display_name': '', 'kind': 'github'},
        ],
        'app_sign_in': true,
      });
      expect(o.passwordAllowed, isTrue);
      expect([for (final p in o.appProviders) p.label], ['Acme', 'gh']);
      expect(o.appProviders.last.kind, 'github');
    });

    test('without app_sign_in an older server offers no provider', () {
      final o = SignInOptions.fromJson({
        'password_login': 'allowed',
        'providers': [
          {'key': 'acme', 'display_name': 'Acme', 'kind': 'oidc'},
        ],
      });
      expect(o.appSignIn, isFalse);
      expect(o.providers, hasLength(1));
      expect(o.appProviders, isEmpty);
    });

    test('app_sign_in false offers no provider', () {
      final o = SignInOptions.fromJson({
        'providers': [
          {'key': 'acme'},
        ],
        'app_sign_in': false,
      });
      expect(o.appProviders, isEmpty);
    });

    test('disabled passwords and null providers', () {
      final o = SignInOptions.fromJson({
        'password_login': 'disabled',
        'providers': null,
        'app_sign_in': true,
      });
      expect(o.passwordAllowed, isFalse);
      expect(o.appProviders, isEmpty);
      expect(SignInOptions.none.passwordAllowed, isTrue);
    });
  });

  group('PKCE', () {
    test('the S256 challenge matches RFC 7636 appendix B', () {
      expect(
        pkceChallenge('dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk'),
        'E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM',
      );
    });

    test('an attempt has a 32-byte verifier and asks for the app redirect', () {
      final a = SsoAttempt.start(
        'https://tix.example/team/',
        'my idp',
        random: Random(1),
      );
      expect(a.verifier, hasLength(43));
      expect(a.verifier, matches(RegExp(r'^[A-Za-z0-9_-]+$')));
      expect(a.state, hasLength(22));
      final url = a.url;
      expect(url.toString(), startsWith('https://tix.example/team/login/sso/'));
      expect(url.pathSegments.last, 'my idp');
      expect(url.queryParameters, {
        'app_redirect': 'red.tix.mobile:/sso',
        'code_challenge': pkceChallenge(a.verifier),
        'code_challenge_method': 'S256',
        'app_state': a.state,
      });
    });

    test('two attempts never share a verifier or state', () {
      final random = Random.secure();
      final a = SsoAttempt.start('https://t', 'k', random: random);
      final b = SsoAttempt.start('https://t', 'k', random: random);
      expect(a.verifier, isNot(b.verifier));
      expect(a.state, isNot(b.state));
    });
  });
}
