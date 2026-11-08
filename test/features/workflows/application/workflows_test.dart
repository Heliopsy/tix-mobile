// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/session/access.dart';
import 'package:tix_mobile/src/data/models/workflow_draft.dart';
import 'package:tix_mobile/src/features/projects/application/project_admin.dart';
import 'package:tix_mobile/src/features/projects/application/projects.dart';
import 'package:tix_mobile/src/features/workflows/application/workflows.dart';

import '../../../helpers/container.dart';
import '../../../helpers/fake_tix.dart';

void keepAlive(ProviderContainer c) {
  c
    ..listen(projectsProvider, (_, _) {})
    ..listen(projectSettingsProvider('infra'), (_, _) {})
    ..listen(projectFieldsProvider('infra'), (_, _) {})
    ..listen(workflowsProvider, (_, _) {})
    ..listen(workflowDetailProvider('ops'), (_, _) {});
}

void main() {
  test('the list puts builtin first, then by name', () async {
    final server = FakeTix()
      ..workflows.add({'id': 'b', 'key': 'b', 'name': 'Bravo'})
      ..workflows.add({'id': 'a', 'key': 'a', 'name': 'alpha'});
    final c = await signedInContainer(server);
    keepAlive(c);
    final list = await c.read(workflowsProvider.future);
    expect(list.map((w) => w.key), ['default', 'a', 'b']);
  });

  test('create adds to the list', () async {
    final c = await signedInContainer(FakeTix());
    keepAlive(c);
    await c.read(workflowsProvider.future);
    await c
        .read(workflowsProvider.notifier)
        .create(WorkflowDraft.minimal('ops', 'Ops').toInput());
    final list = await c.read(workflowsProvider.future);
    expect(list.map((w) => w.key), contains('ops'));
  });

  test('save shows the answer and delete drops it', () async {
    final server = FakeTix()
      ..workflows.add(
        WorkflowDraft.minimal('ops', 'Ops').toWorkflow().toJson(),
      );
    final c = await signedInContainer(server);
    keepAlive(c);
    final w = await c.read(workflowDetailProvider('ops').future);
    final renamed = WorkflowDraft.of(w).copyWith(name: 'Operations');
    await c
        .read(workflowDetailProvider('ops').notifier)
        .save(renamed.toInput());
    expect(c.read(workflowDetailProvider('ops')).value!.name, 'Operations');
    await c.read(workflowDetailProvider('ops').notifier).delete();
    expect(server.workflows.any((w) => w['key'] == 'ops'), isFalse);
  });

  test('access follows whoami', () async {
    final c = await signedInContainer(FakeTix()..identity = {'role': 'viewer'});
    keepAlive(c);
    final a = await c.read(currentAccessProvider.future);
    expect(a.has(Scope.workflowRead), isTrue);
    expect(a.has(Scope.workflowWrite), isFalse);
  });
}
