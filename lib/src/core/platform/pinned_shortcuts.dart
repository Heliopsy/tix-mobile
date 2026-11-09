// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/logging/log.dart';
import 'package:tix_mobile/src/core/platform/deep_links.dart';

part 'pinned_shortcuts.g.dart';

/// One shortcut to put on the home screen: a stable [id], what it is
/// called and the `tix://` link it opens.
@immutable
class PinnedShortcut {
  /// A shortcut called [label] that opens [link].
  const PinnedShortcut({
    required this.id,
    required this.label,
    required this.link,
  });

  /// The project [key], called [name], in the context [context] (a
  /// `<connection>.<tenant>` key).
  factory PinnedShortcut.project({
    required String context,
    required String key,
    required String name,
  }) => PinnedShortcut(
    id: 'pin.$context.project.$key',
    label: name.isEmpty ? key : name,
    link: tixLinkTo('projects/$key', context: context),
  );

  /// The saved filter [id], called [name], in the context [context].
  factory PinnedShortcut.savedFilter({
    required String context,
    required String id,
    required String name,
  }) => PinnedShortcut(
    id: 'pin.$context.filter.$id',
    label: name.isEmpty ? id : name,
    link: tixLinkTo('tasks', context: context, query: {'filter': id}),
  );

  /// The same for the same target in the same context, so pinning it again
  /// updates the one shortcut.
  final String id;

  /// What the launcher shows under the icon.
  final String label;

  /// What a tap opens.
  final Uri link;
}

/// Pinned home-screen shortcuts, behind an interface tests fake.
abstract interface class PinnedShortcuts {
  /// Whether this device's launcher can pin a shortcut.
  Future<bool> supported();

  /// Asks the launcher to pin [shortcut]; false when it could not ask.
  Future<bool> pin(PinnedShortcut shortcut);
}

/// [PinnedShortcuts] over the `tix/pins` channel, which only Android's
/// `MainActivity` answers; elsewhere nothing is supported.
class ChannelPinnedShortcuts implements PinnedShortcuts {
  /// Talks over [_channel].
  const ChannelPinnedShortcuts([
    this._channel = const MethodChannel('tix/pins'),
  ]);

  final MethodChannel _channel;

  @override
  Future<bool> supported() async {
    try {
      return await _channel.invokeMethod<bool>('supported') ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException catch (e) {
      log('pins: support check failed: ${e.code}');
      return false;
    }
  }

  @override
  Future<bool> pin(PinnedShortcut shortcut) async {
    try {
      return await _channel.invokeMethod<bool>('pin', {
            'id': shortcut.id,
            'label': shortcut.label,
            'link': shortcut.link.toString(),
          }) ??
          false;
    } on MissingPluginException {
      return false;
    } on PlatformException catch (e) {
      log('pins: pin failed: ${e.code}');
      return false;
    }
  }
}

/// The platform's pinned shortcuts; tests swap in a fake.
@Riverpod(keepAlive: true)
PinnedShortcuts pinnedShortcuts(Ref ref) => const ChannelPinnedShortcuts();

/// Whether Add to home screen is offered on this device.
@Riverpod(keepAlive: true)
Future<bool> pinSupported(Ref ref) =>
    ref.watch(pinnedShortcutsProvider).supported();
