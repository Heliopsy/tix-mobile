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
    testWidgets('$width: the header survives twice the text size', (
      tester,
    ) async {
      await pumpComponent(tester, page(() {}), size: size, textScale: 2);
      expect(tester.takeException(), isNull);
    });
  }
}
