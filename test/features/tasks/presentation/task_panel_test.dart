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
