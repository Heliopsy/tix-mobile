// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:tix_mobile/src/core/platform/desktop.dart';

/// A desktop recorded instead of driven.
class FakeDesktop implements DesktopShell {
  /// Offers [caps].
  FakeDesktop({
    this.caps = const DesktopCaps(tray: true, autostart: true, hotkey: true),
    this.autostartAnswer = false,
  });

  /// What [start] answers.
  DesktopCaps caps;

  /// What [autostart] answers; null for a platform that cannot say.
  bool? autostartAnswer;

  /// Whether [setAutostart] and [setHotkey] succeed.
  bool accept = true;

  final menus = <TrayMenu?>[];
  final closeToTray = <bool>[];
  final autostarts = <bool>[];
  final hotkeys = <bool>[];
  bool shown = true;
  int shows = 0;
  int hides = 0;
  int quits = 0;
  final _events = StreamController<DesktopEvent>.broadcast();

  /// Sends [event] as the platform would.
  void emit(DesktopEvent event) => _events.add(event);

  @override
  Stream<DesktopEvent> get events => _events.stream;

  @override
  Future<DesktopCaps> start() async => caps;

  @override
  Future<void> setTray(TrayMenu? menu) async => menus.add(menu);

  @override
  Future<void> setCloseToTray({required bool on}) async => closeToTray.add(on);

  @override
  Future<void> show() async {
    shows++;
    shown = true;
  }

  @override
  Future<void> hide() async {
    hides++;
    shown = false;
  }

  @override
  Future<bool> visible() async => shown;

  @override
  Future<void> quit() async => quits++;

  @override
  Future<bool?> autostart() async => autostartAnswer;

  @override
  Future<bool> setAutostart({required bool on}) async {
    autostarts.add(on);
    return accept;
  }

  @override
  Future<bool> setHotkey({required bool on}) async {
    hotkeys.add(on);
    return accept;
  }
}
