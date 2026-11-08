// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/events/events.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/cache/cache_store.dart';
import 'package:tix_mobile/src/features/projects/application/projects.dart';
import 'package:tix_mobile/src/features/tasks/application/tasks.dart';

import '../../helpers/app.dart';
import '../../helpers/container.dart';
import '../../helpers/fake_events.dart';
import '../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;
  late FakeEventSockets sockets;

  Future<void> settle([int ms = 0]) =>
      Future<void>.delayed(Duration(milliseconds: ms));

  Future<FakeSocket> live(ProviderContainer c) async {
    await settle();
    final s = sockets.last..ack();
    await settle();
    return s;
  }

  setUp(() {
    server = FakeTix();
    sockets = FakeEventSockets();
  });

  Future<ProviderContainer> container({CacheStore? cache}) async {
    final stores = signedInStores();
    final c = makeContainer(
      fakeOverrides(
        server,
        settings: stores.settings,
        secrets: stores.secrets,
        events: sockets.connect,
        cache: cache,
      ),
    );
    await c.read(sessionControllerProvider.future);
    return c;
  }

  test('the stream follows the session with its credential', () async {
    final c = await container();
    final stream = c.read(tixEventStreamProvider)!;
    final sub = stream.updates.listen((_) {});
    addTearDown(sub.cancel);
    await settle();
    expect(sockets.last.url.toString(), 'wss://tix.example/api/v1/events');
    expect(sockets.last.headers['Authorization'], 'Bearer tok');
  });

  test('a matching event refreshes a list once per burst', () async {
    final c = await container();
    final sub = c.listen(projectsProvider, (_, _) {});
    addTearDown(sub.close);
    await c.read(projectsProvider.future);
    final s = await live(c);
    expect(server.requestsTo('/api/v1/projects'), hasLength(1));
    server.projects.add({'id': 'p3', 'key': 'ops', 'name': 'Ops'});
    s.event(1, 'project.created');
    await settle(50);
    s.event(2, 'project.updated');
    await settle(50);
    s.event(3, 'task.created');
    await settle(400);
    final now = await c.read(projectsProvider.future);
    expect(now.items.map((p) => p.key), contains('ops'));
    expect(server.requestsTo('/api/v1/projects'), hasLength(2));
  });

  test('an unrelated event refreshes nothing', () async {
    final c = await container();
    final sub = c.listen(projectsProvider, (_, _) {});
    addTearDown(sub.close);
    await c.read(projectsProvider.future);
    final s = await live(c);
    s.event(1, 'comment.added');
    await settle(400);
    expect(server.requestsTo('/api/v1/projects'), hasLength(1));
  });

  test('a task page refreshes only for its own task', () async {
    final c = await container();
    final sub = c.listen(taskDetailProvider('infra-1'), (_, _) {});
    addTearDown(sub.close);
    await c.read(taskDetailProvider('infra-1').future);
    final s = await live(c);
    s.event(1, 'comment.added', subjectId: 'id-infra-2');
    await settle(400);
    expect(server.requestsTo('/tasks/infra-1'), hasLength(1));
    s.event(2, 'comment.added');
    await settle(400);
    expect(server.requestsTo('/tasks/infra-1'), hasLength(2));
  });

  test('a gap refreshes everything listening', () async {
    final c = await container();
    final sub = c.listen(projectsProvider, (_, _) {});
    addTearDown(sub.close);
    await c.read(projectsProvider.future);
    final s = await live(c);
    await s.drop();
    final next = await sockets.opened.first.timeout(const Duration(seconds: 3));
    await settle();
    next.ack();
    await settle(400);
    expect(server.requestsTo('/api/v1/projects'), hasLength(2));
  });

  test('cached data shows at once and the server answer follows', () async {
    final cache = MemoryCacheStore();
    final first = await container(cache: cache);
    await first.read(projectsProvider.future);
    expect(cache.entries, isNotEmpty);

    server.projects.add({'id': 'p3', 'key': 'ops', 'name': 'Ops'});
    final c = await container(cache: cache);
    final seen = <List<String>>[];
    final sub = c.listen(projectsProvider, (_, next) {
      final v = next.value;
      if (v != null) seen.add([for (final p in v.items) p.key]);
    });
    addTearDown(sub.close);
    final shown = await c.read(projectsProvider.future);
    expect(shown.items.map((p) => p.key), ['infra', 'web']);
    await settle(50);
    expect(seen.last, ['infra', 'web', 'ops']);
    expect(server.requestsTo('/api/v1/projects'), hasLength(2));
  });

  test('a refresh after the cached answer asks the server', () async {
    final cache = MemoryCacheStore();
    await (await container(cache: cache)).read(projectsProvider.future);
    final c = await container(cache: cache);
    final sub = c.listen(projectsProvider, (_, _) {});
    addTearDown(sub.close);
    await c.read(projectsProvider.future);
    await settle(50);
    server.override = FakeResponse(500, envelope('internal', 'boom'));
    c.invalidate(projectsProvider);
    await expectLater(c.read(projectsProvider.future), throwsA(anything));
  });
}
