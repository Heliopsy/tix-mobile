// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_shortcuts.g.dart';

/// One launcher shortcut: what it is called and the type it reports.
typedef AppShortcut = ({String type, String label});

/// Launcher shortcuts on Android and home-screen quick actions on iOS.
abstract interface class AppShortcuts {
  /// Offers [items] and calls [onPick] with the type of the one picked,
  /// including the one that started the app.
  Future<void> install(
    List<AppShortcut> items,
    void Function(String type) onPick,
  );
}

/// [AppShortcuts] through the `quick_actions` plugin, which only Android and
/// iOS have; elsewhere it does nothing.
class PluginAppShortcuts implements AppShortcuts {
  /// Uses [_actions].
  const PluginAppShortcuts([this._actions = const QuickActions()]);

  final QuickActions _actions;

  /// Whether this platform has launcher shortcuts.
  static bool get supported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  @override
  Future<void> install(
    List<AppShortcut> items,
    void Function(String type) onPick,
  ) async {
    if (!supported) return;
    await _actions.initialize(onPick);
    await _actions.setShortcutItems([
      for (final i in items)
        ShortcutItem(type: i.type, localizedTitle: i.label),
    ]);
  }
}

/// The platform's launcher shortcuts; tests swap in a fake.
@Riverpod(keepAlive: true)
AppShortcuts appShortcuts(Ref ref) => const PluginAppShortcuts();
