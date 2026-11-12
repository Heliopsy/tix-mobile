// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/data/models/group_pref.dart';
import 'package:tix_mobile/src/data/models/project.dart';
import 'package:tix_mobile/src/data/models/saved_filter.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/data/models/workflow.dart';
import 'package:tix_mobile/src/features/tasks/application/listing.dart';
import 'package:tix_mobile/src/features/tasks/application/screen.dart';

import '../../../helpers/container.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;

  setUp(() => server = FakeTix());

  group('the screen state', () {
    test(
      'a valid expression applies, a bad one is reported and kept out',
      () async {
        final c = await signedInContainer(server);
        final p = taskScreenProvider(const AllScope());
        c.read(p.notifier).setExpression('  tag:ops ');
        expect(c.read(p).expression, 'tag:ops');
        c.read(p.notifier).setExpression('colour:red');
        expect(c.read(p).expression, 'tag:ops');
        expect(c.read(p).filterError, contains('unknown filter key "colour"'));
        c.read(p.notifier).setExpression('tag:ops');
        expect(c.read(p).filterError, isNull);
      },
    );

    test('chips toggle terms and due windows replace each other', () async {
      final c = await signedInContainer(server);
      final p = taskScreenProvider(const AllScope());
      final n = c.read(p.notifier)..toggleTerm('is:starred');
      expect(c.read(p).expression, 'is:starred');
      n.setDue('week');
      expect(c.read(p).expression, 'is:starred due:week');
      n.setDue('today');
      expect(c.read(p).expression, 'is:starred due:today');
      n.setDue('today');
      expect(c.read(p).expression, 'is:starred');
      n.toggleTerm('is:starred');
      expect(c.read(p).expression, '');
    });

    test('a saved filter brings its expression, sort and view', () async {
      final c = await signedInContainer(server);
      final p = taskScreenProvider(const ProjectScope('infra'));
      const f = SavedFilter(
        id: 'f1',
        name: 'Ops',
        query: 'tag:ops',
        sort: 'priority',
        view: 'lanes',
      );
      c.read(p.notifier).applySaved(f);
      expect(c.read(p).expression, 'tag:ops');
      expect(c.read(p).sort, 'priority');
      expect(c.read(p).view, TaskView.lanes);
      expect(c.read(p).savedFilterId, 'f1');
      c.read(p.notifier).clear();
      expect(c.read(p).expression, '');
      expect(c.read(p).sort, 'priority');
    });

    test('views cycle through what the scope offers', () async {
      final c = await signedInContainer(server);
      final p = taskScreenProvider(const ProjectScope('infra'));
      c.read(p.notifier).cycleView();
      expect(c.read(p).view, TaskView.board);
      c.read(p.notifier).cycleView();
      expect(c.read(p).view, TaskView.lanes);
      c.read(p.notifier).cycleView();
      expect(c.read(p).view, TaskView.list);
      expect(viewsFor(const MineScope()), [TaskView.list]);
    });

    test('the list asks for open work, the board for all of it', () {
      const s = TaskScreenState();
      expect(s.query(const AllScope()).openOnly, isTrue);
      expect(s.query(const AllScope()).limit, listPageSize);
      final board = s.copyWith(view: TaskView.board).query(const AllScope());
      expect((board.openOnly, board.limit), (false, boardPageSize));
      expect(
        s.copyWith(showFinished: true).query(const AllScope()).openOnly,
        isFalse,
      );
      expect(s.query(const MineScope()).openOnly, isTrue);
    });
  });

  test('selection toggles, adds and leaves', () async {
    final c = await signedInContainer(server);
    final p = taskSelectionProvider(const AllScope());
    final sub = c.listen(p, (_, _) {});
    addTearDown(sub.close);
    c.read(p.notifier)
      ..toggle('a')
      ..selectAll(['b', 'c'])
      ..toggle('a');
    expect(c.read(p).refs, {'b', 'c'});
    expect(c.read(p).active, isTrue);
    c.read(p.notifier).exit();
    expect(c.read(p).refs, isEmpty);
    expect(c.read(p).active, isFalse);
  });

  test('picking starts select mode and unpicking the last ends it', () async {
    final c = await signedInContainer(server);
    final p = taskSelectionProvider(const AllScope());
    final sub = c.listen(p, (_, _) {});
    addTearDown(sub.close);
    c.read(p.notifier).toggle('a');
    expect(c.read(p).active, isTrue);
    c.read(p.notifier).toggle('a');
    expect(c.read(p).active, isFalse);
  });

  test('the Select button keeps select mode on with nothing picked', () async {
    final c = await signedInContainer(server);
    final p = taskSelectionProvider(const AllScope());
    final sub = c.listen(p, (_, _) {});
    addTearDown(sub.close);
    c.read(p.notifier).enter();
    expect(c.read(p).active, isTrue);
    expect(c.read(p).refs, isEmpty);
    c.read(p.notifier)
      ..toggle('a')
      ..toggle('a');
    expect(c.read(p).active, isTrue);
    expect(c.read(p).refs, isEmpty);
  });

  test('a range runs from the anchor in either direction', () async {
    final c = await signedInContainer(server);
    final p = taskSelectionProvider(const AllScope());
    final sub = c.listen(p, (_, _) {});
    addTearDown(sub.close);
    const order = ['a', 'b', 'c', 'd', 'e'];
    c.read(p.notifier).selectRange(order, 'd');
    expect(c.read(p).refs, {'d'});
    c.read(p.notifier).selectRange(order, 'b');
    expect(c.read(p).refs, {'b', 'c', 'd'});
    c.read(p.notifier)
      ..exit()
      ..toggle('b')
      ..selectRange(order, 'e');
    expect(c.read(p).refs, {'b', 'c', 'd', 'e'});
  });

  test('groups arrange starred first, then moved, then natural', () {
    final arranged = arrangeGroups(
      ['todo', 'doing', 'blocked', 'done'],
      {
        'done': const GroupPref(group: 'done', starred: true),
        'blocked': const GroupPref(group: 'blocked', position: 1),
        'todo': const GroupPref(group: 'todo', hidden: true),
      },
    );
    expect(arranged.visible, ['done', 'blocked', 'doing']);
    expect(arranged.hidden, ['todo']);
  });

  group('the arrangement of a view', () {
    test('changes at once and rolls back when refused', () async {
      final c = await signedInContainer(server);
      final p = viewArrangementProvider('board');
      final sub = c.listen(p, (_, _) {});
      addTearDown(sub.close);
      await c.read(p.future);
      await c.read(p.notifier).hide('blocked', hidden: true);
      expect(c.read(p).value!['blocked']!.hidden, isTrue);
      server.override = FakeResponse(403, envelope('forbidden', 'no'));
      await expectLater(
        c.read(p.notifier).star('todo', starred: true),
        throwsA(anything),
      );
      expect(c.read(p).value!['todo'], isNull);
    });

    test('moving swaps neighbours and sends the whole order', () async {
      final c = await signedInContainer(server);
      final p = viewArrangementProvider('board');
      final sub = c.listen(p, (_, _) {});
      addTearDown(sub.close);
      await c.read(p.future);
      await c.read(p.notifier).move('doing', -1, ['todo', 'doing', 'done']);
      expect(server.requestsTo('/order').single.body, {
        'groups': ['doing', 'todo', 'done'],
      });
      final order = arrangeGroups(['todo', 'doing', 'done'], c.read(p).value!);
      expect(order.visible, ['doing', 'todo', 'done']);
      await c.read(p.notifier).move('doing', -1, ['todo', 'doing', 'done']);
      expect(
        server.requestsTo('/order'),
        hasLength(1),
        reason: 'first already',
      );
      await c.read(p.notifier).reset();
      expect(c.read(p).value, isEmpty);
    });
  });

  test('saved filters save, rename, share, move and delete', () async {
    final c = await signedInContainer(server);
    final p = savedFiltersProvider;
    final sub = c.listen(p, (_, _) {});
    addTearDown(sub.close);
    await c.read(p.future);
    final n = c.read(p.notifier);
    final a = await n.save(
      name: 'A',
      query: 'tag:a',
      sort: '',
      view: 'list',
      shared: false,
    );
    await n.save(name: 'B', query: 'tag:b', sort: '', view: '', shared: true);
    await c.read(p.future);
    await n.move(a, 1);
    expect(c.read(p).value!.map((f) => f.name), ['B', 'A']);
    await n.rename(a, 'A2');
    await n.share(a, shared: true);
    expect(server.filters.firstWhere((f) => f['id'] == a.id)['shared'], true);
    await n.delete(a);
    expect((await c.read(p.future)).map((f) => f.name), ['B']);
  });

  test('due dates fall under My work headings', () {
    final now = DateTime(2026, 11, 4, 10);
    expect(dueBucket(null, now), DueBucket.none);
    expect(dueBucket(DateTime(2026, 11, 4, 9), now), DueBucket.overdue);
    expect(dueBucket(DateTime(2026, 11, 4, 18), now), DueBucket.today);
    expect(dueBucket(DateTime(2026, 11, 9), now), DueBucket.week);
    expect(dueBucket(DateTime(2026, 11, 20), now), DueBucket.later);
  });

  group('lanes', () {
    const infra = Project(id: 'p1', key: 'infra', workflowId: 'wf1');
    const web = Project(id: 'p2', key: 'web', workflowId: 'wf1');
    final ctx = TaskIndex(
      projects: const [infra, web],
      workflows: [Workflow.fromJson(workflowJson())],
    );
    final now = DateTime.utc(2026, 11, 12, 12);
    Task task(
      String ref, {
      String project = 'p1',
      String assignee = '',
      int priority = 3,
      List<String> tags = const [],
      DateTime? due,
    }) => Task.fromJson({
      ...taskJson(
        ref,
        priority: priority,
        assignee: assignee,
        tags: tags,
        due: due?.toIso8601String(),
      ),
      'project_id': project,
    });
    final handles = {'a1': 'raj', 'a2': 'lena'};
    List<Lane> lanes(
      List<Task> tasks,
      LaneGrouping by, {
      String expression = '',
      Map<String, GroupPref> prefs = const {},
    }) => buildLanes(
      tasks,
      by: by,
      query: TaskQuery(expression: expression),
      context: ctx,
      handleOf: (t) => handles[t.assigneeActorId] ?? '',
      me: 'lena',
      now: now,
      prefs: prefs,
    );
    String drawn(List<Lane> ls) =>
        [for (final l in ls) '${l.key}[${l.term}]=${l.tasks.map((t) => t.ref)}']
            .join(' ');

    test('a project page offers every grouping but Project, by assignee', () {
      expect(laneGroupingsFor(const ProjectScope('infra')), [
        LaneGrouping.assignee,
        LaneGrouping.priority,
        LaneGrouping.tag,
        LaneGrouping.due,
      ]);
      const project = TaskScreenState(lanes: LaneGrouping.project);
      expect(lanesOf(project, const ProjectScope('x')), LaneGrouping.assignee);
      expect(lanesOf(project, const AllScope()), LaneGrouping.project);
      expect(
        lanesOf(const TaskScreenState(), const AllScope()),
        LaneGrouping.project,
      );
      expect(LaneGrouping.project.view, 'lanes');
      expect(LaneGrouping.tag.view, 'lanes:tag');
    });

    test('by project, each lane links to its project', () {
      final ls = lanes([task('w-1', project: 'p2')], LaneGrouping.project);
      expect(drawn(ls), 'web[project:web]=(w-1)');
    });

    test('by assignee: people A to Z, a named one empty, Unassigned last', () {
      final ls = lanes(
        [task('t-1', assignee: 'a1'), task('t-2'), task('t-3', assignee: 'a9')],
        LaneGrouping.assignee,
        expression: 'assignee:me',
      );
      expect(
        drawn(ls),
        'a9[assignee:a9]=(t-3) lena[assignee:lena]=() '
        'raj[assignee:raj]=(t-1) -[]=(t-2)',
      );
    });

    test('by priority: highest first, a named priority drawn empty', () {
      final ls = lanes(
        [task('t-1', priority: 4), task('t-2', priority: 1)],
        LaneGrouping.priority,
        expression: 'priority:high',
      );
      expect(
        drawn(ls),
        'highest[priority:highest]=(t-2) high[priority:high]=() '
        'low[priority:low]=(t-1)',
      );
    });

    test('by tag: named first, then A to Z, each card once, No tag last', () {
      final tasks = [
        task('t-1', tags: ['ops', 'api']),
        task('t-2'),
        task('t-3', tags: ['web']),
      ];
      expect(
        drawn(lanes(tasks, LaneGrouping.tag, expression: 'tag:zeta')),
        'zeta[tag:zeta]=() api[tag:api]=(t-1) web[tag:web]=(t-3) -[]=(t-2)',
        reason: 'ops holds no card of its own and nothing names it',
      );
      final hidden = lanes(
        tasks,
        LaneGrouping.tag,
        prefs: {'api': const GroupPref(group: 'api', hidden: true)},
      );
      expect(
        drawn(hidden),
        'ops[tag:ops]=(t-1) web[tag:web]=(t-3) -[]=(t-2)',
        reason: 'a hidden lane gives its cards to the next of their tags',
      );
    });

    test('by due: only the buckets a card lands in, with no link', () {
      final ls = lanes([
        task('t-1', due: now.subtract(const Duration(days: 1))),
        task('t-2'),
      ], LaneGrouping.due);
      expect(drawn(ls), 'overdue[]=(t-1) none[]=(t-2)');
    });

    test('a lane heading replaces the filter with its term', () async {
      final c = await signedInContainer(server);
      final p = taskScreenProvider(const AllScope());
      c.read(p.notifier)
        ..setView(TaskView.lanes)
        ..setLanes(LaneGrouping.tag)
        ..setExpression('is:starred')
        ..showLane('tag:ops');
      expect(c.read(p).expression, 'tag:ops');
      expect(
        (c.read(p).view, c.read(p).lanes),
        (TaskView.lanes, LaneGrouping.tag),
      );
    });
  });

  group('board layout', () {
    final standard = Workflow.fromJson(workflowJson());
    final other = Workflow.fromJson(
      workflowJson(id: 'wf2', key: 'short', states: ['open', 'closed']),
    );
    final ctx = TaskIndex(
      projects: const [
        Project(id: 'p1', key: 'infra', workflowId: 'wf1'),
        Project(id: 'p2', key: 'web', workflowId: 'wf1'),
        Project(id: 'p3', key: 'ops', workflowId: 'wf2'),
      ],
      workflows: [standard, other],
    );

    test('a project draws its own workflow under its own view', () {
      final layout = boardLayout(
        const TaskQuery(scope: ProjectScope('infra')),
        ctx,
      );
      expect(layout, isA<BoardColumns>());
      expect((layout as BoardColumns).view, 'project:infra');
      expect(layout.workflow.id, 'wf1');
    });

    test('projects that agree share a board', () {
      final layout = boardLayout(
        const TaskQuery(expression: 'project:infra project:web'),
        ctx,
      );
      expect((layout as BoardColumns).view, 'board');
    });

    test('projects that disagree are refused, naming each workflow', () {
      final layout = boardLayout(const TaskQuery(), ctx);
      expect(layout, isA<BoardRefused>());
      final groups = (layout as BoardRefused).groups;
      expect(groups.map((g) => '${g.$1.id}: ${g.$2.map((p) => p.key)}'), [
        'wf1: (infra, web)',
        'wf2: (ops)',
      ]);
    });
  });
}
