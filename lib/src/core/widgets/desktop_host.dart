// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/desktop/desktop_state.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/logging/log.dart';
import 'package:tix_mobile/src/core/notifications/local_notifier.dart';
import 'package:tix_mobile/src/core/platform/deep_links.dart';
import 'package:tix_mobile/src/core/platform/desktop.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/update/updates.dart';

/// Mounted above the router on every screen: keeps the desktop's tray icon,
/// its menu and the dock badge in step with the active context, hides the
/// window on close when that is chosen, and turns tray picks and the
/// quick-add hotkey into the same `tix://` links Android's tiles open. Does
/// nothing where the platform offers none of it. It also keeps the update
/// check running on every platform, shows an update in the tray, and
/// installs a staged one on quit when that is chosen.
class DesktopHost extends ConsumerStatefulWidget {
  /// Hosts the desktop around [child].
  const DesktopHost({required this.child, super.key});

  /// The app.
  final Widget child;

  @override
  ConsumerState<DesktopHost> createState() => _DesktopHostState();
}

class _DesktopHostState extends ConsumerState<DesktopHost> {
  StreamSubscription<DesktopEvent>? _events;
  StreamSubscription<String>? _taps;
  bool _ready = false;
  TrayMenu? _menu;
  bool? _close;

  DesktopShell get _shell => ref.read(desktopShellProvider);

  @override
  void initState() {
    super.initState();
    _events = _shell.events.listen((e) => unawaited(_on(e)));
    ref.listenManual(desktopCapsProvider, (_, next) {
      final caps = next.value;
      if (caps != null) unawaited(_start(caps));
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    unawaited(_events?.cancel());
    unawaited(_taps?.cancel());
    super.dispose();
  }

  Future<void> _start(DesktopCaps caps) async {
    if (_ready || !caps.any) return;
    _ready = true;
    _taps = ref.read(localNotesProvider).taps.listen((_) {
      unawaited(_shell.show());
    });
    if (caps.hotkey && ref.read(quickAddHotkeySettingProvider)) {
      if (!await _shell.setHotkey(on: true)) {
        log('desktop: the quick-add hotkey is taken');
      }
    }
    if (caps.background &&
        !(caps.tray && ref.read(closeToTraySettingProvider))) {
      await _shell.show();
    }
  }

  Future<void> _on(DesktopEvent event) async {
    final shell = _shell;
    switch (event) {
      case TrayClicked():
        await (await shell.visible() ? shell.hide() : shell.show());
      case TrayPicked(action: TrayAction.open):
        await shell.show();
      case TrayPicked(action: TrayAction.quickAdd) || HotkeyPressed():
        await _follow('quick-add');
      case TrayPicked(action: TrayAction.inbox):
        await _follow('inbox');
      case TrayPicked(action: TrayAction.update):
        if (ref.read(updatesProvider).phase == UpdatePhase.ready) {
          await ref.read(updatesProvider.notifier).restart();
        } else {
          await _follow('about');
        }
      case TrayPicked(action: TrayAction.quit):
        await _quit();
      case CloseRequested():
        if (ref.read(closeToTraySettingProvider)) {
          await shell.hide();
        } else if (_installsOnQuit) {
          await _quit();
        }
    }
  }

  bool get _installsOnQuit =>
      ref.read(updatesProvider).phase == UpdatePhase.ready &&
      ref.read(autoInstallSettingProvider);

  Future<void> _quit() async {
    await ref.read(updatesProvider.notifier).installOnQuit();
    await _shell.quit();
  }

  Future<void> _follow(String path) async {
    await _shell.show();
    ref.read(deepLinkIntakeProvider).deliver(tixLinkTo(path));
  }

  void _sync(DesktopCaps caps, UpdateState update) {
    if (!caps.any) return;
    final pending =
        update.phase == UpdatePhase.ready &&
        ref.watch(autoInstallSettingProvider);
    // Without a tray the window closes for real, so close is held only
    // while an update waits to be installed on quit.
    final close =
        (caps.tray && ref.watch(closeToTraySettingProvider)) || pending;
    if (close != (_close ?? (caps.tray ? null : false))) {
      _close = close;
      unawaited(_shell.setCloseToTray(on: close));
    }
    if (!caps.tray) return;
    final session = ref.watch(sessionControllerProvider).value;
    final menu = trayMenu(
      context.l10n,
      unread: session == null ? null : ref.watch(trayUnreadProvider),
      context: trayContextLabel(session),
      update: trayUpdateLabel(context.l10n, update),
    );
    if (menu != _menu) {
      _menu = menu;
      unawaited(_shell.setTray(menu));
    }
  }

  @override
  Widget build(BuildContext context) {
    final update = ref.watch(updatesProvider);
    _sync(ref.watch(desktopCapsProvider).value ?? DesktopCaps.none, update);
    return widget.child;
  }
}
