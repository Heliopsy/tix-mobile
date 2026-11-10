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

/// The narrowest the expanded sidebar may be, as on tix web.
const sidebarMinWidth = 180.0;

/// The widest the expanded sidebar may be, as on tix web.
const sidebarMaxWidth = 480.0;

/// The expanded sidebar's width until the reader picks one.
const sidebarDefaultWidth = 256.0;

/// A drag that lets go of the sidebar narrower than this collapses it.
const sidebarCollapseAt = 120.0;

/// The collapsed sidebar: a rail of icons with their short labels.
const railWidth = 80.0;

/// The narrowest the task panel beside a board may be.
const detailMinWidth = 360.0;

/// The widest the task panel beside a board may be.
const detailMaxWidth = 720.0;

/// The task panel's width beside a board until the reader picks one.
const detailDefaultWidth = 460.0;

/// The widest the expanded sidebar may be in a [window] this wide: half
/// of it, within [sidebarMinWidth] and [sidebarMaxWidth].
double sidebarMaxFor(double window) =>
    (window / 2).clamp(sidebarMinWidth, sidebarMaxWidth);

/// The widest the task panel may be in [space] beside the sidebar: 60 % of
/// it, within [detailMinWidth] and [detailMaxWidth].
double detailMaxFor(double space) =>
    (space * 0.6).clamp(detailMinWidth, detailMaxWidth);
