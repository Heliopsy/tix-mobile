// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/data/models/task.dart';

import '../../../helpers/app.dart';
import '../../../helpers/design.dart';

void main() {
  final task = Task(
    id: 't1',
    ref: 'ops-7',
    title: 'Shed load instead of falling over',
    status: 'doing',
    priority: 2,
    tags: const ['a', 'b', 'c', 'd', 'e'],
    dueAt: fixedNow.subtract(const Duration(days: 30)),
  );
  const facts = TaskFacts(
    projectKey: 'ops',
    projectColour: 'amber',
    assigneeHandle: 'raj',
  );

  Finder inRow(Finder f) =>
      find.descendant(of: find.byType(TaskRow), matching: f);

  testWidgets('a wide row shows every marking, two tags and a count', (
    tester,
  ) async {
    await pumpComponent(
      tester,
      TaskRow(task: task, facts: facts, now: fixedNow, onTap: () {}),
      size: desktop,
    );
    for (final text in ['doing', 'high', '@raj', 'ops', 'overdue', 'ops-7']) {
      expect(inRow(find.text(text)), findsOneWidget, reason: text);
    }
    expect(inRow(find.byType(TagChip)), findsNWidgets(2));
    expect(inRow(find.text('+3')), findsOneWidget);
  });

  testWidgets('a narrow row leaves the tags off', (tester) async {
    await pumpComponent(
      tester,
      TaskRow(task: task, facts: facts, now: fixedNow, onTap: () {}),
    );
    expect(inRow(find.byType(TagChip)), findsNothing);
    expect(inRow(find.text('doing')), findsOneWidget);
  });

  testWidgets('the tick completes and reads as a checkbox', (tester) async {
    final semantics = tester.ensureSemantics();
    var toggled = 0;
    await pumpComponent(
      tester,
      TaskRow(task: task, onTap: () {}, onToggleDone: () => toggled++),
    );
    expect(
      tester.getSemantics(find.byType(TaskCheck)),
      isSemantics(
        label: 'Complete',
        isChecked: false,
        hasCheckedState: true,
        isButton: true,
        hasTapAction: true,
      ),
    );
    await tester.tap(find.byType(TaskCheck));
    expect(toggled, 1);
    semantics.dispose();
  });

  testWidgets('a done task is ticked and has no due mark', (tester) async {
    await pumpComponent(
      tester,
      TaskRow(
        task: task.copyWith(status: 'done'),
        now: fixedNow,
        onTap: () {},
        onToggleDone: () {},
      ),
    );
    expect(tester.widget<TaskCheck>(find.byType(TaskCheck)).done, isTrue);
    expect(find.text('overdue'), findsNothing);
  });

  testWidgets('the row opens the task', (tester) async {
    var opened = 0;
    await pumpComponent(tester, TaskRow(task: task, onTap: () => opened++));
    await tester.tap(find.text(task.title));
    expect(opened, 1);
  });

  for (final locale in textLocales) {
    for (final MapEntry(key: width, value: size) in widths.entries) {
      testWidgets('$width, $locale: twice the text size still fits', (
        tester,
      ) async {
        await pumpComponent(
          tester,
          ListView(
            children: [
              TaskRow(task: task, facts: facts, now: fixedNow, onTap: () {}),
              TaskCard(task: task, facts: facts, now: fixedNow, onTap: () {}),
            ],
          ),
          size: size,
          textScale: 2,
          locale: locale,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }
}
