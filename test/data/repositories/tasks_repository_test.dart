// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/cache/response_cache.dart';
import 'package:tix_mobile/src/data/repositories/tasks_repository.dart';

import '../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;
  late MemoryCacheStore store;
  late TasksRepository repo;

  TasksRepository fresh() => TasksRepository(
    server.factory('https://tix.example', const BearerCredential('tok')),
    ResponseCache(store, const CacheScope('c1', 'default')),
  );

  setUp(() {
    server = FakeTix();
    store = MemoryCacheStore();
    repo = fresh();
  });

  test('lists pass the cursor through', () async {
    server.pageSize = 1;
    final first = await repo.projects();
    expect(first.items.single.key, 'infra');
    final next = await repo.projects(cursor: first.nextCursor);
    expect(next.items.single.key, 'web');
    expect(server.requests.last.uri.queryParameters['cursor'], '1');
    expect((await repo.tasks('infra')).items.first.ref, 'infra-1');
    expect(server.requests.last.uri.queryParametersAll['project'], ['infra']);
    expect((await repo.task('infra-2')).title, 'Rotate keys');
  });

  test('first pages and records are kept and read back once', () async {
    await repo.projects();
    await repo.tasks('infra');
    await repo.task('infra-1');
    final later = fresh();
    expect((await later.cachedProjects())!.items.map((p) => p.key), [
      'infra',
      'web',
    ]);
    expect((await later.cachedTasks('infra'))!.items.first.title, 'Fix login');
    expect(
      (await later.cachedTask('infra-1'))!.dueAt,
      DateTime.utc(2026, 11, 20),
    );
    expect(await later.cachedProjects(), isNull, reason: 'served once');
    expect(await later.cachedTasks('web'), isNull, reason: 'never read');
  });

  test('a later page is not cached over the first', () async {
    server.pageSize = 1;
    final first = await repo.projects();
    await repo.projects(cursor: first.nextCursor);
    final cached = await fresh().cachedProjects();
    expect(cached!.items.single.key, 'infra');
  });

  test('a cache in another context sees nothing', () async {
    await repo.projects();
    final other = ResponseCache(store, const CacheScope('c1', 'acme'));
    expect(await other.peek('projects', (j) => j), isNull);
  });

  test('an actor is fetched once', () async {
    await repo.actor('a1');
    await repo.actor('a1');
    expect(server.requestsTo('/actors/a1'), hasLength(1));
  });

  test('a failed actor lookup is tried again next time', () async {
    server.override = FakeResponse(500, envelope('internal', 'boom'));
    await expectLater(repo.actor('a1'), throwsA(isA<TixException>()));
    server.override = null;
    expect((await repo.actor('a1')).handle, 'raj');
  });

  test('quickAdd asks the server to parse the line in the project', () async {
    final task = await repo.quickAdd('web', 'Fix login !high');
    expect(task.ref, 'web-1');
    expect(server.requests.single.body, {
      'title': 'Fix login !high',
      'project_ref': 'web',
      'parse': true,
    });
  });
}
