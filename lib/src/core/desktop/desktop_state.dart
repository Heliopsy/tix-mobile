// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/platform/desktop.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/storage/providers.dart';
import 'package:tix_mobile/src/core/update/updates.dart';
import 'package:tix_mobile/src/data/repositories/settings_repository.dart';

part 'desktop_state.g.dart';

/// What this desktop offers, asked once. [DesktopCaps.none] on phones.
@Riverpod(keepAlive: true)
Future<DesktopCaps> desktopCaps(Ref ref) =>
    ref.watch(desktopShellProvider).start();

/// The active context's unread inbox count for the tray and the dock, null
/// before it has counted. Core cannot read the inbox, so `main` puts the
/// inbox's count in place of this null; it is only watched while someone is
/// signed in.
@riverpod
int? trayUnread(Ref ref) => null;

SettingsRepository _settings(Ref ref) =>
    SettingsRepository(ref.watch(keyValueStoreProvider));

/// Whether closing the window hides it to the tray: on until turned off
/// where a tray shows, and always off where none does, so the window can
/// never vanish with no way back.
@Riverpod(keepAlive: true)
class CloseToTraySetting extends _$CloseToTraySetting {
  @override
  bool build() {
    final tray = ref.watch(desktopCapsProvider).value?.tray ?? false;
    return tray && (_settings(ref).closeToTray() ?? true);
  }

  /// Turns close to tray on or off and remembers it.
  Future<void> set({required bool on}) async {
    state = on;
    await _settings(ref).setCloseToTray(on: on);
  }
}

/// Whether the app starts at login. The platform's answer where it can
/// give one, else what was last chosen here (Flatpak's portal cannot be
/// asked).
@Riverpod(keepAlive: true)
class AutostartSetting extends _$AutostartSetting {
  @override
  Future<bool> build() async {
    final caps = await ref.watch(desktopCapsProvider.future);
    if (!caps.autostart) return false;
    final actual = await ref.read(desktopShellProvider).autostart();
    return actual ?? _settings(ref).autostart();
  }

  /// Turns start at login on or off; false when the platform refused, and
  /// then nothing changes.
  Future<bool> set({required bool on}) async {
    final ok = await ref.read(desktopShellProvider).setAutostart(on: on);
    if (!ok) return false;
    await _settings(ref).setAutostart(on: on);
    state = AsyncData(on);
    return true;
  }
}

/// Whether the global quick-add hotkey is on, where the desktop has global
/// hotkeys.
@Riverpod(keepAlive: true)
class QuickAddHotkeySetting extends _$QuickAddHotkeySetting {
  @override
  bool build() => _settings(ref).quickAddHotkey();

  /// Registers or drops the hotkey and remembers it; false when another app
  /// holds it, and then it stays off.
  Future<bool> set({required bool on}) async {
    final ok = await ref.read(desktopShellProvider).setHotkey(on: on);
    if (on && !ok) return false;
    state = on;
    await _settings(ref).setQuickAddHotkey(on: on);
    return true;
  }
}

/// The global quick-add hotkey as the platform writes it.
String quickAddHotkeyLabel(TargetPlatform platform) =>
    platform == TargetPlatform.macOS ? '⌃⇧Space' : 'Ctrl+Shift+Space';

/// The active context as the tray names it: instance, then tenant.
String? trayContextLabel(Session? session) {
  if (session == null) return null;
  final label = [
    session.instance.name,
    session.connection.tenantLabel,
  ].where((s) => s.isNotEmpty).join(' · ');
  return label.isEmpty ? null : label;
}

/// The tray's entry for [update], null while there is nothing to offer.
String? trayUpdateLabel(AppLocalizations l10n, UpdateState update) {
  final version = update.offer?.version.toString();
  if (version == null) return null;
  return update.phase == UpdatePhase.ready
      ? l10n.trayRestartToUpdate(version)
      : l10n.trayUpdateAvailable(version);
}

/// The tray's tooltip, menu and dock badge for [unread] items in
/// [context], with an [update] entry when one is given.
TrayMenu trayMenu(
  AppLocalizations l10n, {
  int? unread,
  String? context,
  String? update,
}) {
  final count = unread ?? 0;
  return TrayMenu(
    tooltip: l10n.trayTooltip(count),
    labels: {
      TrayAction.open: l10n.trayOpen,
      TrayAction.quickAdd: l10n.quickAddTitle,
      TrayAction.inbox: l10n.trayInbox(count),
      TrayAction.update: ?update,
      TrayAction.quit: l10n.trayQuit,
    },
    context: context,
    badge: count <= 0
        ? null
        : count > 99
        ? '99+'
        : '$count',
  );
}
