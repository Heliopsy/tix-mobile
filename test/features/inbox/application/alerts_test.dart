// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/notifications/local_notifier.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/features/inbox/application/alerts.dart';
import 'package:tix_mobile/src/features/inbox/application/inbox.dart';

import '../../../helpers/app.dart';
import '../../../helpers/container.dart';
import '../../../helpers/fake_events.dart';
import '../../../helpers/fake_notes.dart';
import '../../../helpers/fake_tix.dart';
import '../../../helpers/stores.dart';

void main() {
  late FakeTix server;
  late FakeEventSockets sockets;
  var seq = 0;
  late FakeNotes notes;
  late MemoryKeyValueStore settings;

  Future<ProviderContainer> container({bool enabled = true}) async {
    final stores = signedInStores();
    settings = stores.settings;
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
    if (enabled) {
      // A token's tenant is named once whoami answers, which changes the
      // context's key from `c1.` to `c1.default`.
      settings.values['notif.on.c1.'] = 'true';
      settings.values['notif.on.c1.default'] = 'true';
    }
    for (var i = 0; i < 50; i++) {
      final key = c.read(sessionControllerProvider).value?.ref.tenantKey;
      if (key == 'default') break;
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    final sub = c.listen(inboxAlertsProvider, (_, _) {});
    addTearDown(sub.close);
    await c.read(inboxAlertsProvider.future);
    await Future<void>.delayed(Duration.zero);
    sockets.last.ack();
    await Future<void>.delayed(Duration.zero);
    return c;
  }

  setUp(() {
    server = FakeTix();
    sockets = FakeEventSockets();
    seq = 0;
    notes = FakeNotes();
  });

  Future<void> inboxUpdated() async {
    sockets.last.event(++seq, 'inbox.updated', subjectId: 'me');
    await Future<void>.delayed(const Duration(milliseconds: 400));
    await pumpEventQueue();
  }

  void arrive(
    String id, {
    String kind = 'mention',
    String at = '2026-11-01T11:45:00Z',
  }) => server.inbox.insert(
    0,
    inboxJson(id, kind: kind, ref: 'infra-4', title: 'Cut over', created: at),
  );

  test('items already there at start do not notify', () async {
    await container();
    expect(notes.shown, isEmpty);
    expect(
      settings.values.keys.where((k) => k.startsWith('notif.seen.')),
      hasLength(1),
    );
  });

  test('a new item notifies once, naming who did what to which task', () async {
    await container();
    arrive('i9');
    await inboxUpdated();
    expect(notes.shown, hasLength(1));
    final note = notes.shown.single;
    expect(note.title, '@raj mentioned you');
    expect(note.body, 'infra-4  Cut over');
    expect(note.id, stableNoteId('i9'));
    expect(note.badge, 3);
    final target = NoteTarget.parse(note.payload)!;
    expect(target.route, '/projects/infra/tasks/infra-4');
    expect(target.item, 'i9');
    await inboxUpdated();
    expect(notes.shown, hasLength(1));
  });

  test(
    'nothing notifies while notifications are off, and nothing piles up',
    () async {
      final c = await container(enabled: false);
      arrive('i9');
      await inboxUpdated();
      expect(notes.shown, isEmpty);
      await c
          .read(notificationPrefsStateProvider.notifier)
          .setEnabled(on: true);
      await inboxUpdated();
      expect(notes.shown, isEmpty);
    },
  );

  test('a kind turned off on this device does not notify', () async {
    final c = await container();
    await c
        .read(notificationPrefsStateProvider.notifier)
        .setKind(InboxKind.comment, on: false);
    expect(settings.values['notif.kinds'], 'mention,assigned,status');
    arrive('i9', kind: 'comment');
    await inboxUpdated();
    expect(notes.shown, isEmpty);
    arrive('i10', kind: 'assigned', at: '2026-11-01T11:50:00Z');
    await inboxUpdated();
    expect(notes.shown.single.title, '@raj assigned you');
  });

  test('a burst shows the newest three and sums up the rest', () async {
    await container();
    for (var i = 0; i < 5; i++) {
      arrive('n$i', at: '2026-11-01T11:4$i:00Z');
    }
    await inboxUpdated();
    expect(notes.shown, hasLength(4));
    expect(notes.shown.take(3).map((n) => n.id), [
      for (final id in ['n2', 'n3', 'n4']) stableNoteId(id),
    ]);
    expect(notes.shown.last.title, '2 more inbox items');
    expect(NoteTarget.parse(notes.shown.last.payload)!.route, '/inbox');
  });

  test('a tap marks the item read and answers its task', () async {
    final c = await container();
    final key = notificationContextKey(
      c.read(sessionControllerProvider).value!.ref,
    );
    final route = await c
        .read(inboxAlertsProvider.notifier)
        .open(
          NoteTarget(
            route: '/projects/infra/tasks/infra-1',
            item: 'i1',
            context: key,
          ).encode(),
        );
    expect(route, '/projects/infra/tasks/infra-1');
    expect(server.requestsTo('/api/v1/inbox/i1/read').single.method, 'PUT');
    expect(notes.cancelled, [stableNoteId('i1')]);
  });

  test('a tap from another context or not ours goes nowhere', () async {
    final c = await container();
    final alerts = c.read(inboxAlertsProvider.notifier);
    expect(
      await alerts.open(
        const NoteTarget(
          route: '/inbox',
          item: 'i1',
          context: 'other.x',
        ).encode(),
      ),
      isNull,
    );
    expect(await alerts.open('not json'), isNull);
    expect(await alerts.open(jsonEncode({'route': ''})), isNull);
    expect(server.requestsTo('/api/v1/inbox/i1/read'), isEmpty);
  });

  test(
    'turning on asks permission; a refusal keeps it off and says so',
    () async {
      notes.grant = false;
      final c = await container(enabled: false);
      expect(c.read(notificationPrefsStateProvider).nudge, isTrue);
      await c
          .read(notificationPrefsStateProvider.notifier)
          .setEnabled(on: true);
      expect(notes.asked, 1);
      final prefs = c.read(notificationPrefsStateProvider);
      expect(prefs.enabled, isFalse);
      expect(prefs.blocked, isTrue);
      expect(
        settings.values.keys.where((k) => k.startsWith('notif.on.')),
        isEmpty,
      );
      notes.grant = true;
      await c
          .read(notificationPrefsStateProvider.notifier)
          .setEnabled(on: true);
      expect(c.read(notificationPrefsStateProvider).enabled, isTrue);
      await c
          .read(notificationPrefsStateProvider.notifier)
          .setEnabled(on: false);
      expect(c.read(notificationPrefsStateProvider).enabled, isFalse);
      expect(notes.asked, 2);
    },
  );

  test('putting the offer off is remembered', () async {
    final c = await container(enabled: false);
    await c.read(notificationPrefsStateProvider.notifier).dismissNudge();
    expect(c.read(notificationPrefsStateProvider).nudge, isFalse);
    expect(settings.values['notif.nudge'], 'dismissed');
  });

  test('a failed inbox read notifies nothing and keeps the baseline', () async {
    await container();
    final seen = settings.values.entries
        .where((e) => e.key.startsWith('notif.seen.'))
        .single;
    server.failing['/api/v1/inbox'] = FakeResponse(
      500,
      envelope('internal', 'x'),
    );
    await inboxUpdated();
    expect(notes.shown, isEmpty);
    expect(settings.values[seen.key], seen.value);
  });

  test('an empty inbox at start still notifies the first item', () async {
    server.inbox.clear();
    await container();
    arrive('i9', at: '2026-11-01T12:05:00Z');
    await inboxUpdated();
    expect(notes.shown, hasLength(1));
  });
}
