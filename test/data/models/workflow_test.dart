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
}
