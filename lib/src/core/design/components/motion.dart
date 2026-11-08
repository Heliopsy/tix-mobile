// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart';

/// Touch feedback, in one place so every swipe and completion feels alike.
///
/// The platform decides: phones buzz, desktops ignore the call.
abstract final class TixHaptics {
  /// A swipe crossing its threshold, a toggle flipping.
  static Future<void> tick() => HapticFeedback.selectionClick();

  /// A task completed, a destructive action confirmed.
  static Future<void> confirm() => HapticFeedback.mediumImpact();

  /// Something refused: a failed save that rolled back.
  static Future<void> refuse() => HapticFeedback.heavyImpact();
}
