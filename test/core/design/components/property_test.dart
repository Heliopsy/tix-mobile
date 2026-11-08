// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';

import '../../../helpers/app.dart';
import '../../../helpers/design.dart';

void main() {
  Widget list(VoidCallback onTap) => SingleChildScrollView(
    child: TixPropertyList(
      children: [
        TixPropertyRow(
          key: const Key('priority'),
          label: 'Priority',
          editLabel: 'Change priority',
          onTap: onTap,
          child: const Text('high'),
        ),
        const TixPropertyRow(
          key: Key('project'),
          label: 'Project',
          info: 'Where the task lives.',
          child: Text('Infrastructure'),
        ),
      ],
    ),
  );

  testWidgets('an editable row is a 48 dp button with a pencil', (
    tester,
  ) async {
    var taps = 0;
    await pumpComponent(tester, list(() => taps++));
    final row = find.byKey(const Key('priority'));
    expect(tester.getSize(row).height, greaterThanOrEqualTo(48));
    expect(
      find.descendant(of: row, matching: find.byIcon(Icons.edit_outlined)),
      findsOneWidget,
    );
    await tester.tap(find.text('high'));
    expect(taps, 1);
    expect(find.bySemanticsLabel(RegExp('Change priority')), findsOneWidget);
  });

  testWidgets('a read-only row has no pencil and does nothing', (tester) async {
    await pumpComponent(tester, list(() {}));
    final row = find.byKey(const Key('project'));
    expect(
      find.descendant(of: row, matching: find.byIcon(Icons.edit_outlined)),
      findsNothing,
    );
    expect(
      find.descendant(of: row, matching: find.byType(InkWell)),
      findsNothing,
    );
    expect(find.byType(InfoTip), findsOneWidget);
  });

  testWidgets('wide, the label sits beside the value; at 200% above it', (
    tester,
  ) async {
    await pumpComponent(tester, list(() {}));
    final label = tester.getTopLeft(find.text('Priority'));
    final value = tester.getTopLeft(find.text('high'));
    expect(value.dx, greaterThan(label.dx));
    expect((value.dy - label.dy).abs(), lessThan(12));
  });

  for (final MapEntry(key: width, value: size) in widths.entries) {
    testWidgets('$width: at twice the text size the value moves under it', (
      tester,
    ) async {
      await pumpComponent(tester, list(() {}), size: size, textScale: 2);
      expect(tester.takeException(), isNull);
      final label = tester.getTopLeft(find.text('Priority'));
      final value = tester.getTopLeft(find.text('high'));
      expect(value.dy, greaterThan(label.dy));
    });
  }
}
