// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/app.dart';
import 'package:tix_mobile/src/core/config/config.dart';
import 'package:tix_mobile/src/core/platform/app_info.dart';
import 'package:tix_mobile/src/features/about/presentation/about_screen.dart';
import 'package:tix_mobile/src/features/inbox/presentation/inbox_screen.dart';
import 'package:tix_mobile/src/features/settings/presentation/settings_screen.dart';
import 'package:tix_mobile/src/features/tasks/presentation/task_detail_screen.dart';

import 'helpers/app.dart';
import 'helpers/fake_tix.dart';
import 'helpers/stores.dart';

void main() {
  late FakeTix server;

  setUp(() => server = FakeTix());

  Future<void> pumpApp(
    WidgetTester tester, {
    Size size = phone,
    MemoryKeyValueStore? settings,
    MemorySecretStore? secrets,
    List<Override> extra = const [],
  }) async {
    await setSize(tester, size);
    await tester.pumpWidget(
      ProviderScope(
        retry: noRetry,
        overrides: [
          ...fakeOverrides(server, settings: settings, secrets: secrets),
          ...extra,
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('signed out, the app opens on connect and signs in', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(find.text('Connect to tix'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    await tester.enterText(find.byKey(const Key('connect.url')), 'tix.example');
    await tester.enterText(find.byKey(const Key('connect.token')), 'tok');
    await tester.ensureVisible(find.byKey(const Key('connect.submit')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('connect.submit')));
    await tester.pumpAndSettle();
    expect(find.text('Infrastructure'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('on a phone: projects, tasks, a task and back', (tester) async {
    final stores = signedInStores();
    await pumpApp(tester, settings: stores.settings, secrets: stores.secrets);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
    await tester.tap(find.text('Infrastructure'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('project.switch')), findsOneWidget);
    await tester.tap(find.text('Fix login'));
    await tester.pumpAndSettle();
    expect(find.byType(TaskDetailScreen), findsOneWidget);
    expect(find.text('Raj'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(TaskDetailScreen), findsNothing);
    expect(find.text('Rotate keys'), findsOneWidget);
  });

  testWidgets('on a desktop: a rail and the task beside the list', (
    tester,
  ) async {
    final stores = signedInStores();
    await pumpApp(
      tester,
      size: desktop,
      settings: stores.settings,
      secrets: stores.secrets,
    );
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(
      tester.widget<NavigationRail>(find.byType(NavigationRail)).extended,
      isTrue,
    );
    await tester.tap(find.text('Infrastructure'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rotate keys'));
    await tester.pumpAndSettle();
    expect(find.byType(TaskDetailScreen), findsNothing);
    expect(find.byType(TaskDetailView), findsOneWidget);
    expect(find.text('Fix login'), findsOneWidget);
    expect(find.text('No description.'), findsOneWidget);
  });

  testWidgets('settings switch the language and sign out to connect', (
    tester,
  ) async {
    final stores = signedInStores();
    await pumpApp(
      tester,
      size: const Size(700, 1000),
      settings: stores.settings,
      secrets: stores.secrets,
    );
    expect(find.byType(NavigationRail), findsOneWidget);
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Български'));
    await tester.pumpAndSettle();
    expect(find.text('Настройки'), findsWidgets);
    await tester.scrollUntilVisible(
      find.byKey(const Key('settings.signOut')),
      300,
      scrollable: find
          .descendant(
            of: find.byType(SettingsScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings.signOut')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm.ok')));
    await tester.pumpAndSettle();
    expect(find.text('Свързване с tix'), findsOneWidget);
    expect(stores.secrets.values, isEmpty);
  });

  testWidgets('the dark theme follows the setting', (tester) async {
    final stores = signedInStores();
    stores.settings.values['settings.theme'] = 'dark';
    await pumpApp(tester, settings: stores.settings, secrets: stores.secrets);
    final context = tester.element(find.text('Infrastructure'));
    expect(Theme.of(context).brightness, Brightness.dark);
  });

  testWidgets('tapping the current destination returns to its root', (
    tester,
  ) async {
    final stores = signedInStores();
    await pumpApp(tester, settings: stores.settings, secrets: stores.secrets);
    await tester.tap(find.text('Infrastructure'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('nav.more')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('nav.more.settings')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Projects'));
    await tester.pumpAndSettle();
    expect(find.text('Rotate keys'), findsOneWidget);
    await tester.tap(find.text('Projects').last);
    await tester.pumpAndSettle();
    expect(find.text('Infrastructure'), findsOneWidget);
  });

  group('About is one tap from the shell', () {
    final app = appInfoProvider.overrideWithValue(
      const AsyncData(
        AppInfo(
          version: '0.6.0',
          build: '1',
          platform: 'Linux',
          osVersion: 'test',
        ),
      ),
    );

    testWidgets('on a phone, last under More', (tester) async {
      final stores = signedInStores();
      await pumpApp(
        tester,
        settings: stores.settings,
        secrets: stores.secrets,
        extra: [app],
      );
      await tester.tap(find.byKey(const Key('nav.more')));
      await tester.pumpAndSettle();
      final about = find.byKey(const Key('nav.more.about'));
      expect(
        find.descendant(of: about, matching: find.text('About')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: about, matching: find.byIcon(Icons.info_outline)),
        findsOneWidget,
      );
      expect(
        tester.getTopLeft(about).dy,
        greaterThan(
          tester.getTopLeft(find.byKey(const Key('nav.more.settings'))).dy,
        ),
      );
      await tester.tap(about);
      await tester.pumpAndSettle();
      expect(find.byType(AboutScreen), findsOneWidget);
      expect(find.byKey(const Key('nav.more.about')), findsNothing);
    });

    for (final (name, size) in [
      ('on a tablet, at the foot of the rail', const Size(800, 1000)),
      ('on a desktop, at the foot of the rail', desktop),
    ]) {
      testWidgets(name, (tester) async {
        final stores = signedInStores();
        await pumpApp(
          tester,
          size: size,
          settings: stores.settings,
          secrets: stores.secrets,
          extra: [app],
        );
        final about = find.descendant(
          of: find.byType(NavigationRail),
          matching: find.byKey(const Key('shell.about')),
        );
        expect(about, findsOneWidget);
        await tester.tap(about);
        await tester.pumpAndSettle();
        expect(find.byType(AboutScreen), findsOneWidget);
      });
    }
  });

  testWidgets('the switcher sits above the bar and atop the rail', (
    tester,
  ) async {
    final stores = signedInStores();
    await pumpApp(tester, settings: stores.settings, secrets: stores.secrets);
    final open = find.byKey(const Key('switcher.open'));
    expect(open, findsOneWidget);
    expect(
      tester.getBottomLeft(open).dy,
      lessThanOrEqualTo(tester.getTopLeft(find.byType(NavigationBar)).dy),
    );
    expect(find.text('Work › Default'), findsOneWidget);
  });

  testWidgets('switching tenant from the switcher reloads the projects', (
    tester,
  ) async {
    server
      ..tenants['acme'] = (name: 'Acme', host: '')
      ..tenantProjects['acme'] = [
        {'id': 'p9', 'key': 'ops', 'name': 'Operations'},
      ];
    final stores = signInStores(server, tenants: ['default', 'acme']);
    await pumpApp(
      tester,
      size: desktop,
      settings: stores.settings,
      secrets: stores.secrets,
    );
    expect(
      find.descendant(
        of: find.byType(NavigationRail),
        matching: find.byKey(const Key('switcher.open')),
      ),
      findsOneWidget,
    );
    expect(find.text('Infrastructure'), findsOneWidget);
    await tester.tap(find.byKey(const Key('switcher.open')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('switcher.entry.s1.acme')));
    await tester.pumpAndSettle();
    expect(find.text('Operations'), findsOneWidget);
    expect(find.text('Infrastructure'), findsNothing);
  });

  testWidgets('an expired session offers to sign in again', (tester) async {
    final stores = signInStores(server);
    server.sessions.clear();
    await pumpApp(tester, settings: stores.settings, secrets: stores.secrets);
    await tester.tap(find.byKey(const Key('error.signInAgain')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('connect.password')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('connect.password')), 'pw');
    await tester.ensureVisible(find.byKey(const Key('connect.submit')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('connect.submit')));
    await tester.pumpAndSettle();
    expect(find.text('Infrastructure'), findsOneWidget);
    expect(stores.secrets.values.keys, ['session.s1']);
  });

  testWidgets('a token refused offers no sign-in', (tester) async {
    final stores = signedInStores(token: 'revoked');
    await pumpApp(tester, settings: stores.settings, secrets: stores.secrets);
    expect(find.textContaining('did not accept'), findsOneWidget);
    expect(find.byKey(const Key('error.signInAgain')), findsNothing);
  });

  testWidgets("dates follow the reader's server preference everywhere", (
    tester,
  ) async {
    server
      ..keepsTime = true
      ..timeTenant['time_format'] = 'dotted'
      ..timeUser['timezone'] = 'Europe/Sofia';
    final stores = signedInStores();
    await pumpApp(tester, settings: stores.settings, secrets: stores.secrets);
    await tester.tap(find.text('Infrastructure'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fix login'));
    await tester.pumpAndSettle();
    // Due 2026-11-20T00:00Z is 02:00 on the 20th in Sofia.
    expect(find.text('Fri 20.11.2026'), findsOneWidget);
  });

  testWidgets('the app opens on the start screen chosen here', (tester) async {
    final stores = signedInStores();
    stores.settings.values['settings.start'] = 'inbox';
    await pumpApp(tester, settings: stores.settings, secrets: stores.secrets);
    expect(find.byType(InboxScreen), findsOneWidget);
  });
}
