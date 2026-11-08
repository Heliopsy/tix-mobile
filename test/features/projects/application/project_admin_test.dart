// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/data/models/project_admin.dart';
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
  test('saving updates the settings and reloads the list', () async {
    final server = FakeTix();
    final c = await signedInContainer(server);
    keepAlive(c);
    await c.read(projectsProvider.future);
    await c.read(projectSettingsProvider('infra').future);
    final saved = await c
        .read(projectSettingsProvider('infra').notifier)
        .save(const UpdateProjectInput(name: 'Infra'));
    expect(saved.name, 'Infra');
    expect(c.read(projectSettingsProvider('infra')).value!.name, 'Infra');
    final list = await c.read(projectsProvider.future);
    expect(list.items.first.name, 'Infra');
  });

  test('a refused save leaves the settings as they were', () async {
    final server = FakeTix()
      ..failures['PATCH /api/v1/projects/infra'] = FakeResponse(
        409,
        envelope('conflict', 'nope'),
      );
    final c = await signedInContainer(server);
    keepAlive(c);
    await c.read(projectSettingsProvider('infra').future);
    await expectLater(
      c
          .read(projectSettingsProvider('infra').notifier)
          .save(const UpdateProjectInput(name: 'X')),
      throwsA(isA<TixException>()),
    );
    expect(
      c.read(projectSettingsProvider('infra')).value!.name,
      'Infrastructure',
    );
  });

  test('creating adds the project to the list', () async {
    final server = FakeTix();
    final c = await signedInContainer(server);
    keepAlive(c);
    await c.read(projectsProvider.future);
    await c
        .read(projectsProvider.notifier)
        .create(const CreateProjectInput(name: 'Ops', key: 'ops'));
    final list = await c.read(projectsProvider.future);
    expect(list.items.map((p) => p.key), contains('ops'));
  });

  test('fields are ordered by position then key, and put replaces', () async {
    final server = FakeTix();
    server.fields['infra']!.first['position'] = 50;
    final c = await signedInContainer(server);
    keepAlive(c);
    final fields = await c.read(projectFieldsProvider('infra').future);
    expect(fields.map((f) => f.key), ['paged', 'window', 'env']);
    await c
        .read(projectFieldsProvider('infra').notifier)
        .put(const FieldDefInput(key: 'window', label: 'Window', position: 1));
    expect(c.read(projectFieldsProvider('infra')).value!.map((f) => f.label), [
      'Paged',
      'Window',
      'Environment',
    ]);
    await c.read(projectFieldsProvider('infra').notifier).delete('paged');
    expect(c.read(projectFieldsProvider('infra')).value, hasLength(2));
  });

  test('moving a field saves only the positions that changed', () async {
    final server = FakeTix();
    final list = server.fields['infra']!;
    for (final (i, f) in list.indexed) {
      f['position'] = (i + 1) * 10;
    }
    final c = await signedInContainer(server);
    keepAlive(c);
    await c.read(projectFieldsProvider('infra').future);
    await c.read(projectFieldsProvider('infra').notifier).move(2, 1);
    final puts = server.requests.where((r) => r.method == 'PUT').toList();
    expect(puts.map((r) => r.body['key']), ['paged', 'window']);
    expect(c.read(projectFieldsProvider('infra')).value!.map((f) => f.key), [
      'env',
      'paged',
      'window',
    ]);
  });

  test('a deletion plan reads the counts and the mapping', () async {
    final server = FakeTix()..deletionCounts['infra'] = (tasks: 2, deleted: 1);
    final c = await signedInContainer(server);
    keepAlive(c);
    final plain = await c.read(deletionPlanProvider('infra', null).future);
    expect(plain.statuses, isEmpty);
    final move = await c.read(deletionPlanProvider('infra', 'web').future);
    expect(move.statuses.map((m) => m.to), ['todo', 'in_progress']);
  });

  test('the workflow choices list the tenant workflows', () async {
    final c = await signedInContainer(FakeTix());
    keepAlive(c);
    final list = await c.read(workflowChoicesProvider.future);
    expect(list.single.key, 'default');
  });
}
