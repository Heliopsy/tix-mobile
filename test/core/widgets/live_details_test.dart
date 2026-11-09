// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/events/events.dart';
import 'package:tix_mobile/src/core/platform/app_info.dart';
import 'package:tix_mobile/src/core/widgets/live_details.dart';
import 'package:tix_mobile/src/features/shell/presentation/context_switcher.dart';

import '../../helpers/app.dart';
import '../../helpers/fake_events.dart';
import '../../helpers/fake_tix.dart';

const _token = 'tok-do-not-leak-7f3a';
const _app = AppInfo(
  version: '0.8.0',
  build: '9',
  platform: 'Android',
  osVersion: '15',
);

void main() {
  late FakeEventSockets sockets;
  late List<String> copied;

  setUp(() {
    sockets = FakeEventSockets();
    copied = [];
  });

  Finder inSwitcher(Finder f) =>
      find.descendant(of: find.byKey(const Key('switcher.open')), matching: f);

  Finder inDetails(Finder f) =>
      find.descendant(of: find.byKey(const Key('live.details')), matching: f);

  Future<void> pump(
    WidgetTester tester, {
    Widget button = const ContextSwitcherButton(),
    Size size = phone,
    Locale locale = const Locale('en'),
  }) async {
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied.add((call.arguments as Map)['text'] as String);
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    final stores = signedInStores(token: _token);
    await pumpScreen(
      tester,
      Scaffold(body: const SizedBox.expand(), bottomNavigationBar: button),
      overrides: [
        ...fakeOverrides(
          FakeTix(token: _token),
          settings: stores.settings,
          secrets: stores.secrets,
          events: sockets.connect,
        ),
        appInfoProvider.overrideWithValue(const AsyncData(_app)),
        liveConfigProvider.overrideWithValue(
          const LiveConfig(failuresBeforeFallback: 100),
        ),
      ],
      size: size,
      locale: locale,
    );
  }

  Future<void> openFromIndicator(WidgetTester tester) async {
    await tester.tap(inSwitcher(find.byKey(const Key('live.indicator'))));
    await tester.pumpAndSettle();
  }

  testWidgets('tapping the indicator opens the details, not the switcher', (
    tester,
  ) async {
    sockets.refuse = 403;
    await pump(tester);
    await openFromIndicator(tester);
    expect(find.byKey(const Key('live.details')), findsOneWidget);
    expect(find.byKey(const Key('switcher.sheet')), findsNothing);
    expect(inDetails(find.text('https://tix.example')), findsOneWidget);
    expect(inDetails(find.text('Refused by the server')), findsOneWidget);
    expect(find.byKey(const Key('live.details.hint.refused')), findsOneWidget);
  });

  testWidgets('an unreachable host shows the OS error and its hint', (
    tester,
  ) async {
    sockets.error = const SocketException(
      'Failed host lookup',
      osError: OSError('No address associated with hostname', 7),
    );
    await pump(tester);
    expect(inSwitcher(find.text('Offline')), findsOneWidget);
    await openFromIndicator(tester);
    final kind = tester.widget<Text>(
      find.byKey(const Key('live.details.kind')),
    );
    expect(kind.data, 'Could not reach the server');
    expect(
      tester.widget<Text>(find.byKey(const Key('live.details.os'))).data,
      'No address associated with hostname (code 7)',
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('live.details.type'))).data,
      'SocketException',
    );
    expect(
      find.byKey(const Key('live.details.hint.unreachable')),
      findsOneWidget,
    );
  });

  testWidgets('copy puts a redacted report on the clipboard', (tester) async {
    sockets.error = const WebSocketException(
      'not upgraded: wss://tix.example/api/v1/events?access_token=$_token '
      'Authorization: Bearer $_token',
      502,
    );
    await pump(tester);
    await openFromIndicator(tester);
    expect(
      find.byKey(const Key('live.details.hint.noUpgrade')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('live.details.copy')));
    await tester.pumpAndSettle();
    expect(copied, hasLength(1));
    final report = copied.single;
    expect(report, contains('App: 0.8.0 (9)'));
    expect(report, contains('Platform: Android 15'));
    expect(report, contains('Server: https://tix.example'));
    expect(report, contains('HTTP 502'));
    expect(report, isNot(contains(_token)));
    expect(report, isNot(contains('access_token')));
  });

  testWidgets('reconnect now tries the WebSocket again', (tester) async {
    sockets.refuse = 403;
    await pump(tester);
    await openFromIndicator(tester);
    final before = sockets.attempts;
    expect(before, greaterThan(0));
    await tester.tap(find.byKey(const Key('live.details.reconnect')));
    await tester.pumpAndSettle();
    expect(sockets.attempts, before + 1);
  });

  testWidgets('a long press on the rail opens the details', (tester) async {
    sockets.refuse = 403;
    await pump(
      tester,
      button: const ContextSwitcherButton(rail: true),
      size: desktop,
    );
    await tester.longPress(find.byKey(const Key('switcher.open')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('live.details')), findsOneWidget);
  });

  testWidgets('the indicator says it opens the details', (tester) async {
    final handle = tester.ensureSemantics();
    sockets.refuse = 403;
    await pump(tester);
    expect(
      tester.getSemantics(find.bySemanticsLabel(RegExp('^Live updates'))),
      isSemantics(
        label:
            'Live updates: Not available. '
            'This connection may not follow live updates (it needs the '
            'event:subscribe scope). Pull down to refresh instead.',
        hint: 'Tap for connection details',
        isButton: true,
        hasTapAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('Bulgarian', (tester) async {
    sockets.refuse = 403;
    await pump(tester, locale: const Locale('bg'));
    await openFromIndicator(tester);
    expect(find.text('Подробности за връзката'), findsOneWidget);
    expect(find.text('Свързване отново'), findsOneWidget);
  });

  group('hints', () {
    LiveDiagnostics diag(LiveError? e, {LiveMode mode = LiveMode.offline}) =>
        LiveDiagnostics(
          mode: mode,
          transport: LiveTransport.websocket,
          host: 'https://tix.example',
          modeSince: fixedNow,
          failuresBeforeFallback: 3,
          failureWindow: const Duration(minutes: 2),
          lastError: e,
        );
    LiveError error(Object? cause) =>
        LiveError.from(cause, at: fixedNow, source: LiveErrorSource.poll);

    test('a timeout points at idle timeouts', () {
      expect(liveHints(diag(error(TimeoutException('slow')))), [
        LiveHint.idleTimeout,
      ]);
    });

    test('a dropped socket points at idle timeouts too', () {
      expect(liveHints(diag(error(const EventSocketClosed(1006)))), [
        LiveHint.idleTimeout,
      ]);
    });

    test('polling that works points at the proxy', () {
      expect(liveHints(diag(null, mode: LiveMode.polling)), [
        LiveHint.noUpgrade,
      ]);
    });

    test('TLS points at the certificate', () {
      expect(liveHints(diag(error(const HandshakeException('bad')))), [
        LiveHint.tls,
      ]);
    });

    test('nothing to say when all is well', () {
      expect(liveHints(diag(null, mode: LiveMode.websocket)), isEmpty);
    });
  });
}
