// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/features/tasks/presentation/task_detail_screen.dart';
import 'package:tix_mobile/src/features/tasks/presentation/task_list_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;

  setUp(() => server = FakeTix());

  Future<void> pump(
    WidgetTester tester,
    Widget screen, {
    Size size = phone,
    bool settle = true,
  }) {
    final stores = signedInStores();
    return pumpScreen(
      tester,
      screen,
      size: size,
      settle: settle,
      overrides: fakeOverrides(
        server,
        settings: stores.settings,
        secrets: stores.secrets,
      ),
    );
  }

  for (final MapEntry(key: width, value: size) in widths.entries) {
    group(width, () {
      testWidgets('loading, then data', (tester) async {
        server.gate = Completer<void>();
        await pump(
          tester,
          const TaskListScreen(projectKey: 'infra'),
          size: size,
          settle: false,
        );
        expect(find.byType(SkeletonList), findsOneWidget);
        server.gate!.complete();
        await tester.pumpAndSettle();
        expect(find.text('Fix login'), findsOneWidget);
      });

      testWidgets('empty', (tester) async {
        await pump(tester, const TaskListScreen(projectKey: 'web'), size: size);
        expect(find.text('No tasks in this project.'), findsOneWidget);
      });

      testWidgets('error, then retry', (tester) async {
        server.override = FakeResponse(403, envelope('forbidden', 'no'));
        await pump(
          tester,
          const TaskListScreen(projectKey: 'infra'),
          size: size,
        );
        expect(
          find.text('This token is not allowed to do that.'),
          findsOneWidget,
        );
        server.override = null;
        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle();
        expect(find.text('Fix login'), findsOneWidget);
      });
    });
  }

  testWidgets('on a phone the list opens a task on its own route', (
    tester,
  ) async {
    await pump(tester, const TaskListScreen(projectKey: 'infra'));
    expect(find.text('Fix login'), findsOneWidget);
    final row = find.ancestor(
      of: find.text('Fix login'),
      matching: find.byType(TaskRow),
    );
    for (final text in ['infra-1', 'todo', 'due Nov 20']) {
      expect(
        find.descendant(of: row, matching: find.text(text)),
        findsOneWidget,
      );
    }
    expect(find.byType(TaskDetailView), findsNothing);
    await tester.tap(find.text('Rotate keys'));
    await tester.pumpAndSettle();
    expect(find.text('route:/projects/infra/tasks/infra-2'), findsOneWidget);
  });

  testWidgets('on a wide screen the selected task sits beside the list', (
    tester,
  ) async {
    await pump(
      tester,
      const TaskListScreen(projectKey: 'infra', selectedRef: 'infra-1'),
      size: desktop,
    );
    final tile = tester.widget<TaskRow>(
      find.ancestor(
        of: find.text('Rotate keys'),
        matching: find.byType(TaskRow),
      ),
    );
    expect(tile.selected, isFalse);
    final selected = tester.widget<TaskRow>(
      find.ancestor(
        of: find.text('Fix login').first,
        matching: find.byType(TaskRow),
      ),
    );
    expect(selected.selected, isTrue);
    expect(
      find.descendant(
        of: find.byType(TaskDetailView),
        matching: find.byKey(const Key('task.status')),
      ),
      findsOneWidget,
    );
  });

  testWidgets('on a wide screen with nothing selected the pane says so', (
    tester,
  ) async {
    await pump(
      tester,
      const TaskListScreen(projectKey: 'infra'),
      size: desktop,
    );
    expect(find.text('Pick a task to see it here.'), findsOneWidget);
    expect(find.byType(TaskDetailView), findsNothing);
  });

  testWidgets('an empty project says so', (tester) async {
    await pump(tester, const TaskListScreen(projectKey: 'web'));
    expect(find.text('No tasks in this project.'), findsOneWidget);
  });

  testWidgets('priorities read as words to a screen reader', (tester) async {
    await pump(tester, const TaskListScreen(projectKey: 'infra'));
    final semantics = tester.ensureSemantics();
    for (final label in ['Highest', 'Normal']) {
      expect(
        find.descendant(
          of: find.byType(PriorityMark),
          matching: find.bySemanticsLabel(label),
        ),
        findsOneWidget,
      );
    }
    semantics.dispose();
  });

  testWidgets('quick add creates the task and confirms it', (tester) async {
    await pump(tester, const TaskListScreen(projectKey: 'infra'));
    await tester.tap(find.byKey(const Key('tasks.quickAdd')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('quickAdd.line')),
      'Ship it !high #release',
    );
    await tester.tap(find.byKey(const Key('quickAdd.submit')));
    await tester.pumpAndSettle();
    expect(find.text('Created infra-3'), findsOneWidget);
    expect(find.byKey(const Key('quickAdd.line')), findsNothing);
    expect(find.text('Ship it'), findsOneWidget);
    final post = server.requests.singleWhere((r) => r.method == 'POST');
    expect(post.data, {
      'title': 'Ship it !high #release',
      'project_ref': 'infra',
      'parse': true,
    });
  });

  testWidgets('a refused quick add keeps the line and says why', (
    tester,
  ) async {
    await pump(tester, const TaskListScreen(projectKey: 'infra'));
    await tester.tap(find.byKey(const Key('tasks.quickAdd')));
    await tester.pumpAndSettle();
    server.override = FakeResponse(
      400,
      envelope('invalid', 'unknown handle "nobody"'),
    );
    await tester.enterText(find.byKey(const Key('quickAdd.line')), 'x @nobody');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.textContaining('unknown handle "nobody"'), findsOneWidget);
    expect(find.text('x @nobody'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('quickAdd.line')), findsNothing);
    expect(find.textContaining('Created'), findsNothing);
  });

  testWidgets('an empty quick add sends nothing', (tester) async {
    await pump(tester, const TaskListScreen(projectKey: 'infra'));
    await tester.tap(find.byKey(const Key('tasks.quickAdd')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('quickAdd.submit')));
    await tester.pumpAndSettle();
    expect(server.requests.where((r) => r.method == 'POST'), isEmpty);
  });
}
