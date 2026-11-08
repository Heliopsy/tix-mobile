// SPDX-License-Identifier: AGPL-3.0-or-later

/// A tenant's workflows as the generated client reads them, and the rules
/// the board needs from one.
library;

import 'package:tix_mobile/src/data/api/gen/models.gen.dart';

export 'package:tix_mobile/src/data/api/gen/models.gen.dart'
    show StateCategory, Transition, Workflow, WorkflowDefinition;

/// One state of a workflow; named apart from Flutter's `State`.
typedef WorkflowState = State;

/// What a board reads from a workflow.
extension WorkflowRules on Workflow {
  /// The key of the state a new task starts in.
  String get initial => definition?.initial ?? '';

  /// The states, in declared order.
  List<State> get states => definition?.states ?? const [];

  /// The permitted moves, in declared order.
  List<Transition> get transitions => definition?.transitions ?? const [];

  /// The state [key], if the workflow has it.
  State? state(String key) {
    for (final s in states) {
      if ((s.key ?? '').toLowerCase() == key.toLowerCase()) return s;
    }
    return null;
  }

  /// The category of [s], derived as tix derives an empty one.
  String categoryOf(State s) => s.resolvedCategory(initial);

  /// The states reachable from [from] by any route whose steps need no
  /// comment, [from] left out.
  Set<String> reachableFrom(String from) {
    final seen = <String>{from};
    final queue = [from];
    while (queue.isNotEmpty) {
      final at = queue.removeLast();
      for (final t in transitions) {
        final to = t.to ?? '';
        if (t.from == at && !(t.requiresComment ?? false) && seen.add(to)) {
          queue.add(to);
        }
      }
    }
    return seen..remove(from);
  }

  /// The first terminal state in the done category, where completing goes.
  State? get doneState {
    for (final s in states) {
      if ((s.terminal ?? false) && categoryOf(s) == 'done') return s;
    }
    for (final s in states) {
      if (s.terminal ?? false) return s;
    }
    return null;
  }

  /// The keys of the states that are not terminal.
  List<String> get openStates => [
    for (final s in states)
      if (!(s.terminal ?? false)) s.key ?? '',
  ];

  /// Whether this workflow draws and moves exactly as [other] does: the
  /// same states in order (key, label, terminal, category) and the same
  /// transitions in order, as tix's board merge compares them.
  bool agreesWith(Workflow other) {
    if (id == other.id) return true;
    final a = states;
    final b = other.states;
    if (a.length != b.length ||
        transitions.length != other.transitions.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      final x = a[i];
      final y = b[i];
      if (x.key != y.key ||
          x.label != y.label ||
          (x.terminal ?? false) != (y.terminal ?? false) ||
          categoryOf(x) != other.categoryOf(y)) {
        return false;
      }
    }
    for (var i = 0; i < transitions.length; i++) {
      final x = transitions[i];
      final y = other.transitions[i];
      if (x.from != y.from ||
          x.to != y.to ||
          (x.requiresComment ?? false) != (y.requiresComment ?? false) ||
          x.requiresScope != y.requiresScope) {
        return false;
      }
    }
    return true;
  }
}

/// What a column reads from a state.
extension StateRules on WorkflowState {
  /// The key, which a task's status holds; empty when the server sent none.
  String get id => key ?? '';

  /// The label, or the key when it has none.
  String get name => (label ?? '').isEmpty ? key ?? '' : label!;

  /// The category key, derived as tix derives an empty one: `done` when
  /// terminal, `todo` for the [initial] state, `in_progress` otherwise.
  String resolvedCategory(String initial) =>
      category?.value ??
      ((terminal ?? false)
          ? 'done'
          : key == initial
          ? 'todo'
          : 'in_progress');
}
