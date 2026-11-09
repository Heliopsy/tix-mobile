// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/clock/clock.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/time/time_style.dart';
import 'package:tix_mobile/src/data/models/group_pref.dart';
import 'package:tix_mobile/src/data/models/project.dart';
import 'package:tix_mobile/src/data/models/saved_filter.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/data/models/workflow.dart';
import 'package:tix_mobile/src/data/query/filter_expression.dart';
import 'package:tix_mobile/src/features/tasks/application/listing.dart';

export 'package:tix_mobile/src/data/query/task_query.dart';

part 'screen.g.dart';

/// The filter, drawing and options of the task screen over one scope, kept
/// while the app runs so going back finds them as they were.
@Riverpod(keepAlive: true)
class TaskScreen extends _$TaskScreen {
  @override
  TaskScreenState build(TaskScope scope) => const TaskScreenState();

  /// Applies [expression] when tix's language reads it; otherwise keeps the
  /// filter in force and says why.
  void setExpression(String expression) {
    final text = expression.trim();
    try {
      parseFilterExpression(text, now: ref.read(clockProvider)());
    } on TixException catch (e) {
      state = state.copyWith(filterError: () => e.message);
      return;
    }
    if (text == state.expression) {
      state = state.copyWith(filterError: () => null);
      return;
    }
    state = state.copyWith(
      expression: text,
      filterError: () => null,
      savedFilterId: () => null,
    );
  }

  /// Adds [term] to the filter, or takes it out when it is there.
  void toggleTerm(String term) =>
      setExpression(toggleFilterTerm(state.expression, term));

  /// Replaces any `due:` term with [window], or drops it when [window] is
  /// the one in force.
  void setDue(String window) {
    final on = hasFilterTerm(state.expression, 'due:$window');
    final rest = dropFilterTerms(state.expression, 'due:');
    setExpression(on ? rest : '$rest due:$window');
  }

  /// Sorts by [sort], empty for urgency.
  void setSort(String sort) => state = state.copyWith(sort: sort);

  /// Reverses the sort.
  void toggleDirection() =>
      state = state.copyWith(descending: !state.descending);

  /// Draws the selection as [view].
  void setView(TaskView view) => state = state.copyWith(view: view);

  /// Moves to the next drawing this scope offers.
  void cycleView() {
    final views = viewsFor(scope);
    final at = views.indexOf(state.view);
    setView(views[(at + 1) % views.length]);
  }

  /// Splits the list by [grouping].
  void setGrouping(TaskGrouping grouping) =>
      state = state.copyWith(grouping: grouping);

  /// Shows finished work in the list, or not.
  void setShowFinished({required bool show}) =>
      state = state.copyWith(showFinished: show);

  /// Applies [filter]'s expression, sort and view.
  void applySaved(SavedFilter filter) {
    final view = TaskView.named(filter.view);
    state = state.copyWith(
      expression: filter.query,
      sort: filter.sort,
      view: view != null && viewsFor(scope).contains(view) ? view : null,
      savedFilterId: () => filter.id,
      filterError: () => null,
    );
  }

  /// Takes [fresh], the server's copy of [drawn], when [drawn] is still the
  /// filter applied and its query, sort or view changed.
  void refreshSaved(SavedFilter drawn, SavedFilter fresh) {
    if (state.savedFilterId != drawn.id) return;
    if (fresh.query != drawn.query ||
        fresh.sort != drawn.sort ||
        fresh.view != drawn.view) {
      applySaved(fresh);
    }
  }

  /// Clears the filter when the saved filter [id] is the one applied.
  void dropSaved(String id) {
    if (state.savedFilterId == id) clear();
  }

  /// Clears the filter, keeping the sort and the drawing.
  void clear() => state = state.copyWith(
    expression: '',
    savedFilterId: () => null,
    filterError: () => null,
  );
}

/// The drawings [scope] offers: lanes need more than one project, My work
/// is a list.
List<TaskView> viewsFor(TaskScope scope) => switch (scope) {
  AllScope() => TaskView.values,
  ProjectScope() => const [TaskView.list, TaskView.board],
  MineScope() => const [TaskView.list],
};

/// The tasks picked for a bulk action on one scope, by reference.
@riverpod
class TaskSelection extends _$TaskSelection {
  @override
  Set<String> build(TaskScope scope) => const {};

  /// Picks [ref], or puts it back.
  void toggle(String ref) =>
      state = state.contains(ref) ? ({...state}..remove(ref)) : {...state, ref};

  /// Picks every one of [refs].
  void selectAll(Iterable<String> refs) => state = {...state, ...refs};

  /// Picks nothing.
  void clear() => state = const {};
}

/// The reader's arrangement of one view's groups, by group.
@riverpod
class ViewArrangement extends _$ViewArrangement {
  @override
  Future<Map<String, GroupPref>> build(String view) async {
    ref.watch(arrangementResetsProvider);
    final prefs = await ref.watch(viewPrefsRepositoryProvider).groups(view);
    return {for (final p in prefs) p.group: p};
  }

  Map<String, GroupPref> get _now => state.value ?? const {};

  GroupPref _of(String group) => _now[group] ?? GroupPref(group: group);

  Future<void> _change(
    Map<String, GroupPref> next,
    Future<void> Function() send,
  ) async {
    final before = state.value;
    state = AsyncData(next);
    try {
      await send();
    } on Object {
      if (before != null) state = AsyncData(before);
      rethrow;
    }
  }

  Future<void> _set(
    String group, {
    bool? hidden,
    bool? collapsed,
    bool? starred,
  }) {
    final old = _of(group);
    final next = old.copyWith(
      hidden: hidden ?? old.hidden,
      collapsed: collapsed ?? old.collapsed,
      starred: starred ?? old.starred,
    );
    return _change(
      {..._now, group: next},
      () => ref
          .read(viewPrefsRepositoryProvider)
          .setGroup(
            view,
            group,
            hidden: hidden,
            collapsed: collapsed,
            starred: starred,
          ),
    );
  }

  /// Stars or unstars [group].
  Future<void> star(String group, {required bool starred}) =>
      _set(group, starred: starred);

  /// Collapses [group] to a strip, or opens it.
  Future<void> collapse(String group, {required bool collapsed}) =>
      _set(group, collapsed: collapsed);

  /// Hides or shows [group].
  Future<void> hide(String group, {required bool hidden}) =>
      _set(group, hidden: hidden);

  /// Swaps [group] with its neighbour [by] places along among the visible
  /// groups of its own kind (starred or not), given the view's [natural]
  /// order.
  Future<void> move(String group, int by, List<String> natural) {
    final order = arrangeGroups(natural, _now).visible;
    final starred = _of(group).starred;
    final peers = [
      for (final g in order)
        if (_of(g).starred == starred) g,
    ];
    final at = peers.indexOf(group);
    final to = at + by;
    if (at < 0 || to < 0 || to >= peers.length) return Future.value();
    final other = peers[to];
    final full = [...order];
    final i = full.indexOf(group);
    final j = full.indexOf(other);
    full[i] = other;
    full[j] = group;
    final next = {..._now};
    for (var k = 0; k < full.length; k++) {
      next[full[k]] = _of(full[k]).copyWith(position: k + 1);
    }
    return _change(
      next,
      () => ref.read(viewPrefsRepositoryProvider).order(view, full),
    );
  }

  /// Forgets the whole arrangement.
  Future<void> reset() => _change(
    const {},
    () => ref.read(viewPrefsRepositoryProvider).reset(view),
  );
}

/// The groups of a view as the reader arranged them.
typedef ArrangedGroups = ({List<String> visible, List<String> hidden});

/// [natural] in the reader's order: starred groups first, then groups the
/// reader moved by their position, then the rest as the view draws them.
/// Hidden groups are set apart.
ArrangedGroups arrangeGroups(
  List<String> natural,
  Map<String, GroupPref> prefs,
) {
  int rank(String g) {
    final p = prefs[g];
    final pos = p == null || p.position == 0 ? 1 << 20 : p.position;
    return pos;
  }

  final indexed = [for (var i = 0; i < natural.length; i++) (i, natural[i])]
    ..sort((a, b) {
      final sa = prefs[a.$2]?.starred ?? false;
      final sb = prefs[b.$2]?.starred ?? false;
      if (sa != sb) return sa ? -1 : 1;
      final r = rank(a.$2).compareTo(rank(b.$2));
      return r != 0 ? r : a.$1.compareTo(b.$1);
    });
  return (
    visible: [
      for (final (_, g) in indexed)
        if (!(prefs[g]?.hidden ?? false)) g,
    ],
    hidden: [
      for (final (_, g) in indexed)
        if (prefs[g]?.hidden ?? false) g,
    ],
  );
}

/// The reader's saved filters, then the ones shared with them.
@riverpod
class SavedFilters extends _$SavedFilters {
  @override
  Future<List<SavedFilter>> build() =>
      ref.watch(viewPrefsRepositoryProvider).filters();

  /// The filter [nameOrId] as the server has it now (`filter.show`); the
  /// reader's own wins over a shared one of the same name. One gone from the
  /// server drops out of the list and the error is thrown.
  Future<SavedFilter> fetch(String nameOrId) async {
    try {
      return await ref.read(viewPrefsRepositoryProvider).filter(nameOrId);
    } on TixException catch (e) {
      if (e.kind == TixErrorKind.notFound && ref.mounted) ref.invalidateSelf();
      rethrow;
    }
  }

  /// Saves [query] with its [sort] and [view] as [name].
  Future<SavedFilter> save({
    required String name,
    required String query,
    required String sort,
    required String view,
    required bool shared,
  }) async {
    final saved = await ref
        .read(viewPrefsRepositoryProvider)
        .saveFilter(
          name: name,
          query: query,
          sort: sort,
          view: view,
          shared: shared,
        );
    ref.invalidateSelf();
    return saved;
  }

  /// Renames [filter].
  Future<void> rename(SavedFilter filter, String name) async {
    await ref
        .read(viewPrefsRepositoryProvider)
        .updateFilter(filter.id, name: name);
    ref.invalidateSelf();
  }

  /// Shares [filter] with the tenant or takes it back.
  Future<void> share(SavedFilter filter, {required bool shared}) async {
    await ref
        .read(viewPrefsRepositoryProvider)
        .updateFilter(filter.id, shared: shared);
    ref.invalidateSelf();
  }

  /// Deletes [filter].
  Future<void> delete(SavedFilter filter) async {
    await ref.read(viewPrefsRepositoryProvider).deleteFilter(filter.id);
    ref.invalidateSelf();
  }

  /// Moves [filter] [by] places among the reader's own.
  Future<void> move(SavedFilter filter, int by) async {
    final own = [
      for (final f in state.value ?? const <SavedFilter>[])
        if (f.mine) f,
    ];
    final at = own.indexWhere((f) => f.id == filter.id);
    final to = at + by;
    if (at < 0 || to < 0 || to >= own.length) return;
    final ids = [for (final f in own) f.id];
    ids[at] = own[to].id;
    ids[to] = filter.id;
    state = AsyncData(
      await ref.read(viewPrefsRepositoryProvider).orderFilters(ids),
    );
  }
}

/// The deadline headings of My work, in the order they are drawn.
enum DueBucket {
  /// Past due.
  overdue,

  /// Due before tomorrow.
  today,

  /// Due within seven days.
  week,

  /// Due later.
  later,

  /// No due date.
  none,
}

/// The heading [due] falls under at [now], counting days in [style]'s
/// zone.
DueBucket dueBucket(
  DateTime? due,
  DateTime now, {
  TixTimeStyle style = TixTimeStyle.device,
}) {
  if (due == null) return DueBucket.none;
  if (due.isBefore(now)) return DueBucket.overdue;
  final today = style.day(now);
  DateTime midnight(int days) =>
      style.fromWall(DateTime(today.year, today.month, today.day + days));
  if (due.isBefore(midnight(1))) return DueBucket.today;
  if (due.isBefore(midnight(7))) return DueBucket.week;
  return DueBucket.later;
}

/// What the board draws for a query: one workflow's columns, or why it
/// cannot.
sealed class BoardLayout {
  const BoardLayout();
}

/// The columns of [workflow], arranged under the view [view].
final class BoardColumns extends BoardLayout {
  /// Columns of [workflow].
  const BoardColumns(this.workflow, this.view);

  /// The workflow whose states are the columns.
  final Workflow workflow;

  /// The view preferences name: `board` or `project:KEY`.
  final String view;
}

/// The projects run workflows that disagree.
final class BoardRefused extends BoardLayout {
  /// Names each distinct workflow and its projects.
  const BoardRefused(this.groups);

  /// Each workflow and the projects running it.
  final List<(Workflow, List<Project>)> groups;
}

/// The board for [query] over [context]: the projects it can draw from are
/// the scoped project, the `project:` terms, or every active project.
BoardLayout boardLayout(TaskQuery query, TaskIndex context) {
  final List<Project> projects;
  final String view;
  switch (query.scope) {
    case ProjectScope(:final key):
      projects = [?context.project(key)];
      view = 'project:${context.project(key)?.key ?? key}';
    default:
      final keys = filterTermValues(query.expression, 'project');
      projects = keys.isEmpty
          ? [
              for (final p in context.projects)
                if (p.archivedAt == null) p,
            ]
          : [for (final k in keys) ?context.project(k)];
      view = 'board';
  }
  final groups = <(Workflow, List<Project>)>[];
  for (final p in projects) {
    final w = context.workflowOfProject(p);
    if (w == null) continue;
    final at = groups.indexWhere((g) => g.$1.agreesWith(w));
    if (at < 0) {
      groups.add((w, [p]));
    } else {
      groups[at].$2.add(p);
    }
  }
  if (groups.length == 1) return BoardColumns(groups.single.$1, view);
  if (groups.isEmpty && context.workflows.isNotEmpty) {
    return BoardColumns(context.workflows.first, view);
  }
  return BoardRefused(groups);
}

/// The lanes of [tasks]: every project holding one, and every project a
/// `project:` term names, in the server's project order.
List<Project> laneProjects(
  List<Task> tasks,
  TaskQuery query,
  TaskIndex context,
) {
  final ids = {for (final t in tasks) t.projectId};
  final named = {
    for (final k in filterTermValues(query.expression, 'project'))
      k.toLowerCase(),
  };
  return [
    for (final p in context.projects)
      if (ids.contains(p.id) || named.contains(p.key.toLowerCase())) p,
  ];
}
