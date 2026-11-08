// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:meta/meta.dart';
import 'package:tix_mobile/src/data/models/project_admin.dart';

/// One state of a workflow being edited.
@immutable
class StateDraft {
  /// A state keyed [key].
  const StateDraft({
    required this.key,
    this.label = '',
    this.category,
    this.terminal = false,
    this.revertOnLeaseExpiry = false,
    this.revertTo = '',
    this.savedKey,
  });

  /// The draft of the stored state [s].
  factory StateDraft.of(WorkflowState s) => StateDraft(
    key: s.key ?? '',
    label: s.label ?? '',
    category: s.category,
    terminal: s.terminal ?? false,
    revertOnLeaseExpiry: s.revertOnLeaseExpiry ?? false,
    revertTo: s.revertTo ?? '',
    savedKey: s.key,
  );

  /// What a task's status holds.
  final String key;

  /// The name shown; empty shows the key.
  final String label;

  /// The category; null lets tix derive one.
  final StateCategory? category;

  /// Whether reaching it ends the work.
  final bool terminal;

  /// Whether a task here goes back to [revertTo] when its claim runs out.
  final bool revertOnLeaseExpiry;

  /// Where an expired claim sends the task.
  final String revertTo;

  /// The key this state had in the stored workflow, null for a new one.
  final String? savedKey;

  /// The label, or the key when it has none.
  String get name => label.isEmpty ? key : label;

  /// A copy with the given values replaced.
  StateDraft copyWith({
    String? key,
    String? label,
    StateCategory? Function()? category,
    bool? terminal,
    bool? revertOnLeaseExpiry,
    String? revertTo,
  }) => StateDraft(
    key: key ?? this.key,
    label: label ?? this.label,
    category: category == null ? this.category : category(),
    terminal: terminal ?? this.terminal,
    revertOnLeaseExpiry: revertOnLeaseExpiry ?? this.revertOnLeaseExpiry,
    revertTo: revertTo ?? this.revertTo,
    savedKey: savedKey,
  );

  /// The state as tix reads it.
  WorkflowState toState() => WorkflowState(
    key: key,
    label: label.isEmpty ? null : label,
    category: category,
    terminal: terminal ? true : null,
    revertOnLeaseExpiry: revertOnLeaseExpiry ? true : null,
    revertTo: revertOnLeaseExpiry && revertTo.isNotEmpty ? revertTo : null,
  );

  @override
  bool operator ==(Object other) =>
      other is StateDraft &&
      other.key == key &&
      other.label == label &&
      other.category == category &&
      other.terminal == terminal &&
      other.revertOnLeaseExpiry == revertOnLeaseExpiry &&
      other.revertTo == revertTo &&
      other.savedKey == savedKey;

  @override
  int get hashCode => Object.hash(
    key,
    label,
    category,
    terminal,
    revertOnLeaseExpiry,
    revertTo,
    savedKey,
  );
}

/// One permitted move of a workflow being edited.
@immutable
class TransitionDraft {
  /// The move from [from] to [to].
  const TransitionDraft({
    required this.from,
    required this.to,
    this.requiresComment = false,
    this.requiresScope,
  });

  /// The state key it starts from.
  final String from;

  /// The state key it ends in.
  final String to;

  /// Whether the move needs a comment.
  final bool requiresComment;

  /// A scope the mover must hold, or null.
  final Scope? requiresScope;

  /// The transition as tix reads it.
  Transition toTransition() => Transition(
    from: from,
    to: to,
    requiresComment: requiresComment ? true : null,
    requiresScope: requiresScope,
  );

  @override
  bool operator ==(Object other) =>
      other is TransitionDraft &&
      other.from == from &&
      other.to == to &&
      other.requiresComment == requiresComment &&
      other.requiresScope == requiresScope;

  @override
  int get hashCode => Object.hash(from, to, requiresComment, requiresScope);
}

/// A workflow as the editor holds it: states in order, the moves between
/// them, and where the tasks of removed states go.
///
/// Every change returns a new draft. Renaming a state keeps its moves, the
/// initial state and revert targets pointing at it, and migrates its tasks
/// to the new key. The draft does not validate: tix does, on save.
@immutable
class WorkflowDraft {
  /// A draft of every part.
  const WorkflowDraft({
    required this.key,
    required this.name,
    required this.initial,
    required this.states,
    required this.transitions,
    this.defaultLease = '',
    this.migrate = const {},
    this.builtin = false,
  });

  /// The draft of the stored workflow [w].
  factory WorkflowDraft.of(Workflow w) {
    final d = w.definition;
    return WorkflowDraft(
      key: w.key,
      name: w.name,
      builtin: w.builtin,
      initial: d?.initial ?? '',
      defaultLease: d?.defaultLease ?? '',
      states: [
        for (final s in d?.states ?? const <WorkflowState>[]) StateDraft.of(s),
      ],
      transitions: [
        for (final t in d?.transitions ?? const <Transition>[])
          TransitionDraft(
            from: t.from ?? '',
            to: t.to ?? '',
            requiresComment: t.requiresComment ?? false,
            requiresScope: t.requiresScope,
          ),
      ],
    );
  }

  /// The smallest useful workflow: open, then done, and back.
  factory WorkflowDraft.minimal(String key, String name) => WorkflowDraft(
    key: key,
    name: name,
    initial: 'open',
    states: const [
      StateDraft(key: 'open', label: 'Open', category: StateCategory.todo),
      StateDraft(
        key: 'done',
        label: 'Done',
        category: StateCategory.done,
        terminal: true,
      ),
    ],
    transitions: const [
      TransitionDraft(from: 'open', to: 'done'),
      TransitionDraft(from: 'done', to: 'open'),
    ],
  );

  /// The workflow's key.
  final String key;

  /// The display name.
  final String name;

  /// The key of the state a new task starts in.
  final String initial;

  /// How long a claim holds by default, such as `4h`; empty defers.
  final String defaultLease;

  /// The states, in order.
  final List<StateDraft> states;

  /// The permitted moves.
  final List<TransitionDraft> transitions;

  /// Where the tasks of each removed stored state go, chosen by the person.
  final Map<String, String> migrate;

  /// Whether tix ships it; it can be changed but not deleted.
  final bool builtin;

  /// A copy with the given values replaced.
  WorkflowDraft copyWith({
    String? key,
    String? name,
    String? initial,
    String? defaultLease,
    List<StateDraft>? states,
    List<TransitionDraft>? transitions,
    Map<String, String>? migrate,
  }) => WorkflowDraft(
    key: key ?? this.key,
    name: name ?? this.name,
    initial: initial ?? this.initial,
    defaultLease: defaultLease ?? this.defaultLease,
    states: List.unmodifiable(states ?? this.states),
    transitions: List.unmodifiable(transitions ?? this.transitions),
    migrate: Map.unmodifiable(migrate ?? this.migrate),
    builtin: builtin,
  );

  /// The state [key], or null.
  StateDraft? state(String key) {
    for (final s in states) {
      if (s.key == key) return s;
    }
    return null;
  }

  /// The move from [from] to [to], or null when there is none.
  TransitionDraft? transition(String from, String to) {
    for (final t in transitions) {
      if (t.from == from && t.to == to) return t;
    }
    return null;
  }

  /// Adds [s] at the end.
  WorkflowDraft addState(StateDraft s) => copyWith(states: [...states, s]);

  /// Replaces the state at [index] with [s], following a new key
  /// everywhere the old one was named.
  WorkflowDraft replaceState(int index, StateDraft s) {
    final old = states[index].key;
    String follow(String k) => k == old ? s.key : k;
    return copyWith(
      initial: follow(initial),
      states: [
        for (final (i, x) in states.indexed)
          if (i == index) s else x.copyWith(revertTo: follow(x.revertTo)),
      ],
      transitions: [
        for (final t in transitions)
          TransitionDraft(
            from: follow(t.from),
            to: follow(t.to),
            requiresComment: t.requiresComment,
            requiresScope: t.requiresScope,
          ),
      ],
      migrate: {
        for (final MapEntry(:key, :value) in migrate.entries)
          key: follow(value),
      },
    );
  }

  /// Removes the state at [index] and every move to or from it.
  WorkflowDraft removeState(int index) {
    final gone = states[index].key;
    return copyWith(
      initial: initial == gone ? '' : initial,
      states: [
        for (final (i, s) in states.indexed)
          if (i != index)
            if (s.revertTo == gone) s.copyWith(revertTo: '') else s,
      ],
      transitions: [
        for (final t in transitions)
          if (t.from != gone && t.to != gone) t,
      ],
      migrate: {
        for (final MapEntry(:key, :value) in migrate.entries)
          if (value != gone) key: value,
      },
    );
  }

  /// Moves the state at [from] to the index [to] it has afterwards.
  WorkflowDraft moveState(int from, int to) {
    final list = [...states];
    final s = list.removeAt(from);
    list.insert(to, s);
    return copyWith(states: list);
  }

  /// Allows or forbids the move from [from] to [to].
  WorkflowDraft toggleTransition(String from, String to) {
    if (transition(from, to) != null) {
      return copyWith(
        transitions: [
          for (final t in transitions)
            if (t.from != from || t.to != to) t,
        ],
      );
    }
    return copyWith(
      transitions: [
        ...transitions,
        TransitionDraft(from: from, to: to),
      ],
    );
  }

  /// Sets the rules of the move from [from] to [to].
  WorkflowDraft setRules(
    String from,
    String to, {
    required bool requiresComment,
    Scope? requiresScope,
  }) => copyWith(
    transitions: [
      for (final t in transitions)
        if (t.from == from && t.to == to)
          TransitionDraft(
            from: from,
            to: to,
            requiresComment: requiresComment,
            requiresScope: requiresScope,
          )
        else
          t,
    ],
  );

  /// Sends the tasks of the removed state [from] to [to], or lets tix
  /// decide when [to] is null.
  WorkflowDraft setMigration(String from, String? to) => copyWith(
    migrate: {
      for (final MapEntry(:key, :value) in migrate.entries)
        if (key != from) key: value,
      from: ?to,
    },
  );

  /// The stored states this draft no longer has, renamed ones excepted.
  List<String> removedFrom(Workflow saved) {
    final kept = {for (final s in states) ?s.savedKey};
    return [
      for (final s in saved.definition?.states ?? const <WorkflowState>[])
        if (s.key != null && !kept.contains(s.key)) s.key!,
    ];
  }

  /// The stored states renamed in this draft: old key to new.
  Map<String, String> get renames => {
    for (final s in states)
      if (s.savedKey != null && s.savedKey != s.key) s.savedKey!: s.key,
  };

  /// The definition as tix reads it.
  WorkflowDefinition toDefinition() => WorkflowDefinition(
    initial: initial,
    defaultLease: defaultLease.isEmpty ? null : defaultLease,
    states: [for (final s in states) s.toState()],
    transitions: [for (final t in transitions) t.toTransition()],
  );

  /// The body of a save: the definition, and where removed and renamed
  /// states' tasks go.
  WorkflowInput toInput() {
    final m = {...renames, ...migrate};
    return WorkflowInput(
      key: key,
      name: name,
      definition: toDefinition(),
      migrate: m.isEmpty ? null : m,
    );
  }

  /// The draft as a workflow, for reading its routes.
  Workflow toWorkflow() =>
      Workflow(key: key, name: name, definition: toDefinition());

  /// How many moves each state is from the initial one; states no route
  /// reaches are left out, and the initial state is zero.
  Map<String, int> stepsFromInitial() {
    final w = toWorkflow();
    return {
      if (state(initial) != null) initial: 0,
      for (final r in w.routesFrom(initial)) r.to.id: r.via.length + 1,
    };
  }

  @override
  bool operator ==(Object other) =>
      other is WorkflowDraft &&
      other.key == key &&
      other.name == name &&
      other.initial == initial &&
      other.defaultLease == defaultLease &&
      other.builtin == builtin &&
      _sameList(other.states, states) &&
      _sameList(other.transitions, transitions) &&
      _sameList(_entries(other.migrate), _entries(migrate));

  static List<String> _entries(Map<String, String> m) =>
      [for (final e in m.entries) '${e.key}=${e.value}']..sort();

  static bool _sameList<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    key,
    name,
    initial,
    defaultLease,
    builtin,
    Object.hashAll(states),
    Object.hashAll(transitions),
    Object.hashAll(_entries(migrate)),
  );
}
