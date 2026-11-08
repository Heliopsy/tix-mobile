// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/notifications/local_notifier.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/features/inbox/application/inbox.dart';

import '../../../helpers/app.dart';
import '../../../helpers/container.dart';
import '../../../helpers/fake_events.dart';
import '../../../helpers/fake_notes.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;
  late FakeEventSockets sockets;
  late FakeNotes notes;

  Future<ProviderContainer> container() async {
    final stores = signedInStores();
    final c = makeContainer(
      fakeOverrides(
        server,
        settings: stores.settings,
        secrets: stores.secrets,
        events: sockets.connect,
        notes: notes,
      ),
    );
    await c.read(sessionControllerProvider.future);
    final marks = c.listen(inboxMarksProvider, (_, _) {});
    addTearDown(marks.close);
    return c;
  }

  setUp(() {
    server = FakeTix();
    sockets = FakeEventSockets();
    notes = FakeNotes();
  });

  Future<void> settle([int ms = 0]) =>
      Future<void>.delayed(Duration(milliseconds: ms));

  Future<FakeSocket> live() async {
    await settle();
    final s = sockets.last..ack();
    await settle();
    return s;
  }

  test('lists the first page and appends the next', () async {
    server.pageSize = 2;
    final c = await container();
    final sub = c.listen(inboxListProvider(false), (_, _) {});
    addTearDown(sub.close);
    final first = await c.read(inboxListProvider(false).future);
    expect(first.items.map((i) => i.id), ['i1', 'i2']);
    await c.read(inboxListProvider(false).notifier).loadMore();
    expect(c.read(inboxListProvider(false)).value!.items.map((i) => i.id), [
      'i1',
      'i2',
      'i3',
    ]);
  });

  test(
    'a live inbox event reads the first page again and marks new rows',
    () async {
      final c = await container();
      final sub = c.listen(inboxListProvider(false), (_, _) {});
      final fresh = c.listen(freshInboxIdsProvider, (_, _) {});
      addTearDown(sub.close);
      addTearDown(fresh.close);
      await c.read(inboxListProvider(false).future);
      final s = await live();
      server.inbox.insert(
        0,
        inboxJson('i9', kind: 'comment', created: '2026-11-01T11:59:00Z'),
      );
      s.event(1, 'inbox.updated', subjectId: 'me');
      await settle(400);
      expect(
        c.read(inboxListProvider(false)).value!.items.map((i) => i.id).first,
        'i9',
      );
      expect(c.read(freshInboxIdsProvider), {'i9'});
    },
  );

  test('an event about something else leaves the inbox alone', () async {
    final c = await container();
    final sub = c.listen(inboxListProvider(false), (_, _) {});
    addTearDown(sub.close);
    await c.read(inboxListProvider(false).future);
    final s = await live();
    final before = server.requestsTo('/api/v1/inbox').length;
    s.event(1, 'task.updated');
    await settle(400);
    expect(server.requestsTo('/api/v1/inbox'), hasLength(before));
  });

  test('a gap reads the inbox and the count again', () async {
    final c = await container();
    final list = c.listen(inboxListProvider(false), (_, _) {});
    final count = c.listen(inboxUnreadProvider, (_, _) {});
    addTearDown(list.close);
    addTearDown(count.close);
    await c.read(inboxListProvider(false).future);
    expect(await c.read(inboxUnreadProvider.future), 2);
    await live();
    server.inbox.first['read_at'] = '2026-11-01T12:00:00Z';
    await sockets.last.drop();
    await settle(1400);
    sockets.last.ack();
    await settle(400);
    expect(c.read(inboxUnreadProvider).value, 1);
  });

  test('marking moves the row and the badge at once, and rolls back', () async {
    final c = await container();
    final list = c.listen(inboxListProvider(false), (_, _) {});
    final count = c.listen(inboxUnreadProvider, (_, _) {});
    addTearDown(list.close);
    addTearDown(count.close);
    final items = (await c.read(inboxListProvider(false).future)).items;
    await c.read(inboxUnreadProvider.future);
    final marks = c.read(inboxMarksProvider.notifier);
    final item = items.first;
    marks.apply(item, read: true);
    expect(c.read(inboxListProvider(false)).value!.items.first.read, isTrue);
    expect(c.read(inboxUnreadProvider).value, 1);
    expect(notes.cancelled, [stableNoteId('i1')]);
    marks.rollback(item);
    expect(c.read(inboxListProvider(false)).value!.items.first.read, isFalse);
    await marks.send(item, read: true);
    expect(server.requestsTo('/api/v1/inbox/i1/read').single.method, 'PUT');
  });

  test('opening an item marks it read, and a refusal puts it back', () async {
    final c = await container();
    final list = c.listen(inboxListProvider(false), (_, _) {});
    addTearDown(list.close);
    final items = (await c.read(inboxListProvider(false).future)).items;
    server.failing['/api/v1/inbox/i1/read'] = FakeResponse(
      404,
      envelope('not_found', 'item'),
    );
    await c.read(inboxMarksProvider.notifier).openRead(items.first);
    expect(c.read(inboxListProvider(false)).value!.items.first.read, isFalse);
    server.failing.clear();
    await c.read(inboxMarksProvider.notifier).openRead(items.first);
    expect(c.read(inboxListProvider(false)).value!.items.first.read, isTrue);
  });

  test('mark all read clears every row and the badge', () async {
    final c = await container();
    final list = c.listen(inboxListProvider(false), (_, _) {});
    final count = c.listen(inboxUnreadProvider, (_, _) {});
    addTearDown(list.close);
    addTearDown(count.close);
    await c.read(inboxListProvider(false).future);
    await c.read(inboxUnreadProvider.future);
    final marks = c.read(inboxMarksProvider.notifier);
    final before = marks.applyAll();
    expect(before.map((i) => i.id), ['i1', 'i3']);
    expect(c.read(inboxUnreadProvider).value, 0);
    expect(
      c.read(inboxListProvider(false)).value!.items.every((i) => i.read),
      isTrue,
    );
    expect(notes.cancelledAll, 1);
    marks.rollbackAll(before);
    expect(
      c.read(inboxListProvider(false)).value!.items.where((i) => !i.read),
      hasLength(2),
    );
    expect(await marks.sendAll(), 2);
  });

  test('a kind filter reads on until a page holds a match', () async {
    server
      ..pageSize = 1
      ..inbox.removeAt(0);
    final c = await container();
    final list = c.listen(inboxListProvider(false), (_, _) {});
    addTearDown(list.close);
    await c.read(inboxListProvider(false).future);
    const filter = InboxFilter(kinds: {InboxKind.assigned});
    await c.read(inboxListProvider(false).notifier).fill(filter.keeps);
    expect(c.read(inboxListProvider(false)).value!.items.map((i) => i.id), [
      'i2',
      'i3',
    ]);
  });

  test('the filter toggles kinds and unread', () async {
    final c = await container();
    final f = c.read(inboxFilterStateProvider.notifier)
      ..toggleKind(InboxKind.mention)
      ..toggleKind(InboxKind.status)
      ..toggleKind(InboxKind.mention)
      ..setUnread(unread: true);
    expect(c.read(inboxFilterStateProvider).kinds, {InboxKind.status});
    expect(c.read(inboxFilterStateProvider).unread, isTrue);
    f.clearKinds();
    expect(c.read(inboxFilterStateProvider).kinds, isEmpty);
  });

  test(
    'muting a kind sends the whole list and rolls back on refusal',
    () async {
      final c = await container();
      final sub = c.listen(inboxMutedProvider, (_, _) {});
      addTearDown(sub.close);
      await c.read(inboxMutedProvider.future);
      final muted = c.read(inboxMutedProvider.notifier);
      await muted.setReceive(InboxKind.comment, receive: false);
      expect(server.inboxMuted, ['comment']);
      expect(c.read(inboxMutedProvider).value, {InboxKind.comment});
      server.failing['/api/v1/inbox/prefs'] = FakeResponse(
        500,
        envelope('internal', 'x'),
      );
      await expectLater(
        muted.setReceive(InboxKind.comment, receive: true),
        throwsA(anything),
      );
      expect(c.read(inboxMutedProvider).value, {InboxKind.comment});
    },
  );

  test('the summary counts open work, overdue and due today', () async {
    server.withSummary();
    final c = await container();
    final s = await c.read(inboxSummaryProvider.future);
    expect(s.open, 8);
    expect(s.completed, 4);
    expect(s.overdue, 1);
    expect(s.dueToday, 1);
  });
}
