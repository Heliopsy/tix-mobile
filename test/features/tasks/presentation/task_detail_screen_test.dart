// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/features/tasks/presentation/detail/properties.dart';
import 'package:tix_mobile/src/features/tasks/presentation/detail/sections.dart';
import 'package:tix_mobile/src/features/tasks/presentation/task_detail_screen.dart';

import '../../../helpers/fake_tix.dart';
import 'detail/harness.dart';

void main() {
  late FakeTix server;

  setUp(() => server = FakeTix());

  for (final MapEntry(key: width, value: size) in {
    'compact': tallPhone,
    'expanded': tallDesktop,
  }.entries) {
    testWidgets('$width: loading, then the task', (tester) async {
      server.gate = Completer<void>();
      await pumpTask(tester, server, size: size, settle: false);
      expect(find.byType(SkeletonBox), findsWidgets);
      expect(find.text('Fix login'), findsNothing);
      server.gate!.complete();
      await tester.pumpAndSettle();
      expect(find.text('Fix login'), findsOneWidget);
      expect(find.byType(SkeletonBox), findsNothing);
    });

    testWidgets('$width: a missing task says so and can be retried', (
      tester,
    ) async {
      await pumpTask(tester, server, ref: 'infra-99', size: size);
      expect(find.textContaining('Not found.'), findsOneWidget);
      expect(find.byType(SkeletonBox), findsNothing);
      expect(find.byType(TaskProperties), findsNothing);
      server.tasks['infra']!.add(taskJson('infra-99', title: 'Late'));
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('Late'), findsOneWidget);
    });
  }

  testWidgets('a wide pane puts the properties beside the description', (
    tester,
  ) async {
    await pumpTask(tester, server, size: tallDesktop);
    final props = tester.getRect(find.byType(TaskProperties));
    final description = tester.getRect(find.byType(DescriptionSection));
    expect(props.left, greaterThan(description.right));
    expect(props.top, lessThan(description.bottom));
  });

  testWidgets('a narrow pane stacks the properties above the description', (
    tester,
  ) async {
    await pumpTask(tester, server);
    final props = tester.getRect(find.byType(TaskProperties));
    final description = tester.getRect(find.byType(DescriptionSection));
    expect(props.bottom, lessThanOrEqualTo(description.top));
    expect(props.left, description.left);
  });

  testWidgets('shows the fields, the assignee by name and the description', (
    tester,
  ) async {
    await pumpTask(tester, server);
    expect(find.text('infra-1'), findsOneWidget);
    expect(find.text('Fix login'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('prop.status')),
        matching: find.text('to do'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('prop.priority')),
        matching: find.text('highest'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('prop.assignee')),
        matching: find.text('Raj'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('prop.due')),
        matching: find.textContaining('Nov 20, 2026'),
      ),
      findsOneWidget,
    );
    expect(find.text('#auth'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('task.description')),
        matching: find.text('Steps'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('task.description')),
        matching: find.text('reproduce'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('says what is missing', (tester) async {
    await pumpTask(tester, server, ref: 'infra-2');
    expect(find.text('Unassigned'), findsOneWidget);
    expect(find.text('No due date'), findsOneWidget);
    expect(find.text('No description.'), findsOneWidget);
    expect(find.byKey(const Key('task.description')), findsNothing);
  });

  testWidgets('falls back to the id when the assignee cannot be read', (
    tester,
  ) async {
    server.actors.remove('a1');
    await pumpTask(tester, server);
    expect(
      find.descendant(
        of: find.byKey(const Key('prop.assignee')),
        matching: find.text('a1'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('labels are Bulgarian in Bulgarian', (tester) async {
    await pumpTask(tester, server, ref: 'infra-2', locale: const Locale('bg'));
    expect(find.text('Изпълнител'), findsOneWidget);
    expect(find.text('Без краен срок'), findsOneWidget);
    expect(find.text('Подзадачи'), findsOneWidget);
  });

  testWidgets('at twice the text size a phone does not overflow', (
    tester,
  ) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await pumpTask(tester, server, size: const Size(400, 8000));
    expect(tester.takeException(), isNull);
    expect(find.text('Fix login'), findsOneWidget);
  });

  testWidgets('on a desktop, t opens the move sheet', (tester) async {
    await pumpTask(tester, server, size: tallDesktop);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyT);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('move.doing')), findsOneWidget);
  });

  testWidgets('on a desktop, d marks the task done', (tester) async {
    await pumpTask(tester, server, size: tallDesktop);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyD);
    await tester.pumpAndSettle();
    expect(bodies(server, 'POST', '/tasks/infra-1/route'), [
      {'to': 'done'},
    ]);
    expect(toast('Moved infra-1 to done.'), findsOneWidget);
    expect(find.byKey(const Key('description.field')), findsNothing);
  });

  testWidgets('d leaves a finished task where it is', (tester) async {
    server.tasks['infra']![0]['status'] = 'cancelled';
    await pumpTask(tester, server, size: tallDesktop);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyD);
    await tester.pumpAndSettle();
    expect(count(server, 'POST', '/tasks/infra-1/route'), 0);
    expect(count(server, 'POST', '/tasks/infra-1/transition'), 0);
  });

  testWidgets('on a desktop, E edits the description', (tester) async {
    await pumpTask(tester, server, size: tallDesktop);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyE);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('description.field')), findsOneWidget);
    expect(find.byKey(const Key('title.field')), findsNothing);
  });

  testWidgets('on a desktop, m focuses the comment field', (tester) async {
    await pumpTask(tester, server, size: tallDesktop);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyM);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('move.doing')), findsNothing);
    expect(typingInField(), isTrue);
  });

  testWidgets('on a desktop, y copies the reference', (tester) async {
    final copied = <Object?>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') copied.add(call.arguments);
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await pumpTask(tester, server, size: tallDesktop);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyY);
    await tester.pumpAndSettle();
    expect(copied, [
      {'text': 'infra-1'},
    ]);
  });

  testWidgets('on a desktop, s stars the task', (tester) async {
    await pumpTask(tester, server, size: tallDesktop);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
    await tester.pumpAndSettle();
    expect(count(server, 'PUT', '/tasks/infra-1/star'), 1);
    final star = tester.widget<TixIconButton>(
      find.byKey(const Key('task.star')),
    );
    expect(star.selected, isTrue);
  });

  testWidgets('keys typed into a field stay in it', (tester) async {
    await pumpTask(tester, server, size: tallDesktop);
    await tester.tap(find.byKey(const Key('comment.field')));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.keyS);
    await tester.pumpAndSettle();
    expect(count(server, 'PUT', '/tasks/infra-1/star'), 0);
  });

  testWidgets('the task screen frames the view without a second reference', (
    tester,
  ) async {
    await pumpTask(tester, server);
    final view = tester.widget<TaskDetailView>(find.byType(TaskDetailView));
    expect(view.showRef, isFalse);
  });
}
