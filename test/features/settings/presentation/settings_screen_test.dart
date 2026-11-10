// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/desktop/desktop_state.dart';
import 'package:tix_mobile/src/core/platform/adb_bridge.dart';
import 'package:tix_mobile/src/core/platform/desktop.dart';
import 'package:tix_mobile/src/core/platform/widget_bridge.dart';
import 'package:tix_mobile/src/core/router/routes.dart';
import 'package:tix_mobile/src/core/session/local.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/update/updates.dart';
import 'package:tix_mobile/src/core/widgets/tix_mark.dart';
import 'package:tix_mobile/src/data/cache/cache_store.dart';
import 'package:tix_mobile/src/data/offline/sync_store.dart';
import 'package:tix_mobile/src/features/settings/application/settings.dart';
import 'package:tix_mobile/src/features/settings/presentation/settings_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/design.dart';
import '../../../helpers/fake_desktop.dart';
import '../../../helpers/fake_tix.dart';
import '../../../helpers/fake_widgets.dart';
import '../../../helpers/fixed_updates.dart';
import '../../../helpers/stores.dart';

void main() {
  late ({MemoryKeyValueStore settings, MemorySecretStore secrets}) stores;
  late FakeTix server;

  Future<ProviderContainer> pump(
    WidgetTester tester, {
    Size size = const Size(500, 4000),
    Locale locale = const Locale('en'),
    FakeTix? tix,
    String query = '',
    bool local = false,
    FakeWidgetBridge? widgets,
    CacheStore? cache,
    bool adb = false,
    FakeDesktop? desktop,
    UpdateMode updates = UpdateMode.off,
    FixedUpdates? updater,
  }) async {
    server = tix ?? FakeTix();
    final s = signedInStores();
    s.settings.values['contexts'] = jsonEncode([
      {
        'id': 'c1',
        'name': 'Work',
        'base_url': 'https://tix.example',
        'handle': 'ana',
      },
      {'id': 'c2', 'name': 'Home', 'base_url': 'https://home.example'},
    ]);
    s.secrets.values['token.c2'] = 'tok';
    stores = (settings: s.settings, secrets: s.secrets);
    final c = await pumpScreen(
      tester,
      SettingsScreen(initialQuery: query),
      size: size,
      locale: locale,
      overrides: [
        ...fakeOverrides(
          server,
          settings: s.settings,
          secrets: s.secrets,
          local: local,
          widgets: widgets,
          cache: cache,
          updates: updates,
        ),
        fixedUpdates(updater ?? FixedUpdates(const UpdateState())),
        adbControlOfferedProvider.overrideWithValue(adb),
        desktopShellProvider.overrideWithValue(
          desktop ?? FakeDesktop(caps: DesktopCaps.none),
        ),
      ],
    );
    // The date settings are read in the background; let that request land
    // even when its answer changes nothing on screen.
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    return c;
  }

  group('updates', () {
    Finder section() => find.byKey(const Key('settings.section.updates'));

    testWidgets('no Updates section where updates are off', (tester) async {
      await pump(tester);
      expect(section(), findsNothing);
      expect(find.byKey(const Key('update.status')), findsNothing);
    });

    testWidgets('a self-installing build offers all three', (tester) async {
      final updater = FixedUpdates(const UpdateState());
      final c = await pump(
        tester,
        updates: UpdateMode.install,
        updater: updater,
      );
      expect(section(), findsOneWidget);
      expect(find.text('Check for updates'), findsOneWidget);
      expect(find.text('Install updates automatically'), findsOneWidget);
      expect(c.read(updateCheckSettingProvider), isTrue);
      expect(c.read(autoInstallSettingProvider), isFalse);

      await tester.tap(find.byKey(const Key('settings.updateAuto')));
      await tester.pumpAndSettle();
      expect(c.read(autoInstallSettingProvider), isTrue);
      expect(stores.settings.values['settings.updateAutoInstall'], 'true');

      await tester.tap(find.byKey(const Key('settings.updateCheck')));
      await tester.pumpAndSettle();
      expect(c.read(updateCheckSettingProvider), isFalse);
      expect(stores.settings.values['settings.updateCheck'], 'off');

      await tester.tap(find.byKey(const Key('update.check')));
      await tester.pumpAndSettle();
      expect(updater.checks, 1);
    });

    testWidgets('a build that only notifies has no install switch', (
      tester,
    ) async {
      await pump(tester, updates: UpdateMode.notify);
      expect(section(), findsOneWidget);
      expect(find.text('Check for updates'), findsOneWidget);
      expect(find.byKey(const Key('settings.updateAuto')), findsNothing);
    });

    testWidgets('search finds the update settings', (tester) async {
      await pump(tester, updates: UpdateMode.install, query: 'automatically');
      expect(find.byKey(const Key('settings.updateAuto')), findsOneWidget);
      expect(find.byKey(const Key('settings.updateCheck')), findsNothing);
    });
  });

  group('desktop', () {
    Finder section() => find.byKey(const Key('settings.section.desktop'));

    testWidgets('no Desktop section off the desktop', (tester) async {
      await pump(tester);
      expect(section(), findsNothing);
      expect(find.byKey(const Key('settings.closeToTray')), findsNothing);
    });

    testWidgets('close to tray is on and is turned off and kept', (
      tester,
    ) async {
      final c = await pump(tester, desktop: FakeDesktop());
      expect(section(), findsOneWidget);
      expect(find.text('Keep running in the tray'), findsOneWidget);
      expect(c.read(closeToTraySettingProvider), isTrue);
      await tester.tap(find.byKey(const Key('settings.closeToTray')));
      await tester.pumpAndSettle();
      expect(c.read(closeToTraySettingProvider), isFalse);
      expect(stores.settings.values['settings.closeToTray'], 'false');
    });

    testWidgets('without a tray close to tray is off and says why', (
      tester,
    ) async {
      final c = await pump(
        tester,
        desktop: FakeDesktop(caps: const DesktopCaps(autostart: true)),
      );
      expect(
        find.text(
          'This desktop shows no tray icons, so closing the window quits '
          'tix.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('settings.closeToTray')));
      await tester.pumpAndSettle();
      expect(c.read(closeToTraySettingProvider), isFalse);
      expect(stores.settings.values, isNot(contains('settings.closeToTray')));
    });

    testWidgets('start at login is turned on through the platform', (
      tester,
    ) async {
      final desktop = FakeDesktop();
      await pump(tester, desktop: desktop);
      await tester.tap(find.byKey(const Key('settings.autostart')));
      await tester.pumpAndSettle();
      expect(desktop.autostarts, [true]);
      expect(stores.settings.values['settings.autostart'], 'true');
    });

    testWidgets('a refused start at login says so', (tester) async {
      final desktop = FakeDesktop()..accept = false;
      final c = await pump(tester, desktop: desktop);
      await tester.tap(find.byKey(const Key('settings.autostart')));
      await tester.pumpAndSettle();
      expect(find.text('Could not change start at login'), findsOneWidget);
      expect(c.read(autostartSettingProvider).value, isFalse);
    });

    testWidgets('the hotkey names its keys and is turned on', (tester) async {
      final desktop = FakeDesktop();
      final c = await pump(tester, desktop: desktop);
      expect(
        find.text(
          'Ctrl+Shift+Space opens quick add, even while tix is in the '
          'background.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('settings.hotkey')));
      await tester.pumpAndSettle();
      expect(desktop.hotkeys, [true]);
      expect(c.read(quickAddHotkeySettingProvider), isTrue);
    });

    testWidgets('a taken hotkey says so and stays off', (tester) async {
      final desktop = FakeDesktop()..accept = false;
      final c = await pump(tester, desktop: desktop);
      await tester.tap(find.byKey(const Key('settings.hotkey')));
      await tester.pumpAndSettle();
      expect(
        find.text('Ctrl+Shift+Space is taken by another app'),
        findsOneWidget,
      );
      expect(c.read(quickAddHotkeySettingProvider), isFalse);
    });

    testWidgets('no hotkey or login switch where the desktop has none', (
      tester,
    ) async {
      await pump(
        tester,
        desktop: FakeDesktop(caps: const DesktopCaps(tray: true)),
      );
      expect(section(), findsOneWidget);
      expect(find.byKey(const Key('settings.hotkey')), findsNothing);
      expect(find.byKey(const Key('settings.autostart')), findsNothing);
    });
  });

  testWidgets('ADB control is offered only where there is ADB', (tester) async {
    await pump(tester);
    expect(find.byKey(const Key('settings.section.advanced')), findsNothing);
  });

  testWidgets('ADB control is off until turned on, and kept', (tester) async {
    final c = await pump(tester, adb: true);
    expect(find.byKey(const Key('settings.section.advanced')), findsOneWidget);
    expect(find.text('Allow control over ADB'), findsOneWidget);
    expect(c.read(adbControlSettingProvider), isFalse);
    await tester.tap(find.byKey(const Key('settings.adbControl')));
    await tester.pumpAndSettle();
    expect(c.read(adbControlSettingProvider), isTrue);
    expect(stores.settings.values[AdbControlSetting.key], 'true');
  });

  testWidgets('the idle timeout of local engines is chosen and kept', (
    tester,
  ) async {
    final c = await pump(tester, local: true);
    final idle = find.byKey(const Key('settings.localIdle'));
    expect(tester.widget<SegmentedButton<int>>(idle).selected, {10});
    expect(
      find.descendant(
        of: find.byKey(const Key('settings.section.localEngine')),
        matching: find.text('On this device'),
      ),
      findsOneWidget,
    );
    await tester.ensureVisible(idle);
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: idle, matching: find.text('Never')));
    await tester.pumpAndSettle();
    expect(c.read(localIdleTimeoutProvider), isNull);
    expect(stores.settings.values['settings.local_idle_minutes'], '0');
    await tester.tap(find.descendant(of: idle, matching: find.text('30 min')));
    await tester.pumpAndSettle();
    expect(c.read(localEnginesProvider).idleAfter, const Duration(minutes: 30));
  });

  testWidgets('without local databases there is no idle timeout', (
    tester,
  ) async {
    await pump(tester);
    expect(find.byKey(const Key('settings.localIdle')), findsNothing);
  });

  testWidgets('widgets keep the lock screen to counts until turned off', (
    tester,
  ) async {
    final c = await pump(tester, widgets: FakeWidgetBridge());
    final toggle = find.byKey(const Key('settings.widgetLockCounts'));
    expect(
      find.descendant(
        of: find.byKey(const Key('settings.section.widgets')),
        matching: find.text('On this device'),
      ),
      findsOneWidget,
    );
    expect(c.read(widgetLockCountsSettingProvider), isTrue);
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(c.read(widgetLockCountsSettingProvider), isFalse);
    expect(stores.settings.values['settings.widgetLockCounts'], 'false');
    expect(c.read(widgetsStaleProvider), 1);
  });

  testWidgets('no widgets section where the platform has none', (tester) async {
    await pump(tester);
    expect(find.byKey(const Key('settings.section.widgets')), findsNothing);
  });

  testWidgets('theme and language are chosen and remembered', (tester) async {
    final c = await pump(tester);
    await tester.tap(find.text('Dark'));
    await tester.tap(find.text('Български'));
    await tester.pumpAndSettle();
    expect(c.read(themeSettingProvider), ThemeChoice.dark);
    expect(c.read(localeSettingProvider), const Locale('bg'));
    expect(stores.settings.values['settings.theme'], 'dark');
    expect(stores.settings.values['settings.locale'], 'bg');
    await tester.tap(find.text('System').last);
    await tester.pumpAndSettle();
    expect(c.read(localeSettingProvider), isNull);
  });

  testWidgets('OLED black is a theme, and the system can go black', (
    tester,
  ) async {
    final c = await pump(tester);
    final toggle = find.byKey(const Key('settings.systemBlack'));
    expect(toggle, findsOneWidget);
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(c.read(systemBlackSettingProvider), isTrue);
    expect(stores.settings.values['settings.systemBlack'], 'true');

    await tester.tap(find.text('OLED black'));
    await tester.pumpAndSettle();
    expect(c.read(themeSettingProvider), ThemeChoice.oled);
    expect(stores.settings.values['settings.theme'], 'oled');
    expect(toggle, findsNothing);
  });

  testWidgets('instances shows the active context and opens the list', (
    tester,
  ) async {
    await pump(tester);
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const Key('settings.instances')),
        matching: find.text('2 instances · Work · Default'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('settings.instances')));
    await tester.pumpAndSettle();
    expect(find.text('route:/settings/instances'), findsOneWidget);
  });

  testWidgets('offline opens the Offline screen', (tester) async {
    await pump(tester);
    await tester.dragUntilVisible(
      find.byKey(const Key('settings.offline.open')),
      find.byType(ListView).first,
      const Offset(0, -200),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings.offline.open')));
    await tester.pumpAndSettle();
    expect(find.text('route:/settings/offline'), findsOneWidget);
  });

  testWidgets('add an instance goes to connect', (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(const Key('settings.add')));
    await tester.pumpAndSettle();
    expect(find.text('route:/connect?add=1'), findsOneWidget);
  });

  testWidgets('sign out asks first and forgets the token', (tester) async {
    final c = await pump(tester);
    expect(find.text('Signed in as @ana'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('settings.signOut')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings.signOut')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(stores.secrets.values.containsKey('token.c1'), isTrue);

    await tester.ensureVisible(find.byKey(const Key('settings.signOut')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings.signOut')));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('forgets this connection to Work'),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('confirm.ok')));
    await tester.pumpAndSettle();
    expect(stores.secrets.values.containsKey('token.c1'), isFalse);
    expect(c.read(sessionControllerProvider).value!.connection.id, 'c2');
    expect(find.textContaining('1 instance · Home'), findsOneWidget);
  });

  testWidgets('sign out warns about changes not sent yet', (tester) async {
    final cache = MemoryCacheStore();
    final at = DateTime.utc(2026, 11, 9);
    await SyncStore(cache, const CacheScope('c1', '')).update(
      (s) => s.copyWith(
        entries: [
          for (var i = 0; i < 2; i++)
            OutboxEntry(
              id: 'e$i',
              seq: i + 1,
              op: OutboxOp.comment,
              target: 'infra-1',
              idempotencyKey: 'k$i',
              createdAt: at,
            ),
        ],
      ),
    );
    await pump(tester, cache: cache);
    await tester.ensureVisible(find.byKey(const Key('settings.signOut')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings.signOut')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.textContaining(
          '2 changes made offline have not been sent yet and will be lost.',
        ),
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(stores.secrets.values.containsKey('token.c1'), isTrue);
  });

  testWidgets('about opens the About screen', (tester) async {
    await pump(tester);
    final about = find.byKey(const Key('settings.about.app'));
    await tester.scrollUntilVisible(
      about,
      100,
      scrollable: find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          )
          .first,
    );
    expect(
      find.descendant(of: about, matching: find.byType(TixMark)),
      findsOneWidget,
    );
    await tester.ensureVisible(about);
    await tester.pumpAndSettle();
    await tester.tap(about);
    await tester.pumpAndSettle();
    expect(find.text('route:/settings/about'), findsOneWidget);
  });

  testWidgets('every language is offered in its own name', (tester) async {
    await pump(tester);
    for (final name in ['English', 'Български', 'Français', 'Deutsch']) {
      expect(find.text(name), findsOneWidget);
    }
    await tester.tap(find.text('Deutsch'));
    await tester.pumpAndSettle();
    expect(stores.settings.values['settings.locale'], 'de');
  });

  FakeTix timeServer() => FakeTix()
    ..keepsTime = true
    ..timeGlobal['time_format'] = 'iso'
    ..timeTenant['timezone'] = 'Europe/Sofia';

  Finder inSection(String section, Finder matching) => find.descendant(
    of: find.byKey(Key('settings.section.$section')),
    matching: matching,
  );

  testWidgets('settings are grouped by where they are kept, each labelled', (
    tester,
  ) async {
    server = FakeTix()..identity = {'role': 'member'};
    await pump(tester, tix: server);
    expect(find.byKey(const Key('settings.group.device')), findsOneWidget);
    expect(find.byKey(const Key('settings.group.account')), findsOneWidget);
    expect(find.byKey(const Key('settings.group.tenant')), findsNothing);
    expect(
      inSection('appearance', find.text('On this device')),
      findsOneWidget,
    );
    expect(
      inSection('dates', find.text('Synced to your account')),
      findsOneWidget,
    );
    expect(find.text('Whole tenant'), findsNothing);
  });

  testWidgets('an administrator sees the tenant and reaches Manage', (
    tester,
  ) async {
    await pump(tester);
    expect(inSection('tenant', find.text('Whole tenant')), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('settings.tenant.manage')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings.tenant.manage')));
    await tester.pumpAndSettle();
    expect(find.text('route:/manage'), findsOneWidget);
  });

  testWidgets('account and tenant links sit in their groups', (tester) async {
    await pump(tester);
    for (final (section, key) in [
      ('profile', 'settings.profile.account'),
      ('security', 'settings.security.open'),
      ('security', 'settings.security.tokens'),
      ('calendar', 'settings.calendar.open'),
      ('tenant', 'settings.tenant.settings'),
      ('tenant', 'settings.tenant.webhooks'),
      ('tenant', 'settings.tenant.retention'),
    ]) {
      expect(
        inSection(section, find.byKey(Key(key))),
        findsOneWidget,
        reason: key,
      );
    }
    expect(
      inSection('security', find.text('Synced to your account')),
      findsOneWidget,
    );
  });

  testWidgets('a member gets no tokens and no tenant links', (tester) async {
    server = FakeTix()..identity = {'role': 'member'};
    await pump(tester, tix: server);
    expect(find.byKey(const Key('settings.calendar.open')), findsOneWidget);
    expect(find.byKey(const Key('settings.security.tokens')), findsNothing);
    expect(find.byKey(const Key('settings.tenant.settings')), findsNothing);
  });

  testWidgets('motion, touch feedback and the start screen stay here', (
    tester,
  ) async {
    final c = await pump(tester);
    await tester.tap(find.byKey(const Key('settings.reduceMotion')));
    await tester.tap(find.byKey(const Key('settings.haptics')));
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('settings.start')),
        matching: find.text('Inbox'),
      ),
    );
    await tester.pumpAndSettle();
    expect(c.read(reduceMotionSettingProvider), isTrue);
    expect(c.read(hapticsSettingProvider), isFalse);
    expect(c.read(startScreenSettingProvider), StartScreen.inbox);
    expect(stores.settings.values['settings.reduceMotion'], 'true');
    expect(stores.settings.values['settings.haptics'], 'off');
    expect(stores.settings.values['settings.start'], 'inbox');
  });

  testWidgets('the date format shows what is in force and where from', (
    tester,
  ) async {
    await pump(tester, tix: timeServer());
    await tester.pumpAndSettle();
    expect(
      inSection(
        'dates',
        find.text('In use: ISO (2026-09-21 17:05), from the server default'),
      ),
      findsOneWidget,
    );
    expect(
      inSection(
        'dates',
        find.textContaining('In use: Europe/Sofia, from the tenant default'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('settings.dateFormat')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dotted (21.09.2026 17:05)').last);
    await tester.pumpAndSettle();
    expect(server.requestsTo('/me/time').last.body, {'time_format': 'dotted'});
    expect(
      find.text('In use: Dotted (21.09.2026 17:05), from your choice'),
      findsOneWidget,
    );
    expect(find.text('Saved with your account'), findsOneWidget);

    await tester.tap(find.byKey(const Key('settings.dateFormat')));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Inherit: ISO').last);
    await tester.pumpAndSettle();
    expect(server.timeUser['time_format'], '');
  });

  testWidgets('the time zone is picked from a searchable list', (tester) async {
    await pump(tester, tix: timeServer());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings.timeZone')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('settings.zoneSearch')), 'tok');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('zone.inherit')), findsNothing);
    await tester.tap(find.byKey(const Key('zone.Asia/Tokyo')));
    await tester.pumpAndSettle();
    expect(server.timeUser['timezone'], 'Asia/Tokyo');
    expect(
      find.textContaining('In use: Asia/Tokyo, from your choice'),
      findsOneWidget,
    );
  });

  testWidgets('a credential that is not a person reads the tenant', (
    tester,
  ) async {
    await pump(tester, tix: timeServer()..timePersonal = false);
    await tester.pumpAndSettle();
    expect(find.textContaining('is not a person'), findsOneWidget);
    expect(find.byKey(const Key('settings.dateFormat')), findsNothing);
    await tester.tap(find.byKey(const Key('settings.timeZone')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('settings.zoneSearch')), findsNothing);
  });

  testWidgets('a server without date preferences says dates follow here', (
    tester,
  ) async {
    await pump(tester);
    expect(find.byKey(const Key('settings.datesUnsupported')), findsOneWidget);
    expect(find.textContaining('This version of tix'), findsOneWidget);
    expect(find.byKey(const Key('settings.datesRetry')), findsNothing);
    expect(find.byKey(const Key('settings.datesLoading')), findsNothing);
    expect(find.byKey(const Key('settings.timeZone')), findsNothing);
  });

  testWidgets('date settings still on their way show a spinner', (
    tester,
  ) async {
    final tix = timeServer();
    final s = signedInStores();
    final gate = Completer<void>();
    tix.gate = gate;
    await pumpScreen(
      tester,
      const SettingsScreen(),
      size: const Size(500, 4000),
      settle: false,
      overrides: fakeOverrides(tix, settings: s.settings, secrets: s.secrets),
    );
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byKey(const Key('settings.datesLoading')), findsOneWidget);
    expect(find.byKey(const Key('settings.datesRetry')), findsNothing);
    expect(find.byKey(const Key('settings.datesUnsupported')), findsNothing);
    tix.gate = null;
    gate.complete();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('settings.datesLoading')), findsNothing);
    expect(find.byKey(const Key('settings.dateFormat')), findsOneWidget);
  });

  testWidgets('date settings that failed to load offer a retry', (
    tester,
  ) async {
    final tix = timeServer();
    tix.failing['/api/v1/me/time'] = FakeResponse(
      500,
      envelope('internal', 'down'),
    );
    await pump(tester, tix: tix);
    expect(find.byKey(const Key('settings.datesFailed')), findsOneWidget);
    expect(find.byKey(const Key('settings.datesUnsupported')), findsNothing);
    tix.failing.remove('/api/v1/me/time');
    await tester.tap(find.byKey(const Key('settings.datesRetry')));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('settings.datesFailed')), findsNothing);
    expect(find.byKey(const Key('settings.dateFormat')), findsOneWidget);
  });

  testWidgets('resetting the arrangement asks, then resets three views', (
    tester,
  ) async {
    await pump(tester);
    final reset = find.byKey(const Key('settings.resetArrangement'));
    await tester.tap(reset);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(server.requests.where((r) => r.method == 'DELETE'), isEmpty);

    await tester.tap(reset);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm.ok')));
    await tester.pumpAndSettle();
    expect(
      [
        for (final r in server.requests)
          if (r.method == 'DELETE') r.uri.path,
      ],
      unorderedEquals([
        '/api/v1/views/board/groups',
        '/api/v1/views/lanes/groups',
        '/api/v1/views/mine/groups',
      ]),
    );
    expect(find.text('Arrangement reset'), findsOneWidget);
  });

  testWidgets('search filters every setting and keeps its label', (
    tester,
  ) async {
    await pump(tester, tix: timeServer());
    await tester.enterText(find.byKey(const Key('settings.search')), 'zone');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('settings.timeZone')), findsOneWidget);
    expect(find.byKey(const Key('settings.theme')), findsNothing);
    expect(find.byKey(const Key('settings.group.device')), findsNothing);
    expect(
      inSection('dates', find.text('Synced to your account')),
      findsOneWidget,
    );

    await tester.enterText(find.byKey(const Key('settings.search')), 'motion');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('settings.reduceMotion')), findsOneWidget);
    expect(find.byKey(const Key('settings.timeZone')), findsNothing);

    await tester.enterText(find.byKey(const Key('settings.search')), 'qqq');
    await tester.pumpAndSettle();
    expect(find.text('No setting matches “qqq”'), findsOneWidget);
  });

  testWidgets('the palette opens a setting filtered or on its screen', (
    tester,
  ) async {
    await pump(tester, query: 'Touch feedback');
    expect(find.byKey(const Key('settings.haptics')), findsOneWidget);
    expect(find.byKey(const Key('settings.theme')), findsNothing);
  });

  testWidgets('saved filters and inbox open their screens', (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(const Key('settings.filters.open')));
    await tester.pumpAndSettle();
    expect(find.text('route:/settings/filters'), findsOneWidget);
  });

  for (final locale in textLocales) {
    for (final MapEntry(key: width, value: size) in widths.entries) {
      testWidgets('$width, $locale: fits at twice the text size', (
        tester,
      ) async {
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await pump(
          tester,
          size: size,
          locale: locale,
          tix: timeServer(),
          local: true,
          widgets: FakeWidgetBridge(),
          adb: true,
          desktop: FakeDesktop(),
          updates: UpdateMode.install,
        );
        await tester.pumpAndSettle();
        final list = find
            .byWidgetPredicate(
              (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
            )
            .first;
        for (final key in [
          for (final section in SettingsSection.values)
            'settings.section.${section.name}',
        ]) {
          await tester.scrollUntilVisible(
            find.byKey(Key(key)),
            300,
            scrollable: list,
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: key);
        }
      });
    }
  }
}
