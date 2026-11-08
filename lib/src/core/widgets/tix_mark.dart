// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:material_ui/material_ui.dart';

/// The tix mark, the same rounded square as the app icon and the web favicon.
class TixMark extends StatelessWidget {
  /// Creates the mark, [size] logical pixels square.
  const TixMark({this.size = 64, super.key});

  /// The asset, rendered by scripts/icons.sh at 1x, 2x and 3x of 64 px.
  static const asset = 'assets/branding/app/mark.png';

  /// Width and height in logical pixels.
  final double size;

  @override
  Widget build(BuildContext context) =>
      Image.asset(asset, width: size, height: size, excludeFromSemantics: true);
}
