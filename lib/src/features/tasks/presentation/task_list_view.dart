// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/clock/clock.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/paging/paged.dart';
import 'package:tix_mobile/src/core/theme/layout.dart';
import 'package:tix_mobile/src/core/time/times.dart';
import 'package:tix_mobile/src/core/widgets/paged_list_view.dart';
import 'package:tix_mobile/src/data/models/group_pref.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/data/models/workflow.dart';
import 'package:tix_mobile/src/features/tasks/application/listing.dart';
import 'package:tix_mobile/src/features/tasks/application/screen.dart';
import 'package:tix_mobile/src/features/tasks/presentation/group_menu.dart';
import 'package:tix_mobile/src/features/tasks/presentation/select_mode.dart';
import 'package:tix_mobile/src/features/tasks/presentation/task_actions.dart';

/// One line of a grouped list: a heading or a task.
sealed class ListEntry {
  const ListEntry();
}

/// A group's heading.
final class HeadingEntry extends ListEntry {
  /// Heads [group].
  const HeadingEntry({
    required this.view,
    required this.group,
    required this.label,
    required this.count,
    required this.natural,
    this.category,
  });

  /// The view its arrangement is kept under.
  final String view;

  /// The group.
  final String group;

  /// How it reads.
  final String label;

  /// How many loaded rows it holds.
  final int count;

  /// The view's groups in natural order.
  final List<String> natural;

  /// The status category, for a status heading.
  final StatusCategory? category;
}

/// The hidden groups of a view, at the top of the list.
final class HiddenEntry extends ListEntry {
  /// Lists [hidden] of [view].
  const HiddenEntry(this.view, this.hidden, this.labels);

  /// The view.
  final String view;

  /// The hidden groups.
  final List<String> hidden;

  /// How each group reads.
  final Map<String, String> labels;
}

/// A task.
final class RowEntry extends ListEntry {
  /// Draws [task].
  const RowEntry(this.task);

  /// The task.
  final Task task;
}

/// How a list groups its rows, worked out from the scope and the screen.
class ListGroups {
  const ListGroups._(this.view, this.natural, this.keyOf, this.labelOf);

  /// Groups by status, in the workflows' declared order.
  factory ListGroups.status(TaskScope scope, TaskIndex context) {
    final states = <String, String>{};
    for (final w in context.workflows) {
      for (final s in w.states) {
        states.putIfAbsent(s.id, () => s.name);
      }
    }
    return ListGroups._(
      scope is ProjectScope
          ? 'project:${context.project(scope.key)?.key ?? scope.key}'
          : 'board',
      states.keys.toList(),
      (t) => t.status,
      (g) => states[g] ?? g,
    );
  }

  /// Groups by project, in the server's project order.
  factory ListGroups.project(TaskIndex context) => ListGroups._(
    'lanes',
    [for (final p in context.projects) p.key],
    (t) => context.projectOf(t)?.key ?? '',
    (g) {
      final p = context.project(g);
      return p == null || p.name.isEmpty ? g : p.name;
    },
  );

  /// Groups by deadline, as My work does.
  factory ListGroups.deadline(
    DateTime now,
    AppLocalizations l10n, {
    TixTimeStyle style = TixTimeStyle.device,
  }) => ListGroups._(
    'mine',
    [for (final b in DueBucket.values) b.name],
    (t) => dueBucket(t.dueAt, now, style: style).name,
    (g) => switch (DueBucket.values.byName(g)) {
      DueBucket.overdue => l10n.myWorkOverdue,
      DueBucket.today => l10n.myWorkToday,
      DueBucket.week => l10n.myWorkWeek,
      DueBucket.later => l10n.myWorkLater,
      DueBucket.none => l10n.myWorkNoDate,
    },
  );

  /// The view the arrangement is kept under; empty for no headings.
  final String view;

  /// The groups in the view's own order.
  final List<String> natural;

  /// The group a task falls in.
  final String Function(Task) keyOf;

  /// How a group reads.
  final String Function(String) labelOf;

  /// No headings.
  static const none = ListGroups._('', [], _noKey, _noLabel);

  static String _noKey(Task _) => '';
  static String _noLabel(String _) => '';
}

/// [tasks] as list lines under [groups], arranged by [prefs]: collapsed
/// groups keep their heading, hidden ones go, empty ones are left out.
List<ListEntry> buildListEntries(
  List<Task> tasks,
  ListGroups groups,
  Map<String, GroupPref> prefs, {
  StatusCategory? Function(String group)? categoryOf,
}) {
  if (groups.view.isEmpty) return [for (final t in tasks) RowEntry(t)];
  final byGroup = <String, List<Task>>{};
  for (final t in tasks) {
    (byGroup[groups.keyOf(t)] ??= []).add(t);
  }
  final natural = [
    ...groups.natural,
    for (final g in byGroup.keys)
      if (!groups.natural.contains(g)) g,
  ];
  final arranged = arrangeGroups(natural, prefs);
  final hidden = [
    for (final g in arranged.hidden)
      if (byGroup.containsKey(g)) g,
  ];
  return [
    if (hidden.isNotEmpty || prefs.isNotEmpty)
      HiddenEntry(groups.view, hidden, {
        for (final g in hidden) g: groups.labelOf(g),
      }),
    for (final g in arranged.visible)
      if (byGroup[g] case final List<Task> rows) ...[
        HeadingEntry(
          view: groups.view,
          group: g,
          label: groups.labelOf(g),
          count: rows.length,
          natural: natural,
          category: categoryOf?.call(g),
        ),
        if (!(prefs[g]?.collapsed ?? false))
          for (final t in rows) RowEntry(t),
      ],
  ];
}

/// The rows of one listing: paged, grouped when asked, with swipes, the
/// tick and star, status and priority that open their pickers, a menu on
/// the dots or a secondary click, and select mode for bulk actions, entered
/// with a long press.
///
/// A row just ticked done keeps its place for [TixMotion.settle] so its
/// tick and strike-through can play, then moves to where the listing now
/// puts it, or collapses away when the listing no longer holds it. With
/// reduced motion it moves or goes at once.
class TaskListView extends ConsumerStatefulWidget {
  /// Lists [entries] of the listing for [query].
  const TaskListView({
    required this.query,
    required this.paged,
    required this.entries,
    required this.onOpen,
    required this.empty,
    this.selectedRef,
    this.focusedRef,
    super.key,
  });

  /// The listing.
  final TaskQuery query;

  /// The rows loaded so far.
  final Paged<Task> paged;

  /// The lines to draw, from [buildListEntries].
  final List<ListEntry> entries;

  /// Opens a task.
  final ValueChanged<Task> onOpen;

  /// Shown when nothing matches.
  final Widget empty;

  /// The task open beside the list.
  final String? selectedRef;

  /// The task under the keyboard cursor.
  final String? focusedRef;

  @override
  ConsumerState<TaskListView> createState() => _TaskListViewState();
}

Object _keyOf(ListEntry e) => switch (e) {
  RowEntry(:final task) => ('row', task.id),
  HeadingEntry(:final group) => ('heading', group),
  HiddenEntry() => 'hidden',
};

/// A row kept where it was drawn: [after] is the line it followed, and
/// [leaving] says it has left the listing and collapses once its tick has
/// played.
@immutable
class _Hold {
  const _Hold(this.entry, {required this.after, required this.leaving});

  final RowEntry entry;
  final Object? after;
  final bool leaving;
}

class _TaskListViewState extends ConsumerState<TaskListView> {
  /// Tasks ticked done while this list was drawn, so a ticked row that the
  /// next listing leaves out still gets its hold and collapse. A refresh never
  /// draws the cached page again (the cache answers each key once), so a tick
  /// does not step back while the server's page is on its way.
  final _ticked = <String>{};
  final _held = <String, _Hold>{};
  List<ListEntry> _drawn = const [];

  bool _isDone(Task task) =>
      ref.read(taskContextProvider).value?.isFinished(task) ?? isTaskDone(task);

  @override
  void didUpdateWidget(TaskListView old) {
    super.didUpdateWidget(old);
    if (old.query != widget.query ||
        TixMotion.of(context, TixMotion.settle) == Duration.zero) {
      _ticked.clear();
      _held.clear();
      return;
    }
    final next = <String, (int, Task)>{
      for (final (i, e) in widget.entries.indexed)
        if (e is RowEntry) e.task.id: (i, e.task),
    };
    Object? before;
    for (final e in _drawn) {
      if (e is! RowEntry) {
        before = _keyOf(e);
        continue;
      }
      final id = e.task.id;
      final held = _held[id];
      final anchor = before;
      if (held == null || !held.leaving) before = _keyOf(e);
      if (held != null && held.leaving) continue;
      final now = next[id];
      if (now == null) {
        if (_ticked.contains(id)) {
          _held[id] = _Hold(e, after: anchor, leaving: true);
        }
        continue;
      }
      final (at, task) = now;
      final was = _isDone(e.task);
      final done = _isDone(task);
      if (was && !done) {
        _held.remove(id);
        continue;
      }
      if (!was && done) {
        _ticked.add(id);
        final moved =
            (at == 0 ? null : _keyOf(widget.entries[at - 1])) != anchor;
        if (moved) {
          _held[id] = _Hold(RowEntry(task), after: anchor, leaving: false);
        }
        continue;
      }
      if (held != null && !identical(held.entry.task, task)) {
        _held[id] = _Hold(RowEntry(task), after: held.after, leaving: false);
      }
    }
  }

  List<ListEntry> _merge(List<ListEntry> entries) {
    if (_held.isEmpty) return entries;
    final out = [
      for (final e in entries)
        if (e is! RowEntry || !_held.containsKey(e.task.id)) e,
    ];
    for (final hold in _held.values) {
      final at = hold.after == null
          ? 0
          : out.indexWhere((e) => _keyOf(e) == hold.after) + 1;
      out.insert(at, hold.entry);
    }
    return out;
  }

  void _release(String id) {
    if (mounted && _held.containsKey(id)) setState(() => _held.remove(id));
  }

  @override
  Widget build(BuildContext context) {
    final TaskListView(
      :query,
      :paged,
      :onOpen,
      :empty,
      :selectedRef,
      :focusedRef,
    ) = widget;
    final entries = _drawn = _merge(widget.entries);
    final provider = taskListingProvider(query);
    final selection = ref.watch(taskSelectionProvider(query.scope));
    final picking = selection.active;
    final selector = ref.read(taskSelectionProvider(query.scope).notifier);
    final order = [
      for (final e in widget.entries)
        if (e is RowEntry) e.task.ref,
    ];
    final taskContext = ref.watch(taskContextProvider).value;
    final now = ref.watch(clockProvider)();
    final actions = TaskQuickActions(context, ref, query);
    final l10n = context.l10n;
    final lines = Paged<ListEntry>(
      items: entries,
      cursor: paged.cursor,
      loadingMore: paged.loadingMore,
      moreError: paged.moreError,
    );
    return PagedListView<ListEntry>(
      paged: paged.items.isEmpty && _held.isEmpty
          ? const Paged<ListEntry>(items: [])
          : lines,
      padding: EdgeInsets.only(bottom: context.isCompact ? 96 : TixSpace.s5),
      empty: empty,
      onRefresh: () => ref.refresh(provider.future),
      onLoadMore: () => ref.read(provider.notifier).loadMore(),
      itemBuilder: (context, entry) => switch (entry) {
        HiddenEntry(:final view, :final hidden, :final labels) => Align(
          alignment: AlignmentDirectional.centerEnd,
          child: HiddenGroups(
            view: view,
            hidden: hidden,
            labelOf: (g) => labels[g] ?? g,
          ),
        ),
        HeadingEntry() => GroupHeading(
          key: ValueKey(('heading', entry.group)),
          view: entry.view,
          group: entry.group,
          label: entry.label,
          count: entry.count,
          natural: entry.natural,
          leading: entry.category == null
              ? null
              : StatusPill(label: entry.label, category: entry.category),
        ),
        RowEntry(:final task) => _Slot(
          key: ValueKey(('row', task.id)),
          hold: _held[task.id],
          onReleased: () => _release(task.id),
          child: _Row(
            task: task,
            facts: factsFor(
              task,
              taskContext,
              handle: assigneeHandle(ref, task),
              sync: syncMarkOf(ref, task),
              showProject: query.scope is! ProjectScope,
            ),
            now: now,
            done: actions.isDone(task),
            picked: picking ? selection.contains(task.ref) : null,
            selected: task.ref == selectedRef,
            focused: task.ref == focusedRef,
            onTap: () => tapTask(
              ref,
              query.scope,
              task.ref,
              order: order,
              open: () => onOpen(task),
            ),
            onPicked: (_) => selector.toggle(task.ref),
            onLongPress: () => longPressTask(ref, query.scope, task.ref),
            onMenu: () => showTaskMenu(
              context,
              actions,
              task,
              onOpen: () => onOpen(task),
              onSelect: () => selector.toggle(task.ref),
            ),
            actions: actions,
            completeLabel: l10n.complete,
            snoozeLabel: l10n.snooze,
          ),
        ),
      },
    );
  }
}

/// A row's place in the list: as drawn, or held by a [_Hold] until
/// [TixMotion.settle] has passed, then collapsed when it is leaving, and
/// [onReleased] called. A hold that turns into a leaving one starts again.
/// The structure never changes with the hold, so the row under it keeps its
/// state and its tick goes on playing.
class _Slot extends StatefulWidget {
  const _Slot({
    required this.hold,
    required this.onReleased,
    required this.child,
    super.key,
  });

  final _Hold? hold;
  final VoidCallback onReleased;
  final Widget child;

  @override
  State<_Slot> createState() => _SlotState();
}

class _SlotState extends State<_Slot> with SingleTickerProviderStateMixin {
  late final AnimationController _timer = AnimationController(vsync: this)
    ..addStatusListener((s) {
      if (s == AnimationStatus.completed && widget.hold != null) {
        widget.onReleased();
      }
    });
  double _collapseFrom = 1;
  bool? _running;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _start();
  }

  @override
  void didUpdateWidget(_Slot old) {
    super.didUpdateWidget(old);
    _start();
  }

  void _start() {
    final hold = widget.hold;
    final kind = hold?.leaving;
    if (kind == _running) return;
    _running = kind;
    if (hold == null) {
      _timer.value = 0;
      return;
    }
    final settle = TixMotion.of(context, TixMotion.settle);
    final collapse = hold.leaving
        ? TixMotion.of(context, TixMotion.base)
        : Duration.zero;
    final total = settle + collapse;
    if (total == Duration.zero) {
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onReleased());
      return;
    }
    _collapseFrom = settle.inMicroseconds / total.inMicroseconds;
    _timer.duration = total;
    _timer.forward(from: 0);
  }

  @override
  void dispose() {
    _timer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leaving = widget.hold?.leaving ?? false;
    return IgnorePointer(
      ignoring: leaving,
      child: AnimatedBuilder(
        animation: _timer,
        builder: (context, child) {
          final gone = leaving && _collapseFrom < 1
              ? Interval(
                  _collapseFrom,
                  1,
                  curve: TixMotion.ease,
                ).transform(_timer.value)
              : 0.0;
          return ClipRect(
            child: Align(
              alignment: AlignmentDirectional.topStart,
              heightFactor: 1 - gone,
              child: Opacity(opacity: 1 - gone, child: child),
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.task,
    required this.facts,
    required this.now,
    required this.done,
    required this.picked,
    required this.selected,
    required this.focused,
    required this.onTap,
    required this.onPicked,
    required this.onLongPress,
    required this.onMenu,
    required this.actions,
    required this.completeLabel,
    required this.snoozeLabel,
  });

  final Task task;
  final TaskFacts facts;
  final DateTime now;
  final bool done;
  final bool? picked;
  final bool selected;
  final bool focused;
  final VoidCallback onTap;
  final ValueChanged<bool> onPicked;
  final VoidCallback onLongPress;
  final VoidCallback onMenu;
  final TaskQuickActions actions;
  final String completeLabel;
  final String snoozeLabel;

  VoidCallback? _edit(Future<void> Function(Task) edit) {
    if (picked != null) return null;
    return () {
      if (pickKeyHeld()) {
        onTap();
      } else {
        unawaited(edit(task));
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    final row = TaskRow(
      task: task,
      facts: facts,
      now: now,
      selected: selected,
      focused: focused,
      picked: picked,
      onPicked: onPicked,
      onTap: onTap,
      onLongPress: onLongPress,
      onMore: onMenu,
      onToggleDone: () => actions.toggleDone(task),
      onToggleStar: () => actions.toggleStar(task),
      onStatusTap: _edit(actions.pickMove),
      onPriorityTap: _edit(actions.setPriority),
    );
    if (picked != null) return row;
    return TixSwipeActions(
      id: task.id,
      start: done
          ? null
          : TixSwipeAction.complete(
              completeLabel,
              () => actions.toggleDone(task),
            ),
      end: TixSwipeAction.snooze(snoozeLabel, () => actions.snooze(task)),
      child: row,
    );
  }
}
