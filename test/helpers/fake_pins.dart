// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:tix_mobile/src/core/platform/pinned_shortcuts.dart';

/// Pinned shortcuts recorded instead of asked for.
class FakePins implements PinnedShortcuts {
  /// A launcher that can pin when [canPin], and agrees when [agrees].
  FakePins({this.canPin = true, this.agrees = true});

  /// What [supported] answers.
  bool canPin;

  /// What [pin] answers.
  bool agrees;

  /// Every shortcut asked for, in order.
  final pinned = <PinnedShortcut>[];

  @override
  Future<bool> supported() async => canPin;

  @override
  Future<bool> pin(PinnedShortcut shortcut) async {
    pinned.add(shortcut);
    return agrees;
  }
}
