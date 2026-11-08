// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/data/models/task_patch.dart';

void main() {
  final task = Task(
    id: 'id-1',
    ref: 'infra-1',
    title: 'Fix login',
    body: 'old',
    priority: 3,
    assigneeActorId: 'a1',
    dueAt: DateTime.utc(2026, 11, 20),
    tags: const ['auth'],
    recurrence: 'every day',
    customFields: const {'env': 'production', 'paged': true},
  );

  test('toJson names only the attribute changed', () {
    expect(TaskPatch.title('New').toJson(), {'title': 'New'});
    expect(TaskPatch.priority(1).toJson(), {'priority': 1});
    expect(TaskPatch.assignee('').toJson(), {'assignee_actor_id': ''});
    expect(TaskPatch.tags(const ['a']).toJson(), {
      'tags': ['a'],
    });
    expect(TaskPatch.recurrence('').toJson(), {'recurrence': ''});
    expect(TaskPatch.parent('infra-2').toJson(), {'parent_ref': 'infra-2'});
    expect(TaskPatch.body('b').keys, ['body']);
  });

  test('a cleared due date or field is a JSON null, not absent', () {
    final due = TaskPatch.due(null).toJson();
    expect(due.containsKey('due_at'), isTrue);
    expect(due['due_at'], isNull);
    expect(TaskPatch.field('env', null).toJson(), {
      'custom_fields': {'env': null},
    });
    expect(TaskPatch.due(DateTime.utc(2026, 11, 2, 9)).toJson(), {
      'due_at': '2026-11-02T09:00:00.000Z',
    });
  });

  test('applyTo changes a local task as the server would', () {
    expect(TaskPatch.title('New').applyTo(task).title, 'New');
    expect(TaskPatch.body('b').applyTo(task).body, 'b');
    expect(TaskPatch.priority(1).applyTo(task).priority, 1);
    expect(TaskPatch.assignee('').applyTo(task).assigneeActorId, '');
    expect(TaskPatch.due(null).applyTo(task).dueAt, isNull);
    expect(
      TaskPatch.due(DateTime.utc(2026, 12)).applyTo(task).dueAt,
      DateTime.utc(2026, 12),
    );
    expect(TaskPatch.tags(const ['x']).applyTo(task).tags, ['x']);
    expect(TaskPatch.recurrence('').applyTo(task).recurrence, '');
    expect(TaskPatch.parent('infra-2').applyTo(task), task);
  });

  test('a field change merges over the stored values; null removes', () {
    expect(TaskPatch.field('env', 'staging').applyTo(task).customFields, {
      'env': 'staging',
      'paged': true,
    });
    expect(TaskPatch.field('env', null).applyTo(task).customFields, {
      'paged': true,
    });
  });

  test('inverseFor puts the old values back', () {
    for (final patch in [
      TaskPatch.title('New'),
      TaskPatch.body('b'),
      TaskPatch.priority(1),
      TaskPatch.assignee('a2'),
      TaskPatch.due(null),
      TaskPatch.tags(const []),
      TaskPatch.recurrence(''),
      TaskPatch.field('env', 'staging'),
    ]) {
      final changed = patch.applyTo(task);
      expect(patch.inverseFor(task).applyTo(changed), task, reason: '$patch');
    }
  });

  test('the inverse of setting a new field clears it', () {
    final inverse = TaskPatch.field('window', 'sat').inverseFor(task);
    expect(inverse.toJson(), {
      'custom_fields': {'window': null},
    });
  });

  test('the inverse of clearing a due date sets it back in UTC', () {
    expect(TaskPatch.due(null).inverseFor(task).toJson(), {
      'due_at': '2026-11-20T00:00:00.000Z',
    });
  });

  test('patches with the same fields are equal', () {
    expect(TaskPatch.priority(2), TaskPatch.priority(2));
    expect(TaskPatch.priority(2).hashCode, TaskPatch.priority(2).hashCode);
    expect(TaskPatch.priority(2), isNot(TaskPatch.priority(3)));
  });
}
