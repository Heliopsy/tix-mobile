// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/platform/app_info.dart';
import 'package:tix_mobile/src/core/update/updates.dart';
import 'package:tix_mobile/src/data/local/local_engine.dart';
import 'package:tix_mobile/src/features/about/application/about.dart';
import 'package:tix_mobile/src/features/about/presentation/about_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/attachments.dart';
import '../../../helpers/design.dart';
import '../../../helpers/fake_tix.dart';
import '../../../helpers/fixed_updates.dart';

const _token = 'tok-do-not-leak-7f3a';
const _app = AppInfo(
  version: '0.4.0',
  build: '12',
  platform: 'Linux',
  osVersion: 'Ubuntu 24.04',
);

void main() {
  late FakeAttachments links;
  late List<String> copied;

  setUp(() {
    links = FakeAttachments();
    copied = [];
  });

  Future<void> pump(
    WidgetTester tester, {
    Size size = phone,
    bool signedIn = true,
    LocalTixEngine? engine,
    Locale locale = const Locale('en'),
    UpdateMode updates = UpdateMode.off,
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
    final server = FakeTix(token: _token);
    final stores = signedIn ? signedInStores(token: _token) : null;
    await pumpScreen(
      tester,
      const AboutScreen(),
      size: size,
      locale: locale,
      overrides: [
        ...fakeOverrides(
          server,
          settings: stores?.settings,
          secrets: stores?.secrets,
          engine: engine,
          updates: updates,
        ),
        fixedUpdates(
          FixedUpdates(
            UpdateState(phase: UpdatePhase.available, offer: offerOf('0.5.0')),
          ),
        ),
        appInfoProvider.overrideWithValue(const AsyncData(_app)),
        links.asOverride,
      ],
    );
  }

  Future<void> tap(WidgetTester tester, String key) async {
    final f = find.byKey(Key(key));
    await tester.scrollUntilVisible(
      f,
      200,
      scrollable: find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          )
          .first,
    );
    await tester.ensureVisible(f);
    await tester.pumpAndSettle();
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  String text(WidgetTester tester, String key) =>
      tester.widget<Text>(find.byKey(Key(key))).data!;

  for (final MapEntry(key: width, value: size) in widths.entries) {
    testWidgets('$width: versions, description and links', (tester) async {
      await pump(tester, size: size);
      expect(find.text('Version 0.4.0 (12)'), findsOneWidget);
      expect(text(tester, 'about.app'), '0.4.0 (12)');
      expect(text(tester, 'about.engine'), 'in-memory');
      expect(text(tester, 'about.server'), 'v1.2.3');
      expect(find.textContaining('open source task tracker'), findsOneWidget);
      for (final (id, uri) in [
        ('website', AboutLinks.website),
        ('source', AboutLinks.source),
        ('roadmap', AboutLinks.roadmap),
        ('changelog', AboutLinks.changelog),
        ('server', AboutLinks.server),
        ('security', AboutLinks.security),
      ]) {
        await tap(tester, 'about.link.$id');
        expect(links.links.last, uri, reason: id);
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('without an engine or a session it says so', (tester) async {
    await pump(
      tester,
      signedIn: false,
      engine: const UnavailableLocalTixEngine(),
    );
    expect(text(tester, 'about.engine'), 'Not in this build');
    expect(text(tester, 'about.server'), 'Not connected');
    expect(find.byKey(const Key('about.withServer')), findsNothing);
  });

  testWidgets('report a bug opens the prefilled form', (tester) async {
    await pump(tester);
    await tap(tester, 'about.bug');
    final uri = links.links.single;
    expect(uri.host, 'github.com');
    expect(uri.path, '/heliopsy/tix-mobile/issues/new');
    expect(uri.queryParameters['template'], 'bug_report.yml');
    expect(uri.queryParameters['platform'], 'Linux');
    expect(uri.queryParameters['app-version'], '0.4.0 (12)');
    expect(uri.queryParameters['server-version'], 'v1.2.3');
    expect(uri.queryParameters['logs'], contains('Engine: in-memory'));
  });

  testWidgets('diagnostics keep the server private until asked, and never '
      'carry a token', (tester) async {
    await pump(tester);
    await tap(tester, 'about.copy');
    expect(copied.single, contains('tix-mobile 0.4.0 (12)'));
    expect(copied.single, isNot(contains('tix.example')));
    expect(find.text('Diagnostics copied.'), findsOneWidget);

    await tap(tester, 'about.withServer');
    await tap(tester, 'about.copy');
    expect(copied.last, contains('Server address: https://tix.example'));

    await tap(tester, 'about.bug');
    for (final out in [...copied, links.links.single.toString()]) {
      expect(out, isNot(contains(_token)));
      expect(out, isNot(contains('token')));
    }
  });

  testWidgets('the Licences entry opens the licence page', (tester) async {
    await pump(tester);
    await tap(tester, 'about.licences');
    expect(find.byType(LicensePage), findsOneWidget);
  });

  for (final locale in textLocales) {
    for (final MapEntry(key: width, value: size) in widths.entries) {
      testWidgets('$width, $locale: fits at twice the text size', (
        tester,
      ) async {
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await pump(tester, size: size, locale: locale);
        await tap(tester, 'about.licences');
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('the connection details open from About', (tester) async {
    await pump(tester);
    await tap(tester, 'about.connection');
    expect(find.byKey(const Key('live.details')), findsOneWidget);
    expect(find.text('https://tix.example'), findsOneWidget);
  });

  testWidgets('no connection details while signed out', (tester) async {
    await pump(tester, signedIn: false);
    await tester.scrollUntilVisible(
      find.byKey(const Key('about.licences')),
      200,
      scrollable: find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          )
          .first,
    );
    expect(find.byKey(const Key('about.connection')), findsNothing);
  });

  testWidgets('an available update shows where updates are on', (tester) async {
    await pump(tester, updates: UpdateMode.notify, size: const Size(500, 3000));
    expect(find.byKey(const Key('about.updates')), findsOneWidget);
    expect(find.text('Update available: tix 0.5.0'), findsOneWidget);
  });

  testWidgets('no Updates section where updates are off', (tester) async {
    await pump(tester, size: const Size(500, 3000));
    expect(find.byKey(const Key('about.updates')), findsNothing);
  });
}
