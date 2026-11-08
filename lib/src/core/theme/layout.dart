// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/widgets.dart';

/// Below this width the app uses a bottom navigation bar, above it a rail.
const compactMaxWidth = 600.0;

/// From this width a list and the item it opens share the screen.
const twoPaneMinWidth = 840.0;

/// From this width the navigation rail shows its labels beside the icons.
const extendedRailMinWidth = 1200.0;

/// Width helpers for adaptive layouts.
extension LayoutContext on BuildContext {
  /// Whether the screen is phone-sized.
  bool get isCompact => MediaQuery.sizeOf(this).width < compactMaxWidth;

  /// Whether the screen is wide enough for two panes.
  bool get isTwoPane => MediaQuery.sizeOf(this).width >= twoPaneMinWidth;
}
