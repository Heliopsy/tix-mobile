// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/desktop/desktop_state.dart';
import 'package:tix_mobile/src/core/platform/deep_links.dart';
import 'package:tix_mobile/src/core/platform/desktop.dart';
import 'package:tix_mobile/src/core/widgets/desktop_host.dart';

import '../../helpers/app.dart';
import '../../helpers/fake_desktop.dart';
import '../../helpers/fake_notes.dart';
import '../../helpers/fake_tix.dart';

void main() {
  late FakeDesktop desktop;
  late FakeNotes notes;

  setUp(() {
    desktop = FakeDesktop();
    notes = FakeNotes();
  });

  Future<ProviderContainer> pump(
    WidgetTester tester, {
    bool signedIn = true,
    int? unread,
    Map<String, String> settings = const {},
  }) {
    final server = FakeTix();
    final stores = signInStores(server);
    if (!signedIn) stores.settings.values.remove('context.active');
    stores.settings.values.addAll(settings);
    return pumpScreen(
      tester,
      const DesktopHost(child: Scaffold(body: Text('home'))),
      overrides: [
        ...fakeOverrides(
          server,
          settings: stores.settings,
          secrets: stores.secrets,
          notes: notes,
        ),
        desktopShellProvider.overrideWithValue(desktop),
        trayUnreadProvider.overrideWithValue(unread),
      ],
    );
  }

  testWidgets('the tray carries the count and the context', (tester) async {
    await pump(tester, unread: 4);
    final menu = desktop.menus.last!;
    expect(menu.labels[TrayAction.inbox], 'Inbox (4 unread)');
    expect(menu.tooltip, 'tix: 4 unread');
    expect(menu.badge, '4');
    expect(menu.context, startsWith('Work · '));
    expect(desktop.closeToTray, [true]);
  });

  testWidgets('signed out the tray has no context and no count', (
    tester,
  ) async {
    await pump(tester, signedIn: false, unread: 4);
    final menu = desktop.menus.last!;
    expect(menu.context, isNull);
    expect(menu.labels[TrayAction.inbox], 'Inbox');
    expect(menu.badge, isNull);
  });

  testWidgets('without a tray there is no icon and close quits', (
    tester,
  ) async {
    desktop.caps = const DesktopCaps(autostart: true);
    await pump(tester);
    expect(desktop.menus, isEmpty);
    expect(desktop.closeToTray, isEmpty);
    desktop.emit(const CloseRequested());
    await tester.pumpAndSettle();
    expect(desktop.hides, 0);
  });

  testWidgets('on a phone nothing happens', (tester) async {
    desktop.caps = DesktopCaps.none;
    await pump(tester, settings: {'settings.quickAddHotkey': 'true'});
    expect(desktop.menus, isEmpty);
    expect(desktop.hotkeys, isEmpty);
    notes.tap('x');
    await tester.pumpAndSettle();
    expect(desktop.shows, 0);
  });

  testWidgets('closing hides the window when close to tray is on', (
    tester,
  ) async {
    await pump(tester);
    desktop.emit(const CloseRequested());
    await tester.pumpAndSettle();
    expect(desktop.hides, 1);
    expect(desktop.quits, 0);
  });

  testWidgets('closing does not hide when close to tray is off', (
    tester,
  ) async {
    await pump(tester, settings: {'settings.closeToTray': 'false'});
    expect(desktop.closeToTray, [false]);
    desktop.emit(const CloseRequested());
    await tester.pumpAndSettle();
    expect(desktop.hides, 0);
  });

  testWidgets('a click on the icon toggles the window', (tester) async {
    await pump(tester);
    desktop.emit(const TrayClicked());
    await tester.pumpAndSettle();
    expect(desktop.shown, isFalse);
    desktop.emit(const TrayClicked());
    await tester.pumpAndSettle();
    expect(desktop.shown, isTrue);
  });

  for (final (event, link) in [
    (const TrayPicked(TrayAction.quickAdd), 'tix://quick-add'),
    (const HotkeyPressed(), 'tix://quick-add'),
    (const TrayPicked(TrayAction.inbox), 'tix://inbox'),
  ]) {
    testWidgets('$event shows the window and opens $link', (tester) async {
      final c = await pump(tester);
      desktop
        ..shown = false
        ..emit(event);
      await tester.pumpAndSettle();
      expect(desktop.shown, isTrue);
      expect(c.read(deepLinkIntakeProvider).take(), Uri.parse(link));
    });
  }

  testWidgets('Open shows the window and Quit quits', (tester) async {
    final c = await pump(tester);
    desktop
      ..shown = false
      ..emit(const TrayPicked(TrayAction.open));
    await tester.pumpAndSettle();
    expect(desktop.shown, isTrue);
    expect(c.read(deepLinkIntakeProvider).take(), isNull);
    desktop.emit(const TrayPicked(TrayAction.quit));
    await tester.pumpAndSettle();
    expect(desktop.quits, 1);
  });

  testWidgets('a tapped notification shows the window', (tester) async {
    await pump(tester);
    desktop.shown = false;
    notes.tap('payload');
    await tester.pumpAndSettle();
    expect(desktop.shown, isTrue);
  });

  testWidgets('the hotkey chosen earlier is registered at start', (
    tester,
  ) async {
    await pump(tester, settings: {'settings.quickAddHotkey': 'true'});
    expect(desktop.hotkeys, [true]);
  });

  testWidgets('the hotkey is not registered where there are none', (
    tester,
  ) async {
    desktop.caps = const DesktopCaps(tray: true, autostart: true);
    await pump(tester, settings: {'settings.quickAddHotkey': 'true'});
    expect(desktop.hotkeys, isEmpty);
  });

  testWidgets('a login launch stays hidden with a tray to return to', (
    tester,
  ) async {
    desktop
      ..caps = const DesktopCaps(tray: true, autostart: true, background: true)
      ..shown = false;
    await pump(tester);
    expect(desktop.shows, 0);
  });

  testWidgets('a login launch shows the window without a tray', (tester) async {
    desktop
      ..caps = const DesktopCaps(autostart: true, background: true)
      ..shown = false;
    await pump(tester);
    expect(desktop.shows, 1);
  });

  testWidgets('a login launch shows the window with close to tray off', (
    tester,
  ) async {
    desktop
      ..caps = const DesktopCaps(tray: true, autostart: true, background: true)
      ..shown = false;
    await pump(tester, settings: {'settings.closeToTray': 'false'});
    expect(desktop.shows, 1);
  });
}
