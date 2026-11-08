// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';

import '../../../helpers/design.dart';

void main() {
  testWidgets('a swipe each way runs its action and the row stays', (
    tester,
  ) async {
    final ran = <String>[];
    await pumpComponent(
      tester,
      Column(
        children: [
          TixSwipeActions(
            id: 'row',
            start: TixSwipeAction.complete('Complete', () => ran.add('done')),
            end: TixSwipeAction.snooze('Snooze', () => ran.add('snooze')),
            child: const SizedBox(
              width: double.infinity,
              height: 56,
              child: Text('Fix login'),
            ),
          ),
        ],
      ),
    );
    await tester.drag(find.text('Fix login'), const Offset(300, 0));
    await tester.pumpAndSettle();
    await tester.drag(find.text('Fix login'), const Offset(-300, 0));
    await tester.pumpAndSettle();
    expect(ran, ['done', 'snooze']);
    expect(find.text('Fix login'), findsOneWidget);
  });

  testWidgets('a short swipe does nothing', (tester) async {
    final ran = <String>[];
    await pumpComponent(
      tester,
      TixSwipeActions(
        id: 'row',
        start: TixSwipeAction.star('Star', () => ran.add('star')),
        child: const SizedBox(
          width: double.infinity,
          height: 56,
          child: Text('Fix login'),
        ),
      ),
    );
    await tester.timedDrag(
      find.text('Fix login'),
      const Offset(40, 0),
      const Duration(seconds: 1),
    );
    await tester.pumpAndSettle();
    expect(ran, isEmpty);
  });
}
