// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';

import '../../../helpers/design.dart';

void main() {
  Color colourOf(WidgetTester tester, String text) =>
      tester.widget<Text>(find.text(text)).style!.color!;

  testWidgets('status colours follow the category, never the tenant accent', (
    tester,
  ) async {
    await pumpComponent(
      tester,
      const Wrap(
        children: [
          StatusPill(label: 'doing'),
          StatusPill(label: 'blocked'),
          StatusPill(label: 'Review', category: StatusCategory.waiting),
        ],
      ),
      accent: TixAccent.resolve('plum'),
    );
    const t = TixTokens.light;
    expect(colourOf(tester, 'doing'), t.brand);
    expect(colourOf(tester, 'blocked'), t.warn);
    expect(colourOf(tester, 'review'), t.projects[ProjectColour.violet]);
  });

  testWidgets('a priority reads as its word to a screen reader', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpComponent(tester, const PriorityMark(priority: 1));
    expect(find.bySemanticsLabel('Highest'), findsOneWidget);
    expect(find.text('highest'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('normal priority fades on a row and not on a task screen', (
    tester,
  ) async {
    await pumpComponent(
      tester,
      const Column(
        children: [
          PriorityMark(priority: 3, key: Key('row')),
          PriorityMark(priority: 3, emphasizeNormal: true, key: Key('screen')),
        ],
      ),
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('row')),
        matching: find.byType(Opacity),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('screen')),
        matching: find.byType(Opacity),
      ),
      findsNothing,
    );
  });

  final now = DateTime(2026, 11, 2, 9);
  for (final (due, text, tone) in [
    (DateTime(2026, 10, 30), 'overdue', 'danger'),
    (DateTime(2026, 11, 2, 18), 'due today', 'warn'),
    (DateTime(2026, 11, 5), 'due Thu', 'warn'),
    (DateTime(2026, 12, 24), 'due Dec 24', 'muted'),
  ]) {
    testWidgets('a due date reads "$text"', (tester) async {
      await pumpComponent(tester, DueMark(due: due, now: now));
      const t = TixTokens.light;
      final expected = {'danger': t.danger, 'warn': t.warn, 'muted': t.muted};
      expect(colourOf(tester, text), expected[tone]);
    });
  }

  testWidgets('a tag is a faint hash and the word', (tester) async {
    await pumpComponent(tester, const TagChip('auth'));
    expect(find.text('#auth'), findsOneWidget);
  });

  test('monograms take letters only, as tix does', () {
    expect(monogramOf('Nadia Petrova'), 'NP');
    expect(monogramOf('Atlas (build agent)'), 'AB');
    expect(monogramOf('@raj'), 'R');
    expect(monogramOf(''), '?');
    expect(monogramOf('Иван Петров'), 'ИП');
  });

  test('a hue from a handle is stable', () {
    expect(hueOf('raj'), hueOf('RAJ'));
    expect({
      for (final h in ['raj', 'nadia', 'mint', 'tom', 'lena']) hueOf(h),
    }, hasLength(greaterThan(1)));
  });

  group('compactCount', () {
    test('is the number in full below a thousand', () {
      expect(compactCount(9, 'en'), '9');
      expect(compactCount(10, 'en'), '10');
      expect(compactCount(999, 'en'), '999');
    });

    test('abbreviates from a thousand, in the locale', () {
      expect(compactCount(1000, 'en'), '1K');
      expect(compactCount(1234, 'en'), '1.23K');
      expect(compactCount(12345, 'en'), '12.3K');
      expect(compactCount(123456, 'en'), '123K');
      expect(compactCount(1234, 'fr'), isNot(contains('.')));
      for (final locale in ['en', 'fr', 'de', 'bg']) {
        expect(
          compactCount(1234567, locale),
          isNot(contains('234')),
          reason: locale,
        );
      }
    });
  });
}
