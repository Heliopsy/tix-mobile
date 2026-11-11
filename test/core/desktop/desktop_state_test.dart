// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/desktop/desktop_state.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/platform/desktop.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/storage/providers.dart';
import 'package:tix_mobile/src/core/update/updates.dart';

import '../../helpers/app.dart';
import '../../helpers/container.dart';
import '../../helpers/fake_desktop.dart';
import '../../helpers/fake_tix.dart';
import '../../helpers/fixed_updates.dart';
import '../../helpers/stores.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));

  group('trayMenu', () {
    test('nothing unread: plain labels, no badge', () {
      final menu = trayMenu(en, unread: 0, context: 'Work · Acme');
      expect(menu.labels, {
        TrayAction.open: 'Open tix',
        TrayAction.quickAdd: 'Quick add',
        TrayAction.inbox: 'Inbox',
        TrayAction.quit: 'Quit tix',
      });
      expect(menu.context, 'Work · Acme');
      expect(menu.badge, isNull);
    });

    test('unread items show in the inbox entry and badge', () {
      final menu = trayMenu(en, unread: 3);
      expect(menu.labels[TrayAction.inbox], 'Inbox (3 unread)');
      expect(menu.badge, '3');
      expect(menu.context, isNull);
    });

    test('Activity follows Inbox when it is offered', () {
      final menu = trayMenu(en, activity: true);
      expect(menu.labels.keys, [
        TrayAction.open,
        TrayAction.quickAdd,
        TrayAction.inbox,
        TrayAction.activity,
        TrayAction.quit,
      ]);
      expect(menu.labels[TrayAction.activity], 'Activity');
    });

    test('the badge stops at 99+', () {
      expect(trayMenu(en, unread: 120).badge, '99+');
      expect(trayMenu(en, unread: 99).badge, '99');
    });

    test('no count yet reads as nothing unread', () {
      expect(trayMenu(en), trayMenu(en, unread: 0));
    });

    test('an update entry sits before Quit', () {
      final menu = trayMenu(en, update: 'Update available (0.12.0)');
      expect(menu.labels.keys, [
        TrayAction.open,
        TrayAction.quickAdd,
        TrayAction.inbox,
        TrayAction.update,
        TrayAction.quit,
      ]);
      expect(menu, isNot(trayMenu(en)));
    });

    test('the update entry follows the update', () {
      expect(trayUpdateLabel(en, const UpdateState()), isNull);
      expect(
        trayUpdateLabel(en, const UpdateState(phase: UpdatePhase.current)),
        isNull,
      );
      expect(
        trayUpdateLabel(
          en,
          UpdateState(phase: UpdatePhase.available, offer: offerOf('0.12.0')),
        ),
        'Update available (0.12.0)',
      );
      expect(
        trayUpdateLabel(en, readyState('0.12.0')),
        'Restart to update (0.12.0)',
      );
    });

    test('menus compare by content', () {
      expect(trayMenu(en, unread: 2), trayMenu(en, unread: 2));
      expect(trayMenu(en, unread: 2), isNot(trayMenu(en, unread: 3)));
      expect(
        trayMenu(en, unread: 2).hashCode,
        trayMenu(en, unread: 2).hashCode,
      );
    });
  });

  test('the hotkey is written the platform way', () {
    expect(quickAddHotkeyLabel(TargetPlatform.macOS), '⌃⇧Space');
    expect(quickAddHotkeyLabel(TargetPlatform.linux), 'Ctrl+Shift+Space');
    expect(quickAddHotkeyLabel(TargetPlatform.windows), 'Ctrl+Shift+Space');
  });

  group('trayContextLabel', () {
    test('null signed out', () => expect(trayContextLabel(null), isNull));

    test('instance then tenant', () async {
      final server = FakeTix();
      final stores = signInStores(server);
      final c = makeContainer(
        fakeOverrides(
          server,
          settings: stores.settings,
          secrets: stores.secrets,
        ),
      );
      final session = await c.read(sessionControllerProvider.future);
      final label = trayContextLabel(session);
      expect(label, startsWith('Work · '));
      expect(label, endsWith(session!.connection.tenantLabel));
    });
  });

  group('settings', () {
    late MemoryKeyValueStore store;
    late FakeDesktop desktop;

    setUp(() {
      store = MemoryKeyValueStore();
      desktop = FakeDesktop();
    });

    Future<ProviderContainer> container() async {
      final c = makeContainer([
        keyValueStoreProvider.overrideWithValue(store),
        desktopShellProvider.overrideWithValue(desktop),
      ]);
      await c.read(desktopCapsProvider.future);
      return c;
    }

    test('close to tray is on by default where a tray shows', () async {
      final c = await container();
      expect(c.read(closeToTraySettingProvider), isTrue);
    });

    test('close to tray is off without a tray, whatever was stored', () async {
      desktop.caps = const DesktopCaps(autostart: true);
      store.values['settings.closeToTray'] = 'true';
      final c = await container();
      expect(c.read(closeToTraySettingProvider), isFalse);
    });

    test('turning close to tray off is remembered', () async {
      final c = await container();
      await c.read(closeToTraySettingProvider.notifier).set(on: false);
      expect(c.read(closeToTraySettingProvider), isFalse);
      expect(store.values['settings.closeToTray'], 'false');
      final again = await container();
      expect(again.read(closeToTraySettingProvider), isFalse);
    });

    test('start at login reads the platform first', () async {
      desktop.autostartAnswer = true;
      final c = await container();
      expect(await c.read(autostartSettingProvider.future), isTrue);
    });

    test('start at login falls back to the stored choice', () async {
      desktop.autostartAnswer = null;
      store.values['settings.autostart'] = 'true';
      final c = await container();
      expect(await c.read(autostartSettingProvider.future), isTrue);
    });

    test('start at login is off where it is not offered', () async {
      desktop
        ..caps = const DesktopCaps(tray: true)
        ..autostartAnswer = true;
      final c = await container();
      expect(await c.read(autostartSettingProvider.future), isFalse);
    });

    test('turning start at login on asks the platform and keeps it', () async {
      final c = await container();
      await c.read(autostartSettingProvider.future);
      final ok = await c.read(autostartSettingProvider.notifier).set(on: true);
      expect(ok, isTrue);
      expect(desktop.autostarts, [true]);
      expect(c.read(autostartSettingProvider).value, isTrue);
      expect(store.values['settings.autostart'], 'true');
    });

    test('a refused start at login changes nothing', () async {
      desktop.accept = false;
      final c = await container();
      await c.read(autostartSettingProvider.future);
      final ok = await c.read(autostartSettingProvider.notifier).set(on: true);
      expect(ok, isFalse);
      expect(c.read(autostartSettingProvider).value, isFalse);
      expect(store.values, isNot(contains('settings.autostart')));
    });

    test('the hotkey registers and is remembered', () async {
      final c = await container();
      final ok = await c
          .read(quickAddHotkeySettingProvider.notifier)
          .set(on: true);
      expect(ok, isTrue);
      expect(desktop.hotkeys, [true]);
      expect(c.read(quickAddHotkeySettingProvider), isTrue);
      expect(store.values['settings.quickAddHotkey'], 'true');
    });

    test('a taken hotkey stays off', () async {
      desktop.accept = false;
      final c = await container();
      final ok = await c
          .read(quickAddHotkeySettingProvider.notifier)
          .set(on: true);
      expect(ok, isFalse);
      expect(c.read(quickAddHotkeySettingProvider), isFalse);
      expect(store.values, isNot(contains('settings.quickAddHotkey')));
    });

    test('the tray count is nothing until main supplies one', () async {
      final c = await container();
      expect(c.read(trayUnreadProvider), isNull);
    });
  });
}
