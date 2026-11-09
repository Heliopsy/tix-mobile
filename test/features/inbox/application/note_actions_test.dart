// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/l10n/generated/app_localizations_en.dart';
import 'package:tix_mobile/src/core/notifications/local_notifier.dart';
import 'package:tix_mobile/src/core/offline/outbox.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/cache/response_cache.dart';
import 'package:tix_mobile/src/data/models/connection.dart';
import 'package:tix_mobile/src/data/models/instance.dart';
import 'package:tix_mobile/src/data/repositories/inbox_repository.dart';
import 'package:tix_mobile/src/data/repositories/task_detail_repository.dart';
import 'package:tix_mobile/src/data/repositories/task_list_repository.dart';
import 'package:tix_mobile/src/data/repositories/tasks_repository.dart';
import 'package:tix_mobile/src/features/inbox/application/alerts.dart';
import 'package:tix_mobile/src/features/inbox/application/note_actions.dart';

import '../../../helpers/fake_notes.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  final now = DateTime(2026, 11, 3, 15, 20);

  group('noteActionsFor', () {
    test('a task gets Done, Snooze and Reply', () {
      expect(noteActionsFor(opensTask: true, hidden: false), [
        NoteActionKind.done,
        NoteActionKind.snooze,
        NoteActionKind.reply,
      ]);
    });

    test('hidden content leaves Reply out', () {
      expect(noteActionsFor(opensTask: true, hidden: true), [
        NoteActionKind.done,
        NoteActionKind.snooze,
      ]);
    });

    test('an item about no task gets none', () {
      expect(noteActionsFor(opensTask: false, hidden: false), isEmpty);
      expect(noteActionsFor(opensTask: false, hidden: true), isEmpty);
    });
  });

  test('Snooze runs to nine tomorrow morning, local time', () {
    expect(snoozeUntil(now), DateTime(2026, 11, 4, 9));
    expect(snoozeUntil(DateTime(2026, 12, 31, 23)), DateTime(2027, 1, 1, 9));
  });

  group('NoteActionRequest.parse', () {
    const target = NoteTarget(
      route: '/projects/infra/tasks/infra-1',
      item: 'i1',
      context: 'c1.',
      taskRef: 'infra-1',
      projectKey: 'infra',
    );

    test('reads the button, the notification, the item and the text', () {
      final r = NoteActionRequest.parse({
        'id': 42,
        'action': 'reply',
        'payload': target.encode(),
        'text': 'on it',
      })!;
      expect(r.kind, NoteActionKind.reply);
      expect(r.noteId, 42);
      expect(r.text, 'on it');
      expect(r.target.taskRef, 'infra-1');
      expect(r.target.projectKey, 'infra');
      expect(r.target.item, 'i1');
      expect(r.target.context, 'c1.');
    });

    test('refuses anything else', () {
      expect(NoteActionRequest.parse(null), isNull);
      expect(
        NoteActionRequest.parse({
          'id': 1,
          'action': 'delete',
          'payload': target.encode(),
        }),
        isNull,
      );
      expect(
        NoteActionRequest.parse({'id': 1, 'action': 'done', 'payload': '{'}),
        isNull,
      );
      expect(
        NoteActionRequest.parse({
          'id': '1',
          'action': 'done',
          'payload': target.encode(),
        }),
        isNull,
      );
    });
  });

  group('noteContextEntry', () {
    final at = DateTime.utc(2026);
    final instance = Instance(
      id: 'i1',
      name: 'Work',
      kind: InstanceKind.remote,
      createdAt: at,
    );
    ContextEntry entry(String connection, String tenant) => ContextEntry(
      instance: instance,
      connection: Connection(
        id: connection,
        instanceId: 'i1',
        kind: ConnectionKind.token,
        createdAt: at,
      ),
      tenantKey: tenant,
      tenantName: tenant,
    );

    test('matches the key exactly first', () {
      final acme = entry('c1', 'acme');
      final beta = entry('c1', 'beta');
      expect(noteContextEntry('c1.beta', [acme, beta]), beta);
    });

    test('a key without a tenant finds the connection when it is the only '
        'one', () {
      final acme = entry('c1', 'acme');
      expect(noteContextEntry('c1.', [acme, entry('c2', 'x')]), acme);
      expect(noteContextEntry('c1.', [acme, entry('c1', 'beta')]), isNull);
      expect(noteContextEntry('c9.acme', [acme]), isNull);
    });
  });

  group('NoteActionRunner', () {
    late FakeTix server;
    late FakeNotes notes;
    late SyncStores stores;
    late MemoryCacheStore cache;
    var reachable = true;
    const scope = CacheScope('c1', '');

    NoteActionContext open() {
      final api = server.factory(
        'https://tix.example',
        const BearerCredential('tok'),
      );
      final responses = ResponseCache(cache, scope);
      final online = reachable;
      final outbox = Outbox(
        stores.of(scope),
        offline: () => !online,
        clock: () => now,
      );
      return NoteActionContext(
        outbox: outbox,
        detail: TaskDetailRepository(api, responses, outbox: outbox),
        tasks: TasksRepository(api, responses, outbox: outbox),
        lists: TaskListRepository(api, responses, outbox: outbox),
        inbox: InboxRepository(api, responses),
        reachable: online,
      );
    }

    NoteActionRunner runner({bool known = true}) => NoteActionRunner(
      open: (key) async => known && key == 'c1.' ? open() : null,
      notes: notes,
      l10n: AppLocalizationsEn.new,
      now: () => now,
    );

    NoteActionRequest request(NoteActionKind kind, {String text = ''}) =>
        NoteActionRequest(
          kind: kind,
          noteId: 7,
          text: text,
          target: const NoteTarget(
            route: '/projects/infra/tasks/infra-1',
            item: 'i1',
            context: 'c1.',
            taskRef: 'infra-1',
            projectKey: 'infra',
          ),
        );

    Future<List<OutboxEntry>> queued() async =>
        (await stores.of(scope).load()).entries;

    setUp(() {
      server = FakeTix();
      notes = FakeNotes();
      cache = MemoryCacheStore();
      stores = SyncStores(cache);
      reachable = true;
    });

    test('Done routes to the done state with a key and marks the item '
        'read', () async {
      final outcome = await runner().run(request(NoteActionKind.done));
      expect(outcome, NoteActionOutcome.sent);
      expect(server.task('infra-1')!['status'], 'done');
      final route = server.requestsTo('/tasks/infra-1/route').single;
      expect(route.headers['Idempotency-Key'], isNotEmpty);
      expect(
        server.inbox.firstWhere((i) => i['id'] == 'i1')['read_at'],
        isNotNull,
      );
      expect(notes.cancelled, [7]);
      expect(notes.shown, isEmpty);
      expect(await queued(), isEmpty);
    });

    test('Snooze sends the snooze until tomorrow morning', () async {
      final outcome = await runner().run(request(NoteActionKind.snooze));
      expect(outcome, NoteActionOutcome.sent);
      final until = DateTime.parse(
        server.task('infra-1')!['snoozed_until']! as String,
      );
      expect(until.isAtSameMomentAs(DateTime(2026, 11, 4, 9)), isTrue);
      expect(
        server
            .requestsTo('/tasks/infra-1/snooze')
            .single
            .headers['Idempotency-Key'],
        isNotEmpty,
      );
    });

    test('Reply posts the trimmed text as a comment', () async {
      final outcome = await runner().run(
        request(NoteActionKind.reply, text: '  on it \n'),
      );
      expect(outcome, NoteActionOutcome.sent);
      expect(server.comments['infra-1']!.single['body'], 'on it');
      expect(notes.cancelled, [7]);
    });

    test('offline, each action waits in the outbox with its own key', () async {
      reachable = false;
      final run = runner();
      expect(
        await run.run(request(NoteActionKind.reply, text: 'later')),
        NoteActionOutcome.queued,
      );
      expect(
        await run.run(request(NoteActionKind.snooze)),
        NoteActionOutcome.queued,
      );
      final entries = await queued();
      expect(
        [for (final e in entries) e.op],
        [OutboxOp.comment, OutboxOp.snooze],
      );
      expect(entries.map((e) => e.target).toSet(), {'infra-1'});
      expect(entries.first.values, {'body': 'later'});
      expect(entries.last.values, {
        'until': DateTime(2026, 11, 4, 9).toUtc().toIso8601String(),
      });
      expect(entries.map((e) => e.idempotencyKey).toSet(), hasLength(2));
      expect(server.requests, isEmpty);
      expect(notes.cancelled, [7, 7]);
      expect(notes.shown, isEmpty);
    });

    test('a server that drops out queues the write instead', () async {
      server.offline = true;
      expect(
        await runner().run(request(NoteActionKind.reply, text: 'x')),
        NoteActionOutcome.queued,
      );
      final entry = (await queued()).single;
      expect(entry.op, OutboxOp.comment);
      expect(entry.idempotencyKey, isNotEmpty);
    });

    test('offline Done finds the done state in the saved copies', () async {
      final warm = open();
      await warm.tasks.task('infra-1');
      await warm.tasks.projects();
      await warm.lists.workflows();
      final before = server.requests.length;
      reachable = false;
      expect(
        await runner().run(request(NoteActionKind.done)),
        NoteActionOutcome.queued,
      );
      final entry = (await queued()).single;
      expect(entry.op, OutboxOp.move);
      expect(entry.values, {'to': 'done'});
      expect(entry.idempotencyKey, isNotEmpty);
      expect(server.requests, hasLength(before));
    });

    test(
      'offline Done with no saved copy of the task fails and says so',
      () async {
        reachable = false;
        expect(
          await runner().run(request(NoteActionKind.done)),
          NoteActionOutcome.failed,
        );
        expect(await queued(), isEmpty);
        expect(notes.shown.single.title, "Couldn't mark it done");
        expect(notes.shown.single.body, 'Open tix to try again.');
        expect(notes.shown.single.title, isNot(contains('infra')));
      },
    );

    test('a refusal is not queued and says so', () async {
      server.failing['/api/v1/tasks/infra-1/comments'] = FakeResponse(
        403,
        envelope('forbidden', 'no'),
      );
      expect(
        await runner().run(request(NoteActionKind.reply, text: 'hi')),
        NoteActionOutcome.failed,
      );
      expect(await queued(), isEmpty);
      expect(notes.cancelled, [7]);
      expect(notes.shown.single.title, "Couldn't send your reply");
      expect(NoteTarget.parse(notes.shown.single.payload)!.taskRef, 'infra-1');
    });

    test('an empty reply or a forgotten context fails', () async {
      expect(
        await runner().run(request(NoteActionKind.reply, text: '  ')),
        NoteActionOutcome.failed,
      );
      expect(
        await runner(known: false).run(request(NoteActionKind.snooze)),
        NoteActionOutcome.failed,
      );
      expect(server.requests, isEmpty);
      expect(notes.shown, hasLength(2));
    });
  });
}
