// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:ui' show Color;

import 'package:meta/meta.dart';
import 'package:tix_mobile/src/core/design/colour.dart';

/// The accent a tenant presents itself with: tix's `core.Theme`, one pair of
/// colours for the light scheme and one for the dark ones.
@immutable
class TixAccent {
  /// An accent with every colour given.
  const TixAccent({
    required this.name,
    required this.accent,
    required this.accentSoft,
    required this.accentDark,
    required this.accentSoftDark,
  });

  /// Derives a whole accent from one colour the way tix's `CustomTheme`
  /// does: moved just far enough to reach 4.5:1 on white for the light
  /// scheme and on the dark page for the dark one, each over a tint of
  /// itself.
  factory TixAccent.custom(Color c) {
    const white = Color(0xFFFFFFFF);
    final light = readable(c, contrastFloor, const [white]);
    final dark = readable(c, contrastFloor, const [darkPage]);
    return TixAccent(
      name: hexOf(c),
      accent: light,
      accentSoft: mix(white, light, 0.1),
      accentDark: dark,
      accentSoftDark: mix(darkPage, dark, 0.22),
    );
  }

  /// The accent a tenant's `theme` field names, as tix's
  /// `ThemeRegistry.Resolve` would: a custom `#rrggbb`, a built-in name, or
  /// the default. A theme only the server's configuration defines cannot be
  /// read through the API, so it falls back to the default here.
  factory TixAccent.resolve(String theme) {
    final name = theme.trim().toLowerCase();
    if (name.isEmpty) return standard;
    final custom = parseHex(name);
    if (custom != null) return TixAccent.custom(custom);
    for (final a in builtIn) {
      if (a.name == name) return a;
    }
    return standard;
  }

  /// The dark scheme's page, which a custom accent has to read on.
  static const darkPage = Color(0xFF14171B);

  /// tix's own teal, for a tenant that names no theme.
  static const standard = TixAccent(
    name: 'default',
    accent: Color(0xFF0F766E),
    accentSoft: Color(0xFFE6F4F1),
    accentDark: Color(0xFF2DD4BF),
    accentSoftDark: Color(0xFF123B36),
  );

  /// The themes that ship with tix, in tix's display order.
  static const builtIn = <TixAccent>[
    standard,
    TixAccent(
      name: 'indigo',
      accent: Color(0xFF3B5BDB),
      accentSoft: Color(0xFFEDF0FF),
      accentDark: Color(0xFF8DA2FB),
      accentSoftDark: Color(0xFF1E2749),
    ),
    TixAccent(
      name: 'forest',
      accent: Color(0xFF2B8A3E),
      accentSoft: Color(0xFFE9F7EC),
      accentDark: Color(0xFF6EE7A5),
      accentSoftDark: Color(0xFF13301F),
    ),
    TixAccent(
      name: 'ember',
      accent: Color(0xFFC2410C),
      accentSoft: Color(0xFFFDF0E8),
      accentDark: Color(0xFFFB923C),
      accentSoftDark: Color(0xFF3A2113),
    ),
    TixAccent(
      name: 'violet',
      accent: Color(0xFF7048E8),
      accentSoft: Color(0xFFF1ECFD),
      accentDark: Color(0xFFC4B5FD),
      accentSoftDark: Color(0xFF2A2145),
    ),
    TixAccent(
      name: 'ocean',
      accent: Color(0xFF0B7285),
      accentSoft: Color(0xFFE6F4F6),
      accentDark: Color(0xFF67E8F9),
      accentSoftDark: Color(0xFF0E3440),
    ),
    TixAccent(
      name: 'plum',
      accent: Color(0xFFA61E4D),
      accentSoft: Color(0xFFFBEAF0),
      accentDark: Color(0xFFF9A8D4),
      accentSoftDark: Color(0xFF3D1528),
    ),
    TixAccent(
      name: 'slate',
      accent: Color(0xFF334155),
      accentSoft: Color(0xFFEEF2F6),
      accentDark: Color(0xFFA8B6C8),
      accentSoftDark: Color(0xFF242C36),
    ),
  ];

  /// The theme's name, or the `#rrggbb` it was derived from.
  final String name;

  /// The light scheme's accent.
  final Color accent;

  /// The light scheme's tint.
  final Color accentSoft;

  /// The dark scheme's accent.
  final Color accentDark;

  /// The dark scheme's tint.
  final Color accentSoftDark;

  @override
  bool operator ==(Object other) =>
      other is TixAccent &&
      other.name == name &&
      other.accent == accent &&
      other.accentSoft == accentSoft &&
      other.accentDark == accentDark &&
      other.accentSoftDark == accentSoftDark;

  @override
  int get hashCode =>
      Object.hash(name, accent, accentSoft, accentDark, accentSoftDark);
}
