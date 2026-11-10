// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

part 'desktop.g.dart';

/// What the desktop the app runs on offers. All false on phones and where
/// the runner does not answer.
@immutable
class DesktopCaps {
  /// The offers as the runner reported them.
  const DesktopCaps({
    this.tray = false,
    this.autostart = false,
    this.hotkey = false,
    this.background = false,
  });

  /// Nothing offered: a phone, a test, or a runner without the channel.
  static const none = DesktopCaps();

  /// Whether a tray or menu bar shows the app's icon. False on GNOME
  /// without an AppIndicator extension, where nothing watches for one.
  final bool tray;

  /// Whether the app can start at login.
  final bool autostart;

  /// Whether a global hotkey can be registered: false on Wayland.
  final bool hotkey;

  /// Whether this launch came from the login item, which starts the window
  /// hidden.
  final bool background;

  /// Whether this is a desktop at all.
  bool get any => tray || autostart || hotkey;

  @override
  bool operator ==(Object other) =>
      other is DesktopCaps &&
      other.tray == tray &&
      other.autostart == autostart &&
      other.hotkey == hotkey &&
      other.background == background;

  @override
  int get hashCode => Object.hash(tray, autostart, hotkey, background);
}

/// The tray menu's entries that do something.
enum TrayAction {
  /// Shows and focuses the window.
  open,

  /// Shows the window with quick add.
  quickAdd,

  /// Shows the window on the inbox.
  inbox,

  /// Shows the window on Watch, the live event tail.
  watch,

  /// Installs a staged update, or shows where one is offered; only in the
  /// menu while an update is known.
  update,

  /// Ends the app.
  quit,
}

/// The tray icon's tooltip, its menu labels and the dock badge.
@immutable
class TrayMenu {
  /// A menu with these labels.
  const TrayMenu({
    required this.tooltip,
    required this.labels,
    this.context,
    this.badge,
  });

  /// The icon's tooltip (Windows, macOS).
  final String tooltip;

  /// The label of each action, in menu order; [TrayAction.update] only
  /// while an update is known.
  final Map<TrayAction, String> labels;

  /// The active context, shown as a disabled entry; null when signed out.
  final String? context;

  /// The dock badge on macOS, null for none.
  final String? badge;

  @override
  bool operator ==(Object other) =>
      other is TrayMenu &&
      other.tooltip == tooltip &&
      mapEquals(other.labels, labels) &&
      other.context == context &&
      other.badge == badge;

  @override
  int get hashCode => Object.hash(
    tooltip,
    Object.hashAll(labels.entries.map((e) => (e.key, e.value))),
    context,
    badge,
  );
}

/// Something that happened in the tray, the window or the hotkey.
sealed class DesktopEvent {
  const DesktopEvent();
}

/// The tray icon itself was clicked (Windows, macOS; Linux only has a menu).
final class TrayClicked extends DesktopEvent {
  /// The click.
  const TrayClicked();
}

/// A tray menu entry was picked.
final class TrayPicked extends DesktopEvent {
  /// [action] was picked.
  const TrayPicked(this.action);

  /// What was picked.
  final TrayAction action;
}

/// The window's close button was pressed while closing hides it.
final class CloseRequested extends DesktopEvent {
  /// The press.
  const CloseRequested();
}

/// The global quick-add hotkey was pressed.
final class HotkeyPressed extends DesktopEvent {
  /// The press.
  const HotkeyPressed();
}

/// The window, the tray icon, start at login and the global hotkey on Linux,
/// Windows and macOS.
abstract interface class DesktopShell {
  /// Asks the runner what it offers and starts listening. Answers
  /// [DesktopCaps.none] on phones.
  Future<DesktopCaps> start();

  /// What happens in the tray, the window and the hotkey.
  Stream<DesktopEvent> get events;

  /// Shows [menu], or removes the icon with null.
  Future<void> setTray(TrayMenu? menu);

  /// Whether the close button hides the window instead of ending the app.
  Future<void> setCloseToTray({required bool on});

  /// Shows, restores and focuses the window.
  Future<void> show();

  /// Hides the window; the app keeps running.
  Future<void> hide();

  /// Whether the window is on screen.
  Future<bool> visible();

  /// Ends the app.
  Future<void> quit();

  /// Whether the app starts at login, null when the platform cannot say.
  Future<bool?> autostart();

  /// Turns start at login on or off; false when the platform refused.
  Future<bool> setAutostart({required bool on});

  /// Registers or drops the quick-add hotkey; false when it is taken.
  Future<bool> setHotkey({required bool on});
}

/// [DesktopShell] through `tray_manager`, `window_manager` and the runner's
/// `tix/desktop` channel. Phones never touch the plugins.
class PluginDesktopShell
    with TrayListener, WindowListener
    implements DesktopShell {
  /// Talks to the runner over [channel].
  PluginDesktopShell([this.channel = const MethodChannel('tix/desktop')]);

  /// The runner's channel.
  final MethodChannel channel;

  final _events = StreamController<DesktopEvent>.broadcast();
  Map<String, TrayAction> _ids = const {};
  bool _tray = false;
  bool _started = false;

  /// Whether this platform is a desktop the app ships on.
  static bool get desktop =>
      !kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS);

  /// Whether this runs inside Flatpak, where the tray takes an icon name
  /// rather than a path.
  static bool get flatpak => Platform.environment.containsKey('FLATPAK_ID');

  @override
  Stream<DesktopEvent> get events => _events.stream;

  @override
  Future<DesktopCaps> start() async {
    if (!desktop) return DesktopCaps.none;
    final Map<Object?, Object?>? caps;
    try {
      caps = await channel.invokeMapMethod<Object?, Object?>('capabilities');
    } on MissingPluginException {
      return DesktopCaps.none;
    }
    if (caps == null) return DesktopCaps.none;
    final result = DesktopCaps(
      tray: caps['tray'] == true,
      autostart: caps['autostart'] == true,
      hotkey: caps['hotkey'] == true,
      background: caps['background'] == true,
    );
    if (!_started) {
      _started = true;
      channel.setMethodCallHandler((call) async {
        if (call.method == 'hotkey') _events.add(const HotkeyPressed());
      });
      await windowManager.ensureInitialized();
      windowManager.addListener(this);
      trayManager.addListener(this);
    }
    return result;
  }

  @override
  Future<void> setTray(TrayMenu? menu) async {
    if (menu == null) {
      if (_tray) await trayManager.destroy();
      _tray = false;
      if (Platform.isMacOS) await windowManager.setBadgeLabel();
      return;
    }
    if (!_tray) {
      await trayManager.setIcon(_icon(), isTemplate: Platform.isMacOS);
      _tray = true;
    }
    if (!Platform.isLinux) await trayManager.setToolTip(menu.tooltip);
    if (Platform.isMacOS) await windowManager.setBadgeLabel(menu.badge);
    final ids = <String, TrayAction>{};
    MenuItem item(TrayAction a) {
      ids[a.name] = a;
      return MenuItem(key: a.name, label: menu.labels[a] ?? a.name);
    }

    final context = menu.context;
    await trayManager.setContextMenu(
      Menu(
        items: [
          item(TrayAction.open),
          item(TrayAction.quickAdd),
          item(TrayAction.inbox),
          if (menu.labels.containsKey(TrayAction.watch)) item(TrayAction.watch),
          if (menu.labels.containsKey(TrayAction.update))
            item(TrayAction.update),
          MenuItem.separator(),
          if (context != null) ...[
            MenuItem(key: 'context', label: context, disabled: true),
            MenuItem.separator(),
          ],
          item(TrayAction.quit),
        ],
      ),
    );
    _ids = ids;
  }

  /// The tray icon: Linux reads the bundle's PNG, or the installed icon by
  /// name under Flatpak, where the host cannot see the sandbox's paths;
  /// Windows reads the runner's .ico beside it; macOS takes a template image
  /// from the assets.
  static String _icon() {
    if (Platform.isMacOS) return 'assets/branding/tray/menubar.png';
    if (Platform.isLinux && flatpak) return 'red.tix.tix_mobile';
    final sep = Platform.pathSeparator;
    final data = '${File(Platform.resolvedExecutable).parent.path}${sep}data';
    return '$data$sep${Platform.isWindows ? 'app_icon.ico' : 'icon.png'}';
  }

  @override
  Future<void> setCloseToTray({required bool on}) =>
      windowManager.setPreventClose(on);

  @override
  Future<void> show() async {
    await windowManager.show();
    await windowManager.focus();
  }

  @override
  Future<void> hide() => windowManager.hide();

  @override
  Future<bool> visible() => windowManager.isVisible();

  @override
  Future<void> quit() async {
    await setTray(null);
    await windowManager.setPreventClose(false);
    await windowManager.destroy();
  }

  @override
  Future<bool?> autostart() => channel.invokeMethod<bool>('autostart');

  @override
  Future<bool> setAutostart({required bool on}) async =>
      await channel.invokeMethod<bool>('setAutostart', on) ?? false;

  @override
  Future<bool> setHotkey({required bool on}) async =>
      await channel.invokeMethod<bool>('setHotkey', on) ?? false;

  @override
  void onTrayIconMouseDown() => _events.add(const TrayClicked());

  @override
  void onTrayIconRightMouseDown() => unawaited(trayManager.popUpContextMenu());

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    final action = _ids[menuItem.key];
    if (action != null) _events.add(TrayPicked(action));
  }

  @override
  void onWindowClose() => _events.add(const CloseRequested());
}

/// The desktop's tray, window and hotkey; tests swap in a fake.
@Riverpod(keepAlive: true)
DesktopShell desktopShell(Ref ref) => PluginDesktopShell();
