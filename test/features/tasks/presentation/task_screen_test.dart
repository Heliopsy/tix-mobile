// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
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

  for (final MapEntry(key: width, value: size) in widths.entries) {
    group(width, () {
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
    await tester.tap(find.byKey(const Key('menu.select')));
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
    await tester.tap(find.byKey(const Key('menu.select')));
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
    await tester.longPress(row('Landing page'));
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
    await tester.tap(find.byKey(const Key('menu.select')));
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

  group('the board', () {
    Future<void> board(WidgetTester tester, {Size size = desktop}) async {
      await pump(tester, const TaskListScreen(projectKey: 'infra'), size: size);
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
