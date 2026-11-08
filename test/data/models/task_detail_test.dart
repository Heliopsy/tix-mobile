// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/data/models/task_detail.dart';

import '../../helpers/fake_tix.dart';

void main() {
  final workflow = Workflow.fromJson(FakeTix().workflow);

  group('Workflow.routesFrom', () {
    test('lists every reachable state, nearest first', () {
      final routes = workflow.routesFrom('todo');
      expect(routes.map((r) => r.to.key), [
        'doing',
        'cancelled',
        'blocked',
        'done',
      ]);
    });

    test('names the states a move passes through', () {
      final routes = {for (final r in workflow.routesFrom('todo')) r.to.key: r};
      expect(routes['doing']!.via, isEmpty);
      expect(routes['done']!.via.map((s) => s.key), ['doing']);
      expect(routes['done']!.via.single.label, 'Doing');
    });

    test('a move needs a comment when any hop does', () {
      final fromTodo = {
        for (final r in workflow.routesFrom('todo')) r.to.key: r,
      };
      expect(fromTodo['blocked']!.requiresComment, isTrue);
      expect(fromTodo['done']!.requiresComment, isFalse);
      final fromDoing = {
        for (final r in workflow.routesFrom('doing')) r.to.key: r,
      };
      expect(fromDoing['blocked']!.requiresComment, isTrue);
    });

    test('leaves out the state it starts in', () {
      expect(
        workflow.routesFrom('doing').map((r) => r.to.key),
        isNot(contains('doing')),
      );
    });

    test('matches the status in any case', () {
      expect(workflow.routesFrom('DOING').map((r) => r.to.key), [
        'todo',
        'blocked',
        'done',
        'cancelled',
      ]);
      expect(workflow.state('Done')!.terminal, isTrue);
      expect(workflow.state('nope'), isNull);
    });

    test('an unknown state has no moves', () {
      expect(workflow.routesFrom('nope'), isEmpty);
    });
  });

  group('AuditEntry.changedKeys', () {
    test('names what changed, leaving bookkeeping out', () {
      final e = AuditEntry.fromJson({
        'seq': 3,
        'action': 'task.update',
        'before': {
          'priority': 3,
          'tags': ['a'],
          'version': 1,
          'updated_at': 'x',
          'custom_fields': {'env': 'prod'},
          'title': 'same',
        },
        'after': {
          'priority': 2,
          'tags': ['a', 'b'],
          'version': 2,
          'updated_at': 'y',
          'custom_fields': {'env': 'staging'},
          'title': 'same',
          'due_at': '2026-11-01',
        },
      });
      expect(e.changedKeys, ['priority', 'tags', 'custom_fields', 'due_at']);
    });

    test('is empty for a creation or a removal', () {
      expect(
        const AuditEntry(action: 'task.create', after: {'a': 1}).changedKeys,
        isEmpty,
      );
      expect(
        const AuditEntry(action: 'task.delete', before: {'a': 1}).changedKeys,
        isEmpty,
      );
    });

    test('equal nested values are not changes', () {
      const e = AuditEntry(
        before: {
          'm': {
            'a': [1, 2],
          },
        },
        after: {
          'm': {
            'a': [1, 2],
          },
        },
      );
      expect(e.changedKeys, isEmpty);
    });
  });

  test('a comment is edited when it changed after it was written', () {
    final at = DateTime.utc(2026, 11);
    expect(Comment(id: 'c', createdAt: at, updatedAt: at).edited, isFalse);
    expect(
      Comment(
        id: 'c',
        createdAt: at,
        updatedAt: at.add(const Duration(minutes: 5)),
      ).edited,
      isTrue,
    );
    expect(const Comment(id: 'c').edited, isFalse);
  });

  test('a field is named by its label, else its key', () {
    expect(
      const FieldDef(key: 'env', label: 'Environment').name,
      'Environment',
    );
    expect(const FieldDef(key: 'env').name, 'env');
    expect(FieldDef.fromJson({'key': 'k', 'default': 3}).defaultValue, 3);
  });

  test('a route result reads where it stopped', () {
    final r = RouteResult.fromJson({
      'from': 'todo',
      'route': ['doing', 'done'],
      'applied': ['doing'],
      'stopped': 'done',
      'reason': 'needs review',
      'task': taskJson('infra-1', status: 'doing'),
    });
    expect(r.stopped, 'done');
    expect(r.task!.status, 'doing');
  });
}
