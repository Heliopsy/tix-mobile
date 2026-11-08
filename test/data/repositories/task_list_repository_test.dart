// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/cache/response_cache.dart';
import 'package:tix_mobile/src/data/models/bulk.dart';
import 'package:tix_mobile/src/data/repositories/task_list_repository.dart';
import 'package:tix_mobile/src/data/repositories/view_prefs_repository.dart';

import '../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;
  late TixApi api;
  late TaskListRepository tasks;
  late ViewPrefsRepository views;

  setUp(() {
    server = FakeTix();
    api = server.factory('https://tix.example', const BearerCredential('tok'));
    final cache = ResponseCache(
      MemoryCacheStore(),
      const CacheScope('c1', 'default'),
    );
    tasks = TaskListRepository(api, cache);
    views = ViewPrefsRepository(api, cache);
  });

  test('a listing repeats parameters and pages by cursor', () async {
    server.pageSize = 1;
    final first = await tasks.list((
      params: {
        'status': ['todo', 'doing'],
        'tag': ['auth'],
      },
      sort: 'due_at',
      direction: 'desc',
      limit: 1,
    ));
    final sent = server.requestsTo('/api/v1/tasks').single.uri;
    expect(sent.queryParametersAll['status'], ['todo', 'doing']);
    expect(sent.queryParameters['sort'], 'due_at');
    expect(sent.queryParameters['direction'], 'desc');
    expect(sent.queryParameters['limit'], '1');
    expect(first.items.single.ref, 'infra-1');
    expect(first.nextCursor, isNull);
    const plain = (
      params: <String, List<String>>{},
      sort: null,
      direction: null,
      limit: 1,
    );
    final all = await tasks.list(plain);
    expect(all.items.map((t) => t.ref), ['infra-1']);
    expect(all.nextCursor, '1');
    final next = await tasks.list(plain, cursor: all.nextCursor);
    expect(next.items.single.ref, 'infra-2');
    expect(next.items.single.projectId, 'p1');
  });

  test('bulk sends one request and reads each outcome', () async {
    server.refuse['infra-2'] = ('precondition_failed', 'no route');
    final result = await tasks.bulk(
      const BulkTaskInput(
        action: BulkAction.tagAdd,
        refs: ['infra-1', 'infra-2'],
        tag: 'x',
      ),
    );
    expect(server.requestsTo('/tasks/bulk').single.body, {
      'action': 'tag_add',
      'refs': ['infra-1', 'infra-2'],
      'tag': 'x',
    });
    expect(result.applied, 1);
    expect(result.refusals.single.error, 'no route');
  });

  test('one-task moves and assigns throw the refusal', () async {
    await tasks.move('infra-1', 'doing');
    expect(server.requestsTo('/tasks/bulk').last.body, {
      'action': 'move',
      'refs': ['infra-1'],
      'to': 'doing',
    });
    await tasks.assign('infra-1', 'me');
    expect(
      server.requestsTo('/tasks/bulk').last.body['assignee_actor_id'],
      'me',
    );
    server.refuse['infra-1'] = ('precondition_failed', 'not from here');
    await expectLater(
      tasks.move('infra-1', 'done'),
      throwsA(
        isA<TixException>()
            .having((e) => e.kind, 'kind', TixErrorKind.preconditionFailed)
            .having((e) => e.message, 'message', 'not from here'),
      ),
    );
  });

  test('star, snooze, workflows, stats and whoami', () async {
    await tasks.star('infra-1');
    await tasks.unstar('infra-1');
    final snoozed = await tasks.snooze('infra-1', DateTime.utc(2026, 11, 2));
    expect(snoozed.snoozedUntil, DateTime.utc(2026, 11, 2));
    expect((await tasks.unsnooze('infra-1')).snoozedUntil, isNull);
    expect(
      server.requests.map((r) => '${r.method} ${r.uri.path}').toList(),
      containsAllInOrder([
        'PUT /api/v1/tasks/infra-1/star',
        'DELETE /api/v1/tasks/infra-1/star',
        'PUT /api/v1/tasks/infra-1/snooze',
        'DELETE /api/v1/tasks/infra-1/snooze',
      ]),
    );
    expect((await tasks.workflows()).single.key, 'default');
    expect((await tasks.me()).handle, 'ana');
    expect((await api.stats.read(project: 'infra')).open, 2);
  });

  test('view arrangements go to the view API', () async {
    await views.setGroup('project:infra', 'blocked', hidden: true);
    expect(server.requestsTo('/groups/blocked').single.body, {'hidden': true});
    expect((await views.groups('project:infra')).single.hidden, isTrue);
    final ordered = await views.order('lanes', ['web', 'infra']);
    expect(ordered.map((g) => (g.group, g.position)), [
      ('web', 1),
      ('infra', 2),
    ]);
    await views.reset('lanes');
    expect(await views.groups('lanes'), isEmpty);
  });

  test('saved filters are created, changed, ordered and deleted', () async {
    final a = await views.saveFilter(
      name: 'Ops',
      query: 'tag:ops',
      sort: 'priority',
      view: 'board',
      shared: true,
    );
    expect(server.requestsTo('/api/v1/filters').last.body, {
      'name': 'Ops',
      'query': 'tag:ops',
      'sort': 'priority',
      'view': 'board',
      'shared': true,
    });
    final b = await views.saveFilter(name: 'Mine', query: 'assignee:me');
    final renamed = await views.updateFilter(
      a.id,
      name: 'Ops 2',
      shared: false,
    );
    expect(renamed.name, 'Ops 2');
    expect(server.requestsTo('/filters/${a.id}').single.body, {
      'name': 'Ops 2',
      'shared': false,
    });
    final ordered = await views.orderFilters([b.id, a.id]);
    expect(ordered.map((f) => f.id), [b.id, a.id]);
    await views.deleteFilter(a.id);
    expect((await views.filters()).single.name, 'Mine');
  });
}
