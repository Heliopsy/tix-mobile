// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/data/models/project_admin.dart';
import 'package:tix_mobile/src/data/models/workflow_draft.dart';

Workflow stored() => Workflow.fromJson({
  'key': 'flow',
  'name': 'Flow',
  'definition': {
    'initial': 'todo',
    'default_lease': '4h',
    'states': [
      {'key': 'todo', 'label': 'To do', 'category': 'todo'},
      {
        'key': 'doing',
        'label': 'Doing',
        'revert_on_lease_expiry': true,
        'revert_to': 'todo',
      },
      {'key': 'review', 'label': 'Review'},
      {'key': 'done', 'label': 'Done', 'terminal': true},
    ],
    'transitions': [
      {'from': 'todo', 'to': 'doing'},
      {'from': 'doing', 'to': 'review', 'requires_comment': true},
      {'from': 'review', 'to': 'done', 'requires_scope': 'project:write'},
      {'from': 'done', 'to': 'todo'},
    ],
  },
});

void main() {
  test('a stored workflow round-trips unchanged', () {
    final w = stored();
    final d = WorkflowDraft.of(w);
    final input = d.toInput();
    expect(input.key, 'flow');
    expect(input.migrate, isNull);
    expect(input.definition!.toJson(), w.definition!.toJson());
    expect(WorkflowDraft.of(w), d);
  });

  test('reordering moves the state to its new index', () {
    final d = WorkflowDraft.of(stored()).moveState(3, 1);
    expect(
      [for (final s in d.states) s.key],
      ['todo', 'done', 'doing', 'review'],
    );
    expect(
      [
        for (final s in WorkflowDraft.of(stored()).moveState(0, 2).states)
          s.key,
      ],
      ['doing', 'review', 'todo', 'done'],
    );
  });

  test('renaming a state follows it everywhere and migrates its tasks', () {
    final d = WorkflowDraft.of(stored());
    final renamed = d.replaceState(0, d.states[0].copyWith(key: 'open'));
    expect(renamed.initial, 'open');
    expect(renamed.state('doing')!.revertTo, 'open');
    expect(renamed.transition('open', 'doing'), isNotNull);
    expect(renamed.transition('done', 'open'), isNotNull);
    expect(renamed.toInput().migrate, {'todo': 'open'});
    expect(renamed.removedFrom(stored()), isEmpty);
  });

  test('removing a state drops its moves and asks where its tasks go', () {
    final d = WorkflowDraft.of(stored()).removeState(2);
    expect(d.state('review'), isNull);
    expect(
      d.transitions.any((t) => t.from == 'review' || t.to == 'review'),
      isFalse,
    );
    expect(d.removedFrom(stored()), ['review']);
    final migrated = d.setMigration('review', 'doing');
    expect(migrated.toInput().migrate, {'review': 'doing'});
    expect(migrated.setMigration('review', null).toInput().migrate, isNull);
  });

  test('toggling adds and removes a move', () {
    final d = WorkflowDraft.of(stored());
    final added = d.toggleTransition('todo', 'done');
    expect(added.transition('todo', 'done'), isNotNull);
    expect(
      added.toggleTransition('todo', 'done').transition('todo', 'done'),
      isNull,
    );
  });

  test('rules are kept on the wire', () {
    final d = WorkflowDraft.of(stored()).setRules(
      'todo',
      'doing',
      requiresComment: true,
      requiresScope: Scope.taskTransition,
    );
    final t = d.toInput().definition!.transitions!.first;
    expect(t.requiresComment, isTrue);
    expect(t.requiresScope, Scope.taskTransition);
  });

  test('steps count moves from the initial state', () {
    final d = WorkflowDraft.of(stored());
    expect(d.stepsFromInitial(), {
      'todo': 0,
      'doing': 1,
      'review': 2,
      'done': 3,
    });
    final cut = d.toggleTransition('doing', 'review');
    expect(cut.stepsFromInitial().containsKey('review'), isFalse);
    expect(cut.stepsFromInitial().containsKey('done'), isFalse);
  });

  test('the minimal workflow opens and closes', () {
    final d = WorkflowDraft.minimal('support', 'Support');
    expect(d.initial, 'open');
    expect(d.state('done')!.terminal, isTrue);
    expect(d.toInput().name, 'Support');
  });
}
