// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/cache/response_cache.dart';
import 'package:tix_mobile/src/data/models/project_admin.dart';
import 'package:tix_mobile/src/data/repositories/projects_repository.dart';
import 'package:tix_mobile/src/data/repositories/workflows_repository.dart';

import '../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;
  late ProjectsRepository projects;
  late WorkflowsRepository workflows;
  late ResponseCache cache;

  setUp(() {
    server = FakeTix();
    final api = server.factory(
      'https://tix.example',
      const BearerCredential('tok'),
    );
    cache = ResponseCache(MemoryCacheStore(), const CacheScope('c1', ''));
    projects = ProjectsRepository(api, cache);
    workflows = WorkflowsRepository(api, cache);
  });

  RequestOptionsView last() => RequestOptionsView(server.requests.last);

  test('create sends the input and returns the project', () async {
    final p = await projects.create(
      const CreateProjectInput(name: 'Mobile', key: 'mobile', color: 'teal'),
    );
    expect(last().line, 'POST /api/v1/projects');
    expect(last().body, {'name': 'Mobile', 'key': 'mobile', 'color': 'teal'});
    expect(p.key, 'mobile');
  });

  test('update sends only what is set', () async {
    await projects.update('infra', const UpdateProjectInput(color: 'violet'));
    expect(last().line, 'PATCH /api/v1/projects/infra');
    expect(last().body, {'color': 'violet'});
  });

  test('archive asks the delete route to archive', () async {
    await projects.archive('infra');
    expect(last().line, 'DELETE /api/v1/projects/infra');
    expect(last().query, {'archive': 'true'});
  });

  test('a deletion plan names the target', () async {
    server.deletionCounts['infra'] = (tasks: 3, deleted: 1);
    final plan = await projects.deletionPlan('infra', moveTasksTo: 'web');
    expect(last().line, 'GET /api/v1/projects/infra/deletion');
    expect(last().query, {'move_tasks_to': 'web'});
    expect(plan.tasks, 3);
    expect(plan.statuses, isNotEmpty);
  });

  test('delete moves the tasks or deletes them', () async {
    server.deletionCounts['infra'] = (tasks: 3, deleted: 0);
    await projects.delete('infra', moveTasksTo: 'web');
    expect(last().query, {'move_tasks_to': 'web'});
    await projects.delete('web', deleteTasks: true);
    expect(last().query, {'delete_tasks': 'true'});
  });

  test('icon reads the image bytes', () async {
    server.icons['infra'] = [1, 2, 3];
    expect(await projects.icon('infra'), [1, 2, 3]);
    expect(last().line, 'GET /api/v1/projects/infra/icon');
  });

  test('fields are cached, put and deleted', () async {
    expect((await projects.fields('infra')).map((f) => f.key), [
      'env',
      'window',
      'paged',
    ]);
    expect(await projects.cachedFields('infra'), hasLength(3));
    await projects.putField(
      'infra',
      const FieldDefInput(key: 'points', type: FieldType.int, defaultValue: 3),
    );
    expect(last().line, 'PUT /api/v1/projects/infra/fields');
    expect(last().body, {'key': 'points', 'type': 'int', 'default': 3});
    await projects.deleteField('infra', 'points');
    expect(last().line, 'DELETE /api/v1/projects/infra/fields/points');
  });

  test('a project is cached for its settings', () async {
    expect((await projects.project('infra')).name, 'Infrastructure');
    expect((await projects.cachedProject('infra'))!.key, 'infra');
  });

  test('workflows list, read, create, save and delete', () async {
    expect((await workflows.list()).single.key, 'default');
    expect(await workflows.cachedList(), hasLength(1));
    expect((await workflows.workflow('default')).name, 'Default');
    const input = WorkflowInput(
      key: 'support',
      name: 'Support',
      definition: WorkflowDefinition(
        initial: 'open',
        states: [WorkflowState(key: 'open')],
      ),
    );
    await workflows.create(input);
    expect(last().line, 'PUT /api/v1/workflows');
    expect(last().body['key'], 'support');
    await workflows.save('support', input);
    expect(last().line, 'PUT /api/v1/workflows/support');
    await workflows.delete('support');
    expect(last().line, 'DELETE /api/v1/workflows/support');
  });
}

/// The parts of a request these tests compare.
extension type RequestOptionsView(RequestOptions o) {
  /// `METHOD /path`.
  String get line => '${o.method} ${o.uri.path}';

  /// The JSON body.
  Map<String, dynamic> get body => o.data as Map<String, dynamic>;

  /// The query.
  Map<String, String> get query => o.uri.queryParameters;
}
