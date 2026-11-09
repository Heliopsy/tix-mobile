// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/data/cache/cache_store.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/data/offline/connection_jobs.dart';
import 'package:tix_mobile/src/data/offline/outbox.dart';

import 'fake_sender.dart';

void main() {
  late SyncStore store;
  late MemoryCacheStore cache;
  late Outbox outbox;
  late FakeSender server;
  late OutboxReplayer replayer;
  late bool offline;
  late ConflictPolicy policy;
  var ids = 0;

  final t0 = DateTime.utc(2026, 11, 8, 12);
  const a = Task(
    id: '1',
    ref: 'infra-1',
    title: 'Fix login',
    status: 'todo',
    priority: 3,
    body: 'Steps',
    projectId: 'infra',
    version: 4,
  );
  const b = Task(id: '2', ref: 'infra-2', title: 'Docs', version: 1);

  setUp(() {
    ids = 0;
    offline = true;
    policy = ConflictPolicy.ask;
    cache = MemoryCacheStore();
    store = SyncStore(cache, const CacheScope('c1', ''));
    String uuid() => 'u${ids++}';
    outbox = Outbox(store, offline: () => offline, clock: () => t0, uuid: uuid);
    server = FakeSender([a, b]);
    replayer = OutboxReplayer(
      store,
      server,
      policy: () => policy,
      clock: () => t0,
      uuid: uuid,
    );
  });

  Future<OutboxEntry> queue(
    OutboxOp op,
    String target, {
    Task? base,
    Map<String, Object?> values = const {},
  }) => outbox.write(
    op: op,
    target: target,
    base: base,
    values: values,
    online: (_) => fail('sent while offline'),
    local: (e) => e,
  );

  List<OutboxEntry> entries() => store.now.entries;
  List<ConflictRecord> conflicts() => store.now.conflicts;

  group('ordering', () {
    test(
      'writes to one task go in order, each on the version before',
      () async {
        await queue(OutboxOp.update, a.ref, base: a, values: {'title': 'One'});
        await queue(OutboxOp.update, a.ref, base: a, values: {'priority': 1});
        await queue(OutboxOp.move, a.ref, base: a, values: {'to': 'doing'});

        final report = await replayer.replay();

        expect(report.sent, 3);
        expect(entries(), isEmpty);
        expect(
          [for (final c in server.calls) c.op],
          [OutboxOp.update, OutboxOp.update, OutboxOp.move],
        );
        expect([for (final c in server.calls) c.version], [4, 5, null]);
        final now = server.tasks[a.ref]!;
        expect((now.title, now.priority, now.status), ('One', 1, 'doing'));
      },
    );

    test('a write waiting for the person holds back later writes to that '
        'task only', () async {
      server.edit(a.ref, (t) => t.copyWith(title: 'Theirs'));
      await queue(OutboxOp.update, a.ref, base: a, values: {'title': 'Mine'});
      await queue(OutboxOp.update, a.ref, base: a, values: {'priority': 1});
      await queue(OutboxOp.update, b.ref, base: b, values: {'title': 'Guide'});

      await replayer.replay();

      expect(server.tasks[a.ref]!.priority, 3);
      expect(server.tasks[b.ref]!.title, 'Guide');
      expect(entries().map((e) => (e.target, e.state)), [
        (a.ref, OutboxState.conflict),
        (a.ref, OutboxState.pending),
      ]);
    });

    test('an unreachable server leaves every write waiting', () async {
      await queue(OutboxOp.update, a.ref, base: a, values: {'title': 'One'});
      server.down = true;

      final report = await replayer.replay();

      expect(report.unreachable, isTrue);
      expect(entries().single.state, OutboxState.pending);
    });

    test('online, a write to a task with writes waiting queues behind '
        'them', () async {
      await queue(OutboxOp.update, a.ref, base: a, values: {'title': 'One'});
      offline = false;
      var sent = false;
      await outbox.write<void>(
        op: OutboxOp.update,
        target: a.ref,
        base: a,
        values: {'priority': 1},
        online: (_) async => sent = true,
        local: (_) {},
      );
      expect(sent, isFalse);
      expect(entries(), hasLength(2));
    });

    test('online, a network failure queues the write', () async {
      offline = false;
      final e = await outbox.write<OutboxEntry?>(
        op: OutboxOp.comment,
        target: a.ref,
        values: {'body': 'hi'},
        online: (_) => throw const TixException(TixErrorKind.network),
        local: (e) => e,
      );
      expect(e?.op, OutboxOp.comment);
      expect(entries(), hasLength(1));
    });

    test('online, a refusal is not queued', () async {
      offline = false;
      await expectLater(
        outbox.write<void>(
          op: OutboxOp.comment,
          target: a.ref,
          online: (_) => throw const TixException(TixErrorKind.forbidden),
          local: (_) {},
        ),
        throwsA(isA<TixException>()),
      );
      expect(entries(), isEmpty);
    });
  });

  group('drafts', () {
    test('writes to a draft are sent to the real reference once it is '
        'created', () async {
      final draft = await outbox.create({
        'title': 'Spike !high',
        'project_ref': 'infra',
        'parse': true,
      }, online: (_) => fail('sent while offline'));
      expect(draft.ref, 'infra-draft1');
      expect(isDraftRef(draft.ref), isTrue);
      final sub = await outbox.create({
        'title': 'Sub',
        'project_ref': 'infra',
        'parent_ref': draft.ref,
      }, online: (_) => fail('sent while offline'));
      await queue(OutboxOp.comment, draft.ref, values: {'body': 'note'});
      await queue(
        OutboxOp.dependencyAdd,
        b.ref,
        values: {'depends_on': draft.ref},
      );
      await queue(OutboxOp.update, draft.ref, values: {'priority': 1});

      final report = await replayer.replay();

      expect(report.sent, 5);
      expect(entries(), isEmpty);
      final real = outbox.realRef(draft.ref);
      expect(real, isNot(draft.ref));
      expect(server.tasks[real]!.title, 'Spike');
      expect(server.tasks[real]!.priority, 1);
      expect(server.tasks[outbox.realRef(sub.ref)]!.parentId, real);
      expect(server.comments[real], ['note']);
      expect(server.comments['${b.ref}/deps'], [real]);
      expect(
        server.calls.where(
          (c) =>
              (c.op != OutboxOp.create && isDraftRef(c.target)) ||
              c.values.values.any((v) => v is String && isDraftRef(v)),
        ),
        isEmpty,
        reason: 'no request names a draft',
      );
    });

    test('a write still waiting after its draft was sent names the real '
        'reference', () async {
      final draft = await outbox.create({
        'title': 'Spike',
        'project_ref': 'infra',
      }, online: (_) => fail('sent while offline'));
      await queue(
        OutboxOp.dependencyAdd,
        b.ref,
        values: {'depends_on': draft.ref},
      );
      server.refuse[b.ref] = const TixException(TixErrorKind.forbidden);

      await replayer.replay();

      final waiting = entries().single;
      expect(waiting.state, OutboxState.failed);
      expect(waiting.values['depends_on'], outbox.realRef(draft.ref));
      expect(isDraftRef('${waiting.values['depends_on']}'), isFalse);
    });

    test(
      'a draft that never got created holds back what waits on it',
      () async {
        final draft = await outbox.create({
          'title': 'Spike',
          'project_ref': 'infra',
        }, online: (_) => fail('sent while offline'));
        await queue(
          OutboxOp.dependencyAdd,
          b.ref,
          values: {'depends_on': draft.ref},
        );
        server.refuse[draft.ref] = const TixException(
          TixErrorKind.forbidden,
          message: 'no task:create',
        );

        await replayer.replay();

        expect(entries().map((e) => e.state), [
          OutboxState.failed,
          OutboxState.pending,
        ]);
        expect(entries().first.errorMessage, 'no task:create');
        expect(server.comments['${b.ref}/deps'], isNull);
      },
    );
  });

  group('idempotent retry', () {
    setUp(() async {
      await outbox.create({
        'title': 'Spike',
        'project_ref': 'infra',
      }, online: (_) => fail('sent while offline'));
      server.loseNextAnswer = true;
    });

    test('a server that honours the key is asked again with the same '
        'key', () async {
      server.honoursKeys = true;
      final first = await replayer.replay();
      expect(first.unreachable, isTrue);
      expect(entries().single.state, OutboxState.pending);

      await replayer.replay();

      expect(entries(), isEmpty);
      final creates = server.calls.where((c) => c.op == OutboxOp.create);
      expect(creates.map((c) => c.key).toSet(), hasLength(1));
      expect(
        server.tasks.values.where((t) => t.title == 'Spike'),
        hasLength(1),
      );
    });

    test('a server that says the create was applied but its answer was '
        'not kept is not asked again; the task is found', () async {
      server
        ..honoursKeys = true
        ..loseNextAnswer = false
        ..tasks['infra-77'] = const Task(
          ref: 'infra-77',
          title: 'Spike',
          projectId: 'infra',
        );
      server.refuse['infra-draft1'] = const TixException(
        TixErrorKind.conflict,
        message:
            'the request with this idempotency key was applied but its '
            'response was not kept',
      );

      await replayer.replay();

      expect(entries(), isEmpty);
      expect(outbox.realRef('infra-draft1'), 'infra-77');
      expect(server.calls.where((c) => c.op == OutboxOp.create), hasLength(1));
    });

    test('a request with the key still running is tried again later', () async {
      server
        ..honoursKeys = true
        ..loseNextAnswer = false
        ..refuse['infra-draft1'] = const TixException(
          TixErrorKind.conflict,
          message: 'a request with this idempotency key is still running',
        );

      final first = await replayer.replay();

      expect(first.unreachable, isTrue);
      expect(entries().single.state, OutboxState.pending);
      await replayer.replay();
      expect(entries(), isEmpty);
    });

    test('an update applied the first time is done after a read', () async {
      await outbox.discardAll();
      server.honoursKeys = true;
      await queue(OutboxOp.update, a.ref, base: a, values: {'title': 'One'});
      server.edit(a.ref, (t) => t.copyWith(title: 'One'));
      server.refuse[a.ref] = const TixException(
        TixErrorKind.conflict,
        message:
            'the request with this idempotency key was applied but its '
            'response was not kept',
      );

      await replayer.replay();

      expect(entries(), isEmpty);
      expect(conflicts(), isEmpty);
    });

    test('whether the server honours keys is asked once and kept', () async {
      server
        ..honoursKeys = true
        ..loseNextAnswer = false;
      await replayer.replay();
      await outbox.create({
        'title': 'Another',
        'project_ref': 'infra',
      }, online: (_) => fail('sent while offline'));
      await replayer.replay();
      expect(server.probes, 1);
      expect(store.now.idempotency, isTrue);
    });

    test('without the key, a lost create is looked up rather than sent '
        'twice', () async {
      await replayer.replay();
      expect(entries().single.state, OutboxState.needsCheck);

      await replayer.replay();

      expect(entries(), isEmpty);
      expect(server.calls.where((c) => c.op == OutboxOp.create), hasLength(1));
      expect(
        server.tasks.values.where((t) => t.title == 'Spike'),
        hasLength(1),
      );
      expect(outbox.realRef('infra-draft1'), isNot('infra-draft1'));
    });

    test(
      'without the key, a create found twice waits for the person',
      () async {
        await replayer.replay();
        server.tasks['infra-x'] = const Task(
          ref: 'infra-x',
          title: 'Spike',
          projectId: 'infra',
        );

        await replayer.replay();

        expect(entries().single.state, OutboxState.needsCheck);
        await outbox.forgetCreate(entries().single.id);
        expect(entries(), isEmpty);
      },
    );

    test(
      'an online create whose answer is lost is queued to be checked',
      () async {
        await outbox.discardAll();
        offline = false;
        final draft = await outbox.create({
          'title': 'Other',
          'project_ref': 'infra',
        }, online: (_) => throw const TixException(TixErrorKind.timeout));
        expect(isDraftRef(draft.ref), isTrue);
        expect(entries().single.state, OutboxState.needsCheck);
      },
    );
  });

  group('three-way merge on 409', () {
    test('disjoint changes merge and are sent on the new version', () async {
      server.edit(a.ref, (t) => t.copyWith(priority: 1));
      await queue(OutboxOp.update, a.ref, base: a, values: {'title': 'Mine'});

      final report = await replayer.replay();

      expect(report.conflicts, 0);
      expect(conflicts(), isEmpty);
      final now = server.tasks[a.ref]!;
      expect((now.title, now.priority), ('Mine', 1));
      expect(server.calls.last.version, 5);
    });

    group('the same attribute', () {
      setUp(() async {
        server.edit(a.ref, (t) => t.copyWith(title: 'Theirs'));
        await queue(
          OutboxOp.update,
          a.ref,
          base: a,
          values: {'title': 'Mine', 'priority': 2},
        );
      });

      test('asks by default', () async {
        await replayer.replay();

        expect(entries().single.state, OutboxState.conflict);
        final r = conflicts().single;
        expect(r.resolution, isNull);
        expect(r.fields.single.field, 'title');
        expect(
          (r.fields.single.mine, r.fields.single.theirs),
          ('Mine', 'Theirs'),
        );
        expect(server.tasks[a.ref]!.title, 'Theirs');
      });

      test('keep mine sends mine and records it', () async {
        policy = ConflictPolicy.keepMine;
        await replayer.replay();

        expect(entries(), isEmpty);
        expect(server.tasks[a.ref]!.title, 'Mine');
        expect(server.tasks[a.ref]!.priority, 2);
        expect(conflicts().single.resolution, Resolution.mine);
        expect(conflicts().single.auto, isTrue);
      });

      test(
        'keep theirs keeps theirs, sends the rest, and records it',
        () async {
          policy = ConflictPolicy.keepTheirs;
          await replayer.replay();

          expect(entries(), isEmpty);
          expect(server.tasks[a.ref]!.title, 'Theirs');
          expect(server.tasks[a.ref]!.priority, 2);
          expect(conflicts().single.resolution, Resolution.theirs);
        },
      );

      test('the person settles it by keeping mine', () async {
        await replayer.replay();
        await outbox.resolve(conflicts().single.id, Resolution.mine);
        await replayer.replay();

        expect(server.tasks[a.ref]!.title, 'Mine');
        expect(conflicts().single.resolution, Resolution.mine);
        expect(conflicts().single.auto, isFalse);
      });

      test('the person settles it with an edit', () async {
        await replayer.replay();
        await outbox.resolve(
          conflicts().single.id,
          Resolution.edited,
          edited: {'title': 'Both'},
        );
        await replayer.replay();

        expect(server.tasks[a.ref]!.title, 'Both');
        expect(server.tasks[a.ref]!.priority, 2);
      });

      test('keep all theirs settles every open conflict', () async {
        server.edit(b.ref, (t) => t.copyWith(title: 'B theirs'));
        await queue(OutboxOp.update, b.ref, base: b, values: {'title': 'B'});
        await replayer.replay();
        expect(conflicts().where((r) => r.resolution == null), hasLength(2));

        await outbox.resolveAll(Resolution.theirs);
        await replayer.replay();

        expect(
          conflicts().every((r) => r.resolution == Resolution.theirs),
          isTrue,
        );
        expect(server.tasks[a.ref]!.title, 'Theirs');
        expect(server.tasks[a.ref]!.priority, 2);
        expect(server.tasks[b.ref]!.title, 'B theirs');
      });
    });

    test("a status move over someone else's move follows the policy", () async {
      server.edit(a.ref, (t) => t.copyWith(status: 'blocked'));
      await queue(OutboxOp.move, a.ref, base: a, values: {'to': 'doing'});

      await replayer.replay();

      expect(conflicts().single.fields.single.field, 'status');
      expect(server.tasks[a.ref]!.status, 'blocked');
      await outbox.resolve(conflicts().single.id, Resolution.mine);
      await replayer.replay();
      expect(server.tasks[a.ref]!.status, 'doing');
    });

    test("a move the workflow refuses is a conflict with the server's "
        'reason', () async {
      server.forbiddenMoves['done'] = 'no route from todo to done';
      await queue(OutboxOp.move, a.ref, base: a, values: {'to': 'done'});

      await replayer.replay();

      final r = conflicts().single;
      expect(r.kind, ConflictKind.invalidMove);
      expect(r.reason, 'no route from todo to done');
      expect(r.wanted, 'done');
      expect(entries().single.state, OutboxState.conflict);

      await outbox.resolve(r.id, Resolution.edited, edited: {'to': 'doing'});
      await replayer.replay();
      expect(server.tasks[a.ref]!.status, 'doing');
    });

    group('a task deleted on the server', () {
      setUp(() async {
        await queue(OutboxOp.update, a.ref, base: a, values: {'title': 'Mine'});
        await queue(OutboxOp.comment, a.ref, values: {'body': 'note'});
        server.delete(a.ref);
        await replayer.replay();
      });

      test('is a conflict', () {
        expect(conflicts().single.kind, ConflictKind.deleted);
        expect(entries().first.state, OutboxState.conflict);
      });

      test('restore and apply brings it back with the writes', () async {
        await outbox.resolve(conflicts().single.id, Resolution.restored);
        await replayer.replay();

        expect(server.tasks[a.ref]!.title, 'Mine');
        expect(server.comments[a.ref], ['note']);
        expect(entries(), isEmpty);
      });

      test('discard mine drops every write to it', () async {
        await outbox.resolve(conflicts().single.id, Resolution.discarded);

        expect(entries(), isEmpty);
        expect(server.tasks[a.ref], isNull);
      });
    });

    test('additive writes never conflict', () async {
      server.edit(a.ref, (t) => t.copyWith(title: 'Theirs', tags: ['ops']));
      await queue(OutboxOp.comment, a.ref, base: a, values: {'body': 'hi'});
      await queue(OutboxOp.tagAdd, a.ref, base: a, values: {'name': 'auth'});
      await queue(OutboxOp.star, a.ref, base: a);

      final report = await replayer.replay();

      expect(report.conflicts, 0);
      expect(entries(), isEmpty);
      expect(server.comments[a.ref], ['hi']);
      expect(server.tasks[a.ref]!.tags, ['ops', 'auth']);
      expect(server.tasks[a.ref]!.starred, isTrue);
    });

    test('a refusal fails the write with the reason; it can be edited and '
        'sent again', () async {
      await queue(OutboxOp.update, a.ref, base: a, values: {'priority': 9});
      server.refuse[a.ref] = const TixException(
        TixErrorKind.invalid,
        message: 'priority must be 1 to 5',
      );

      final report = await replayer.replay();

      expect(report.failed, 1);
      final e = entries().single;
      expect(
        (e.state, e.errorCode, e.errorMessage),
        (OutboxState.failed, 'invalid', 'priority must be 1 to 5'),
      );
      await outbox.retry(e.id, values: {'priority': 1});
      await replayer.replay();
      expect(server.tasks[a.ref]!.priority, 1);
    });
  });

  group('policy and history', () {
    test('changing the policy settles conflicts found after, not the open '
        'ones', () async {
      server.edit(a.ref, (t) => t.copyWith(title: 'Theirs'));
      await queue(OutboxOp.update, a.ref, base: a, values: {'title': 'Mine'});
      await replayer.replay();

      policy = ConflictPolicy.keepTheirs;
      server.edit(b.ref, (t) => t.copyWith(title: 'B theirs'));
      await queue(OutboxOp.update, b.ref, base: b, values: {'title': 'B'});
      await replayer.replay();

      final byRef = {for (final r in conflicts()) r.taskRef: r};
      expect(byRef[a.ref]!.resolution, isNull);
      expect(byRef[b.ref]!.resolution, Resolution.theirs);
      expect(byRef[b.ref]!.auto, isTrue);
    });

    test('a settled conflict is reversed by sending the other side', () async {
      policy = ConflictPolicy.keepMine;
      server.edit(a.ref, (t) => t.copyWith(title: 'Theirs'));
      await queue(OutboxOp.update, a.ref, base: a, values: {'title': 'Mine'});
      await replayer.replay();
      expect(server.tasks[a.ref]!.title, 'Mine');
      final r = conflicts().single;
      expect(Outbox.reversible(r), isTrue);

      await outbox.reverse(r.id);
      await replayer.replay();

      expect(server.tasks[a.ref]!.title, 'Theirs');
      expect(conflicts().single.resolution, Resolution.theirs);

      await outbox.reverse(r.id);
      await replayer.replay();
      expect(server.tasks[a.ref]!.title, 'Mine');
    });

    test('the outbox survives a restart', () async {
      await queue(OutboxOp.update, a.ref, base: a, values: {'title': 'One'});
      final kept = SyncStore(cache, store.scope);
      expect((await kept.load()).entries.single.values, {'title': 'One'});
    });
  });

  group('one replay at a time', () {
    test('two replayers of one outbox never send a write twice', () async {
      final locks = ReplayLocks();
      OutboxReplayer make() =>
          OutboxReplayer(store, server, policy: () => policy, locks: locks);
      await queue(OutboxOp.update, a.ref, base: a, values: {'title': 'One'});
      server.hold = Completer<void>();
      final first = make().replay();
      await pumpEventQueue();
      final second = make().replay();
      await pumpEventQueue();
      server.hold!.complete();
      final reports = await Future.wait([first, second]);
      expect(reports.map((r) => r.sent), [1, 0]);
      expect(server.calls, hasLength(1));
      expect(locks.busy(store.scope), isFalse);
    });

    test('the policy is read once, when the replay starts', () async {
      var reads = 0;
      final counted = OutboxReplayer(
        store,
        server,
        policy: () {
          reads++;
          return ConflictPolicy.keepMine;
        },
        clock: () => t0,
      );
      server
        ..edit(a.ref, (t) => t.copyWith(title: 'Theirs'))
        ..edit(b.ref, (t) => t.copyWith(title: 'Theirs too'));
      await queue(OutboxOp.update, a.ref, base: a, values: {'title': 'Mine'});
      await queue(OutboxOp.update, b.ref, base: b, values: {'title': 'Mine'});

      final report = await counted.replay();

      expect(report.conflicts, 2);
      expect(reads, 1);
    });

    test('a cancelled job stops before the next write', () async {
      final jobs = ConnectionJobs();
      await queue(OutboxOp.update, a.ref, base: a, values: {'title': 'One'});
      await queue(OutboxOp.update, a.ref, base: a, values: {'priority': 1});
      server.hold = Completer<void>();
      final replay = jobs.run('c1', (job) => replayer.replay(job: job));
      await pumpEventQueue();
      final stop = jobs.stop('c1');
      server.hold!.complete();
      await expectLater(replay, throwsA(isA<JobCancelled>()));
      await stop;
      expect(server.calls, hasLength(1));
      expect(entries(), hasLength(1));
    });
  });

  group('idempotency keys a day old', () {
    late DateTime now;
    late OutboxReplayer aged;

    setUp(() async {
      now = t0;
      server.honoursKeys = true;
      aged = OutboxReplayer(
        store,
        server,
        policy: () => policy,
        clock: () => now,
        uuid: () => 'k${ids++}',
      );
      await outbox.create({
        'title': 'Spike',
        'project_ref': 'infra',
      }, online: (_) => fail('sent while offline'));
    });

    List<SentCall> creates() =>
        server.calls.where((c) => c.op == OutboxOp.create).toList();

    test('a create sent over 23 hours ago is looked up, not sent '
        'again', () async {
      server.loseNextAnswer = true;
      await aged.replay();
      expect(entries().single.firstSentAt, t0);
      server.forgetKeys();
      now = t0.add(idempotencyKeyLife);

      await aged.replay();

      expect(entries(), isEmpty);
      expect(creates(), hasLength(1));
      expect(
        server.tasks.values.where((t) => t.title == 'Spike'),
        hasLength(1),
      );
    });

    test('found twice, it waits for the person as a create to check', () async {
      server.loseNextAnswer = true;
      await aged.replay();
      server
        ..forgetKeys()
        ..tasks['infra-x'] = const Task(
          ref: 'infra-x',
          title: 'Spike',
          projectId: 'infra',
        );
      now = t0.add(const Duration(days: 2));

      await aged.replay();

      expect(entries().single.state, OutboxState.needsCheck);
      expect(creates(), hasLength(1));
    });

    test('found nowhere, it is sent with a fresh key', () async {
      await store.update((s) => s.copyWith(idempotency: true));
      server.timeOutNext = true;
      await aged.replay();
      final first = entries().single;
      expect(first.firstSentAt, t0);
      now = t0.add(const Duration(hours: 30));

      await aged.replay();

      expect(entries(), isEmpty);
      expect(creates().single.key, isNot(first.idempotencyKey));
    });

    test(
      'a refused connection is not an attempt: no stamp, same key',
      () async {
        await store.update((s) => s.copyWith(idempotency: false));
        final key = entries().single.idempotencyKey;
        server.down = true;
        await aged.replay();
        expect(entries().single.firstSentAt, isNull);
        expect(entries().single.state, OutboxState.pending);
        server.down = false;
        now = t0.add(const Duration(days: 2));

        await aged.replay();

        expect(entries(), isEmpty);
        expect(creates().single.key, key);
      },
    );

    test(
      'a title that only starts like the queued one is never adopted',
      () async {
        await outbox.discardAll();
        await store.update((s) => s.copyWith(idempotency: false));
        final draft = await outbox.create({
          'title': 'Call Bob re invoice',
          'project_ref': 'infra',
        }, online: (_) => fail('sent while offline'));
        server
          ..timeOutNext = true
          ..tasks['infra-50'] = const Task(
            ref: 'infra-50',
            title: 'Call Bob',
            projectId: 'infra',
          );
        await aged.replay();
        expect(entries().single.state, OutboxState.needsCheck);

        await aged.replay();

        expect(entries().single.state, OutboxState.needsCheck);
        expect(outbox.realRef(draft.ref), draft.ref);
        expect(creates(), isEmpty);
      },
    );

    test('an exact title, spaced differently, is adopted', () async {
      await outbox.discardAll();
      await store.update((s) => s.copyWith(idempotency: false));
      final draft = await outbox.create({
        'title': '  Call   Bob ',
        'project_ref': 'infra',
      }, online: (_) => fail('sent while offline'));
      server
        ..timeOutNext = true
        ..tasks['infra-50'] = const Task(
          ref: 'infra-50',
          title: 'Call Bob',
          projectId: 'infra',
        );
      await aged.replay();
      await aged.replay();
      expect(entries(), isEmpty);
      expect(outbox.realRef(draft.ref), 'infra-50');
    });

    group('comments', () {
      setUp(() async {
        await outbox.discardAll();
        await store.update((s) => s.copyWith(idempotency: true));
        await queue(OutboxOp.comment, a.ref, values: {'body': 'Before Friday'});
      });

      List<SentCall> adds() =>
          server.calls.where((c) => c.op == OutboxOp.comment).toList();

      test('a day-old comment that arrived is not added again', () async {
        server.loseNextComment = true;
        await aged.replay();
        expect(entries().single.firstSentAt, t0);
        server.forgetKeys();
        now = t0.add(const Duration(hours: 24));

        await aged.replay();

        expect(entries(), isEmpty);
        expect(server.comments[a.ref], ['Before Friday']);
        expect(adds(), hasLength(1));
      });

      test(
        'a day-old comment that never arrived goes with a new key',
        () async {
          server.timeOutNext = true;
          await aged.replay();
          final key = entries().single.idempotencyKey;
          now = t0.add(const Duration(hours: 24));

          await aged.replay();

          expect(entries(), isEmpty);
          expect(server.comments[a.ref], ['Before Friday']);
          expect(adds().single.key, isNot(key));
        },
      );

      test('a fresh key is trusted without a lookup', () async {
        server.loseNextComment = true;
        await aged.replay();
        now = t0.add(const Duration(hours: 1));

        await aged.replay();

        expect(server.commentLookups, isEmpty);
        expect(server.comments[a.ref], ['Before Friday']);
      });
    });

    test('a create never sent keeps its key however old', () async {
      final key = entries().single.idempotencyKey;
      now = t0.add(const Duration(days: 3));

      await aged.replay();

      expect(entries(), isEmpty);
      expect(creates().single.key, key);
    });
  });

  group('pruning', () {
    ConflictRecord settled(String id, DateTime at) => ConflictRecord(
      id: id,
      entryId: 'e',
      taskRef: a.ref,
      kind: ConflictKind.fields,
      createdAt: at,
      resolution: Resolution.mine,
      resolvedAt: at,
    );

    test('settled conflicts go after 30 days or past the newest 100', () {
      final open = ConflictRecord(
        id: 'open',
        entryId: 'e',
        taskRef: a.ref,
        kind: ConflictKind.deleted,
        createdAt: t0.subtract(const Duration(days: 90)),
      );
      final snap = SyncSnapshot(
        conflicts: [
          for (var i = 0; i < 120; i++)
            settled('s$i', t0.subtract(Duration(hours: i))),
          settled('old', t0.subtract(const Duration(days: 31))),
          open,
        ],
      );

      final pruned = pruneSnapshot(snap, t0);

      expect(pruned.conflicts, hasLength(settledConflictsMax + 1));
      expect(pruned.conflicts.first.id, 's0');
      expect(pruned.conflicts.map((r) => r.id), contains('open'));
      expect(pruned.conflicts.map((r) => r.id), isNot(contains('old')));
      expect(pruned.conflicts.map((r) => r.id), isNot(contains('s100')));
    });

    test('sent drafts keep the newest and any a write still names', () {
      final snap = SyncSnapshot(
        drafts: {
          for (var i = 0; i < sentDraftsMax + 10; i++)
            'infra-draft$i': 'infra-${1000 + i}',
        },
        entries: [
          OutboxEntry(
            id: 'e',
            seq: 1,
            op: OutboxOp.dependencyAdd,
            target: b.ref,
            idempotencyKey: 'k',
            createdAt: t0,
            values: const {'depends_on': 'infra-draft0'},
          ),
        ],
      );

      final pruned = pruneSnapshot(snap, t0);

      expect(pruned.drafts, hasLength(sentDraftsMax + 1));
      expect(pruned.drafts['infra-draft0'], 'infra-1000');
      expect(pruned.drafts.containsKey('infra-draft1'), isFalse);
      expect(
        pruned.drafts.containsKey('infra-draft${sentDraftsMax + 9}'),
        isTrue,
      );
    });

    test('a replay prunes, and nothing pruned means nothing written', () async {
      await store.update(
        (s) => s.copyWith(
          conflicts: [settled('old', t0.subtract(const Duration(days: 40)))],
        ),
      );
      await replayer.replay();
      expect(conflicts(), isEmpty);
      final kept = pruneSnapshot(store.now, t0);
      expect(identical(kept, store.now), isTrue);
    });
  });

  group('project stars', () {
    test('a queued star and unstar are sent in order to the project', () async {
      await queue(OutboxOp.projectStar, 'infra');
      await queue(OutboxOp.projectStar, 'web');
      await queue(OutboxOp.projectUnstar, 'infra');

      final report = await replayer.replay();

      expect(report.sent, 3);
      expect(entries(), isEmpty);
      expect(server.projectStars, {'web'});
      expect(
        [
          for (final c in server.calls)
            if (c.target == 'infra') c.op,
        ],
        [OutboxOp.projectStar, OutboxOp.projectUnstar],
      );
    });

    test(
      'a project gone on the server is refused, not a deleted task',
      () async {
        await queue(OutboxOp.projectStar, 'gone');

        final report = await replayer.replay();

        expect(report.failed, 1);
        expect(entries().single.state, OutboxState.failed);
        expect(conflicts(), isEmpty);
      },
    );

    test('a star applied whose answer was lost is done without reading a '
        'task', () async {
      server.honoursKeys = true;
      await queue(OutboxOp.projectStar, 'infra');
      server.refuse['infra'] = const TixException(
        TixErrorKind.conflict,
        message:
            'the request with this idempotency key was applied but its '
            'response was not kept',
      );

      await replayer.replay();

      expect(entries(), isEmpty);
    });

    test('only waiting stars are listed, oldest first', () async {
      await queue(OutboxOp.projectStar, 'infra');
      await queue(OutboxOp.update, a.ref, base: a, values: {'title': 'One'});
      await queue(OutboxOp.projectUnstar, 'web');
      expect(outbox.projectStarWrites().map((e) => (e.op, e.target)), [
        (OutboxOp.projectStar, 'infra'),
        (OutboxOp.projectUnstar, 'web'),
      ]);
    });
  });

  group('overlay', () {
    test("draws waiting writes on the server's task", () async {
      await queue(OutboxOp.update, a.ref, base: a, values: {'title': 'One'});
      await queue(OutboxOp.move, a.ref, base: a, values: {'to': 'doing'});
      await queue(OutboxOp.tagAdd, a.ref, base: a, values: {'name': 'x'});
      final t = outbox.overlay(a);
      expect((t.title, t.status), ('One', 'doing'));
      expect(t.tags, ['x']);
    });
  });
}
