// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart';
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
        label: 'Mark done',
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

  testWidgets('select mode draws a checkbox and a muted, inert tick', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var toggled = 0;
    final picks = <bool>[];
    await pumpComponent(
      tester,
      TaskRow(
        task: task,
        onTap: () {},
        picked: false,
        onPicked: picks.add,
        onToggleDone: () => toggled++,
        onMore: () {},
      ),
    );
    expect(find.byType(TaskPick), findsOneWidget);
    expect(tester.widget<TaskCheck>(find.byType(TaskCheck)).inert, isTrue);
    expect(find.byKey(const Key('row.more')), findsNothing);
    expect(find.bySemanticsLabel('Mark done'), findsNothing);
    expect(
      tester.getSemantics(find.byType(Checkbox)),
      isSemantics(
        label: 'Select',
        isChecked: false,
        hasCheckedState: true,
        hasTapAction: true,
      ),
    );
    await tester.tap(find.byType(TaskCheck), warnIfMissed: false);
    expect(toggled, 0);
    await tester.tap(find.byType(Checkbox));
    expect(picks, [true]);
    semantics.dispose();
  });

  testWidgets('the dots open the menu, a long press does its own thing', (
    tester,
  ) async {
    var menu = 0;
    var pressed = 0;
    await pumpComponent(
      tester,
      TaskRow(
        task: task,
        onTap: () {},
        onLongPress: () => pressed++,
        onMore: () => menu++,
      ),
    );
    await tester.tap(find.byKey(const Key('row.more')));
    await tester.longPress(find.text(task.title));
    expect((menu, pressed), (1, 1));
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

  group('ticking', () {
    Widget toggling({required bool reduced, bool startDone = false}) {
      var done = startDone;
      return StatefulBuilder(
        builder: (context, setState) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
          child: TaskRow(
            task: task.copyWith(status: done ? 'done' : 'doing'),
            onTap: () {},
            onToggleDone: () => setState(() => done = !done),
          ),
        ),
      );
    }

    Finder strike() => find.byKey(const Key('row.strike'));

    TextDecoration? decoration(WidgetTester tester) =>
        tester.widget<Text>(find.text(task.title)).style?.decoration;

    Color? fill(WidgetTester tester) {
      final box = tester.widget<Container>(
        find.byKey(const Key('check.circle')),
      );
      return (box.decoration! as BoxDecoration).color;
    }

    testWidgets('fills the tick, sweeps the strike-through and settles', (
      tester,
    ) async {
      final haptics = <Object?>[];
      final messenger = tester.binding.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'HapticFeedback.vibrate') {
          haptics.add(call.arguments);
        }
        return null;
      });
      addTearDown(
        () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
      );
      await pumpComponent(tester, toggling(reduced: false));
      final ok = tester.element(find.byType(TaskRow)).tix.ok;
      await tester.tap(find.byType(TaskCheck));
      await tester.pump();
      await tester.pump(TixMotion.fast * 0.5);
      expect(fill(tester), isNot(ok));
      await tester.pump(TixMotion.settle * 0.5);
      expect(strike(), findsOneWidget);
      expect(decoration(tester), isNull);
      await tester.pumpAndSettle();
      expect(strike(), findsNothing);
      expect(decoration(tester), TextDecoration.lineThrough);
      expect(fill(tester), ok);
      expect(haptics, ['HapticFeedbackType.lightImpact']);
    });

    testWidgets('unticking plays it backwards', (tester) async {
      await pumpComponent(tester, toggling(reduced: false, startDone: true));
      expect(decoration(tester), TextDecoration.lineThrough);
      await tester.tap(find.byType(TaskCheck));
      await tester.pump();
      await tester.pump(TixMotion.settle * 0.5);
      expect(strike(), findsOneWidget);
      await tester.pumpAndSettle();
      expect(strike(), findsNothing);
      expect(decoration(tester), isNull);
      expect(fill(tester), Colors.transparent);
    });

    testWidgets('with reduced motion the change is instant', (tester) async {
      await pumpComponent(tester, toggling(reduced: true));
      await tester.tap(find.byType(TaskCheck));
      await tester.pump();
      expect(strike(), findsNothing);
      expect(decoration(tester), TextDecoration.lineThrough);
      expect(fill(tester), tester.element(find.byType(TaskRow)).tix.ok);
      await tester.pump(TixMotion.settle * 0.5);
      expect(strike(), findsNothing);
      expect(decoration(tester), TextDecoration.lineThrough);
    });

    testWidgets('a row drawn done does not animate', (tester) async {
      await pumpComponent(tester, toggling(reduced: false, startDone: true));
      expect(tester.hasRunningAnimations, isFalse);
      expect(strike(), findsNothing);
    });
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
