// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/app.dart';
import 'package:tix_mobile/src/core/config/config.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/models/connection.dart';
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
    browser = FakeSsoBrowser(supported: false);
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

  testWidgets('an error redirect says the sign-in did not finish', (
    tester,
  ) async {
    browser.answer = (url) => Uri.parse(
      'red.tix.mobile:/sso?error=access_denied'
      '&state=${url.queryParameters['app_state']}',
    );
    await signInAt(tester);
    await tap(tester, acme);
    await tester.pumpAndSettle();
    expect(errorText(tester), contains('did not finish (access_denied)'));
    expect(retry, findsOneWidget);
    expect(secrets.values, isEmpty);
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
