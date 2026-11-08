// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/features/inbox/application/alerts.dart';

import '../../../helpers/app.dart';
import '../../../helpers/container.dart';
import '../../../helpers/fake_events.dart';
import '../../../helpers/fake_notes.dart';
import '../../../helpers/fake_tix.dart';
import '../../../helpers/stores.dart';

void main() {
  late FakeTix server;
  late FakeEventSockets sockets;
  late FakeNotes notes;
  late MemoryKeyValueStore settings;
  var seq = 0;

  Future<ProviderContainer> container() async {
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
    settings.values['notif.on.c1.'] = 'true';
    settings.values['notif.on.c1.default'] = 'true';
    for (var i = 0; i < 50; i++) {
      final key = c.read(sessionControllerProvider).value?.ref.tenantKey;
      if (key == 'default') break;
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    final sub = c.listen(inboxAlertsProvider, (_, _) {});
    addTearDown(sub.close);
    final prefs = c.listen(notificationPrefsStateProvider, (_, _) {});
    addTearDown(prefs.close);
    await c.read(inboxAlertsProvider.future);
    await Future<void>.delayed(Duration.zero);
    sockets.last.ack();
    await Future<void>.delayed(Duration.zero);
    return c;
  }

  setUp(() {
    server = FakeTix();
    sockets = FakeEventSockets();
    notes = FakeNotes();
    seq = 0;
  });

  Future<void> arrive(String id, String at) async {
    server.inbox.insert(
      0,
      inboxJson(id, ref: 'infra-4', title: 'Cut over', created: at),
    );
    sockets.last.event(++seq, 'inbox.updated', subjectId: 'me');
    await Future<void>.delayed(const Duration(milliseconds: 400));
    await pumpEventQueue();
  }

  test('every note carries a public version naming no task', () async {
    await container();
    await arrive('i9', '2026-11-01T11:45:00Z');
    final note = notes.shown.single;
    expect(note.body, contains('Cut over'));
    expect(note.publicTitle, 'New in your inbox');
    expect(note.publicBody, isNot(contains('Cut over')));
  });

  test('hiding content leaves the task out, for this context only', () async {
    final c = await container();
    expect(c.read(notificationPrefsStateProvider).hideContent, isFalse);
    await c
        .read(notificationPrefsStateProvider.notifier)
        .setHideContent(on: true);
    expect(c.read(notificationPrefsStateProvider).hideContent, isTrue);
    expect(
      settings.values.keys.where((k) => k.startsWith('notif.private.')),
      hasLength(1),
    );
    await arrive('i9', '2026-11-01T11:45:00Z');
    final note = notes.shown.single;
    expect(note.title, 'New in your inbox');
    expect(note.body, 'Open tix to read it.');
    expect(note.title + note.body, isNot(contains('infra-4')));
    expect(
      NoteTarget.parse(note.payload)?.route,
      '/projects/infra/tasks/infra-4',
    );
    await c
        .read(notificationPrefsStateProvider.notifier)
        .setHideContent(on: false);
    await arrive('i10', '2026-11-01T11:50:00Z');
    expect(notes.shown.last.body, contains('Cut over'));
  });
}
