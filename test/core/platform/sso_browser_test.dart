// SPDX-License-Identifier: AGPL-3.0-or-later

@TestOn('linux')
library;

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/platform/deep_links.dart';
import 'package:tix_mobile/src/core/platform/sso_browser.dart';
import 'package:tix_mobile/src/data/models/sso.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('tix/links-sso-test');
  const attempt = SsoAttempt(
    baseUrl: 'https://tix.example',
    provider: 'acme',
    verifier: 'v',
    state: 's',
  );
  late DeepLinkIntake intake;
  late List<Uri> launched;
  late List<List<String>> ran;

  setUp(() {
    intake = DeepLinkIntake(channel);
    addTearDown(intake.dispose);
    launched = [];
    ran = [];
  });

  PlatformSsoBrowser browser({
    bool opens = true,
    ProcessResult Function(String exe, List<String> args)? answer,
    Map<String, String> environment = const {},
    Duration desktopWait = const Duration(minutes: 5),
  }) => PlatformSsoBrowser(
    intake,
    launch: (u) async {
      launched.add(u);
      return opens;
    },
    run: (exe, args) async {
      ran.add([exe, ...args]);
      return (answer ?? (_, _) => ProcessResult(1, 0, 'tix.desktop\n', ''))(
        exe,
        args,
      );
    },
    environment: environment,
    desktopWait: desktopWait,
  );

  Matcher kind(TixErrorKind k) =>
      throwsA(isA<TixException>().having((e) => e.kind, 'kind', k));

  test('the desktop opens the browser and hears the redirect', () async {
    final b = browser();
    final answer = b.authenticate(attempt);
    await pumpEventQueue();
    expect(launched, [attempt.url]);
    intake.deliver(Uri.parse('tix://inbox'));
    final redirect = Uri.parse('red.tix.mobile:/sso?code=c&state=s');
    intake.deliver(redirect);
    expect(await answer, redirect);
  });

  test(
    'a redirect from an older tab is ignored and the wait goes on',
    () async {
      final b = browser();
      final answer = b.authenticate(attempt);
      await pumpEventQueue();
      intake
        ..deliver(Uri.parse('red.tix.mobile:/sso?code=old&state=older'))
        ..deliver(Uri.parse('red.tix.mobile:/sso?code=none'));
      final redirect = Uri.parse('red.tix.mobile:/sso?code=c&state=s');
      intake.deliver(redirect);
      expect(await answer, redirect);
      expect(intake.hasSsoRedirect, isFalse);
    },
  );

  test('cancel gives up the sign-in', () async {
    final b = browser();
    final answer = b.authenticate(attempt);
    await pumpEventQueue();
    await b.cancel();
    expect(await answer, isNull);
  });

  test('a desktop wait past its limit fails as expired', () async {
    final b = browser(desktopWait: const Duration(milliseconds: 10));
    await expectLater(b.authenticate(attempt), kind(TixErrorKind.ssoExpired));
    final late = Uri.parse('red.tix.mobile:/sso?code=c&state=s');
    intake.deliver(late);
    expect(intake.takeSso(within: ssoCodeLifetime), late);
  });

  test('a browser that will not open fails the sign-in', () async {
    await expectLater(
      browser(opens: false).authenticate(attempt),
      kind(TixErrorKind.ssoFailed),
    );
  });

  test('a redirect that restarted the app is handed over once', () async {
    final b = browser();
    final redirect = Uri.parse('red.tix.mobile:/sso?code=c&state=s');
    intake.deliver(redirect);
    expect(await b.leftOver(), redirect);
    expect(await b.leftOver(), isNull);
  });

  group('Linux', () {
    test('is supported when xdg-mime names a handler', () async {
      final b = browser();
      expect(await b.supported(), isTrue);
      expect(ran.single, [
        'xdg-mime',
        'query',
        'default',
        'x-scheme-handler/red.tix.mobile',
      ]);
    });

    test('is not supported when no handler is registered', () async {
      final b = browser(answer: (_, _) => ProcessResult(1, 0, '\n', ''));
      expect(await b.supported(), isFalse);
      final failing = browser(answer: (_, _) => ProcessResult(1, 4, '', 'x'));
      expect(await failing.supported(), isFalse);
    });

    test('is not supported without xdg-mime', () async {
      final b = browser(
        answer: (exe, _) => throw ProcessException(exe, const []),
      );
      expect(await b.supported(), isFalse);
    });

    test('a Flatpak exports its handler and asks no one', () async {
      final b = browser(
        environment: const {'FLATPAK_ID': 'red.tix.tix_mobile'},
      );
      expect(await b.supported(), isTrue);
      expect(ran, isEmpty);
    });
  });

  group('the Windows scheme', () {
    test('is written in three reg calls', () async {
      await browser(answer: (_, _) => ProcessResult(1, 0, '', ''))
          .registerWindowsScheme();
      expect(ran, hasLength(3));
      expect(ran.every((c) => c.first == 'reg' && c[1] == 'add'), isTrue);
    });

    test('fails the sign-in when reg refuses', () async {
      final b = browser(
        answer: (_, args) =>
            ProcessResult(1, args.contains('URL Protocol') ? 1 : 0, '', 'no'),
      );
      await expectLater(
        b.registerWindowsScheme(),
        kind(TixErrorKind.ssoFailed),
      );
      expect(ran, hasLength(2));
    });

    test('fails the sign-in when reg is missing', () async {
      final b = browser(
        answer: (exe, _) => throw ProcessException(exe, const []),
      );
      await expectLater(
        b.registerWindowsScheme(),
        kind(TixErrorKind.ssoFailed),
      );
    });
  });
}
