// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/cache/cache_store.dart';
import 'package:tix_mobile/src/data/models/bulk.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/features/tasks/application/listing.dart';

import '../../../helpers/app.dart';
import '../../../helpers/container.dart';
import '../../../helpers/fake_events.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;

  setUp(() {
    server = FakeTix(
      tasks: {
        'infra': [
          taskJson('infra-1', title: 'One', tags: ['a']),
          taskJson('infra-2', title: 'Two', status: 'doing', starred: true),
          taskJson('infra-3', title: 'Three', status: 'done'),
        ],
        'web': [taskJson('web-1', title: 'Web', assignee: 'me')],
      },
    );
  });

  Future<(ProviderContainer, TaskQuery)> listing(TaskQuery query) async {
    final c = await signedInContainer(server);
    final sub = c.listen(taskListingProvider(query), (_, _) {});
    addTearDown(sub.close);
    await c.read(taskListingProvider(query).future);
    return (c, query);
  }

  List<String> refs(ProviderContainer c, TaskQuery q) => [
    for (final t in c.read(taskListingProvider(q)).value!.items) t.ref,
  ];

  Uri lastListing() => server.requestsTo('/api/v1/tasks').last.uri;

  test('the list asks for open states unless a status is named', () async {
    final (c, q) = await listing(const TaskQuery(openOnly: true));
    expect(lastListing().queryParametersAll['status'], [
      'todo',
      'doing',
      'blocked',
    ]);
    expect(refs(c, q), ['infra-1', 'infra-2', 'web-1']);
    await listing(const TaskQuery(openOnly: true, expression: 'status:done'));
    expect(lastListing().queryParametersAll['status'], ['done']);
    await listing(const TaskQuery());
    expect(lastListing().queryParameters.containsKey('status'), isFalse);
  });

  test('the scope narrows to a project or to the reader', () async {
    final (c, q) = await listing(const TaskQuery(scope: ProjectScope('web')));
    expect(lastListing().queryParametersAll['project'], ['web']);
    expect(refs(c, q), ['web-1']);
    await listing(const TaskQuery(scope: MineScope()));
    final mine = lastListing().queryParameters;
    expect(mine['assignee'], 'me');
    expect(mine['sort'], 'due_at');
  });

  test('sort, direction and page size travel with the query', () async {
    await listing(const TaskQuery(sort: 'title', descending: true, limit: 200));
    final p = lastListing().queryParameters;
    expect((p['sort'], p['direction'], p['limit']), ('title', 'desc', '200'));
  });

  test('a page is appended once and repeats are dropped', () async {
    server.pageSize = 2;
    final (c, q) = await listing(const TaskQuery());
    await c.read(taskListingProvider(q).notifier).loadMore();
    expect(refs(c, q), ['infra-1', 'infra-2', 'infra-3', 'web-1']);
    expect(lastListing().queryParameters['cursor'], '2');
  });

  test('a listing nobody watches stays cached for a while', () async {
    final c = await signedInContainer(server);
    const q = TaskQuery();
    final sub = c.listen(taskListingProvider(q), (_, _) {});
    await c.read(taskListingProvider(q).future);
    sub.close();
    await Future<void>.delayed(Duration.zero);
    final again = c.listen(taskListingProvider(q), (_, _) {});
    addTearDown(again.close);
    expect(c.read(taskListingProvider(q)).hasValue, isTrue);
    expect(server.requestsTo('/api/v1/tasks'), hasLength(1));
  });

  test('a bulk move applies at once and Undo moves each task back', () async {
    final (c, q) = await listing(const TaskQuery());
    final n = c.read(taskListingProvider(q).notifier);
    final run = await n.bulk(
      const BulkTaskInput(
        action: BulkAction.move,
        refs: ['infra-1', 'infra-2'],
        to: 'done',
      ),
    );
    expect(run.result.applied, 2);
    Task row(String ref) => c
        .read(taskListingProvider(q))
        .value!
        .items
        .firstWhere((t) => t.ref == ref);
    expect(row('infra-1').status, 'done');
    await n.undo(run);
    expect(row('infra-1').status, 'todo');
    expect(row('infra-2').status, 'doing');
    final undo = server.requestsTo('/tasks/bulk').skip(1).map((r) => r.body);
    expect(undo, [
      {
        'action': 'move',
        'refs': ['infra-1'],
        'to': 'todo',
      },
      {
        'action': 'move',
        'refs': ['infra-2'],
        'to': 'doing',
      },
    ]);
  });

  test('a refused task goes back and is left out of Undo', () async {
    server.refuse['infra-2'] = ('precondition_failed', 'no route');
    final (c, q) = await listing(const TaskQuery());
    final n = c.read(taskListingProvider(q).notifier);
    final run = await n.bulk(
      const BulkTaskInput(
        action: BulkAction.priority,
        refs: ['infra-1', 'infra-2'],
        priority: 1,
      ),
    );
    final items = c.read(taskListingProvider(q)).value!.items;
    expect(items.firstWhere((t) => t.ref == 'infra-1').priority, 1);
    expect(items.firstWhere((t) => t.ref == 'infra-2').priority, 3);
    expect(undoRequests(run.request, run.before, run.result), [
      const BulkTaskInput(
        action: BulkAction.priority,
        refs: ['infra-1'],
        priority: 3,
      ),
    ]);
  });

  test('a failed bulk request puts every row back', () async {
    final (c, q) = await listing(const TaskQuery());
    final before = c.read(taskListingProvider(q)).value!.items;
    server.override = FakeResponse(403, envelope('forbidden', 'no'));
    await expectLater(
      c
          .read(taskListingProvider(q).notifier)
          .bulk(
            const BulkTaskInput(action: BulkAction.delete, refs: ['infra-1']),
          ),
      throwsA(anything),
    );
    expect(c.read(taskListingProvider(q)).value!.items, before);
  });

  test('a bulk delete takes rows out and Undo restores them', () async {
    final (c, q) = await listing(const TaskQuery());
    final n = c.read(taskListingProvider(q).notifier);
    final run = await n.bulk(
      const BulkTaskInput(action: BulkAction.delete, refs: ['infra-1']),
    );
    expect(refs(c, q), isNot(contains('infra-1')));
    await n.undo(run);
    expect(server.requestsTo('/tasks/bulk').last.body, {
      'action': 'restore',
      'refs': ['infra-1'],
    });
    await c.read(taskListingProvider(q).future);
    expect(refs(c, q), contains('infra-1'));
  });

  group('an Undo the server refuses', () {
    Task row(ProviderContainer c, TaskQuery q, String ref) => c
        .read(taskListingProvider(q))
        .value!
        .items
        .firstWhere((t) => t.ref == ref);

    test('stops and shows what the server holds', () async {
      final (c, q) = await listing(const TaskQuery());
      final n = c.read(taskListingProvider(q).notifier);
      final run = await n.bulk(
        const BulkTaskInput(
          action: BulkAction.move,
          refs: ['infra-1', 'infra-2'],
          to: 'done',
        ),
      );
      server.refuse['infra-2'] = ('precondition_failed', 'no way back');
      await expectLater(n.undo(run), throwsA(isA<TixException>()));
      await c.read(taskListingProvider(q).future);
      expect(row(c, q, 'infra-1').status, 'todo');
      expect(row(c, q, 'infra-2').status, 'done');
    });

    test('a failed request reloads the rows', () async {
      final (c, q) = await listing(const TaskQuery());
      final n = c.read(taskListingProvider(q).notifier);
      final run = await n.bulk(
        const BulkTaskInput(action: BulkAction.star, refs: ['infra-1']),
      );
      server.override = FakeResponse(500, envelope('internal', 'down'));
      await expectLater(n.undo(run), throwsA(isA<TixException>()));
      server.override = null;
      await c.read(taskListingProvider(q).future);
      expect(row(c, q, 'infra-1').starred, isTrue);
    });

    test('a refused restore reloads what did come back', () async {
      final (c, q) = await listing(const TaskQuery());
      final n = c.read(taskListingProvider(q).notifier);
      final run = await n.bulk(
        const BulkTaskInput(
          action: BulkAction.delete,
          refs: ['infra-1', 'web-1'],
        ),
      );
      server.refuse['web-1'] = ('forbidden', 'not yours');
      await expectLater(n.undo(run), throwsA(isA<TixException>()));
      await c.read(taskListingProvider(q).future);
      expect(refs(c, q), contains('infra-1'));
      expect(refs(c, q), isNot(contains('web-1')));
    });
  });

  group('undo requests', () {
    final before = {
      'x-1': Task.fromJson(taskJson('x-1', tags: ['x'])),
      'x-2': Task.fromJson(taskJson('x-2', starred: true)),
    };
    BulkResult ok(List<String> refs, {String copy = ''}) => BulkResult(
      applied: refs.length,
      outcomes: [
        for (final r in refs) BulkOutcome(ref: r, applied: true, copyRef: copy),
      ],
    );

    test('tags only come off the tasks that lacked them', () {
      expect(
        undoRequests(
          const BulkTaskInput(
            action: BulkAction.tagAdd,
            refs: ['x-1', 'x-2'],
            tag: 'x',
          ),
          before,
          ok(['x-1', 'x-2']),
        ),
        [
          const BulkTaskInput(
            action: BulkAction.tagRemove,
            refs: ['x-2'],
            tag: 'x',
          ),
        ],
      );
      expect(
        undoRequests(
          const BulkTaskInput(
            action: BulkAction.tagRemove,
            refs: ['x-1', 'x-2'],
            tag: 'x',
          ),
          before,
          ok(['x-1', 'x-2']),
        ),
        [
          const BulkTaskInput(
            action: BulkAction.tagAdd,
            refs: ['x-1'],
            tag: 'x',
          ),
        ],
      );
    });

    test('stars, assignees, copies and deletes reverse', () {
      expect(
        undoRequests(
          const BulkTaskInput(action: BulkAction.star, refs: ['x-1', 'x-2']),
          before,
          ok(['x-1', 'x-2']),
        ),
        [
          const BulkTaskInput(action: BulkAction.unstar, refs: ['x-1']),
        ],
      );
      expect(
        undoRequests(
          const BulkTaskInput(action: BulkAction.unstar, refs: ['x-1', 'x-2']),
          before,
          ok(['x-1', 'x-2']),
        ),
        [
          const BulkTaskInput(action: BulkAction.star, refs: ['x-2']),
        ],
      );
      expect(
        undoRequests(
          const BulkTaskInput(
            action: BulkAction.assign,
            refs: ['x-1'],
            assigneeActorId: 'me',
          ),
          before,
          ok(['x-1']),
        ),
        [
          const BulkTaskInput(
            action: BulkAction.assign,
            refs: ['x-1'],
            assigneeActorId: '',
          ),
        ],
      );
      expect(
        undoRequests(
          const BulkTaskInput(action: BulkAction.copy, refs: ['x-1']),
          before,
          ok(['x-1'], copy: 'a-9'),
        ),
        [
          const BulkTaskInput(action: BulkAction.delete, refs: ['a-9']),
        ],
      );
      expect(
        undoRequests(
          const BulkTaskInput(action: BulkAction.restore, refs: ['x-1']),
          before,
          ok(['x-1']),
        ),
        [
          const BulkTaskInput(action: BulkAction.delete, refs: ['x-1']),
        ],
      );
    });
  });

  test('quick actions call their own routes', () async {
    final (c, q) = await listing(const TaskQuery());
    final n = c.read(taskListingProvider(q).notifier);
    await n.sendStar('infra-1', starred: true);
    await n.sendSnooze('infra-1', DateTime.utc(2026, 11, 2));
    await n.sendSnooze('infra-1', null);
    await n.sendAssign('infra-1', 'me');
    await n.sendMove('infra-1', 'doing');
    expect(
      server.requests.skip(4).map((r) => '${r.method} ${r.uri.path}'),
      containsAllInOrder([
        'PUT /api/v1/tasks/infra-1/star',
        'PUT /api/v1/tasks/infra-1/snooze',
        'DELETE /api/v1/tasks/infra-1/snooze',
        'POST /api/v1/tasks/bulk',
        'POST /api/v1/tasks/bulk',
      ]),
    );
  });

  test(
    'the task context resolves projects, workflows and categories',
    () async {
      final c = await signedInContainer(server);
      final ctx = await c.read(taskContextProvider.future);
      final task = Task.fromJson({
        ...taskJson('infra-9', status: 'doing'),
        'project_id': 'p1',
      });
      expect(ctx.projectOf(task)?.key, 'infra');
      expect(ctx.categoryOf(task), 'in_progress');
      expect(ctx.isFinished(task.copyWith(status: 'cancelled')), isTrue);
      expect(ctx.openStates, ['todo', 'doing', 'blocked']);
    },
  );

  test('a task event reloads the listing', () async {
    final sockets = FakeEventSockets();
    final stores = signedInStores();
    final c = makeContainer(
      fakeOverrides(
        server,
        settings: stores.settings,
        secrets: stores.secrets,
        events: sockets.connect,
      ),
    );
    await c.read(sessionControllerProvider.future);
    const q = TaskQuery();
    final sub = c.listen(taskListingProvider(q), (_, _) {});
    addTearDown(sub.close);
    await c.read(taskListingProvider(q).future);
    await Future<void>.delayed(Duration.zero);
    sockets.last.ack();
    await Future<void>.delayed(Duration.zero);
    server.tasks['infra']!.first['title'] = 'Renamed';
    sockets.last.event(1, 'task.updated');
    await Future<void>.delayed(const Duration(milliseconds: 400));
    await c.read(taskListingProvider(q).future);
    expect(c.read(taskListingProvider(q)).value!.items.first.title, 'Renamed');
  });

  test('a claim event reloads the listing and its held count', () async {
    final sockets = FakeEventSockets();
    final stores = signedInStores();
    final c = makeContainer(
      fakeOverrides(
        server,
        settings: stores.settings,
        secrets: stores.secrets,
        events: sockets.connect,
      ),
    );
    await c.read(sessionControllerProvider.future);
    const q = TaskQuery();
    final sub = c.listen(taskListingProvider(q), (_, _) {});
    addTearDown(sub.close);
    await c.read(taskListingProvider(q).future);
    expect(
      heldByAgent(c.read(taskListingProvider(q)).value!.items, fixedNow),
      0,
    );
    await Future<void>.delayed(Duration.zero);
    sockets.last.ack();
    await Future<void>.delayed(Duration.zero);
    server.tasks['infra']!.first.addAll(
      heldJson(fixedNow.add(const Duration(minutes: 30))),
    );
    sockets.last.event(1, 'task.claimed');
    await Future<void>.delayed(const Duration(milliseconds: 400));
    await c.read(taskListingProvider(q).future);
    expect(
      heldByAgent(c.read(taskListingProvider(q)).value!.items, fixedNow),
      1,
    );
  });

  group('heldByAgent', () {
    Task task(String ref, [Map<String, Object?> extra = const {}]) =>
        Task.fromJson({...taskJson(ref), ...extra});

    test('counts claims whose lease has not run out', () {
      final soon = fixedNow.add(const Duration(minutes: 5));
      expect(
        heldByAgent([
          task('infra-1', heldJson(soon)),
          task('infra-2', heldJson(soon)),
          task('infra-3'),
        ], fixedNow),
        2,
      );
    });

    test('a lapsed lease and a claim without one are not held', () {
      expect(
        heldByAgent([
          task(
            'infra-1',
            heldJson(fixedNow.subtract(const Duration(minutes: 1))),
          ),
          task('infra-2', heldJson(fixedNow)),
          task('infra-3', {'claimed_by_actor_id': 'bot'}),
          task('infra-4', {
            'lease_expires_at': fixedNow
                .add(const Duration(hours: 1))
                .toIso8601String(),
          }),
        ], fixedNow),
        0,
      );
    });
  });

  test('a cached first page draws before the server answers', () async {
    final cache = MemoryCacheStore();
    Future<ProviderContainer> open() async {
      final stores = signedInStores();
      final c = makeContainer(
        fakeOverrides(
          server,
          settings: stores.settings,
          secrets: stores.secrets,
          cache: cache,
        ),
      );
      await c.read(sessionControllerProvider.future);
      return c;
    }

    const q = TaskQuery();
    final first = await open();
    await first.read(taskListingProvider(q).future);
    first.dispose();
    server.tasks['infra']!.first['title'] = 'Changed';
    final second = await open();
    final sub = second.listen(taskListingProvider(q), (_, _) {});
    addTearDown(sub.close);
    final shown = await second.read(taskListingProvider(q).future);
    expect(shown.items.first.title, 'One');
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(
      second.read(taskListingProvider(q)).value!.items.first.title,
      'Changed',
    );
  });
}
