// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/gestures.dart'
    show kDoubleTapMinTime, kDoubleTapTimeout;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/features/tasks/presentation/task_list_screen.dart';
import 'package:tix_mobile/src/features/tasks/presentation/task_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_tix.dart';
import '../../../helpers/stores.dart';

void main() {
  late FakeTix server;
  late MemoryKeyValueStore settings;

  setUp(() {
    server = FakeTix(
      tasks: {
        'infra': [
          taskJson('infra-1', title: 'Fix login'),
          taskJson('infra-2', title: 'Rotate keys', status: 'doing'),
        ],
      },
    );
  });

  Future<void> pump(
    WidgetTester tester,
    Widget screen, {
    Size size = desktop,
  }) async {
    final stores = signedInStores();
    settings = stores.settings;
    await pumpScreen(
      tester,
      TixShortcuts(child: screen),
      size: size,
      overrides: fakeOverrides(
        server,
        settings: stores.settings,
        secrets: stores.secrets,
      ),
    );
  }

  final panel = find.byType(TaskPanel);
  final close = find.byKey(const Key('tasks.detail.close'));

  Future<void> open(WidgetTester tester, String title) async {
    await tester.tap(find.text(title));
    await tester.pumpAndSettle();
  }

  testWidgets('the close button shuts a task opened from Tasks', (
    tester,
  ) async {
    await pump(tester, const TasksScreen());
    await open(tester, 'Fix login');
    expect(panel, findsOneWidget);
    expect(find.byTooltip('Close task'), findsOneWidget);
    await tester.tap(close);
    await tester.pumpAndSettle();
    expect(panel, findsNothing);
    expect(find.text('Fix login'), findsOneWidget);
  });

  testWidgets('Escape shuts it', (tester) async {
    await pump(tester, const TasksScreen());
    await open(tester, 'Fix login');
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(panel, findsNothing);
  });

  testWidgets('in select mode Escape leaves select mode first', (tester) async {
    await pump(
      tester,
      const TaskListScreen(projectKey: 'infra', selectedRef: 'infra-1'),
    );
    await tester.tap(find.byKey(const Key('view.board')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tasks.selectMode')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('bulk.bar')), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('bulk.bar')), findsNothing);
    expect(panel, findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('route:/projects/infra'), findsOneWidget);
  });

  testWidgets('going elsewhere and back shows the plain list', (tester) async {
    await pump(tester, const TasksScreen());
    await open(tester, 'Fix login');
    final router = GoRouter.of(tester.element(panel));
    unawaited(router.push('/inbox'));
    await tester.pumpAndSettle();
    expect(find.text('route:/inbox'), findsOneWidget);
    router.pop();
    await tester.pumpAndSettle();
    expect(find.text('Fix login'), findsOneWidget);
    expect(panel, findsNothing);
  });

  testWidgets("a project's task closes to the project's own address", (
    tester,
  ) async {
    await pump(
      tester,
      const TaskListScreen(projectKey: 'infra', selectedRef: 'infra-1'),
    );
    expect(panel, findsOneWidget);
    await tester.tap(close);
    await tester.pumpAndSettle();
    expect(find.text('route:/projects/infra'), findsOneWidget);
  });

  testWidgets("Escape closes a project's task to the project", (tester) async {
    await pump(
      tester,
      const TaskListScreen(projectKey: 'infra', selectedRef: 'infra-1'),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('route:/projects/infra'), findsOneWidget);
  });

  testWidgets('with no task open the list takes the whole window', (
    tester,
  ) async {
    await pump(tester, const TaskListScreen(projectKey: 'infra'));
    expect(panel, findsNothing);
    expect(find.byKey(const Key('tasks.detail.pane')), findsNothing);
    expect(find.byType(VerticalDivider), findsNothing);
    expect(find.byType(EmptyState), findsNothing);
    final row = tester.getSize(find.byType(TaskRow).first);
    expect(row.width, greaterThan(desktop.width / 2));
  });

  testWidgets('a task open beside the list gets the resizable panel', (
    tester,
  ) async {
    await pump(
      tester,
      const TaskListScreen(projectKey: 'infra', selectedRef: 'infra-1'),
    );
    expect(panel, findsOneWidget);
    expect(find.byKey(const Key('tasks.detail.pane')), findsOneWidget);
    expect(find.byKey(const Key('tasks.detail.resize')), findsOneWidget);
  });

  group('beside a board', () {
    final pane = find.byKey(const Key('tasks.detail.pane'));
    final handle = find.byKey(const Key('tasks.detail.resize'));

    Future<void> board(WidgetTester tester) async {
      await pump(
        tester,
        const TaskListScreen(projectKey: 'infra', selectedRef: 'infra-1'),
      );
      await tester.tap(find.byKey(const Key('view.board')));
      await tester.pumpAndSettle();
    }

    testWidgets('the panel drags wider and keeps its width', (tester) async {
      await board(tester);
      expect(tester.getSize(pane).width, 460);
      await tester.drag(handle, const Offset(-100, 0));
      await tester.pump(kDoubleTapTimeout);
      await tester.pumpAndSettle();
      expect(tester.getSize(pane).width, 560);
      expect(settings.values['layout.detail.width'], '560');
      expect(close, findsOneWidget);
    });

    testWidgets('a double click restores its width', (tester) async {
      await board(tester);
      await tester.drag(handle, const Offset(100, 0));
      await tester.pump(kDoubleTapTimeout);
      await tester.pumpAndSettle();
      expect(tester.getSize(pane).width, 360);
      await tester.tap(handle);
      await tester.pump(kDoubleTapMinTime);
      await tester.tap(handle);
      await tester.pumpAndSettle();
      expect(tester.getSize(pane).width, 460);
      expect(settings.values.containsKey('layout.detail.width'), isFalse);
    });

    testWidgets('a kept width is used', (tester) async {
      final stores = signedInStores();
      stores.settings.values['layout.detail.width'] = '600';
      settings = stores.settings;
      await pumpScreen(
        tester,
        const TaskListScreen(projectKey: 'infra', selectedRef: 'infra-1'),
        size: desktop,
        overrides: fakeOverrides(
          server,
          settings: stores.settings,
          secrets: stores.secrets,
        ),
      );
      await tester.tap(find.byKey(const Key('view.board')));
      await tester.pumpAndSettle();
      expect(tester.getSize(pane).width, 600);
    });
  });

  group('no mark is left on a row', () {
    TaskRow row(WidgetTester tester, String title) => tester.widget<TaskRow>(
      find.ancestor(of: find.text(title), matching: find.byType(TaskRow)),
    );

    testWidgets('once the task opened with a click is closed', (tester) async {
      await pump(tester, const TasksScreen());
      await open(tester, 'Fix login');
      expect(row(tester, 'Fix login').selected, isTrue);
      expect(row(tester, 'Fix login').focused, isFalse);
      await tester.tap(close);
      await tester.pumpAndSettle();
      expect(row(tester, 'Fix login').selected, isFalse);
      expect(row(tester, 'Fix login').focused, isFalse);
    });

    testWidgets('when the window narrows and the panel goes', (tester) async {
      await pump(tester, const TasksScreen());
      await open(tester, 'Fix login');
      await setSize(tester, phone);
      await tester.pumpAndSettle();
      expect(panel, findsNothing);
      expect(row(tester, 'Fix login').selected, isFalse);
    });

    testWidgets('by the keyboard cursor after a click', (tester) async {
      await pump(tester, const TasksScreen());
      await tester.sendKeyEvent(LogicalKeyboardKey.keyJ);
      await tester.pump();
      expect(row(tester, 'Fix login').focused, isTrue);
      await tester.tap(find.text('Rotate keys'));
      await tester.pumpAndSettle();
      await tester.tap(close);
      await tester.pumpAndSettle();
      expect(row(tester, 'Fix login').focused, isFalse);
      expect(row(tester, 'Rotate keys').focused, isFalse);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyJ);
      await tester.pump();
      expect(row(tester, 'Fix login').focused, isTrue);
    });

    testWidgets('of a board card opened with a click', (tester) async {
      await pump(tester, const TasksScreen());
      await tester.tap(find.byKey(const Key('view.board')));
      await tester.pumpAndSettle();
      final card = find.byKey(const Key('card.infra-1'));
      await tester.tap(card);
      await tester.pumpAndSettle();
      await tester.tap(close);
      await tester.pumpAndSettle();
      expect(tester.widget<TaskCard>(card).selected, isFalse);
    });
  });

  testWidgets('a phone opens the task on its own screen, with no panel', (
    tester,
  ) async {
    await pump(tester, const TasksScreen(), size: phone);
    await open(tester, 'Fix login');
    expect(panel, findsNothing);
    expect(close, findsNothing);
    expect(find.text('route:/projects/infra/tasks/infra-1'), findsOneWidget);
  });
}
