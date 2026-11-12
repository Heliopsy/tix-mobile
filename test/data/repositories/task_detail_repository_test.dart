// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/cache/response_cache.dart';
import 'package:tix_mobile/src/data/repositories/task_detail_repository.dart';

import '../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;
  late TaskDetailRepository repo;

  setUp(() {
    server = FakeTix();
    repo = TaskDetailRepository(
      server.factory('https://tix.example', const BearerCredential('tok')),
      ResponseCache(MemoryCacheStore(), const CacheScope('c1', '')),
    );
  });

  RequestOptions last() => server.requests.last;

  test('task reads by reference or id', () async {
    expect((await repo.task('infra-1')).title, 'Fix login');
    expect((await repo.task('id-infra-2')).ref, 'infra-2');
    expect(last().method, 'GET');
    expect(last().uri.path, '/api/v1/tasks/id-infra-2');
  });

  test('update sends only the patch, with a version when given', () async {
    final t = await repo.update('infra-1', TaskPatch.priority(2), version: 1);
    expect(last().method, 'PATCH');
    expect(last().uri.path, '/api/v1/tasks/infra-1');
    expect(last().body, {'priority': 2, 'version': 1});
    expect(t.priority, 2);
    expect(t.version, 2);
  });

  test('clearing a due date sends an explicit null', () async {
    await repo.update('infra-1', TaskPatch.due(null), version: 1);
    expect(last().method, 'PATCH');
    expect(last().uri.path, '/api/v1/tasks/infra-1');
    expect(last().body, {'due_at': null, 'version': 1});
  });

  test('clearing a custom field sends its key with a null', () async {
    await repo.update('infra-1', TaskPatch.field('k', null));
    expect(last().method, 'PATCH');
    expect(last().body, {
      'custom_fields': {'k': null},
    });
  });

  test('check sends the item, the state and the version', () async {
    final t = await repo.check('infra-1', 1, done: true, version: 1);
    expect(last().method, 'POST');
    expect(last().uri.path, '/api/v1/tasks/infra-1/checklist');
    expect(last().body, {'item': 1, 'done': true, 'version': 1});
    expect(t.body, contains('- [x] reproduce'));
  });

  test('move routes to the destination and reads the result', () async {
    final r = await repo.move('infra-1', 'doing', comment: 'go');
    expect(last().uri.path, '/api/v1/tasks/infra-1/route');
    expect(last().body, {'to': 'doing', 'comment': 'go'});
    expect(r.from, 'todo');
    expect(r.applied, ['doing']);
    expect(r.task!.status, 'doing');
    await repo.move('infra-1', 'done');
    expect(last().body, {'to': 'done'});
  });

  test('star and unstar', () async {
    await repo.setStar('infra-1', starred: true);
    expect(last().method, 'PUT');
    expect(last().uri.path, '/api/v1/tasks/infra-1/star');
    expect(server.task('infra-1')!['starred'], isTrue);
    await repo.setStar('infra-1', starred: false);
    expect(last().method, 'DELETE');
    expect(server.task('infra-1')!['starred'], isFalse);
  });

  test('snooze sends the instant in UTC; null wakes', () async {
    final until = DateTime.utc(2026, 11, 2, 9);
    final t = await repo.snooze('infra-1', until);
    expect(last().method, 'PUT');
    expect(last().uri.path, '/api/v1/tasks/infra-1/snooze');
    expect(last().body, {'until': '2026-11-02T09:00:00.000Z'});
    expect(t.snoozedUntil, until);
    final woken = await repo.snooze('infra-1', null);
    expect(last().method, 'DELETE');
    expect(woken.snoozedUntil, isNull);
  });

  test('copy sends what travels and reads the copy', () async {
    final copy = await repo.copy(
      'infra-1',
      const CopyTaskInput(projectRef: 'web', withSubtasks: true, link: true),
    );
    expect(last().uri.path, '/api/v1/tasks/infra-1/copy');
    expect(last().body, {
      'project_ref': 'web',
      'with_subtasks': true,
      'link': true,
    });
    expect(copy.ref, startsWith('web-'));
    expect(copy.copiedFromId, 'id-infra-1');
  });

  test('delete passes hard and cascade only when set; restore', () async {
    await repo.delete('infra-2');
    expect(last().method, 'DELETE');
    expect(last().uri.path, '/api/v1/tasks/infra-2');
    expect(last().uri.queryParameters, isEmpty);
    expect(server.trash.keys, ['infra-2']);
    final back = await repo.restore('infra-2');
    expect(last().uri.path, '/api/v1/tasks/infra-2/restore');
    expect(back.ref, 'infra-2');
    await repo.delete('infra-2', hard: true, cascade: true);
    expect(last().uri.queryParameters, {'hard': 'true', 'cascade': 'true'});
    expect(server.trash, isEmpty);
  });

  test('subtasks read the tree a level deeper than drawn', () async {
    server.tasks['infra']!.addAll([
      taskJson('infra-3', title: 'Child', parentId: 'id-infra-1'),
      taskJson('infra-4', title: 'Grandchild', parentId: 'id-infra-3'),
    ]);
    final tree = await repo.subtasks('infra-1');
    expect(last().uri.path, '/api/v1/tasks/infra-1/tree');
    expect(last().uri.queryParameters, {'depth': '4'});
    expect(tree.tasks.map((t) => t.ref), ['infra-3', 'infra-4']);
    expect(tree.nodes.single.children.single.task.ref, 'infra-4');
    expect(tree.shallow, isFalse);
    final cached = await repo.cachedSubtasks('infra-1');
    expect(cached!.tasks.map((t) => t.ref), ['infra-3', 'infra-4']);
  });

  test('a tree too large to walk is read one level deep', () async {
    server.tasks['infra']!.add(
      taskJson('infra-3', title: 'Child', parentId: 'id-infra-1'),
    );
    server.routes.add(
      (o, path, _) async =>
          path.endsWith('/tree') && o.uri.queryParameters['depth'] == '4'
          ? FakeResponse(
              422,
              envelope('precondition_failed', 'more than 10000 descendants'),
            )
          : null,
    );
    final tree = await repo.subtasks('infra-1');
    expect(last().uri.queryParameters, {'depth': '1'});
    expect(tree.tasks.single.ref, 'infra-3');
    expect(tree.shallow, isTrue);
    expect(tree.complete, isFalse);
    expect((await repo.cachedSubtasks('infra-1'))!.shallow, isTrue);
  });

  test('any other refusal of the tree is not retried', () async {
    server.failing['/api/v1/tasks/infra-1/tree'] = FakeResponse(
      500,
      envelope('internal', 'boom'),
    );
    await expectLater(repo.subtasks('infra-1'), throwsA(isA<TixException>()));
    expect(server.requestsTo('/api/v1/tasks/infra-1/tree'), hasLength(1));
  });

  test('addSubtask creates with the parent', () async {
    await repo.addSubtask('infra', 'infra-1', 'Child');
    expect(last().method, 'POST');
    expect(last().uri.path, '/api/v1/tasks');
    expect(last().body, {
      'title': 'Child',
      'project_ref': 'infra',
      'parent_ref': 'infra-1',
    });
  });

  test('history pages newest first with a cursor', () async {
    server
      ..pageSize = 1
      ..audit['infra-1'] = [
        {'seq': 2, 'action': 'task.update'},
        {'seq': 1, 'action': 'task.create'},
      ];
    final first = await repo.history('infra-1');
    expect(last().uri.path, '/api/v1/tasks/infra-1/audit');
    expect(last().uri.queryParameters, {'limit': '50', 'direction': 'desc'});
    expect(first.items.single.seq, 2);
    expect(first.nextCursor, '1');
    final second = await repo.history('infra-1', cursor: first.nextCursor);
    expect(last().uri.queryParameters['cursor'], '1');
    expect(second.items.single.action, 'task.create');
    expect(second.hasMore, isFalse);
  });

  test('tags are added, removed and listed', () async {
    await repo.addTag('infra-1', 'ops');
    expect(last().method, 'POST');
    expect(last().uri.path, '/api/v1/tasks/infra-1/tags');
    expect(last().body, {'name': 'ops'});
    await repo.removeTag('infra-1', 'a b');
    expect(last().method, 'DELETE');
    expect(last().uri.path, '/api/v1/tasks/infra-1/tags/a%20b');
    final tags = await repo.tags();
    expect(last().uri.path, '/api/v1/tags');
    expect(tags.map((t) => t.name), containsAll(['auth', 'ops', 'backend']));
  });

  test('comments are listed, added, edited and deleted', () async {
    final c = await repo.addComment('infra-1', 'hello');
    expect(last().method, 'POST');
    expect(last().uri.path, '/api/v1/tasks/infra-1/comments');
    expect(last().body, {'body': 'hello'});
    expect(c.authorActorId, 'me');
    expect((await repo.comments('infra-1')).single.body, 'hello');
    final edited = await repo.editComment(c.id, 'hi');
    expect(last().method, 'PATCH');
    expect(last().uri.path, '/api/v1/comments/${c.id}');
    expect(last().body, {'body': 'hi'});
    expect(edited.body, 'hi');
    expect(edited.edited, isTrue);
    await repo.deleteComment(c.id);
    expect(last().method, 'DELETE');
    expect(last().uri.path, '/api/v1/comments/${c.id}');
    expect(await repo.comments('infra-1'), isEmpty);
  });

  test('dependencies are added by reference, listed and removed', () async {
    await repo.addDependency('infra-1', 'infra-2');
    expect(last().uri.path, '/api/v1/tasks/infra-1/deps');
    expect(last().body, {'depends_on': 'infra-2'});
    final deps = await repo.dependencies('infra-1');
    expect(deps.single.dependsOn, 'id-infra-2');
    await repo.removeDependency('infra-1', 'id-infra-2');
    expect(last().method, 'DELETE');
    expect(last().uri.path, '/api/v1/tasks/infra-1/deps/id-infra-2');
    expect(await repo.dependencies('infra-1'), isEmpty);
  });

  test('artifacts are attached and listed', () async {
    final a = await repo.attach(
      'infra-1',
      const ArtifactInput(
        kind: ArtifactKind.file,
        name: 'a.txt',
        contentType: 'text/plain',
        blob: 'aGk=',
      ),
    );
    expect(last().method, 'PUT');
    expect(last().uri.path, '/api/v1/tasks/infra-1/artifacts');
    expect(last().body, {
      'kind': 'file',
      'name': 'a.txt',
      'content_type': 'text/plain',
      'blob': 'aGk=',
    });
    expect(a.name, 'a.txt');
    expect((await repo.artifacts('infra-1')).single.blob, 'aGk=');
  });

  test('fields, project, workflow and trash', () async {
    final fields = await repo.fields('infra');
    expect(last().uri.path, '/api/v1/projects/infra/fields');
    expect(fields.first.enumOptions, ['production', 'staging']);
    final p = await repo.project('p1');
    expect(last().uri.path, '/api/v1/projects/p1');
    expect(p.workflowId, 'wf1');
    final w = await repo.workflow('wf1');
    expect(last().uri.path, '/api/v1/workflows/wf1');
    expect(w.definition!.states!.map((s) => s.key), contains('blocked'));
    expect(
      w.definition!.transitions!.any((t) => t.requiresComment ?? false),
      isTrue,
    );
    final trash = await repo.trash();
    expect(last().uri.path, '/api/v1/trash');
    expect(trash.enabled, isTrue);
  });

  test('actors follow next_cursor to the end', () async {
    final adapter = FakeAdapter((o) {
      final cursor = o.uri.queryParameters['cursor'];
      return FakeResponse(200, {
        'items': [
          {'id': cursor == null ? 'a1' : 'a2', 'handle': 'x'},
        ],
        'next_cursor': cursor == null ? 'n' : '',
      });
    });
    final repo = TaskDetailRepository(
      TixApi(baseUrl: 'https://tix.example', adapter: adapter),
      ResponseCache(MemoryCacheStore(), const CacheScope('c1', '')),
    );
    final actors = await repo.actors();
    expect(actors.map((a) => a.id), ['a1', 'a2']);
    expect(adapter.requests, hasLength(2));
    expect(adapter.requests.first.uri.queryParameters, {'limit': '500'});
    expect(adapter.requests.last.uri.queryParameters['cursor'], 'n');
  });

  test('a refusal arrives as a typed error with the message', () async {
    server.failures['PATCH /api/v1/tasks/infra-1'] = FakeResponse(
      400,
      envelope('invalid', 'cannot read rule'),
    );
    await expectLater(
      repo.update('infra-1', TaskPatch.recurrence('x')),
      throwsA(
        isA<TixException>()
            .having((e) => e.kind, 'kind', TixErrorKind.invalid)
            .having((e) => e.message, 'message', 'cannot read rule'),
      ),
    );
  });
}
