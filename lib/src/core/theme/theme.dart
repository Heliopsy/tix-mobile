// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:material_ui/material_ui.dart';

/// The tix accent, the web app's `--accent`.
const tixSeed = Color(0xFF0F766E);

/// The app theme for [brightness], from the platform's dynamic [scheme] when
/// it offers one and from [tixSeed] otherwise.
ThemeData buildTheme(Brightness brightness, {ColorScheme? scheme}) {
  final colors =
      scheme ??
      ColorScheme.fromSeed(seedColor: tixSeed, brightness: brightness);
  return ThemeData(
    colorScheme: colors,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
