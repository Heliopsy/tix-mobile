// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:math' as math;
import 'dart:ui' show Color;

/// The contrast every text colour in the app clears, WCAG AA for body text.
const contrastFloor = 4.5;

/// [c] as `#rrggbb`, lower case.
String hexOf(Color c) {
  String two(double v) =>
      (v * 255).round().clamp(0, 255).toRadixString(16).padLeft(2, '0');
  return '#${two(c.r)}${two(c.g)}${two(c.b)}';
}

/// Parses `#rrggbb` (the only form tix accepts), null for anything else.
Color? parseHex(String value) {
  final v = value.trim();
  if (v.length != 7 || !v.startsWith('#')) return null;
  final n = int.tryParse(v.substring(1), radix: 16);
  if (n == null || v.substring(1).contains(RegExp('[^0-9a-fA-F]'))) {
    return null;
  }
  return Color(0xFF000000 | n);
}

/// WCAG relative luminance of [c], from 0 to 1.
double luminance(Color c) {
  double lin(double s) {
    final v = (s * 255).roundToDouble() / 255;
    return v <= 0.04045
        ? v / 12.92
        : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * lin(c.r) + 0.7152 * lin(c.g) + 0.0722 * lin(c.b);
}

/// The WCAG 2 contrast ratio between [a] and [b], from 1 to 21.
double contrast(Color a, Color b) {
  var la = luminance(a);
  var lb = luminance(b);
  if (la < lb) (la, lb) = (lb, la);
  return (la + 0.05) / (lb + 0.05);
}

/// [t] of [other] blended into [c] channel by channel, like tix's `Mix` and
/// CSS `color-mix(in srgb)`.
Color mix(Color c, Color other, double t) {
  int m(double a, double b) => ((a * (1 - t) + b * t) * 255).round();
  return Color.fromARGB(255, m(c.r, other.r), m(c.g, other.g), m(c.b, other.b));
}

/// [c] when it reaches [floor] against every one of [backgrounds], otherwise
/// the least blend towards black or white that does: tix's `Readable`.
Color readable(Color c, double floor, List<Color> backgrounds) {
  bool clears(Color x) => backgrounds.every((bg) => contrast(x, bg) >= floor);
  if (clears(c)) return c;
  final mean = backgrounds.isEmpty
      ? 1.0
      : backgrounds.map(luminance).reduce((a, b) => a + b) / backgrounds.length;
  final target = mean > 0.18
      ? const Color(0xFF000000)
      : const Color(0xFFFFFFFF);
  var lo = 0.0;
  var hi = 1.0;
  for (var i = 0; i < 24; i++) {
    final mid = (lo + hi) / 2;
    if (clears(mix(c, target, mid))) {
      hi = mid;
    } else {
      lo = mid;
    }
  }
  return mix(c, target, hi);
}

/// Whichever of [light] and [dark] reads better on [background].
Color onColour(
  Color background, {
  Color light = const Color(0xFFFFFFFF),
  Color dark = const Color(0xFF08231A),
}) => contrast(light, background) >= contrast(dark, background) ? light : dark;
