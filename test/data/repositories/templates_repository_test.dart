// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/cache/response_cache.dart';
import 'package:tix_mobile/src/data/models/template.dart';
import 'package:tix_mobile/src/data/repositories/templates_repository.dart';

import '../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;
  late TemplatesRepository repo;

  setUp(() {
    server = FakeTix();
    repo = TemplatesRepository(
      server.factory('https://tix.example', const BearerCredential('tok')),
      ResponseCache(MemoryCacheStore(), const CacheScope('c1', '')),
    );
  });

  test('list reads a page of templates as tix answers', () async {
    server.templates['t1'] = {
      'id': 't1',
      'tenant_id': 'x',
      'name': 'weekly',
      'project_id': 'p',
      'project_key': 'ops',
      'task': {
        'title': 'Cut the alerts that nobody acts on',
        'priority': 2,
        'tags': ['noise', 'oncall'],
        'custom_fields': {'paged': false},
        'subtasks': [
          {
            'title': 'a',
            'subtasks': [
              {'title': 'b'},
            ],
          },
        ],
      },
      'due_in': '72h0m0s',
      'uses': 3,
      'creator_actor_id': 'me',
      'created_at': '2026-11-08T15:44:07.005044099Z',
    };
    final page = await repo.list(cursor: '0');
    final t = page.items.single;
    expect(t.name, 'weekly');
    expect(t.projectKey, 'ops');
    expect(t.tenantWide, isFalse);
    expect(t.shape.tags, ['noise', 'oncall']);
    expect(t.subtaskCount, 2);
    expect(t.dueIn, '72h0m0s');
    expect(t.uses, 3);
    expect(server.requests.single.uri.queryParameters['cursor'], '0');
  });

  test('save sends the task, the name and the options', () async {
    final saved = await repo.save(
      const SaveTemplateInput(
        taskRef: 'infra-1',
        name: 'weekly',
        withSubtasks: true,
        dueIn: '3d',
      ),
    );
    expect(saved.name, 'weekly');
    final sent = server.requestsTo('/api/v1/templates').single;
    expect(sent.method, 'POST');
    expect(sent.body, {
      'task_ref': 'infra-1',
      'name': 'weekly',
      'with_subtasks': true,
      'due_in': '3d',
    });
  });

  test('a taken name is a conflict', () async {
    server.addTemplate('weekly');
    await expectLater(
      repo.save(const SaveTemplateInput(taskRef: 'infra-1', name: 'weekly')),
      throwsA(
        isA<TixException>().having(
          (e) => e.kind,
          'kind',
          TixErrorKind.conflict,
        ),
      ),
    );
  });

  test('saveFromLine creates the task with parse, then saves it', () async {
    await repo.saveFromLine(
      project: 'infra',
      line: 'Standup notes #team',
      name: 'standup',
    );
    final create = server.requestsTo('/api/v1/tasks').single;
    expect(create.body, {
      'title': 'Standup notes #team',
      'project_ref': 'infra',
      'parse': true,
    });
    final save = server.requestsTo('/api/v1/templates').single;
    expect(save.body['task_ref'], 'infra-3');
    expect(save.body['name'], 'standup');
  });

  test('update sends only the fields given', () async {
    final t = server.addTemplate('weekly');
    await repo.update(
      t['id']! as String,
      const UpdateTemplateInput(name: 'weekly-review'),
    );
    final sent = server.requests.single;
    expect(sent.method, 'PATCH');
    expect(sent.uri.path, '/api/v1/templates/${t['id']}');
    expect(sent.body, {'name': 'weekly-review'});
  });

  test('get, delete and use address the template', () async {
    final t = server.addTemplate('weekly', project: 'infra', title: 'Review');
    final id = t['id']! as String;
    expect((await repo.get('WEEKLY')).id, id);
    final task = await repo.use(id, project: 'web');
    expect(task.ref, 'web-1');
    expect(server.requests.last.body, {'project_ref': 'web'});
    await repo.use(id);
    expect(server.requests.last.body, isEmpty);
    await repo.delete(id);
    expect(server.requests.last.method, 'DELETE');
    expect(server.templates, isEmpty);
  });
}
