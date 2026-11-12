// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/features/tasks/application/task_detail.dart';

import '../../../helpers/container.dart';
import '../../../helpers/fake_tix.dart';

/// Keeps [provider] alive in [c] for the test, and returns it.
P keep<P extends ProviderListenable<Object?>>(ProviderContainer c, P provider) {
  final sub = c.listen(provider, (_, _) {});
  addTearDown(sub.close);
  return provider;
}

void main() {
  late FakeTix server;

  setUp(() => server = FakeTix());

  Future<ProviderContainer> signedIn() => signedInContainer(server);

  group('TaskDetailController', () {
    Future<(ProviderContainer, TaskDetailController)> open([
      String ref = 'infra-1',
    ]) async {
      final c = await signedIn();
      await c.read(keep(c, taskDetailControllerProvider(ref)).future);
      return (c, c.read(taskDetailControllerProvider(ref).notifier));
    }

    Task now(ProviderContainer c, [String ref = 'infra-1']) =>
        c.read(taskDetailControllerProvider(ref)).value!;

    test('begin draws a change, drop takes it back', () async {
      final (c, ctl) = await open();
      final change = TaskChange.patch(TaskPatch.priority(5));
      ctl.begin(change);
      expect(now(c).priority, 5);
      ctl.drop(change);
      expect(now(c).priority, 1);
      expect(
        server.requestsTo('/tasks/infra-1').where((r) => r.method == 'PATCH'),
        isEmpty,
      );
    });

    test('commit sends the change and keeps the server answer', () async {
      final (c, ctl) = await open();
      await ctl.change(TaskChange.patch(TaskPatch.title('New')));
      final patch = server.requests.last;
      expect(patch.method, 'PATCH');
      expect(patch.body, {'title': 'New'});
      expect(now(c).title, 'New');
      expect(now(c).version, 2);
    });

    test('a refused change rolls back to the server state', () async {
      final (c, ctl) = await open();
      server.failures['PATCH /api/v1/tasks/infra-1'] = FakeResponse(
        403,
        envelope('forbidden', 'task:write'),
      );
      final change = TaskChange.patch(TaskPatch.priority(4));
      ctl.begin(change);
      expect(now(c).priority, 4);
      await expectLater(ctl.commit(change), throwsA(isA<TixException>()));
      expect(server.requests.last.method, 'PATCH');
      expect(now(c).priority, 1);
    });

    test('changes in flight are drawn on top of each other', () async {
      final (c, ctl) = await open();
      server.gate = Completer<void>();
      final title = TaskChange.patch(TaskPatch.title('New'));
      final prio = TaskChange.patch(TaskPatch.priority(2));
      ctl
        ..begin(title)
        ..begin(prio);
      final sends = [ctl.commit(title), ctl.commit(prio)];
      expect(now(c).title, 'New');
      expect(now(c).priority, 2);
      server.gate!.complete();
      server.gate = null;
      await Future.wait(sends);
      expect(now(c).title, 'New');
      expect(now(c).priority, 2);
    });

    test('version-checked sends carry the latest server version', () async {
      final (c, ctl) = await open();
      server.task('infra-1')!['body'] = '- [ ] a\n- [ ] b';
      await ctl.reload();
      final first = TaskChange.check(1, done: true);
      final second = TaskChange.check(2, done: true);
      ctl
        ..begin(first)
        ..begin(second);
      await Future.wait([ctl.commit(first), ctl.commit(second)]);
      final checks = server.requestsTo('/checklist');
      expect(checks.map((r) => r.body['version']), [1, 2]);
      expect(now(c).body, '- [x] a\n- [x] b');
      expect(now(c).version, 3);
    });

    test('a checklist tick shows before the server answers', () async {
      final (c, ctl) = await open();
      server.gate = Completer<void>();
      final send = ctl.change(TaskChange.check(1, done: true));
      expect(now(c).body, contains('- [x] reproduce'));
      server.gate!.complete();
      server.gate = null;
      await send;
      expect(server.task('infra-1')!['body'], contains('- [x] reproduce'));
    });

    test('a star applies locally after a bodiless answer', () async {
      final (c, ctl) = await open();
      await ctl.change(TaskChange.star(starred: true));
      expect(server.requests.last.method, 'PUT');
      expect(now(c).starred, isTrue);
      await ctl.change(TaskChange.star(starred: false));
      expect(now(c).starred, isFalse);
    });

    test('snooze and wake', () async {
      final (c, ctl) = await open();
      final until = DateTime.utc(2026, 11, 2, 9);
      await ctl.change(TaskChange.snooze(until));
      expect(now(c).snoozedUntil, until);
      await ctl.change(TaskChange.snooze(null));
      expect(now(c).snoozedUntil, isNull);
      expect(server.requests.last.method, 'DELETE');
    });

    test('move shows the new status and keeps the server answer', () async {
      final (c, ctl) = await open();
      server.gate = Completer<void>();
      final move = ctl.move('doing', comment: 'why');
      expect(now(c).status, 'doing');
      server.gate!.complete();
      server.gate = null;
      final result = await move;
      expect(server.requests.last.body, {'to': 'doing', 'comment': 'why'});
      expect(result.stopped, isEmpty);
      expect(now(c).status, 'doing');
    });

    test(
      'a move that stops partway leaves the task where it stopped',
      () async {
        final (c, ctl) = await open();
        server.routeStops['infra-1'] = (
          state: 'doing',
          reason: 'needs a lease',
        );
        final result = await ctl.move('done');
        expect(result.stopped, 'doing');
        expect(result.reason, 'needs a lease');
        expect(now(c).status, 'todo');
      },
    );

    test('a refused move rolls back', () async {
      final (c, ctl) = await open();
      server.failures['POST /api/v1/tasks/infra-1/route'] = FakeResponse(
        422,
        envelope('precondition_failed', 'not allowed'),
      );
      await expectLater(ctl.move('done'), throwsA(isA<TixException>()));
      expect(now(c).status, 'todo');
    });

    test('delete, then restore from the trash', () async {
      final (c, ctl) = await open('infra-2');
      await ctl.delete();
      expect(server.trash.keys, ['infra-2']);
      await ctl.restore();
      expect(server.requests.last.uri.path, endsWith('/infra-2/restore'));
      expect(now(c, 'infra-2').ref, 'infra-2');
      expect(server.trash, isEmpty);
    });

    test('delete permanently with subtasks', () async {
      final (_, ctl) = await open();
      await ctl.delete(hard: true, cascade: true);
      expect(server.requests.last.uri.queryParameters, {
        'hard': 'true',
        'cascade': 'true',
      });
      expect(server.task('infra-1'), isNull);
    });

    test('copy returns the copy', () async {
      final (_, ctl) = await open();
      final copy = await ctl.copy(const CopyTaskInput(projectRef: 'web'));
      expect(server.requests.last.uri.path, endsWith('/infra-1/copy'));
      expect(copy.ref, 'web-1');
    });
  });

  test('comments are added, edited and deleted', () async {
    final c = await signedIn();
    server.comments['infra-1'] = [
      {'id': 'c0', 'body': 'first', 'author_actor_id': 'a1'},
    ];
    final provider = taskCommentsProvider('infra-1');
    expect((await c.read(keep(c, provider).future)).single.body, 'first');
    final added = await c.read(provider.notifier).add('second');
    expect(server.requests.last.body, {'body': 'second'});
    expect(c.read(provider).value!.map((x) => x.body), ['first', 'second']);
    await c.read(provider.notifier).edit(added.id, 'changed');
    expect(c.read(provider).value!.map((x) => x.body), ['first', 'changed']);
    await c.read(provider.notifier).delete('c0');
    expect(server.requests.last.method, 'DELETE');
    expect(c.read(provider).value!.map((x) => x.id), [added.id]);
  });

  group('TaskDependencies', () {
    test('reads each task waited for, and adds and removes', () async {
      server.deps['id-infra-1'] = ['id-infra-2'];
      final c = await signedIn();
      final provider = taskDependenciesProvider('infra-1');
      expect(
        (await c.read(keep(c, provider).future)).single.title,
        'Rotate keys',
      );
      server.tasks['web'] = [taskJson('web-1', title: 'Ship')];
      await c.read(provider.notifier).add('web-1');
      expect(server.requests.firstWhere((r) => r.method == 'POST').body, {
        'depends_on': 'web-1',
      });
      expect(c.read(provider).value!.map((t) => t.ref), ['infra-2', 'web-1']);
      await c.read(provider.notifier).remove(c.read(provider).value!.first);
      expect(server.requests.last.method, 'DELETE');
      expect(server.requests.last.uri.path, endsWith('/deps/id-infra-2'));
      expect(c.read(provider).value!.map((t) => t.ref), ['web-1']);
      expect(server.deps['id-infra-1'], ['id-web-1']);
    });

    test('a task that cannot be read stands in by its id', () async {
      server.deps['id-infra-1'] = ['id-gone'];
      final c = await signedIn();
      final deps = await c.read(
        keep(c, taskDependenciesProvider('infra-1')).future,
      );
      expect(deps.single.ref, 'id-gone');
      expect(deps.single.title, isEmpty);
    });
  });

  test('a subtask is created under its parent', () async {
    server.tasks['infra']!.add(
      taskJson('infra-3', title: 'Child', parentId: 'id-infra-1'),
    );
    final c = await signedIn();
    final provider = taskSubtasksProvider('infra-1');
    expect(
      (await c.read(keep(c, provider).future)).tasks.single.ref,
      'infra-3',
    );
    await c.read(provider.notifier).add('infra', 'Another');
    expect(server.requests.last.body, containsPair('parent_ref', 'infra-1'));
    expect(server.requests.last.body, containsPair('project_ref', 'infra'));
    expect(c.read(provider).value!.nodes, hasLength(2));
  });

  test('an artifact is attached and listed', () async {
    final c = await signedIn();
    final provider = taskArtifactsProvider('infra-1');
    expect(await c.read(keep(c, provider).future), isEmpty);
    await c
        .read(provider.notifier)
        .attach(
          const ArtifactInput(
            kind: ArtifactKind.file,
            name: 'a.txt',
            blob: 'aGk=',
          ),
        );
    expect(server.requests.last.method, 'PUT');
    expect(c.read(provider).value!.single.name, 'a.txt');
  });

  test('history pages with loadMore', () async {
    server
      ..pageSize = 2
      ..audit['infra-1'] = [
        for (var i = 5; i > 0; i--) {'seq': i, 'action': 'task.update'},
      ];
    final c = await signedIn();
    final provider = taskHistoryProvider('infra-1');
    expect((await c.read(keep(c, provider).future)).items.map((e) => e.seq), [
      5,
      4,
    ]);
    await c.read(provider.notifier).loadMore();
    await c.read(provider.notifier).loadMore();
    final all = c.read(provider).value!;
    expect(all.items.map((e) => e.seq), [5, 4, 3, 2, 1]);
    expect(all.hasMore, isFalse);
    expect(server.requestsTo('/audit').last.uri.queryParameters['cursor'], '4');
  });

  test("a project's workflow is read through the project", () async {
    final c = await signedIn();
    final w = await c.read(keep(c, projectWorkflowProvider('infra')).future);
    expect(w.key, 'default');
    expect(server.requestsTo('/projects/infra'), hasLength(1));
    expect(server.requestsTo('/workflows/wf1'), hasLength(1));
  });

  test("a project's fields", () async {
    final c = await signedIn();
    final fields = await c.read(keep(c, projectFieldsProvider('infra')).future);
    expect(fields.map((f) => f.key), ['env', 'window', 'paged']);
  });

  test('the actor directory lists the tenant', () async {
    final c = await signedIn();
    final actors = await c.read(keep(c, actorDirectoryProvider).future);
    expect(actors.map((a) => a.handle), containsAll(['ana', 'raj']));
    expect(server.requestsTo('/api/v1/actors'), hasLength(1));
  });

  test('tags and trash', () async {
    final c = await signedIn();
    expect(
      (await c.read(keep(c, tagDirectoryProvider).future)).map((t) => t.name),
      contains('ops'),
    );
    server.trashEnabled = false;
    expect(
      (await c.read(keep(c, trashStatusProvider).future)).enabled,
      isFalse,
    );
  });

  test('copy targets leave archived projects out', () async {
    server.projects.add({
      'id': 'p3',
      'key': 'old',
      'archived_at': '2026-01-01T00:00:00Z',
    });
    final c = await signedIn();
    final projects = await c.read(keep(c, copyTargetsProvider).future);
    expect(projects.map((p) => p.key), ['infra', 'web']);
  });

  group('SnoozePreset.from', () {
    test('later today is three hours on, rounded up to the hour', () {
      expect(
        SnoozePreset.laterToday.from(DateTime(2026, 11, 3, 10, 20)),
        DateTime(2026, 11, 3, 14),
      );
      expect(
        SnoozePreset.laterToday.from(DateTime(2026, 11, 3, 10)),
        DateTime(2026, 11, 3, 13),
      );
      expect(
        SnoozePreset.laterToday.from(DateTime(2026, 11, 3, 22, 30)),
        DateTime(2026, 11, 4, 2),
      );
    });

    test('tomorrow is nine in the morning', () {
      expect(
        SnoozePreset.tomorrow.from(DateTime(2026, 11, 3, 15)),
        DateTime(2026, 11, 4, 9),
      );
    });

    test('next week is nine on the coming Monday', () {
      // 2026-11-02 is a Monday, 2026-11-08 a Sunday.
      expect(
        SnoozePreset.nextWeek.from(DateTime(2026, 11, 2, 8)),
        DateTime(2026, 11, 9, 9),
      );
      expect(
        SnoozePreset.nextWeek.from(DateTime(2026, 11, 8, 20)),
        DateTime(2026, 11, 9, 9),
      );
    });
  });

  test('projectKeyOf reads the key before the last dash', () {
    expect(projectKeyOf('infra-8'), 'infra');
    expect(projectKeyOf('my-app-12'), 'my-app');
    expect(projectKeyOf('nodash'), 'nodash');
  });
}
