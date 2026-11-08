// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/data/models/template.dart';
import 'package:tix_mobile/src/features/templates/application/templates.dart';

import '../../../helpers/container.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  const before = TaskTemplate(
    id: 't1',
    name: 'weekly',
    projectKey: 'ops',
    dueIn: '72h0m0s',
    task: TemplateTask(
      title: 'Review',
      priority: 2,
      tags: ['ops'],
      recurrence: 'every week',
    ),
  );

  UpdateTemplateInput changes({
    String name = 'weekly',
    String title = 'Review',
    String body = '',
    int priority = 2,
    List<String> tags = const ['ops'],
    String recurrence = 'every week',
    String dueIn = '3d',
    String projectKey = 'ops',
  }) => templateChanges(
    before,
    name: name,
    title: title,
    body: body,
    priority: priority,
    tags: tags,
    recurrence: recurrence,
    dueIn: dueIn,
    projectKey: projectKey,
  );

  test('nothing changed sends nothing', () {
    expect(isEmptyUpdate(changes()), isTrue);
  });

  test('only what changed is sent', () {
    expect(changes(name: 'weekly-review').toJson(), {'name': 'weekly-review'});
    expect(changes(tags: ['ops', 'review']).toJson(), {
      'tags': ['ops', 'review'],
    });
    expect(changes(dueIn: '').toJson(), {'due_in': '0'});
    expect(changes(projectKey: '').toJson(), {'project_ref': ''});
    expect(changes(priority: 1, recurrence: '').toJson(), {
      'priority': 1,
      'recurrence': '',
    });
  });

  test('due offsets read as a person writes them', () {
    expect(readableDueIn('72h0m0s'), '3d');
    expect(readableDueIn('336h0m0s'), '2w');
    expect(readableDueIn('5h0m0s'), '5h');
    expect(readableDueIn('1h30m0s'), '1h30m0s');
    expect(readableDueIn(''), '');
    expect(readableDueIn(null), '');
  });

  test('tags split on spaces and commas, hashes dropped', () {
    expect(splitTags(' #a, b  c,'), ['a', 'b', 'c']);
  });

  test('template facts count subtasks at any depth', () {
    const t = TaskTemplate(
      task: TemplateTask(
        subtasks: [
          TemplateTask(subtasks: [TemplateTask()]),
          TemplateTask(),
        ],
      ),
    );
    expect(t.subtaskCount, 3);
    expect(t.tenantWide, isTrue);
    expect(const TaskTemplate().shape.title, isEmpty);
  });

  group('the list', () {
    late FakeTix server;

    setUp(() => server = FakeTix());

    test('use counts the use and says tasks changed', () async {
      server.addTemplate('weekly', project: 'infra', uses: 1);
      final c = await signedInContainer(server);
      final sub = c.listen(templatesProvider, (_, _) {});
      addTearDown(sub.close);
      final t = (await c.read(templatesProvider.future)).items.single;
      final task = await c.read(templatesProvider.notifier).use(t);
      expect(task.ref, 'infra-3');
      expect(c.read(templatesProvider).value!.items.single.uses, 2);
    });

    test('delete removes it from the list', () async {
      server
        ..addTemplate('a')
        ..addTemplate('b');
      final c = await signedInContainer(server);
      final sub = c.listen(templatesProvider, (_, _) {});
      addTearDown(sub.close);
      final first = (await c.read(templatesProvider.future)).items.first;
      await c.read(templatesProvider.notifier).delete(first);
      expect(c.read(templatesProvider).value!.items.map((t) => t.name), ['b']);
      expect(server.templates.values.map((t) => t['name']), ['b']);
    });

    test('current reads the server copy, the listed one on failure', () async {
      server.addTemplate('weekly', title: 'Old');
      final c = await signedInContainer(server);
      final sub = c.listen(templatesProvider, (_, _) {});
      addTearDown(sub.close);
      final listed = (await c.read(templatesProvider.future)).items.single;
      (server.templates.values.single['task']! as Map)['title'] = 'New';
      final fresh = await c.read(templatesProvider.notifier).current(listed);
      expect(fresh.shape.title, 'New');
      server.override = FakeResponse(500, envelope('internal', 'x'));
      final fallback = await c.read(templatesProvider.notifier).current(listed);
      expect(fallback.shape.title, 'Old');
    });
  });
}
