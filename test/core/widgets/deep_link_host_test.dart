// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/platform/deep_links.dart';
import 'package:tix_mobile/src/core/platform/sso_pending.dart';
import 'package:tix_mobile/src/core/quick/quick_add.dart';
import 'package:tix_mobile/src/core/widgets/deep_link_host.dart';
import 'package:tix_mobile/src/data/models/sso.dart';

import '../../helpers/app.dart';
import '../../helpers/fake_tix.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('tix/links-host-test');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  String? pending;

  setUp(() {
    pending = null;
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method != 'take') return null;
      final p = pending;
      pending = null;
      return p;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
  });

  Future<void> open(
    WidgetTester tester,
    String link, {
    PendingSso? kept,
  }) async {
    pending = link;
    final stores = signedInStores();
    if (kept != null) {
      stores.secrets.values[PendingSsoStore.key] = jsonEncode(kept.toJson());
    }
    await pumpScreen(
      tester,
      const DeepLinkHost(child: Scaffold(body: Text('home'))),
      settle: false,
      overrides: [
        ...fakeOverrides(
          FakeTix(),
          settings: stores.settings,
          secrets: stores.secrets,
        ),
        deepLinkIntakeProvider.overrideWith((ref) {
          final intake = DeepLinkIntake(channel);
          ref.onDispose(intake.dispose);
          return intake;
        }),
      ],
    );
    await tester.pumpAndSettle();
  }

  const routes = {
    'tix://inbox': 'route:/inbox',
    'tix://projects': 'route:/projects',
    'tix://projects/OPS': 'route:/projects/OPS',
    'tix://projects/OPS/tasks/OPS-12': 'route:/projects/OPS/tasks/OPS-12',
    'tix://settings': 'route:/settings',
    'tix://about': 'route:/settings/about',
    'tix://tasks': 'route:/tasks',
    'tix://tasks?filter=f7': 'route:/tasks?filter=f7',
  };
  for (final MapEntry(key: link, value: shown) in routes.entries) {
    testWidgets('$link opens its screen', (tester) async {
      await open(tester, link);
      expect(find.text(shown), findsOneWidget);
      expect(find.text('Link not recognised'), findsNothing);
    });
  }

  testWidgets('tix://quick-add asks for quick add in the named project', (
    tester,
  ) async {
    await open(tester, 'tix://quick-add?project=OPS');
    final container = ProviderScope.containerOf(
      tester.element(find.text('home')),
    );
    final draft = container.read(quickAddDraftsProvider);
    expect(draft, isNotNull);
    expect(draft!.project, 'OPS');
    expect(draft.text, isEmpty);
    expect(find.text('Link not recognised'), findsNothing);
  });

  PendingSso kept({String? instanceId, String? replacing}) => PendingSso(
    attempt: const SsoAttempt(
      baseUrl: 'https://tix.example',
      provider: 'acme',
      verifier: 'v',
      state: 's',
    ),
    startedAt: fixedNow,
    instanceId: instanceId,
    replacing: replacing,
  );

  const redirect = 'red.tix.mobile:/sso?code=c&state=s';

  testWidgets('a sign-in redirect that restarted the app opens the connect '
      'screen it started from', (tester) async {
    await open(tester, redirect, kept: kept(replacing: 'c1'));
    expect(find.text('route:/connect?connection=c1'), findsOneWidget);
    expect(find.text('Link not recognised'), findsNothing);
  });

  testWidgets('one for a new connection opens adding to its instance', (
    tester,
  ) async {
    await open(tester, redirect, kept: kept(instanceId: 'i1'));
    expect(find.text('route:/connect?instance=i1'), findsOneWidget);
  });

  testWidgets('one with nothing kept opens adding a server', (tester) async {
    await open(tester, redirect);
    expect(find.text('route:/connect?add=1'), findsOneWidget);
  });

  testWidgets('an unknown link says so and goes home', (tester) async {
    await open(tester, 'tix://nowhere/at/all');
    expect(find.text('route:/projects'), findsOneWidget);
    expect(find.text('Link not recognised'), findsOneWidget);
  });

  testWidgets('a link naming no saved context says so and goes home', (
    tester,
  ) async {
    await open(tester, 'tix://inbox?context=nowhere');
    expect(find.text('route:/projects'), findsOneWidget);
    expect(find.text('Link not recognised'), findsOneWidget);
  });
}
