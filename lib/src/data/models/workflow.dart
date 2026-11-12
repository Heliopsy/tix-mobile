// SPDX-License-Identifier: AGPL-3.0-or-later

/// A tenant's workflows as the generated client reads them, and the rules
/// the board needs from one.
library;

import 'package:meta/meta.dart';
import 'package:tix_mobile/src/data/api/gen/models.gen.dart';

export 'package:tix_mobile/src/data/api/gen/models.gen.dart'
    show Scope, StateCategory, Transition, Workflow, WorkflowDefinition;

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

  /// Every state reachable from [from], each with its shortest route, as
  /// tix's `core.Routes` lists them: breadth first, a state that two equally
  /// short routes reach once per route (at most four), never longer than
  /// [maxRouteSteps].
  List<WorkflowRoute> routesFrom(String from) {
    final edges = <String, List<String>>{};
    for (final t in transitions) {
      (edges[t.from ?? ''] ??= []).add(t.to ?? '');
    }
    final dist = <String, int>{from: 0};
    final seen = <String>{};
    var frontier = [(from, const <State>[])];
    final out = <WorkflowRoute>[];
    for (
      var depth = 1;
      depth <= maxRouteSteps && frontier.isNotEmpty;
      depth++
    ) {
      final counts = <String, int>{};
      final next = <(String, List<State>)>[];
      for (final (at, via) in frontier) {
        for (final to in edges[at] ?? const <String>[]) {
          final d = dist[to];
          if (d != null && d < depth) continue;
          final state = _exact(to);
          if (state == null) continue;
          final route = WorkflowRoute(from: from, to: state, via: via);
          if (seen.contains(route.value) || (counts[to] ?? 0) >= 4) continue;
          seen.add(route.value);
          counts[to] = (counts[to] ?? 0) + 1;
          dist[to] = depth;
          out.add(route);
          next.add((to, [...via, state]));
        }
      }
      frontier = next;
    }
    return out;
  }

  State? _exact(String key) {
    for (final s in states) {
      if (s.key == key) return s;
    }
    return null;
  }

  /// What a tick offers a task in [from]: completing it when the state is
  /// open, reopening it when terminal; [has] says which scopes the reader
  /// holds. Mirrors the web's `tickRoutes`: one candidate is a box, more are
  /// a menu of the usable ones, none says why.
  TickPlan tickPlan(String from, bool Function(Scope scope) has) {
    final reopen = _exact(from)?.terminal ?? false;
    if (!has(Scope.taskTransition)) {
      return TickPlan.locked(TickLock.cannotMove, reopen: reopen);
    }
    final found = <WorkflowRoute>[];
    var fewest = 0;
    for (final r in routesFrom(from)) {
      final terminal = r.to.terminal ?? false;
      if (reopen && !terminal) {
        if (fewest == 0 || r.hops < fewest) {
          fewest = r.hops;
          found.clear();
        }
        if (r.hops == fewest) found.add(r);
      } else if (!reopen && terminal && categoryOf(r.to) == 'done') {
        found.add(r);
      }
    }
    if (found.isEmpty) {
      return TickPlan.locked(TickLock.noRoute, reopen: reopen);
    }
    final usable = <WorkflowRoute>[];
    TickPlan? why;
    for (final r in found) {
      final blocked = _blocked(r, has, reopen: reopen);
      if (blocked == null) {
        usable.add(r);
      } else {
        why ??= blocked;
      }
    }
    if (usable.isEmpty) return why!;
    return TickPlan(routes: usable, choose: found.length > 1, reopen: reopen);
  }

  TickPlan? _blocked(
    WorkflowRoute r,
    bool Function(Scope scope) has, {
    required bool reopen,
  }) {
    var at = r.from;
    for (final next in r.keys) {
      final edge = transitions.where((t) => t.from == at && t.to == next);
      for (final t in edge.take(1)) {
        if (t.requiresComment ?? false) {
          return TickPlan.locked(TickLock.needsComment, reopen: reopen);
        }
        final scope = t.requiresScope;
        if (scope != null && !has(scope)) {
          return TickPlan.locked(
            TickLock.needsScope,
            reopen: reopen,
            scope: scope.value,
          );
        }
      }
      at = next;
    }
    return null;
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

/// The most transitions a route takes, as tix bounds it.
const maxRouteSteps = 16;

/// One state a task can reach and the way there, as tix's `core.Route`.
@immutable
class WorkflowRoute {
  /// The route from [from] to [to], passing through [via].
  const WorkflowRoute({
    required this.from,
    required this.to,
    this.via = const [],
  });

  /// The key of the state the task is in now.
  final String from;

  /// The state the route ends in.
  final State to;

  /// The states passed through on the way, in order.
  final List<State> via;

  /// Whether the route passes through another state.
  bool get multiHop => via.isNotEmpty;

  /// How many transitions applying it performs.
  int get hops => via.length + 1;

  /// The state keys to move through, in order.
  List<String> get keys => [for (final s in via) s.id, to.id];

  /// The states' names, in the same order.
  List<String> get labels => [for (final s in via) s.name, to.name];

  /// The whole journey, from the current state.
  String get path => [from, ...labels].join(' → ');

  /// The route as tix spells it in a field.
  String get value => keys.join('>');
}

/// Why a tick offers nothing.
enum TickLock {
  /// The reader may not move tasks.
  cannotMove,

  /// The task's workflow could not be read.
  noWorkflow,

  /// No route leads to done, or back to an open state.
  noRoute,

  /// Every route needs a comment.
  needsComment,

  /// Every route needs a scope the reader lacks.
  needsScope,
}

/// What a task's tick does: apply one route, offer a menu of them, or say
/// why it cannot.
@immutable
class TickPlan {
  /// Routes the tick offers; [choose] makes them a menu.
  const TickPlan({
    required this.routes,
    required this.choose,
    required this.reopen,
  }) : lock = null,
       scope = '';

  /// A tick that offers nothing, for [lock].
  const TickPlan.locked(
    TickLock this.lock, {
    required this.reopen,
    this.scope = '',
  }) : routes = const [],
       choose = false;

  /// The usable routes.
  final List<WorkflowRoute> routes;

  /// Whether the routes are a menu rather than one box.
  final bool choose;

  /// Whether ticking reopens a finished task.
  final bool reopen;

  /// Why nothing is offered, or null.
  final TickLock? lock;

  /// The scope a [TickLock.needsScope] lock names.
  final String scope;

  /// Whether the tick offers nothing.
  bool get locked => lock != null;
}
