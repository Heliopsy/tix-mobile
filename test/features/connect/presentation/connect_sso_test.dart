// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/app.dart';
import 'package:tix_mobile/src/core/config/config.dart';
import 'package:tix_mobile/src/core/platform/sso_pending.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/models/connection.dart';
import 'package:tix_mobile/src/data/models/sso.dart';
import 'package:tix_mobile/src/features/connect/presentation/connect_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_sso.dart';
import '../../../helpers/fake_tix.dart';
import '../../../helpers/stores.dart';

void main() {
  late FakeTix server;
  late MemorySecretStore secrets;
  late FakeSsoBrowser browser;

  setUp(() {
    server = FakeTix()..ssoOptions = ssoOptionsJson();
    secrets = MemorySecretStore();
    browser = FakeSsoBrowser();
  });

  final acme = find.byKey(const Key('connect.sso.acme'));
  final github = find.byKey(const Key('connect.sso.github'));
  final error = find.byKey(const Key('connect.error'));
  final retry = find.byKey(const Key('connect.sso.retry'));
  final waiting = find.byKey(const Key('connect.sso.waiting'));

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pump();
    await tester.tap(finder);
  }

  /// The connect screen on the sign-in method with [url] typed and its
  /// options read.
  Future<ProviderContainer> signInAt(
    WidgetTester tester, {
    String url = 'tix.example',
    Size size = phone,
  }) async {
    final c = await pumpScreen(
      tester,
      const ConnectScreen(),
      size: size,
      overrides: fakeOverrides(server, secrets: secrets, sso: browser),
    );
    await tester.enterText(find.byKey(const Key('connect.url')), url);
    await tap(tester, find.text('Sign in'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    return c;
  }

  String errorText(WidgetTester tester) => tester.widget<Text>(error).data!;

  for (final MapEntry(key: width, value: size) in widths.entries) {
    testWidgets('$width: one button per provider, beside the password', (
      tester,
    ) async {
      await signInAt(tester, size: size);
      expect(
        find.descendant(of: acme, matching: find.text('Sign in with Acme')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: github, matching: find.text('Sign in with GitHub')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('connect.password')), findsOneWidget);
      expect(find.byKey(const Key('connect.submit')), findsOneWidget);
      expect(
        tester.getSemantics(acme),
        matchesSemantics(
          label: 'Sign in with Acme',
          hint: 'Opens in your browser',
          isButton: true,
          isEnabled: true,
          hasEnabledState: true,
          isFocusable: true,
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
    });
  }

  testWidgets('the buttons fit at 200% text', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await signInAt(tester);
    expect(acme, findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('no buttons from a server without app_sign_in', (tester) async {
    server.ssoOptions = ssoOptionsJson(appSignIn: null);
    await signInAt(tester);
    expect(acme, findsNothing);
    expect(find.byKey(const Key('connect.password')), findsOneWidget);
  });

  testWidgets('no buttons when app_sign_in is false', (tester) async {
    server.ssoOptions = ssoOptionsJson(appSignIn: false);
    await signInAt(tester);
    expect(acme, findsNothing);
  });

  testWidgets('no buttons from a tix without the options route', (
    tester,
  ) async {
    server.ssoOptions = null;
    await signInAt(tester);
    expect(acme, findsNothing);
    expect(find.byKey(const Key('connect.password')), findsOneWidget);
  });

  testWidgets('no buttons where the platform has no browser for it', (
    tester,
  ) async {
    browser = FakeSsoBrowser(isSupported: false);
    await signInAt(tester);
    expect(acme, findsNothing);
  });

  testWidgets('disabled passwords hide the form but keep the token', (
    tester,
  ) async {
    server.ssoOptions = ssoOptionsJson(passwordLogin: 'disabled');
    await signInAt(tester);
    expect(acme, findsOneWidget);
    expect(find.byKey(const Key('connect.email')), findsNothing);
    expect(find.byKey(const Key('connect.password')), findsNothing);
    expect(find.byKey(const Key('connect.submit')), findsNothing);
    await tap(tester, find.text('Token'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('connect.token')), findsOneWidget);
    expect(find.byKey(const Key('connect.submit')), findsOneWidget);
  });

  testWidgets('disabled passwords and no provider say to use a token', (
    tester,
  ) async {
    server.ssoOptions = ssoOptionsJson(
      appSignIn: false,
      passwordLogin: 'disabled',
    );
    await signInAt(tester);
    expect(find.byKey(const Key('connect.password')), findsNothing);
    expect(find.byKey(const Key('connect.noPassword')), findsOneWidget);
  });

  testWidgets('the browser opens the provider with PKCE and a state', (
    tester,
  ) async {
    browser.answer = (url) => ssoRedirectFor(server, url);
    final c = await signInAt(tester);
    await tap(tester, acme);
    await tester.pumpAndSettle();
    final url = browser.opened.single;
    expect(url.path, '/login/sso/acme');
    expect(url.queryParameters['app_redirect'], 'red.tix.mobile:/sso');
    expect(url.queryParameters['code_challenge_method'], 'S256');
    expect(error, findsNothing);
    final session = c.read(sessionControllerProvider).value;
    expect(session?.connection.kind, ConnectionKind.signIn);
    expect(session?.connection.email, 'ana@example.com');
    expect(secrets.values.values.single, startsWith('sess-'));
  });

  testWidgets('waiting for the browser, then cancelled from the app', (
    tester,
  ) async {
    await signInAt(tester);
    await tap(tester, acme);
    for (var i = 0; i < 10 && browser.opened.isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 1));
    }
    expect(waiting, findsOneWidget);
    expect(browser.opened, hasLength(1));
    expect(tester.widget<OutlinedButton>(github).onPressed, isNull);
    await tap(tester, find.byKey(const Key('connect.sso.cancel')));
    await tester.pumpAndSettle();
    expect(browser.cancels, 1);
    expect(waiting, findsNothing);
    expect(error, findsNothing);
    expect(tester.widget<OutlinedButton>(github).onPressed, isNotNull);
    expect(secrets.values, isEmpty);
  });

  testWidgets('closing the browser returns quietly to the form', (
    tester,
  ) async {
    browser.answer = (_) => null;
    await signInAt(tester);
    await tap(tester, acme);
    await tester.pumpAndSettle();
    expect(browser.opened, hasLength(1));
    expect(error, findsNothing);
    expect(waiting, findsNothing);
    expect(find.byKey(const Key('connect.password')), findsOneWidget);
    expect(
      server.requests.where((r) => r.uri.path.endsWith('/sso/exchange')),
      isEmpty,
    );
  });

  testWidgets('a redirect with another state is refused unexchanged', (
    tester,
  ) async {
    browser.answer = (url) => ssoRedirectFor(server, url, state: 'forged');
    await signInAt(tester);
    await tap(tester, acme);
    await tester.pumpAndSettle();
    expect(errorText(tester), contains('could not be verified'));
    expect(retry, findsOneWidget);
    expect(
      server.requests.where((r) => r.uri.path.endsWith('/sso/exchange')),
      isEmpty,
    );
    expect(secrets.values, isEmpty);
  });

  Uri errorRedirect(Uri url, String reason) => Uri.parse(
    'red.tix.mobile:/sso?error=$reason'
    '&state=${url.queryParameters['app_state']}',
  );

  testWidgets('a declined or refused sign-in says so, no retry', (
    tester,
  ) async {
    browser.answer = (url) => errorRedirect(url, 'access_denied');
    await signInAt(tester);
    await tap(tester, acme);
    await tester.pumpAndSettle();
    expect(errorText(tester), contains('declined or refused'));
    expect(errorText(tester), isNot(contains('access_denied')));
    expect(retry, findsNothing);
    expect(waiting, findsNothing);
    expect(find.byKey(const Key('connect.password')), findsOneWidget);
    expect(tester.widget<OutlinedButton>(acme).onPressed, isNotNull);
    expect(secrets.values, isEmpty);
  });

  testWidgets('an account the tenant does not know is explained, no retry', (
    tester,
  ) async {
    browser.answer = (url) => errorRedirect(url, 'not_linked');
    await signInAt(tester);
    await tap(tester, acme);
    await tester.pumpAndSettle();
    expect(errorText(tester), contains('not linked to anyone'));
    expect(errorText(tester), isNot(contains('not_linked')));
    expect(retry, findsNothing);
    expect(secrets.values, isEmpty);
  });

  testWidgets('an expired sign-in says so and can be tried again', (
    tester,
  ) async {
    browser.answer = (url) => errorRedirect(url, 'expired');
    await signInAt(tester);
    await tap(tester, acme);
    await tester.pumpAndSettle();
    expect(errorText(tester), contains('took too long'));
    expect(retry, findsOneWidget);
  });

  for (final reason in ['provider_error', 'server_error']) {
    testWidgets('$reason says the sign-in did not finish, without the code', (
      tester,
    ) async {
      browser.answer = (url) => errorRedirect(url, reason);
      await signInAt(tester);
      await tap(tester, acme);
      await tester.pumpAndSettle();
      expect(errorText(tester), contains('did not finish'));
      expect(errorText(tester), isNot(contains(reason)));
      expect(retry, findsOneWidget);
      expect(secrets.values, isEmpty);
    });
  }

  testWidgets('the attempt is kept while the browser is open', (tester) async {
    await signInAt(tester);
    await tap(tester, acme);
    for (var i = 0; i < 10 && browser.opened.isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 1));
    }
    final kept = jsonDecode(
      secrets.values[PendingSsoStore.key]!,
    ) as Map<String, Object?>;
    final url = browser.opened.single;
    expect(kept['base_url'], 'https://tix.example');
    expect(kept['provider'], 'acme');
    expect(kept['state'], url.queryParameters['app_state']);
    expect(
      pkceChallenge(kept['verifier']! as String),
      url.queryParameters['code_challenge'],
    );
    expect(kept['started_at'], isNotNull);
    await tap(tester, find.byKey(const Key('connect.sso.cancel')));
    await tester.pumpAndSettle();
    expect(secrets.values, isEmpty);
  });

  testWidgets('cancelling during the exchange saves nothing', (tester) async {
    final gate = Completer<void>();
    final c = await signInAt(tester);
    browser.answer = (url) {
      server.gate = gate;
      return ssoRedirectFor(server, url);
    };
    await tap(tester, acme);
    for (
      var i = 0;
      i < 20 && !server.requests.any((r) => r.uri.path.endsWith('/exchange'));
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 1));
    }
    await tap(tester, find.byKey(const Key('connect.sso.cancel')));
    await tester.pump();
    server.gate = null;
    gate.complete();
    await tester.pumpAndSettle();
    expect(c.read(sessionControllerProvider).value, isNull);
    expect(secrets.values, isEmpty);
    expect(error, findsNothing);
  });

  group('after the app was restarted', () {
    PendingSso keep(String state, {String name = ''}) {
      final pending = PendingSso(
        attempt: SsoAttempt(
          baseUrl: 'https://tix.example',
          provider: 'acme',
          verifier: 'v' * 43,
          state: state,
        ),
        startedAt: fixedNow.subtract(const Duration(minutes: 1)),
        name: name,
      );
      secrets.values[PendingSsoStore.key] = jsonEncode(pending.toJson());
      return pending;
    }

    Future<ProviderContainer> open(WidgetTester tester) async {
      final c = await pumpScreen(
        tester,
        const ConnectScreen(),
        overrides: fakeOverrides(server, secrets: secrets, sso: browser),
      );
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      return c;
    }

    testWidgets('a kept attempt and its redirect finish the sign-in', (
      tester,
    ) async {
      final pending = keep('s1');
      final code = server.grantSso(pkceChallenge(pending.attempt.verifier));
      browser.left = Uri.parse('red.tix.mobile:/sso?code=$code&state=s1');
      final c = await open(tester);
      expect(error, findsNothing);
      final session = c.read(sessionControllerProvider).value;
      expect(session?.connection.email, 'ana@example.com');
      expect(secrets.values.keys.single, startsWith('session.'));
      expect(browser.opened, isEmpty);
    });

    testWidgets('a redirect for another attempt says it was interrupted', (
      tester,
    ) async {
      keep('s1');
      browser.left = Uri.parse('red.tix.mobile:/sso?code=c&state=other');
      final c = await open(tester);
      expect(errorText(tester), contains('interrupted'));
      expect(c.read(sessionControllerProvider).value, isNull);
      expect(secrets.values, isEmpty);
      expect(
        server.requests.where((r) => r.uri.path.endsWith('/sso/exchange')),
        isEmpty,
      );
    });

    testWidgets('a redirect with nothing kept says it was interrupted', (
      tester,
    ) async {
      browser.left = Uri.parse('red.tix.mobile:/sso?code=c&state=s1');
      await open(tester);
      expect(errorText(tester), contains('interrupted'));
    });

    testWidgets('a kept attempt with no redirect says it was interrupted '
        'and offers the provider again', (tester) async {
      keep('s1');
      await open(tester);
      expect(errorText(tester), contains('interrupted'));
      expect(secrets.values, isEmpty);
      expect(
        tester
            .widget<EditableText>(
              find.descendant(
                of: find.byKey(const Key('connect.url')),
                matching: find.byType(EditableText),
              ),
            )
            .controller
            .text,
        'https://tix.example',
      );
      expect(retry, findsOneWidget);
    });

    testWidgets('a kept attempt past its lifetime is dropped quietly', (
      tester,
    ) async {
      final old = PendingSso(
        attempt: const SsoAttempt(
          baseUrl: 'https://tix.example',
          provider: 'acme',
          verifier: 'v',
          state: 's1',
        ),
        startedAt: fixedNow.subtract(const Duration(minutes: 11)),
      );
      secrets.values[PendingSsoStore.key] = jsonEncode(old.toJson());
      await open(tester);
      expect(error, findsNothing);
      expect(secrets.values, isEmpty);
    });

    testWidgets('nothing kept and nothing held leaves the screen alone', (
      tester,
    ) async {
      await open(tester);
      expect(error, findsNothing);
    });
  });

  testWidgets('a refused exchange is explained and can be tried again', (
    tester,
  ) async {
    browser.answer = (url) => Uri.parse(
      'red.tix.mobile:/sso?code=stale'
      '&state=${url.queryParameters['app_state']}',
    );
    final c = await signInAt(tester);
    await tap(tester, github);
    await tester.pumpAndSettle();
    expect(errorText(tester), contains('did not accept this sign-in'));
    expect(secrets.values, isEmpty);

    browser.answer = (url) => ssoRedirectFor(server, url);
    await tap(tester, retry);
    await tester.pumpAndSettle();
    expect(browser.opened.last.path, '/login/sso/github');
    expect(error, findsNothing);
    expect(c.read(sessionControllerProvider).value, isNotNull);
  });

  group('in the app', () {
    Future<void> pumpApp(
      WidgetTester tester, {
      MemoryKeyValueStore? settings,
      MemorySecretStore? secrets,
    }) async {
      await setSize(tester, phone);
      await tester.pumpWidget(
        ProviderScope(
          retry: noRetry,
          overrides: fakeOverrides(
            server,
            settings: settings,
            secrets: secrets,
            sso: browser,
          ),
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('a provider sign-in lands on the home screen', (tester) async {
      browser.answer = (url) => ssoRedirectFor(server, url);
      final store = MemorySecretStore();
      await pumpApp(tester, secrets: store);
      await tester.enterText(
        find.byKey(const Key('connect.url')),
        'tix.example',
      );
      await tap(tester, find.text('Sign in'));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      await tap(tester, acme);
      await tester.pumpAndSettle();
      expect(find.text('Infrastructure'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(store.values.keys.single, startsWith('session.'));
    });

    testWidgets('reconnecting a refused token by provider clears refusedAt', (
      tester,
    ) async {
      browser.answer = (url) => ssoRedirectFor(server, url);
      final stores = signedInStores(token: 'revoked');
      await pumpApp(tester, settings: stores.settings, secrets: stores.secrets);
      expect(find.byKey(const Key('connect.tokenRefused')), findsOneWidget);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(ConnectScreen)),
      );
      final repo = container.read(instancesRepositoryProvider);
      final refused = repo.connections().single;
      expect(refused.refusedAt, isNotNull);

      await tap(tester, find.text('Sign in'));
      await tester.pumpAndSettle();
      await tap(tester, acme);
      await tester.pumpAndSettle();

      expect(find.text('Infrastructure'), findsOneWidget);
      final now = repo.connection(refused.id)!;
      expect(now.refusedAt, isNull);
      expect(now.kind, ConnectionKind.signIn);
      expect(browser.opened.single.host, 'tix.example');
      expect(stores.secrets.values.keys, ['session.${refused.id}']);
    });

    testWidgets('signing in again after the session ended offers providers', (
      tester,
    ) async {
      browser.answer = (url) => ssoRedirectFor(server, url);
      final stores = signInStores(server);
      server.sessions.clear();
      await pumpApp(tester, settings: stores.settings, secrets: stores.secrets);
      expect(find.byKey(const Key('connect.signedOut')), findsOneWidget);
      await tap(tester, acme);
      await tester.pumpAndSettle();
      expect(find.text('Infrastructure'), findsOneWidget);
      expect(stores.secrets.values.keys, ['session.s1']);
    });
  });
}
