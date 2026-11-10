// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart';

/// Touch feedback, in one place so every swipe and completion feels alike.
///
/// The platform decides: phones buzz, desktops ignore the call. The person
/// can turn it off on this device in Settings.
abstract final class TixHaptics {
  /// Whether feedback is on. A static rather than a provider because the
  /// callers are gesture handlers deep in components that hold no ref;
  /// `App` keeps it in step with the setting.
  static bool enabled = true;

  /// A swipe crossing its threshold, a toggle flipping.
  static Future<void> tick() =>
      enabled ? HapticFeedback.selectionClick() : Future.value();

  /// A task ticked done on its row: light, so working down a list does not
  /// rattle the phone.
  static Future<void> light() =>
      enabled ? HapticFeedback.lightImpact() : Future.value();

  /// A task completed, a destructive action confirmed.
  static Future<void> confirm() =>
      enabled ? HapticFeedback.mediumImpact() : Future.value();

  /// Something refused: a failed save that rolled back.
  static Future<void> refuse() =>
      enabled ? HapticFeedback.heavyImpact() : Future.value();
}
