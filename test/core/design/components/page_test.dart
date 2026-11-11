// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';

import '../../../helpers/app.dart';
import '../../../helpers/design.dart';

void main() {
  Widget page(VoidCallback onAdd) => TixPage(
    title: 'Projects',
    subtitle: 'Every project in Acme',
    primaryAction: TixAction(
      key: const Key('add'),
      label: 'New project',
      icon: Icons.add,
      onPressed: onAdd,
    ),
    body: const SizedBox.expand(),
  );

  testWidgets('on a phone the create action is a labelled floating button', (
    tester,
  ) async {
    var added = 0;
    await pumpComponent(tester, page(() => added++));
    final add = find.byKey(const Key('add'));
    expect(tester.widget(add), isA<FloatingActionButton>());
    expect(
      find.descendant(of: add, matching: find.text('New project')),
      findsOneWidget,
    );
    await tester.tap(add);
    expect(added, 1);
    expect(find.text('Every project in Acme'), findsOneWidget);
  });

  testWidgets('on a desktop it is the primary button in the header', (
    tester,
  ) async {
    var added = 0;
    await pumpComponent(tester, page(() => added++), size: desktop);
    final add = find.byKey(const Key('add'));
    expect(tester.widget<TixButton>(add).intent, TixButtonIntent.primary);
    expect(find.byType(FloatingActionButton), findsNothing);
    await tester.tap(add);
    expect(added, 1);
  });

  for (final MapEntry(key: width, value: size) in widths.entries) {
    testWidgets('$width: a subtitle note follows the line in the accent', (
      tester,
    ) async {
      await pumpComponent(
        tester,
        const TixPage(
          title: 'Infra',
          subtitle: '12 tasks',
          subtitleNote: '3 held by an agent',
          body: SizedBox.expand(),
        ),
        size: size,
      );
      final text = tester.widget<Text>(
        find.byWidgetPredicate(
          (w) =>
              w is Text &&
              w.textSpan?.toPlainText() == '12 tasks · 3 held by an agent',
        ),
      );
      final note = (text.textSpan! as TextSpan).children!.last as TextSpan;
      expect(note.text, '3 held by an agent');
      expect(
        note.style?.color,
        tester.element(find.byType(TixPage)).tix.accent,
      );
    });
  }

  for (final locale in textLocales) {
    for (final MapEntry(key: width, value: size) in widths.entries) {
      testWidgets('$width, $locale: the header survives twice the text size', (
        tester,
      ) async {
        await pumpComponent(
          tester,
          page(() {}),
          size: size,
          textScale: 2,
          locale: locale,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }
}
