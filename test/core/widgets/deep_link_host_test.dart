// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/platform/deep_links.dart';
import 'package:tix_mobile/src/core/widgets/deep_link_host.dart';

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

  Future<void> open(WidgetTester tester, String link) async {
    pending = link;
    final stores = signedInStores();
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
  };
  for (final MapEntry(key: link, value: shown) in routes.entries) {
    testWidgets('$link opens its screen', (tester) async {
      await open(tester, link);
      expect(find.text(shown), findsOneWidget);
      expect(find.text('Link not recognised'), findsNothing);
    });
  }

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
