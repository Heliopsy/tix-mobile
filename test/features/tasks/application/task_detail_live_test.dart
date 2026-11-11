// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/events/events.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/features/tasks/application/task_detail.dart';

import '../../../helpers/app.dart';
import '../../../helpers/container.dart';
import '../../../helpers/fake_events.dart';
import '../../../helpers/fake_parity.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;
  late FakeEventSockets sockets;

  Future<void> settle([int ms = 0]) =>
      Future<void>.delayed(Duration(milliseconds: ms));

  setUp(() {
    server = FakeTix();
    sockets = FakeEventSockets();
  });

  Future<(ProviderContainer, FakeSocket)> live() async {
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
    final stream = c.read(tixEventStreamProvider)!;
    final sub = stream.updates.listen((_) {});
    addTearDown(sub.cancel);
    await settle();
    final s = sockets.last..ack();
    await settle();
    return (c, s);
  }

  test('the task reloads when it changes elsewhere', () async {
    final (c, s) = await live();
    final sub = c.listen(taskDetailControllerProvider('infra-1'), (_, _) {});
    addTearDown(sub.close);
    await c.read(taskDetailControllerProvider('infra-1').future);
    server.task('infra-1')!['title'] = 'Renamed elsewhere';
    s.event(1, 'task.updated');
    await settle(400);
    final now = await c.read(taskDetailControllerProvider('infra-1').future);
    expect(now.title, 'Renamed elsewhere');
  });

  for (final type in [
    'task.claimed',
    'task.released',
    'task.lease_expired',
    'task.reclaimed',
  ]) {
    test('$type reads the claim length again', () async {
      FakeParity.on(server);
      final (c, s) = await live();
      final task = c.listen(taskDetailControllerProvider('infra-1'), (_, _) {});
      addTearDown(task.close);
      await c.read(taskDetailControllerProvider('infra-1').future);
      final sub = c.listen(taskLeaseProvider('infra-1'), (_, _) {});
      addTearDown(sub.close);
      await c.read(taskLeaseProvider('infra-1').future);
      final before = server.requestsTo('/tasks/infra-1/lease').length;
      s.event(1, type);
      await settle(400);
      await c.read(taskLeaseProvider('infra-1').future);
      expect(server.requestsTo('/tasks/infra-1/lease'), hasLength(before + 1));
    });
  }

  test("another task's claim leaves this one's length alone", () async {
    FakeParity.on(server);
    final (c, s) = await live();
    final task = c.listen(taskDetailControllerProvider('infra-1'), (_, _) {});
    addTearDown(task.close);
    await c.read(taskDetailControllerProvider('infra-1').future);
    final sub = c.listen(taskLeaseProvider('infra-1'), (_, _) {});
    addTearDown(sub.close);
    await c.read(taskLeaseProvider('infra-1').future);
    final before = server.requestsTo('/tasks/infra-1/lease').length;
    s.event(1, 'task.claimed', subjectId: 'id-infra-2');
    await settle(400);
    expect(server.requestsTo('/tasks/infra-1/lease'), hasLength(before));
  });

  test("another task's change leaves this one alone", () async {
    final (c, s) = await live();
    final sub = c.listen(taskDetailControllerProvider('infra-1'), (_, _) {});
    addTearDown(sub.close);
    await c.read(taskDetailControllerProvider('infra-1').future);
    final before = server.requestsTo('/api/v1/tasks/infra-1').length;
    s.event(1, 'task.updated', subjectId: 'id-infra-2');
    await settle(400);
    expect(server.requestsTo('/api/v1/tasks/infra-1'), hasLength(before));
  });

  test('a comment added elsewhere appears', () async {
    final (c, s) = await live();
    final task = c.listen(taskDetailControllerProvider('infra-1'), (_, _) {});
    addTearDown(task.close);
    await c.read(taskDetailControllerProvider('infra-1').future);
    final sub = c.listen(taskCommentsProvider('infra-1'), (_, _) {});
    addTearDown(sub.close);
    expect(await c.read(taskCommentsProvider('infra-1').future), isEmpty);
    server.comments['infra-1'] = [
      {'id': 'c9', 'author_actor_id': 'a1', 'body': 'from the web'},
    ];
    s.event(1, 'comment.added');
    await settle(400);
    final now = await c.read(taskCommentsProvider('infra-1').future);
    expect(now.single.body, 'from the web');
  });

  test('a reaction made elsewhere shows', () async {
    final (c, s) = await live();
    final task = c.listen(taskDetailControllerProvider('infra-1'), (_, _) {});
    addTearDown(task.close);
    await c.read(taskDetailControllerProvider('infra-1').future);
    server.comments['infra-1'] = [
      {'id': 'c9', 'task_id': 'id-infra-1', 'body': 'ship it'},
    ];
    final sub = c.listen(taskCommentsProvider('infra-1'), (_, _) {});
    addTearDown(sub.close);
    final first = await c.read(taskCommentsProvider('infra-1').future);
    expect(first.single.reactions, isEmpty);
    server.comments['infra-1']!.single['reactions'] = [
      {
        'emoji': '🚀',
        'count': 1,
        'actor_ids': ['a1'],
      },
    ];
    s.event(
      1,
      'comment.reacted',
      subjectId: 'c9',
      payload: {'task_id': 'id-infra-1', 'emoji': '🚀', 'reacted': true},
    );
    await settle(400);
    final now = await c.read(taskCommentsProvider('infra-1').future);
    expect(now.single.reactions.single.emoji, '🚀');
  });

  test("a new comment's channel comes from its event", () async {
    final (c, s) = await live();
    final task = c.listen(taskDetailControllerProvider('infra-1'), (_, _) {});
    addTearDown(task.close);
    await c.read(taskDetailControllerProvider('infra-1').future);
    final sub = c.listen(taskCommentChannelsProvider('infra-1'), (_, _) {});
    addTearDown(sub.close);
    expect(
      await c.read(taskCommentChannelsProvider('infra-1').future),
      isEmpty,
    );
    s.event(
      1,
      'comment.added',
      subjectId: 'c9',
      payload: {'task_id': 'id-infra-1'},
      via: {'kind': 'api', 'token_name': 'ci-agent'},
    );
    await settle(100);
    final now = await c.read(taskCommentChannelsProvider('infra-1').future);
    expect(now['c9']?.tokenName, 'ci-agent');
  });
}
