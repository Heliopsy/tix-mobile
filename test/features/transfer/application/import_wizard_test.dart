// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/data/repositories/transfer_repository.dart';
import 'package:tix_mobile/src/features/transfer/application/import_wizard.dart';

import '../../../helpers/container.dart';
import '../../../helpers/fake_people.dart';
import '../../../helpers/fake_tix.dart';
import '../../../helpers/import_answers.dart';

void main() {
  late FakeTix server;
  late FakePeople people;
  late ProviderContainer c;

  setUp(() async {
    server = FakeTix();
    people = FakePeople.on(server)..importAnswer = jiraAnswer;
    c = await signedInContainer(server);
  });

  ImportWizard wizard() => c.read(importWizardProvider('infra').notifier);
  ImportDraft draft() => c.read(importWizardProvider('infra'));

  test('a file goes to the columns with no mapping sent first', () async {
    final keep = c.listen(importWizardProvider('infra'), (_, _) {});
    addTearDown(keep.close);
    wizard().chooseFile('jira.csv', 'Summary,Status\nFix login,Open\n');
    expect(draft().ready, isTrue);
    await wizard().next();
    expect(draft().step, ImportStep.columns);
    expect(people.imports.single, {
      'content': 'Summary,Status\nFix login,Open\n',
      'filename': 'jira.csv',
      'mode': 'upsert',
      'dry_run': true,
      'preview': 200,
    });
    expect(draft().result!.columns, hasLength(5));
  });

  test('columns and values become the mapping, every column written', () async {
    final keep = c.listen(importWizardProvider('infra'), (_, _) {});
    addTearDown(keep.close);
    wizard().chooseFile('jira.csv', 'x');
    await wizard().next();
    wizard().setColumn('Sprint', 'ignore');
    await wizard().next();
    expect(draft().step, ImportStep.valueMap);
    expect(sentMapping(people.imports.last), {
      'version': 1,
      'columns': {
        'Summary': 'title',
        'Status': 'status',
        'Assignee': 'assignee',
        'Priority': 'priority',
        'Sprint': 'ignore',
      },
    });
    wizard()
      ..setValue('status', 'In Review', 'doing')
      ..setValue('priority', 'P1', '')
      ..setValue('assignee', 'jane@example.com', 'jane')
      ..setPolicy('assignee', 'skip_row');
    await wizard().next();
    expect(draft().step, ImportStep.preview);
    final m = sentMapping(people.imports.last);
    expect(m['values'], {
      'status': {'Open': 'todo', 'In Review': 'doing'},
      'assignee': {'jane@example.com': 'jane'},
    });
    expect(m['unknown'], {'assignee': 'skip_row'});
    expect(draft().result!.failed, 0);
  });

  test('back keeps every choice', () async {
    final keep = c.listen(importWizardProvider('infra'), (_, _) {});
    addTearDown(keep.close);
    wizard().chooseFile('jira.csv', 'x');
    await wizard().next();
    wizard().setColumn('Summary', 'body');
    await wizard().next();
    wizard().back();
    expect(draft().step, ImportStep.columns);
    expect(draft().target(draft().result!.columns.first), 'body');
    wizard().back();
    expect(draft().step, ImportStep.source);
    expect(draft().filename, 'jira.csv');
  });

  test('a pasted list is sent as lines, with no mapping', () async {
    people.importAnswer = linesAnswer;
    final keep = c.listen(importWizardProvider('infra'), (_, _) {});
    addTearDown(keep.close);
    wizard().setLines('Fix login #bug\nWrite docs');
    expect(draft().pasted, isTrue);
    await wizard().next();
    expect(draft().step, ImportStep.preview);
    expect(people.imports.single['format'], 'lines');
    expect(people.imports.single.containsKey('filename'), isFalse);
    expect(people.imports.single.containsKey('mapping'), isFalse);
    wizard().back();
    expect(draft().step, ImportStep.source);
  });

  test('the mode runs the dry run again, then the import commits', () async {
    final keep = c.listen(importWizardProvider('infra'), (_, _) {});
    addTearDown(keep.close);
    wizard().chooseFile('jira.csv', 'x');
    await wizard().skipToPreview();
    expect(draft().step, ImportStep.preview);
    await wizard().setMode(ImportMode.create);
    expect(people.imports.last['mode'], 'create');
    expect(people.imports.last['dry_run'], true);
    await wizard().commit();
    expect(people.imports.last['dry_run'], false);
    expect(draft().step, ImportStep.result);
    expect(draft().committed!.committed, isFalse);
    wizard().back();
    expect(draft().step, ImportStep.preview);
    wizard().restart();
    expect(draft().filename, isEmpty);
    expect(draft().step, ImportStep.source);
  });

  test('a refusal stays on the step and says why', () async {
    final keep = c.listen(importWizardProvider('infra'), (_, _) {});
    addTearDown(keep.close);
    server.override = FakeResponse(
      422,
      envelope('invalid', 'column "X" maps to "nope", which is not a target'),
    );
    wizard().chooseFile('jira.csv', 'x');
    await wizard().next();
    expect(draft().step, ImportStep.source);
    expect(draft().error, isNotNull);
    expect(draft().busy, isFalse);
  });

  test('a new file or project starts the mapping over', () async {
    final keep = c.listen(importWizardProvider('infra'), (_, _) {});
    addTearDown(keep.close);
    wizard().chooseFile('jira.csv', 'x');
    await wizard().next();
    wizard().setColumn('Summary', 'body');
    wizard().setProject('web');
    expect(draft().project, 'web');
    expect(draft().columns, isEmpty);
    expect(draft().result, isNull);
    expect(draft().filename, 'jira.csv');
    wizard().clearFile();
    expect(draft().pasted, isTrue);
    expect(draft().ready, isFalse);
  });

  test('the error report quotes, guards and fills in the row', () {
    final csv = importErrorsCsv(
      TaskImportResult.fromJson(jiraAnswer({'dry_run': true})),
    );
    expect(csv, jiraErrorsCsv);
    expect(utf8.encode(csv), isNotEmpty);
  });

  test('the workflow states come from the project', () async {
    expect(await c.read(importStatesProvider('infra').future), [
      (key: 'todo', label: 'To do'),
      (key: 'doing', label: 'Doing'),
      (key: 'blocked', label: 'Blocked'),
      (key: 'done', label: 'Done'),
      (key: 'cancelled', label: 'Cancelled'),
    ]);
  });
}
