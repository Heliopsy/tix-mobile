// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/cache/response_cache.dart';
import 'package:tix_mobile/src/data/models/inbox.dart';
import 'package:tix_mobile/src/data/repositories/inbox_repository.dart';

import '../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;
  late InboxRepository repo;

  setUp(() {
    server = FakeTix();
    repo = InboxRepository(
      server.factory('https://tix.example', const BearerCredential('tok')),
      ResponseCache(MemoryCacheStore(), const CacheScope('c1', 'default')),
    );
  });

  test(
    'lists items, unread only on request, and pages with the cursor',
    () async {
      server.pageSize = 2;
      final first = await repo.items();
      expect(first.items.map((i) => i.id), ['i1', 'i2']);
      expect(first.items.first.kind, InboxKind.mention);
      expect(first.items.first.read, isFalse);
      expect(first.items[1].read, isTrue);
      final next = await repo.items(cursor: first.nextCursor);
      expect(next.items.single.id, 'i3');
      expect(server.requestsTo('/api/v1/inbox').last.uri.queryParameters, {
        'limit': '50',
        'cursor': '2',
      });
      final unread = await repo.items(unread: true);
      expect(unread.items.map((i) => i.id), ['i1', 'i3']);
      expect(
        server.requestsTo('/api/v1/inbox').last.uri.queryParameters['unread'],
        'true',
      );
    },
  );

  test('counts, marks one read and unread, and marks all read', () async {
    expect(await repo.unreadCount(), 2);
    expect((await repo.markRead('i1')).read, isTrue);
    expect(server.requestsTo('/api/v1/inbox/i1/read').single.method, 'PUT');
    expect(await repo.unreadCount(), 1);
    expect((await repo.markUnread('i1')).read, isFalse);
    expect(server.requestsTo('/api/v1/inbox/i1/read').last.method, 'DELETE');
    expect(await repo.markAllRead(), 2);
    expect(await repo.unreadCount(), 0);
  });

  test('reads and replaces the muted kinds in a stable order', () async {
    expect(await repo.muted(), isEmpty);
    final muted = await repo.setMuted({InboxKind.status, InboxKind.mention});
    expect(muted, {InboxKind.mention, InboxKind.status});
    expect(server.requestsTo('/api/v1/inbox/prefs').last.body, {
      'muted': ['mention', 'status'],
    });
    expect(server.inboxMuted, ['mention', 'status']);
  });

  test('ignores a muted kind this app does not know', () async {
    server.inboxMuted.add('reaction');
    expect(await repo.muted(), isEmpty);
  });

  test(
    'manages channels: add, edit, test, deliveries, redeliver, delete',
    () async {
      final created = await repo.addChannel(
        const InboxChannelInput(
          name: 'Slack',
          url: 'https://hooks.slack.com/x',
          format: 'slack',
          kinds: ['mention'],
        ),
      );
      expect(created.secret, 'whsec_test');
      expect(server.requestsTo('/api/v1/channels').last.body, {
        'name': 'Slack',
        'url': 'https://hooks.slack.com/x',
        'format': 'slack',
        'kinds': ['mention'],
      });
      expect((await repo.channels()).single.name, 'Slack');
      final edited = await repo.editChannel(
        created.id,
        const InboxChannelUpdate(active: false),
      );
      expect(edited.active, isFalse);
      expect(server.requestsTo('/api/v1/channels/${created.id}').last.body, {
        'active': false,
      });
      final test = await repo.testChannel(created.id);
      expect(test.itemId, isEmpty);
      final page = await repo.deliveries(created.id);
      expect(page.items.single.status, DeliveryStatus.delivered);
      await repo.redeliver(test.id);
      expect(
        server.requestsTo('/api/v1/channel-deliveries/${test.id}/redeliver'),
        hasLength(1),
      );
      await repo.deleteChannel(created.id);
      expect(await repo.channels(), isEmpty);
    },
  );

  test('a refused channel carries the field the server named', () async {
    await expectLater(
      repo.addChannel(const InboxChannelInput(name: 'x', url: 'http://x')),
      throwsA(
        isA<TixException>()
            .having((e) => e.kind, 'kind', TixErrorKind.invalid)
            .having((e) => e.details['field'], 'field', 'url'),
      ),
    );
  });

  test('deleting a channel that is gone is not_found', () async {
    await expectLater(
      repo.deleteChannel('nope'),
      throwsA(
        isA<TixException>().having(
          (e) => e.kind,
          'kind',
          TixErrorKind.notFound,
        ),
      ),
    );
  });

  test('reads stats over seven days and the open tasks due', () async {
    server.withSummary();
    final stats = await repo.stats();
    expect(stats.completed, 4);
    expect(stats.byCategory.first.category, StateCategory.todo);
    expect(server.requestsTo('/api/v1/stats').single.uri.queryParameters, {
      'window': '7d',
    });
    server.dueTasks!.add({
      ...taskJson('infra-9', due: '2026-10-01T00:00:00Z'),
      'completed_at': '2026-10-02T00:00:00Z',
    });
    final due = await repo.openTasksDueBefore(DateTime.utc(2026, 11, 2));
    expect(due.map((t) => t.ref), ['infra-1', 'infra-5']);
    final q = server.requestsTo('/api/v1/tasks').last.uri.queryParameters;
    expect(q['assignee'], 'me');
    expect(q['due_before'], '2026-11-02T00:00:00.000Z');
  });

  test('an item knows its project key and whether it opens a task', () {
    const item = InboxItem(id: 'x', taskRef: 'my-proj-12');
    expect(item.projectKey, 'my-proj');
    expect(item.opensTask, isTrue);
    expect(
      const InboxItem(id: 'x', taskRef: 'web-3', taskGone: true).opensTask,
      isFalse,
    );
    expect(const InboxItem(id: 'x', taskRef: '01JABC').projectKey, '');
    expect(
      InboxItem.fromJson(const {'id': 'x', 'kind': 'reaction'}).kind,
      isNull,
    );
  });
}
