// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/repositories/transfer_repository.dart';

import '../../helpers/fake_people.dart';
import '../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;
  late FakePeople people;
  late TransferRepository repo;

  setUp(() {
    server = FakeTix();
    people = FakePeople.on(server);
    repo = TransferRepository(
      server.factory('https://tix.example', const BearerCredential('tok')),
    );
  });

  test('a task export arrives byte for byte, whatever the format', () async {
    final csv = await repo.exportTasks(
      'infra',
      const TaskExportInput(format: 'csv', columns: ['ref', 'title']),
    );
    expect(utf8.decode(csv), 'ref,title\ninfra-1,Fix login\n');
    expect(people.lastExport, {
      'format': 'csv',
      'columns': ['ref', 'title'],
    });
    final json = await repo.exportTasks(
      'infra',
      const TaskExportInput(format: 'json'),
    );
    expect(jsonDecode(utf8.decode(json)), [
      {'ref': 'infra-1'},
    ]);
  });

  test('snapshots, projects, fields and imports', () async {
    expect(utf8.decode(await repo.exportSnapshot()), contains('"infra"'));
    expect(server.requests.last.body, {
      'include_comments': true,
      'include_artifacts': false,
    });
    expect((await repo.projects()).map((p) => p.key), ['infra', 'web']);
    expect((await repo.fields('infra')).map((f) => f.key), contains('env'));
    final dry = await repo.importTasks(
      'infra',
      content: 'title\nA\nB\n',
      filename: 'a.csv',
      commit: false,
    );
    expect(dry.dryRun, isTrue);
    expect(people.imports.single['dry_run'], true);
    await repo.importTasks(
      'infra',
      content: 'x',
      filename: 'a.csv',
      commit: true,
    );
    expect(people.imports.last['dry_run'], false);
  });

  test('an import sends its format, mapping, mode and preview', () async {
    await repo.importTasks(
      'infra',
      content: 'Fix login #bug\nWrite docs',
      format: 'lines',
      mode: 'skip',
      commit: false,
      preview: 200,
    );
    expect(people.imports.last, {
      'content': 'Fix login #bug\nWrite docs',
      'format': 'lines',
      'mode': 'skip',
      'dry_run': true,
      'preview': 200,
    });
    await repo.importTasks(
      'infra',
      content: 'Summary\nA\n',
      filename: 'jira.csv',
      mapping: '{"version":1,"columns":{"Summary":"title"}}',
      mode: 'upsert',
      commit: true,
    );
    expect(people.imports.last, {
      'content': 'Summary\nA\n',
      'filename': 'jira.csv',
      'mapping': '{"version":1,"columns":{"Summary":"title"}}',
      'mode': 'upsert',
      'dry_run': false,
    });
  });

  test('a workflow reads as its states', () async {
    expect(await repo.workflowStates('wf1'), [
      (key: 'todo', label: 'To do'),
      (key: 'doing', label: 'Doing'),
      (key: 'blocked', label: 'Blocked'),
      (key: 'done', label: 'Done'),
      (key: 'cancelled', label: 'Cancelled'),
    ]);
  });
}
