// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/features/tasks/presentation/task_detail_screen.dart';
import 'package:tix_mobile/src/features/tasks/presentation/task_list_screen.dart';
import 'package:tix_mobile/src/features/tasks/presentation/task_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;

  setUp(() {
    server = FakeTix(
      tasks: {
        'infra': [
          taskJson('infra-1', title: 'Fix login', priority: 1, assignee: 'me'),
          taskJson('infra-2', title: 'Rotate keys', status: 'doing'),
          taskJson('infra-3', title: 'Old work', status: 'done'),
        ],
        'web': [
          taskJson('web-1', title: 'Landing page', due: '2026-10-30T00:00:00Z'),
        ],
      },
    );
  });

  Future<void> pump(
    WidgetTester tester,
    Widget screen, {
    Size size = phone,
    bool settle = true,
  }) async {
    final stores = signedInStores();
    await pumpScreen(
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

  List<Uri> listings() => [
    for (final r in server.requestsTo('/api/v1/tasks'))
      if (r.method == 'GET') r.uri,
  ];

  Finder row(String title) =>
      find.ancestor(of: find.text(title), matching: find.byType(TaskRow));

  TextSpan? heldNote(WidgetTester tester) {
    for (final text in tester.widgetList<Text>(find.byType(Text))) {
      final span = text.textSpan;
      if (span is! TextSpan) continue;
      for (final child in span.children ?? const <InlineSpan>[]) {
        if (child is TextSpan && (child.text ?? '').contains('held by')) {
          return child;
        }
      }
    }
    return null;
  }

  for (final MapEntry(key: width, value: size) in widths.entries) {
    group(width, () {
      testWidgets('says how many tasks an agent holds, in the accent', (
        tester,
      ) async {
        final soon = fixedNow.add(const Duration(minutes: 20));
        server.tasks['infra']![0].addAll(heldJson(soon));
        server.tasks['infra']![1].addAll(heldJson(soon));
        server.tasks['web']![0].addAll(
          heldJson(fixedNow.subtract(const Duration(minutes: 1))),
        );
        await pump(tester, const TasksScreen(), size: size);
        final note = heldNote(tester);
        expect(note?.text, '2 held by an agent');
        final accent = tester.element(find.byType(TasksScreen)).tix.accent;
        expect(note?.style?.color, accent);
      });

      testWidgets('says nothing about agents when none holds a task', (
        tester,
      ) async {
        await pump(tester, const TasksScreen(), size: size);
        expect(find.text('Fix login'), findsOneWidget);
        expect(heldNote(tester), isNull);
      });

      testWidgets('loading, then open work', (tester) async {
        server.gate = Completer<void>();
        await pump(tester, const TasksScreen(), size: size, settle: false);
        await tester.pump(const Duration(milliseconds: 50));
        expect(find.byType(SkeletonList), findsOneWidget);
        server.gate!.complete();
        await tester.pumpAndSettle();
        expect(find.text('Fix login'), findsOneWidget);
        expect(find.text('Landing page'), findsOneWidget);
        expect(find.text('Old work'), findsNothing);
        expect(listings().last.queryParametersAll['status'], [
          'todo',
          'doing',
          'blocked',
        ]);
      });

      testWidgets('a filter that matches nothing says so', (tester) async {
        await pump(tester, const TasksScreen(), size: size);
        await tester.enterText(find.byKey(const Key('filter.field')), 'zzz');
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pumpAndSettle();
        expect(find.text('Nothing matches this filter.'), findsOneWidget);
        expect(listings().last.queryParameters['q'], 'zzz');
      });

      testWidgets('an error, then retry', (tester) async {
        server.override = FakeResponse(403, envelope('forbidden', 'no'));
        await pump(tester, const TasksScreen(), size: size);
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

  testWidgets('a chip writes its term and asks again', (tester) async {
    await pump(tester, const TasksScreen());
    await tester.tap(find.byKey(const Key('chip.mine')));
    await tester.pumpAndSettle();
    final field = tester.widget<TextField>(
      find.byKey(const Key('filter.field')),
    );
    expect(field.controller!.text, 'assignee:me');
    expect(listings().last.queryParametersAll['assignee'], ['me']);
    expect(find.text('Fix login'), findsOneWidget);
    expect(find.text('Landing page'), findsNothing);
    await tester.tap(find.byKey(const Key('chip.mine')));
    await tester.pumpAndSettle();
    expect(field.controller!.text, '');
    expect(find.text('Landing page'), findsOneWidget);
  });

  testWidgets('Finished shows done work too', (tester) async {
    await pump(tester, const TasksScreen());
    await tester.ensureVisible(find.byKey(const Key('chip.finished')));
    await tester.tap(find.byKey(const Key('chip.finished')));
    await tester.pumpAndSettle();
    expect(find.text('Old work'), findsOneWidget);
    expect(listings().last.queryParameters.containsKey('status'), isFalse);
  });

  testWidgets('a bad expression is reported and the rows stay', (tester) async {
    await pump(tester, const TasksScreen());
    final before = listings().length;
    await tester.enterText(find.byKey(const Key('filter.field')), 'colour:red');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.byKey(const Key('filter.error'))).data,
      contains('unknown filter key "colour"'),
    );
    expect(find.text('Fix login'), findsOneWidget);
    expect(listings(), hasLength(before));
  });

  testWidgets('a swipe completes at once and Undo reopens', (tester) async {
    await pump(tester, const TasksScreen());
    await tester.drag(row('Fix login'), const Offset(300, 0));
    await tester.pumpAndSettle();
    expect(server.requestsTo('/tasks/bulk').single.body, {
      'action': 'move',
      'refs': ['infra-1'],
      'to': 'done',
    });
    expect(
      tester
          .widget<TaskCheck>(
            find.descendant(
              of: row('Fix login'),
              matching: find.byType(TaskCheck),
            ),
          )
          .done,
      isTrue,
    );
    expect(find.text('infra-1 completed'), findsOneWidget);
    await tester.tap(find.byKey(const Key('toast.action')));
    await tester.pumpAndSettle();
    expect(server.requestsTo('/tasks/bulk').last.body['to'], 'todo');
    expect(
      tester
          .widget<TaskCheck>(
            find.descendant(
              of: row('Fix login'),
              matching: find.byType(TaskCheck),
            ),
          )
          .done,
      isFalse,
    );
  });

  testWidgets('a refused star goes back and says why', (tester) async {
    await pump(tester, const TasksScreen());
    server.override = FakeResponse(403, envelope('forbidden', 'nope'));
    await tester.tap(
      find.descendant(of: row('Fix login'), matching: find.byTooltip('Star')),
    );
    await tester.pumpAndSettle();
    expect(server.requests.last.method, 'PUT');
    expect(
      find.descendant(
        of: row('Fix login'),
        matching: find.byIcon(Icons.star_outline_rounded),
      ),
      findsOneWidget,
    );
    expect(find.textContaining('not allowed'), findsOneWidget);
  });

  testWidgets('picked rows star in one request with one Undo', (tester) async {
    await pump(tester, const TasksScreen());
    await tester.longPress(row('Fix login'));
    await tester.pumpAndSettle();
    await tester.tap(row('Landing page'));
    await tester.pumpAndSettle();
    expect(find.text('2 selected'), findsOneWidget);
    await tester.tap(find.byKey(const Key('bulk.star')));
    await tester.pumpAndSettle();
    expect(server.requestsTo('/tasks/bulk').single.body, {
      'action': 'star',
      'refs': ['infra-1', 'web-1'],
    });
    expect(find.byKey(const Key('bulk.bar')), findsNothing);
    expect(find.text('2 tasks changed'), findsOneWidget);
    await tester.tap(find.byKey(const Key('toast.action')));
    await tester.pumpAndSettle();
    expect(server.requestsTo('/tasks/bulk').last.body, {
      'action': 'unstar',
      'refs': ['infra-1', 'web-1'],
    });
  });

  testWidgets('picked rows go to anyone in the tenant', (tester) async {
    await pump(tester, const TasksScreen(), size: desktop);
    await tester.longPress(row('Fix login'));
    await tester.pumpAndSettle();
    await tester.tap(row('Landing page'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bulk.assign')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('actor.a1')));
    await tester.pumpAndSettle();
    expect(server.requestsTo('/tasks/bulk').single.body, {
      'action': 'assign',
      'refs': ['infra-1', 'web-1'],
      'assignee_actor_id': 'a1',
    });
    await tester.tap(find.byKey(const Key('toast.action')));
    await tester.pumpAndSettle();
    final undo = server.requestsTo('/tasks/bulk').skip(1).map((r) => r.body);
    expect(undo, [
      {
        'action': 'assign',
        'refs': ['infra-1'],
        'assignee_actor_id': 'me',
      },
      {
        'action': 'assign',
        'refs': ['web-1'],
        'assignee_actor_id': '',
      },
    ]);
  });

  testWidgets('a row is given to someone from its menu', (tester) async {
    await pump(tester, const TasksScreen());
    await tester.tap(
      find.descendant(
        of: row('Landing page'),
        matching: find.byKey(const Key('row.more')),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('menu.assign')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('actor.a1')));
    await tester.pumpAndSettle();
    expect(server.requestsTo('/tasks/bulk').single.body, {
      'action': 'assign',
      'refs': ['web-1'],
      'assignee_actor_id': 'a1',
    });
    expect(find.text('web-1 assigned'), findsOneWidget);
  });

  testWidgets('a bulk delete confirms, then names a refused task', (
    tester,
  ) async {
    server.refuse['web-1'] = ('forbidden', 'not yours');
    await pump(tester, const TasksScreen(), size: desktop);
    await tester.longPress(row('Fix login'));
    await tester.pumpAndSettle();
    await tester.tap(row('Landing page'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bulk.delete')));
    await tester.pumpAndSettle();
    expect(server.requestsTo('/tasks/bulk'), isEmpty);
    await tester.tap(find.byKey(const Key('confirm.ok')));
    await tester.pumpAndSettle();
    expect(find.text('Fix login'), findsNothing);
    expect(find.text('Landing page'), findsOneWidget);
    expect(find.text('1 changed. Refused: web-1: not yours'), findsOneWidget);
  });

  testWidgets('picked rows move to another project with no Undo', (
    tester,
  ) async {
    await pump(tester, const TasksScreen(), size: desktop);
    await tester.longPress(row('Fix login'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bulk.moveProject')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('moveProject.infra')), findsNothing);
    await tester.tap(find.byKey(const Key('moveProject.web')));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('its old reference keeps leading to it'),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('moveProject.confirm')));
    await tester.pumpAndSettle();
    expect(server.requestsTo('/tasks/bulk').single.body, {
      'action': 'move_project',
      'refs': ['infra-1'],
      'project_ref': 'web',
    });
    expect(find.text('1 task changed'), findsOneWidget);
    expect(find.byKey(const Key('toast.action')), findsNothing);
  });

  testWidgets('j, j and Enter open the second task', (tester) async {
    await pump(tester, const TixShortcuts(child: TasksScreen()));
    await tester.sendKeyEvent(LogicalKeyboardKey.keyJ);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyJ);
    await tester.pump();
    expect(tester.widget<TaskRow>(row('Rotate keys')).focused, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyX);
    await tester.pumpAndSettle();
    expect(find.text('1 selected'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('bulk.bar')), findsNothing);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('route:/projects/infra/tasks/infra-2'), findsOneWidget);
  });

  testWidgets('a task tapped open is not left marked on the way back', (
    tester,
  ) async {
    await pump(tester, const TixShortcuts(child: TasksScreen()));
    await tester.tap(find.text('Rotate keys'));
    await tester.pumpAndSettle();
    expect(find.text('route:/projects/infra/tasks/infra-2'), findsOneWidget);
    GoRouter.of(tester.element(find.textContaining('route:'))).pop();
    await tester.pumpAndSettle();
    expect(tester.widget<TaskRow>(row('Rotate keys')).focused, isFalse);
    expect(tester.widget<TaskRow>(row('Rotate keys')).selected, isFalse);
  });

  group('quick edits on a row', () {
    List<Object?> patches(String ref) => [
      for (final r in server.requestsTo('/tasks/$ref'))
        if (r.method == 'PATCH') r.data,
    ];

    Finder inRow(String title, Finder f) =>
        find.descendant(of: row(title), matching: f);

    testWidgets('the priority opens the picker, and Undo puts it back', (
      tester,
    ) async {
      await pump(tester, const TasksScreen());
      await tester.tap(inRow('Fix login', find.byType(PriorityMark)));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('priority.2')));
      await tester.pumpAndSettle();
      expect(patches('infra-1'), [
        {'priority': 2},
      ]);
      expect(
        tester
            .widget<PriorityMark>(inRow('Fix login', find.byType(PriorityMark)))
            .priority,
        2,
      );
      expect(find.text('infra-1 priority changed'), findsOneWidget);
      await tester.tap(find.byKey(const Key('toast.action')));
      await tester.pumpAndSettle();
      expect(patches('infra-1').last, {'priority': 1});
      expect(
        tester
            .widget<PriorityMark>(inRow('Fix login', find.byType(PriorityMark)))
            .priority,
        1,
      );
    });

    testWidgets('the status opens the moves its workflow allows', (
      tester,
    ) async {
      await pump(tester, const TasksScreen());
      await tester.tap(inRow('Fix login', find.byType(StatusPill)));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('move.doing')));
      await tester.pumpAndSettle();
      expect(server.requestsTo('/tasks/bulk').single.body, {
        'action': 'move',
        'refs': ['infra-1'],
        'to': 'doing',
      });
      expect(find.text('infra-1 moved to Doing'), findsOneWidget);
    });

    testWidgets('the menu sets a due date and adds a tag', (tester) async {
      await pump(tester, const TasksScreen());
      Future<void> menu(String item) async {
        await tester.tap(inRow('Fix login', find.byKey(const Key('row.more'))));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(Key(item)));
        await tester.pumpAndSettle();
      }

      await menu('menu.due');
      await tester.tap(find.byKey(const Key('due.tomorrow')));
      await tester.pumpAndSettle();
      final local = fixedNow.toLocal();
      final tomorrow = DateTime(local.year, local.month, local.day + 1);
      expect(patches('infra-1'), [
        {'due_at': tomorrow.toUtc().toIso8601String()},
      ]);
      expect(find.text('infra-1 due date set'), findsOneWidget);

      await menu('menu.tag');
      await tester.tap(find.byKey(const Key('tag.offer.ops')));
      await tester.pumpAndSettle();
      expect(
        [
          for (final r in server.requestsTo('/tasks/infra-1/tags'))
            if (r.method == 'POST') r.data,
        ],
        [
          {'name': 'ops'},
        ],
      );
      expect(find.text('infra-1 tagged ops'), findsOneWidget);
    });

    testWidgets('the menu shares the task', (tester) async {
      final copied = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied.add((call.arguments as Map)['text'] as String);
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await pump(tester, const TasksScreen());
      await tester.tap(inRow('Fix login', find.byKey(const Key('row.more'))));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('menu.share')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('share.text')));
      await tester.pumpAndSettle();
      expect(copied, ['infra-1 Fix login']);
      expect(find.text('Key and title copied'), findsOneWidget);
    });

    testWidgets('p on the focused row opens the priority picker', (
      tester,
    ) async {
      await pump(tester, const TixShortcuts(child: TasksScreen()));
      await tester.sendKeyEvent(LogicalKeyboardKey.keyJ);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyJ);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyP);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('priority.1')));
      await tester.pumpAndSettle();
      expect(patches('infra-2'), [
        {'priority': 1},
      ]);
      expect(patches('infra-1'), isEmpty);
    });

    testWidgets('in select mode the chips only pick', (tester) async {
      await pump(tester, const TasksScreen());
      await tester.longPress(row('Fix login'));
      await tester.pumpAndSettle();
      await tester.tap(inRow('Rotate keys', find.byType(PriorityMark)));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('priority.1')), findsNothing);
      expect(find.text('2 selected'), findsOneWidget);
    });
  });

  group('a ticked row', () {
    Widget screen({required bool reduced}) => Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
        child: const TixShortcuts(child: TasksScreen()),
      ),
    );

    Future<void> tickThenRefresh(WidgetTester tester) async {
      await tester.tap(
        find.descendant(of: row('Fix login'), matching: find.byType(TaskCheck)),
      );
      await tester.pumpAndSettle();
      expect(server.requestsTo('/tasks/bulk').single.body['to'], 'done');
      await tester.sendKeyEvent(LogicalKeyboardKey.keyR);
      await tester.pump();
      await tester.pump(TixMotion.fast);
    }

    testWidgets('stays a moment when the listing drops it, then collapses', (
      tester,
    ) async {
      await pump(tester, screen(reduced: false));
      await tickThenRefresh(tester);
      expect(find.text('Fix login'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('Fix login'), findsNothing);
      expect(find.text('Rotate keys'), findsOneWidget);
    });

    testWidgets('goes at once with reduced motion', (tester) async {
      await pump(tester, screen(reduced: true));
      await tickThenRefresh(tester);
      expect(find.text('Fix login'), findsNothing);
      expect(find.text('Rotate keys'), findsOneWidget);
    });

    testWidgets('never shows open again while a refresh waits on the server', (
      tester,
    ) async {
      await pump(tester, screen(reduced: false));
      await tester.tap(
        find.descendant(of: row('Fix login'), matching: find.byType(TaskCheck)),
      );
      await tester.pumpAndSettle();
      final gate = server.gate = Completer<void>();
      await tester.sendKeyEvent(LogicalKeyboardKey.keyR);
      for (var frame = 0; frame < 30; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
        final ticks = find.descendant(
          of: row('Fix login'),
          matching: find.byType(TaskCheck),
        );
        for (final e in ticks.evaluate()) {
          expect((e.widget as TaskCheck).done, isTrue, reason: 'frame $frame');
        }
      }
      server.gate = null;
      gate.complete();
      await tester.pumpAndSettle();
      expect(find.text('Fix login'), findsNothing);
      expect(find.text('Rotate keys'), findsOneWidget);
    });
  });

  group('select mode', () {
    Finder bar() => find.byKey(const Key('bulk.bar'));

    Finder pick(String title) =>
        find.descendant(of: row(title), matching: find.byType(TaskPick));

    Finder tick(String title) =>
        find.descendant(of: row(title), matching: find.byType(TaskCheck));

    Future<void> withKey(
      WidgetTester tester,
      LogicalKeyboardKey key,
      Future<void> Function() action,
    ) async {
      await tester.sendKeyDownEvent(key);
      await action();
      await tester.sendKeyUpEvent(key);
      await tester.pumpAndSettle();
    }

    testWidgets('is off by default: only the tick on each row', (tester) async {
      await pump(tester, const TasksScreen());
      expect(find.byType(TaskPick), findsNothing);
      expect(find.byType(TaskCheck), findsNWidgets(3));
      expect(bar(), findsNothing);
    });

    testWidgets('the Select button turns it on with nothing picked and it '
        'stays until left from the bar', (tester) async {
      await pump(tester, const TasksScreen());
      await tester.tap(find.byKey(const Key('tasks.selectMode')));
      await tester.pumpAndSettle();
      expect(find.text('0 selected'), findsOneWidget);
      expect(find.byType(TaskPick), findsNWidgets(3));
      expect(find.byKey(const Key('tasks.quickAdd')), findsNothing);
      await tester.tap(row('Fix login'));
      await tester.pumpAndSettle();
      expect(find.text('1 selected'), findsOneWidget);
      expect(find.textContaining('route:'), findsNothing);
      await tester.tap(row('Fix login'));
      await tester.pumpAndSettle();
      expect(find.text('0 selected'), findsOneWidget);
      expect(find.byType(TaskPick), findsNWidgets(3));
      await tester.tap(find.byKey(const Key('bulk.clear')));
      await tester.pumpAndSettle();
      expect(bar(), findsNothing);
      expect(find.byType(TaskPick), findsNothing);
    });

    testWidgets('Escape leaves it after the Select button', (tester) async {
      await pump(tester, const TixShortcuts(child: TasksScreen()));
      await tester.tap(find.byKey(const Key('tasks.selectMode')));
      await tester.pumpAndSettle();
      expect(bar(), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(bar(), findsNothing);
      expect(find.byType(TaskPick), findsNothing);
    });

    testWidgets('a long press picks the row, and unpicking the last row '
        'leaves', (tester) async {
      await pump(tester, const TasksScreen());
      await tester.longPress(row('Fix login'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('menu.open')), findsNothing);
      expect(find.text('1 selected'), findsOneWidget);
      expect(tester.widget<TaskPick>(pick('Fix login')).picked, isTrue);
      expect(tester.widget<TaskPick>(pick('Rotate keys')).picked, isFalse);
      await tester.tap(row('Fix login'));
      await tester.pumpAndSettle();
      expect(bar(), findsNothing);
      expect(find.byType(TaskPick), findsNothing);
    });

    testWidgets('the menu stays on the dots', (tester) async {
      await pump(tester, const TasksScreen());
      await tester.tap(
        find.descendant(
          of: row('Fix login'),
          matching: find.byKey(const Key('row.more')),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('menu.open')), findsOneWidget);
      expect(bar(), findsNothing);
    });

    testWidgets('back leaves select mode before the screen', (tester) async {
      await pump(tester, const TasksScreen());
      await tester.longPress(row('Fix login'));
      await tester.pumpAndSettle();
      expect(bar(), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(bar(), findsNothing);
      expect(find.text('Fix login'), findsOneWidget);
    });

    testWidgets('Ctrl-click picks a row and Shift-click a range', (
      tester,
    ) async {
      await pump(tester, const TasksScreen(), size: desktop);
      await withKey(
        tester,
        LogicalKeyboardKey.controlLeft,
        () => tester.tap(row('Fix login')),
      );
      expect(find.text('1 selected'), findsOneWidget);
      expect(find.byType(TaskDetailView), findsNothing);
      await withKey(
        tester,
        LogicalKeyboardKey.shiftLeft,
        () => tester.tap(row('Rotate keys')),
      );
      expect(find.text('2 selected'), findsOneWidget);
      expect(tester.widget<TaskPick>(pick('Landing page')).picked, isFalse);
      await withKey(
        tester,
        LogicalKeyboardKey.shiftLeft,
        () => tester.tap(row('Landing page')),
      );
      expect(find.text('3 selected'), findsOneWidget);
    });

    testWidgets('the tick is muted, read as nothing and only picks', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pump(tester, const TasksScreen());
      expect(find.bySemanticsLabel('Mark done'), findsWidgets);
      await tester.tap(find.byKey(const Key('tasks.selectMode')));
      await tester.pumpAndSettle();
      expect(tester.widget<TaskCheck>(tick('Fix login')).inert, isTrue);
      expect(find.bySemanticsLabel('Mark done'), findsNothing);
      expect(find.bySemanticsLabel('Select'), findsWidgets);
      await tester.tap(tick('Fix login'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text('1 selected'), findsOneWidget);
      expect(server.requestsTo('/tasks/bulk'), isEmpty);
      semantics.dispose();
    });

    testWidgets('x picks, Shift+Down extends, Escape leaves, d completes', (
      tester,
    ) async {
      await pump(tester, const TixShortcuts(child: TasksScreen()));
      await tester.sendKeyEvent(LogicalKeyboardKey.keyJ);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyX);
      await tester.pumpAndSettle();
      expect(find.text('1 selected'), findsOneWidget);
      await withKey(
        tester,
        LogicalKeyboardKey.shiftLeft,
        () => tester.sendKeyEvent(LogicalKeyboardKey.arrowDown),
      );
      expect(find.text('2 selected'), findsOneWidget);
      expect(tester.widget<TaskPick>(pick('Rotate keys')).picked, isTrue);
      expect(tester.widget<TaskRow>(row('Rotate keys')).focused, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(bar(), findsNothing);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyE);
      await tester.pumpAndSettle();
      expect(server.requestsTo('/tasks/bulk'), isEmpty);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyD);
      await tester.pumpAndSettle();
      expect(server.requestsTo('/tasks/bulk').single.body, {
        'action': 'move',
        'refs': ['infra-2'],
        'to': 'done',
      });
    });
  });

  group('the board', () {
    Future<void> board(WidgetTester tester, {Size size = desktop}) async {
      await pump(tester, const TaskListScreen(projectKey: 'infra'), size: size);
      if (size == phone) {
        await tester.tap(find.byKey(const Key('view.menu')));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.byKey(const Key('view.board')));
      await tester.pumpAndSettle();
    }

    Finder column(String key) => find.byKey(ValueKey(('column', key)));

    testWidgets('draws the workflow with counts', (tester) async {
      await board(tester);
      for (final s in ['todo', 'doing', 'blocked', 'done', 'cancelled']) {
        expect(column(s), findsOneWidget);
      }
      expect(
        tester.widget<Text>(find.byKey(const Key('column.done.count'))).data,
        '1',
      );
      expect(listings().last.queryParameters['limit'], '200');
    });

    testWidgets('a drag moves the card and offers Undo', (tester) async {
      await board(tester);
      final from = tester.getCenter(find.byKey(const Key('card.infra-1')));
      final to = tester.getCenter(column('doing'));
      final gesture = await tester.startGesture(from);
      await gesture.moveBy(const Offset(20, 0));
      await tester.pump();
      await gesture.moveTo(to);
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      expect(server.requestsTo('/tasks/bulk').single.body, {
        'action': 'move',
        'refs': ['infra-1'],
        'to': 'doing',
      });
      expect(
        find.descendant(
          of: column('doing'),
          matching: find.byKey(const Key('card.infra-1')),
        ),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('toast.action')));
      await tester.pumpAndSettle();
      expect(server.requestsTo('/tasks/bulk').last.body['to'], 'todo');
      expect(
        find.descendant(
          of: column('todo'),
          matching: find.byKey(const Key('card.infra-1')),
        ),
        findsOneWidget,
      );
    });

    testWidgets('a drop on its own column sends nothing', (tester) async {
      await board(tester);
      final from = tester.getCenter(find.byKey(const Key('card.infra-1')));
      final gesture = await tester.startGesture(from);
      await gesture.moveBy(const Offset(20, 40));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      expect(server.requestsTo('/tasks/bulk'), isEmpty);
    });

    testWidgets('a column the workflow cannot reach refuses the card', (
      tester,
    ) async {
      final definition =
          server.workflows.first['definition']! as Map<String, Object?>;
      definition['transitions'] = [
        for (final t in definition['transitions']! as List<Object?>)
          <String, Object?>{
            ...t! as Map<String, Object?>,
            if ((t as Map)['to'] == 'cancelled') 'requires_comment': true,
          },
      ];
      await board(tester, size: const Size(1900, 900));
      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('card.infra-1'))),
      );
      await gesture.moveBy(const Offset(20, 0));
      await tester.pump();
      await gesture.moveTo(tester.getCenter(column('cancelled')));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
      expect(server.requestsTo('/tasks/bulk'), isEmpty);
    });

    testWidgets('a hidden column goes and can come back', (tester) async {
      await board(tester);
      await tester.tap(find.byKey(const Key('group.blocked.menu')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('group.blocked.hide')));
      await tester.pumpAndSettle();
      expect(column('blocked'), findsNothing);
      expect(server.requestsTo('/groups/blocked').single.body, {
        'hidden': true,
      });
      await tester.ensureVisible(find.byKey(const Key('hidden.project:infra')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('hidden.project:infra')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('hidden.show.blocked')));
      await tester.pumpAndSettle();
      expect(column('blocked'), findsOneWidget);
    });

    testWidgets('projects on different workflows get the list', (tester) async {
      server.workflows.add(
        workflowJson(id: 'wf2', key: 'short', states: ['open', 'closed']),
      );
      server.projects[1]['workflow_id'] = 'wf2';
      await pump(tester, const TasksScreen(), size: desktop);
      await tester.tap(find.byKey(const Key('view.board')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('board.refused')), findsOneWidget);
      expect(find.textContaining('Default (default): infra'), findsOneWidget);
      expect(row('Fix login'), findsOneWidget);
    });

    testWidgets('cards pick with Ctrl-click, then with a tap, and stop '
        'dragging', (tester) async {
      await board(tester);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.tap(find.byKey(const Key('card.infra-1')));
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      expect(find.text('1 selected'), findsOneWidget);
      expect(find.byType(TaskPick), findsNWidgets(3));
      expect(find.byType(Draggable<Task>), findsNothing);
      await tester.tap(find.byKey(const Key('card.infra-2')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('bulk.star')));
      await tester.pumpAndSettle();
      expect(server.requestsTo('/tasks/bulk').single.body, {
        'action': 'star',
        'refs': ['infra-1', 'infra-2'],
      });
    });

    testWidgets('a long press on a phone picks the card it ends on', (
      tester,
    ) async {
      await board(tester, size: phone);
      await tester.longPress(find.byKey(const Key('card.infra-1')));
      await tester.pumpAndSettle();
      expect(find.text('1 selected'), findsOneWidget);
      expect(
        tester
            .widget<TaskPick>(
              find.descendant(
                of: find.byKey(const Key('card.infra-1')),
                matching: find.byType(TaskPick),
              ),
            )
            .picked,
        isTrue,
      );
      expect(server.requestsTo('/tasks/bulk'), isEmpty);
    });
  });

  testWidgets('lanes pick cards with a long press and mute the ticks', (
    tester,
  ) async {
    await pump(tester, const TasksScreen(), size: desktop);
    await tester.tap(find.byKey(const Key('view.lanes')));
    await tester.pumpAndSettle();
    await tester.longPress(find.byKey(const Key('card.web-1')));
    await tester.pumpAndSettle();
    expect(find.text('1 selected'), findsOneWidget);
    expect(find.byKey(const Key('menu.open')), findsNothing);
    final tick = find.descendant(
      of: find.byKey(const Key('card.infra-1')),
      matching: find.byType(TaskCheck),
    );
    expect(tester.widget<TaskCheck>(tick).inert, isTrue);
    await tester.tap(tick, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('2 selected'), findsOneWidget);
    expect(server.requestsTo('/tasks/bulk'), isEmpty);
    await tester.tap(find.byKey(const Key('card.web-1')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('card.infra-1')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('bulk.bar')), findsNothing);
    expect(find.byType(TaskPick), findsNothing);
  });

  testWidgets('lanes draw a lane per project with ticks', (tester) async {
    await pump(tester, const TasksScreen(), size: desktop);
    await tester.tap(find.byKey(const Key('view.lanes')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey(('lane', 'infra'))), findsOneWidget);
    expect(find.byKey(const ValueKey(('lane', 'web'))), findsOneWidget);
    expect(find.byKey(const Key('card.infra-3')), findsNothing);
    await tester.tap(find.byKey(const Key('chip.lanesFinished')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('card.infra-3')), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('card.web-1')),
        matching: find.byType(TaskCheck),
      ),
    );
    await tester.pumpAndSettle();
    expect(server.requestsTo('/tasks/bulk').single.body['to'], 'done');
  });

  testWidgets('lanes group by priority, and a heading narrows to its lane', (
    tester,
  ) async {
    await pump(tester, const TasksScreen(), size: desktop);
    await tester.tap(find.byKey(const Key('view.lanes')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sort.menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('lanes.by.priority')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey(('lane', 'infra'))), findsNothing);
    Finder inLane(String lane, String card) => find.descendant(
      of: find.byKey(ValueKey(('lane', lane))),
      matching: find.byKey(Key('card.$card')),
    );
    expect(inLane('highest', 'infra-1'), findsOneWidget);
    expect(inLane('normal', 'web-1'), findsOneWidget);
    expect(find.byKey(const ValueKey(('lane', 'low'))), findsNothing);
    expect(
      server.requests.map((r) => Uri.decodeFull(r.uri.path)),
      contains('/api/v1/views/lanes:priority/groups'),
    );
    await tester.tap(find.byKey(const Key('lane.head.highest')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('filter.field')))
          .controller!
          .text,
      'priority:highest',
    );
    expect(listings().last.queryParametersAll['priority'], ['1']);
    expect(inLane('highest', 'infra-1'), findsOneWidget);
  });

  testWidgets("My work groups the reader's tasks by deadline", (tester) async {
    server.tasks['web']!.first['assignee_actor_id'] = 'me';
    await pump(tester, const MyWorkScreen());
    expect(listings().last.queryParameters['assignee'], 'me');
    expect(find.byKey(const Key('heading.overdue')), findsOneWidget);
    expect(find.byKey(const Key('heading.none')), findsOneWidget);
    expect(find.byKey(const Key('heading.today')), findsNothing);
    await tester.tap(find.byKey(const Key('heading.none')));
    await tester.pumpAndSettle();
    expect(find.text('Fix login'), findsNothing);
    expect(server.requestsTo('/groups/none').single.body, {'collapsed': true});
  });

  testWidgets('the filter saves under a name and becomes a chip', (
    tester,
  ) async {
    await pump(tester, const TasksScreen());
    await tester.tap(find.byKey(const Key('chip.starred')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('saved.save')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('save.name')), 'Stars');
    await tester.tap(find.byKey(const Key('save.shared')));
    await tester.tap(find.byKey(const Key('save.ok')));
    await tester.pumpAndSettle();
    expect(
      server
          .requestsTo('/api/v1/filters')
          .firstWhere((r) => r.method == 'POST')
          .body,
      {
        'name': 'Stars',
        'query': 'is:starred',
        'shared': true,
        'sort': '',
        'view': 'list',
      },
    );
    expect(find.byKey(const Key('saved.f1')), findsOneWidget);
    expect(find.text('Saved Stars'), findsOneWidget);
  });

  testWidgets('a project switches from its title', (tester) async {
    await pump(tester, const TaskListScreen(projectKey: 'infra'));
    await tester.tap(find.byKey(const Key('project.switch')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('project.switch.web')));
    await tester.pumpAndSettle();
    expect(find.text('route:/projects/web'), findsOneWidget);
  });

  group('the project switcher', () {
    setUp(() {
      server = FakeTix(
        projects: [
          {
            'id': 'p1',
            'key': 'infra',
            'name': 'Infrastructure',
            'color': 'blue',
            'icon_name': 'server',
            'workflow_id': 'wf1',
          },
          {
            'id': 'p2',
            'key': 'web',
            'name': 'Web',
            'color': 'violet',
            'icon': 'W',
            'workflow_id': 'wf1',
          },
          {
            'id': 'p3',
            'key': 'ops',
            'name': 'Operations',
            'workflow_id': 'wf1',
          },
        ],
        tasks: {
          'infra': [taskJson('infra-1', title: 'Fix login')],
        },
      );
    });

    Finder within(Key key, Finder matching) =>
        find.descendant(of: find.byKey(key), matching: matching);

    testWidgets("closed, it shows the current project's icon", (tester) async {
      await pump(tester, const TaskListScreen(projectKey: 'infra'));
      final glyph = tester.widget<Icon>(
        within(const Key('project.switch.mark'), find.byType(Icon)),
      );
      expect(glyph.icon, Icons.dns_outlined);
      expect(glyph.color, TixTokens.light.projects[ProjectColour.blue]);
    });

    testWidgets('open, every project wears its mark and the current one a '
        'check', (tester) async {
      await pump(tester, const TaskListScreen(projectKey: 'infra'));
      await tester.tap(find.byKey(const Key('project.switch')));
      await tester.pumpAndSettle();
      for (final key in ['infra', 'web', 'ops']) {
        expect(
          within(Key('project.switch.$key'), find.byType(ProjectMark)),
          findsOneWidget,
        );
      }
      expect(
        within(
          const Key('project.switch.infra'),
          find.byIcon(Icons.dns_outlined),
        ),
        findsOneWidget,
      );
      expect(
        within(const Key('project.switch.web'), find.text('W')),
        findsOneWidget,
      );
      expect(
        within(const Key('project.switch.infra'), find.byIcon(Icons.check)),
        findsOneWidget,
      );
      expect(
        within(const Key('project.switch.web'), find.byIcon(Icons.check)),
        findsNothing,
      );
    });

    testWidgets('a project with no icon or colour gets its monogram', (
      tester,
    ) async {
      await pump(tester, const TaskListScreen(projectKey: 'infra'));
      await tester.tap(find.byKey(const Key('project.switch')));
      await tester.pumpAndSettle();
      final monogram = tester.widget<Text>(
        within(const Key('projectOption.ops.mark'), find.byType(Text)),
      );
      expect(monogram.data, 'OP');
      expect(monogram.style!.color, TixTokens.light.muted);
    });
  });
}
