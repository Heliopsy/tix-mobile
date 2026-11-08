// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/accent.dart';
import 'package:tix_mobile/src/core/design/colour.dart';
import 'package:tix_mobile/src/core/design/theme.dart';
import 'package:tix_mobile/src/core/design/tokens.dart';

void main() {
  const schemes = {
    'light': TixTokens.light,
    'dark': TixTokens.dark,
    'dim': TixTokens.dim,
  };

  for (final MapEntry(key: name, value: t) in schemes.entries) {
    group('$name contrast', () {
      for (final (label, page) in [('page', t.bg), ('surface', t.surface)]) {
        test('text tokens clear 4.5:1 on the $label', () {
          for (final c in [t.ink, t.muted, t.danger, t.ok]) {
            expect(
              contrast(c, page),
              greaterThanOrEqualTo(4.5),
              reason: hexOf(c),
            );
          }
        });
        test('project colours clear 3:1 on the $label', () {
          for (final c in t.projects.values) {
            expect(
              contrast(c, page),
              greaterThanOrEqualTo(3),
              reason: hexOf(c),
            );
          }
        });
      }
    });
  }

  for (final a in [...TixAccent.builtIn, TixAccent.resolve('#ffcc00')]) {
    for (final b in Brightness.values) {
      test('${a.name} ${b.name}: text on the accent and the accent on '
          'its tint read', () {
        final t = TixTokens.of(b).withAccent(a);
        expect(contrast(t.onAccent, t.accent), greaterThanOrEqualTo(4.5));
        expect(contrast(t.accent, t.accentSoft), greaterThanOrEqualTo(3));
        expect(contrast(t.accent, t.bg), greaterThanOrEqualTo(3));
      });
    }
  }

  test('a tenant accent never moves status, priority or project colours', () {
    const plain = TixTokens.light;
    final themed = plain.withAccent(TixAccent.resolve('plum'));
    expect(themed.accent, isNot(plain.accent));
    for (final c in StatusCategory.values) {
      expect(themed.status(c), plain.status(c), reason: c.name);
    }
    for (var p = 1; p <= 5; p++) {
      expect(themed.priority(p), plain.priority(p));
    }
    expect(themed.projects, plain.projects);
  });

  test('project colours resolve palette names and shade custom ones', () {
    const t = TixTokens.light;
    expect(t.projectColour('teal'), t.projects[ProjectColour.teal]);
    expect(t.projectColour(''), isNull);
    expect(t.projectColour('nonsense'), isNull);
    final custom = t.projectColour('#ffee00')!;
    expect(contrast(custom, t.surface), greaterThanOrEqualTo(4.5));
  });

  test('status categories are guessed from the built-in workflow names', () {
    expect(StatusCategory.guess('Doing'), StatusCategory.inProgress);
    expect(StatusCategory.guess('in_progress'), StatusCategory.inProgress);
    expect(StatusCategory.guess('cancelled'), StatusCategory.cancelled);
    expect(StatusCategory.guess('triage'), StatusCategory.unknown);
  });

  test('lerp blends colours and lands on the target', () {
    final mid = TixTokens.light.lerp(TixTokens.dark, 0.5);
    expect(mid.bg, Color.lerp(TixTokens.light.bg, TixTokens.dark.bg, 0.5));
    expect(TixTokens.light.lerp(TixTokens.dark, 1).ink, TixTokens.dark.ink);
    expect(TixTokens.light.lerp(null, 0.5), same(TixTokens.light));
  });

  test('the theme carries the tokens and maps them to Material roles', () {
    final theme = buildTixTheme(
      Brightness.dark,
      accent: TixAccent.resolve('ocean'),
    );
    final t = theme.extension<TixTokens>()!;
    expect(t.accent, const Color(0xFF67E8F9));
    expect(theme.colorScheme.primary, t.accent);
    expect(theme.colorScheme.surface, TixTokens.dark.bg);
    expect(theme.colorScheme.error, TixTokens.dark.danger);
    expect(theme.textTheme.bodyMedium!.fontSize, TixText.md);
    expect(theme.textTheme.headlineSmall!.fontSize, TixText.xl2);
  });
}
