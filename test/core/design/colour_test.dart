// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/accent.dart';
import 'package:tix_mobile/src/core/design/colour.dart';

void main() {
  test('contrast is the WCAG ratio', () {
    expect(
      contrast(const Color(0xFF000000), const Color(0xFFFFFFFF)),
      closeTo(21, 0.01),
    );
    expect(
      contrast(const Color(0xFF0F766E), const Color(0xFFFFFFFF)),
      closeTo(5.47, 0.01),
    );
  });

  test('hex parses only #rrggbb, as tix accepts', () {
    expect(parseHex('#7A3EF0'), const Color(0xFF7A3EF0));
    expect(parseHex('#abc'), isNull);
    expect(parseHex('teal'), isNull);
    expect(parseHex('#12345g'), isNull);
    expect(hexOf(const Color(0xFF7A3EF0)), '#7a3ef0');
  });

  // Reference values printed by tix's own core.CustomTheme, so the app
  // derives a custom accent to the same pixels the browser shows.
  const tix = {
    '#7a3ef0': ['#7a3ef0', '#f2ecfe', '#9262f3', '#30284b'],
    '#ffcc00': ['#907300', '#f4f1e6', '#ffcc00', '#483f15'],
    '#0e7490': ['#0e7490', '#e7f1f4', '#338aa1', '#1b3038'],
    '#111111': ['#111111', '#e7e7e7', '#808080', '#2c2e31'],
  };
  for (final MapEntry(:key, :value) in tix.entries) {
    test('a custom accent $key derives as tix derives it', () {
      final a = TixAccent.resolve(key);
      expect(
        [a.accent, a.accentSoft, a.accentDark, a.accentSoftDark].map(hexOf),
        value,
      );
    });
  }

  test('a derived accent reads on both pages', () {
    final a = TixAccent.custom(const Color(0xFFFFEE00));
    expect(contrast(a.accent, const Color(0xFFFFFFFF)), greaterThan(4.5));
    expect(contrast(a.accentDark, TixAccent.darkPage), greaterThan(4.5));
  });

  test('names resolve like ThemeRegistry.Resolve', () {
    expect(TixAccent.resolve(''), TixAccent.standard);
    expect(TixAccent.resolve(' Ember ').name, 'ember');
    expect(TixAccent.resolve('acme-configured'), TixAccent.standard);
    expect(TixAccent.builtIn.map((a) => a.name), [
      'default',
      'indigo',
      'forest',
      'ember',
      'violet',
      'ocean',
      'plum',
      'slate',
    ]);
  });
}
