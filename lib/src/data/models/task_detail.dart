// SPDX-License-Identifier: AGPL-3.0-or-later

/// What hangs off a task, as the generated client reads it, and the few
/// readings of it the task screen needs.
library;

import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:tix_mobile/src/data/api/gen/models.gen.dart';

export 'package:tix_mobile/src/data/api/gen/models.gen.dart'
    show
        Artifact,
        ArtifactInput,
        ArtifactKind,
        AuditEntry,
        CheckItemInput,
        Comment,
        CommentRequest,
        CopyTaskInput,
        Dependency,
        DependencyRequest,
        FieldDef,
        FieldType,
        LeaseGrant,
        LeaseSource,
        RouteInput,
        RouteResult,
        SnoozeInput,
        Source,
        StateCategory,
        Tag,
        TagRequest,
        TransitionInput,
        TrashStatus,
        Via,
        Workflow,
        WorkflowDefinition;

/// One state of a workflow; the generated name clashes with Flutter's.
typedef WorkflowState = State;

/// One permitted move between two states.
typedef WorkflowTransition = Transition;

/// A state reachable from another, and the states a move passes through.
@immutable
class WorkflowRoute {
  /// A move ending in [to] through [via].
  const WorkflowRoute({
    required this.to,
    this.via = const [],
    this.requiresComment = false,
  });

  /// The destination state.
  final State to;

  /// The states entered on the way, in order, the destination left out.
  final List<State> via;

  /// Whether any hop of the move needs a comment.
  final bool requiresComment;
}

/// A state's key and the name to show for it.
extension StateNames on State {
  /// The key, empty when the workflow left it out.
  String get id => key ?? '';

  /// The label, or the key when it has none.
  String get name => (label ?? '').isEmpty ? id : label!;
}

/// Reading a workflow's state machine.
extension WorkflowRoutes on Workflow {
  List<State> get _states => definition?.states ?? const [];

  List<Transition> get _transitions => definition?.transitions ?? const [];

  /// The state [key], matched in any case, or null.
  State? state(String key) {
    final k = key.toLowerCase();
    for (final s in _states) {
      if (s.id.toLowerCase() == k) return s;
    }
    return null;
  }

  /// Every state reachable from [from], nearest first, each with the
  /// shortest route the workflow allows.
  List<WorkflowRoute> routesFrom(String from) {
    final start = state(from)?.id ?? from;
    final previous = <String, Transition>{};
    final queue = Queue<String>()..add(start);
    final order = <String>[];
    while (queue.isNotEmpty) {
      final at = queue.removeFirst();
      for (final t in _transitions) {
        final to = t.to ?? '';
        if (t.from != at || to.isEmpty || to == start) continue;
        if (previous.containsKey(to)) continue;
        previous[to] = t;
        order.add(to);
        queue.add(to);
      }
    }
    return [
      for (final key in order)
        if (state(key) case final dest?) _route(dest, start, previous),
    ];
  }

  WorkflowRoute _route(
    State dest,
    String start,
    Map<String, Transition> previous,
  ) {
    final hops = <Transition>[];
    var at = dest.id;
    while (at != start) {
      final t = previous[at]!;
      hops.insert(0, t);
      at = t.from ?? start;
    }
    return WorkflowRoute(
      to: dest,
      via: [
        for (final h in hops.sublist(0, hops.length - 1))
          state(h.to!) ?? State(key: h.to),
      ],
      requiresComment: hops.any((h) => h.requiresComment ?? false),
    );
  }
}

/// Whether a comment was changed after it was written.
extension CommentEdits on Comment {
  /// True when it was edited more than a second after it was written.
  bool get edited =>
      updatedAt != null &&
      createdAt != null &&
      updatedAt!.difference(createdAt!).inSeconds.abs() > 1;
}

/// The name to show for a custom field.
extension FieldDefNames on FieldDef {
  /// The label, or the key when the field has none.
  String get name => label.isEmpty ? key : label;

  /// The field's type on the wire, `string` when the server named none.
  String get typeName => type?.value ?? 'string';
}

/// An artifact's kind on the wire.
extension ArtifactKinds on Artifact {
  /// The kind, empty when the server named none this app knows.
  String get kindName => kind?.value ?? '';
}

/// What an audit entry changed.
extension AuditChanges on AuditEntry {
  /// The top-level keys whose values differ between before and after,
  /// bookkeeping fields left out.
  List<String> get changedKeys {
    final b = before;
    final a = after;
    if (b is! Map || a is! Map) return const [];
    const ignored = {'updated_at', 'version', 'checklist'};
    return [
      for (final k in {...b.keys, ...a.keys}.cast<String>())
        if (!ignored.contains(k) && !_same(b[k], a[k])) k,
    ];
  }

  static bool _same(Object? x, Object? y) {
    if (x is List && y is List) {
      if (x.length != y.length) return false;
      for (var i = 0; i < x.length; i++) {
        if (!_same(x[i], y[i])) return false;
      }
      return true;
    }
    if (x is Map && y is Map) {
      if (x.length != y.length) return false;
      return x.keys.every((k) => _same(x[k], y[k]));
    }
    return x == y;
  }
}
