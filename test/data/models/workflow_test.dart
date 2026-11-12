// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/data/models/workflow.dart';

import '../../helpers/fake_tix.dart';

void main() {
  final standard = Workflow.fromJson(workflowJson());

  Workflow machine(List<String> states, List<(String, String, bool)> moves) =>
      Workflow.fromJson({
        'id': 'w',
        'definition': {
          'initial': states.first,
          'states': [
            for (final s in states) {'key': s},
          ],
          'transitions': [
            for (final (from, to, comment) in moves)
              {'from': from, 'to': to, 'requires_comment': comment},
          ],
        },
      });

  test('reads states, transitions and the derived categories', () {
    expect(standard.states.map((s) => s.id), [
      'todo',
      'doing',
      'blocked',
      'done',
      'cancelled',
    ]);
    expect(standard.state('DOING')?.name, 'Doing');
    expect(standard.openStates, ['todo', 'doing', 'blocked']);
    expect(standard.doneState?.id, 'done');
    const bare = WorkflowState(key: 'review');
    expect(bare.resolvedCategory('todo'), 'in_progress');
    expect(bare.resolvedCategory('review'), 'todo');
    expect(
      const WorkflowState(key: 'x', terminal: true).resolvedCategory(''),
      'done',
    );
    expect(const WorkflowState(key: 'x').name, 'x');
  });

  test('reach follows transitions and skips ones needing a comment', () {
    final w = machine(
      ['a', 'b', 'c', 'd'],
      [('a', 'b', false), ('b', 'c', false), ('a', 'd', true)],
    );
    expect(w.reachableFrom('a'), {'b', 'c'});
    expect(w.reachableFrom('c'), isEmpty);
    expect(w.doneState, isNull);
  });

  test('agreement compares states and transitions, not names or ids', () {
    final copy = Workflow.fromJson(
      workflowJson(id: 'wf2', key: 'other', name: 'Other'),
    );
    final shorter = Workflow.fromJson(
      workflowJson(id: 'wf3', states: ['todo', 'done']),
    );
    expect(standard.agreesWith(copy), isTrue);
    expect(standard.agreesWith(shorter), isFalse);
    final relabelled = copy.copyWith(
      definition: copy.definition!.copyWith(
        states: [
          copy.states.first.copyWith(label: 'Backlog'),
          ...copy.states.skip(1),
        ],
      ),
    );
    expect(standard.agreesWith(relabelled), isFalse);
    final rerouted = copy.copyWith(
      definition: copy.definition!.copyWith(
        transitions: [
          copy.transitions.first.copyWith(requiresComment: true),
          ...copy.transitions.skip(1),
        ],
      ),
    );
    expect(standard.agreesWith(rerouted), isFalse);
  });

  group('tick plan', () {
    Workflow flow(
      List<Map<String, Object?>> states,
      List<Map<String, Object?>> moves,
    ) => Workflow.fromJson({
      'id': 'w',
      'definition': {
        'initial': states.first['key'],
        'states': states,
        'transitions': moves,
      },
    });

    const todo = {'key': 'todo'};
    const review = {'key': 'review', 'label': 'Review'};
    const done = {'key': 'done', 'terminal': true, 'category': 'done'};
    const shipped = {'key': 'shipped', 'terminal': true, 'category': 'done'};
    const cancelled = {
      'key': 'cancelled',
      'terminal': true,
      'category': 'cancelled',
    };
    bool all(Scope _) => true;

    test('routes are shortest, breadth first, each once', () {
      final w = flow(
        [todo, review, done],
        [
          {'from': 'todo', 'to': 'review'},
          {'from': 'review', 'to': 'done'},
          {'from': 'done', 'to': 'todo'},
        ],
      );
      final routes = w.routesFrom('todo');
      expect(routes.map((r) => r.value), ['review', 'review>done']);
      expect(routes.last.path, 'todo → Review → done');
      expect(routes.last.hops, 2);
    });

    test('one route to done is a box', () {
      final w = flow(
        [todo, done, cancelled],
        [
          {'from': 'todo', 'to': 'done'},
          {'from': 'todo', 'to': 'cancelled'},
        ],
      );
      final plan = w.tickPlan('todo', all);
      expect(plan.locked, isFalse);
      expect(plan.choose, isFalse);
      expect(plan.routes.single.value, 'done');
    });

    test('two done states are a menu, even when one is blocked', () {
      final w = flow(
        [todo, done, shipped],
        [
          {'from': 'todo', 'to': 'done'},
          {'from': 'todo', 'to': 'shipped', 'requires_comment': true},
        ],
      );
      final plan = w.tickPlan('todo', all);
      expect(plan.choose, isTrue);
      expect(plan.routes.map((r) => r.value), ['done']);
    });

    test('reopening takes the nearest open states', () {
      final w = flow(
        [todo, review, done],
        [
          {'from': 'done', 'to': 'review'},
          {'from': 'review', 'to': 'todo'},
        ],
      );
      final plan = w.tickPlan('done', all);
      expect(plan.reopen, isTrue);
      expect(plan.routes.single.value, 'review');
    });

    test('says why when nothing is usable', () {
      final none = flow([todo, done], []);
      expect(none.tickPlan('todo', all).lock, TickLock.noRoute);
      final comment = flow(
        [todo, done],
        [
          {'from': 'todo', 'to': 'done', 'requires_comment': true},
        ],
      );
      expect(comment.tickPlan('todo', all).lock, TickLock.needsComment);
      final scoped = flow(
        [todo, done],
        [
          {'from': 'todo', 'to': 'done', 'requires_scope': 'task:delete'},
        ],
      );
      final plan = scoped.tickPlan('todo', (s) => s != Scope.taskDelete);
      expect(plan.lock, TickLock.needsScope);
      expect(plan.scope, 'task:delete');
      expect(
        scoped.tickPlan('todo', (s) => s != Scope.taskTransition).lock,
        TickLock.cannotMove,
      );
    });
  });
}
