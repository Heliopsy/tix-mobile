// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/clock/clock.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/paging/paged.dart';
import 'package:tix_mobile/src/core/theme/layout.dart';
import 'package:tix_mobile/src/core/widgets/paged_list_view.dart';
import 'package:tix_mobile/src/data/models/group_pref.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/data/models/workflow.dart';
import 'package:tix_mobile/src/features/tasks/application/listing.dart';
import 'package:tix_mobile/src/features/tasks/application/screen.dart';
import 'package:tix_mobile/src/features/tasks/presentation/group_menu.dart';
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
  factory ListGroups.deadline(DateTime now, AppLocalizations l10n) =>
      ListGroups._(
        'mine',
        [for (final b in DueBucket.values) b.name],
        (t) => dueBucket(t.dueAt, now).name,
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
/// tick and star, a menu on long press, and picking for bulk actions.
class TaskListView extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = taskListingProvider(query);
    final selection = ref.watch(taskSelectionProvider(query.scope));
    final picking = selection.isNotEmpty;
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
      paged: paged.items.isEmpty ? const Paged<ListEntry>(items: []) : lines,
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
        RowEntry(:final task) => _Row(
          key: ValueKey(('row', task.id)),
          task: task,
          facts: factsFor(
            task,
            taskContext,
            handle: assigneeHandle(ref, task),
            showProject: query.scope is! ProjectScope,
          ),
          now: now,
          done: actions.isDone(task),
          picked: picking ? selection.contains(task.ref) : null,
          selected: task.ref == selectedRef,
          focused: task.ref == focusedRef,
          onTap: () => picking
              ? ref
                    .read(taskSelectionProvider(query.scope).notifier)
                    .toggle(task.ref)
              : onOpen(task),
          onPicked: (_) => ref
              .read(taskSelectionProvider(query.scope).notifier)
              .toggle(task.ref),
          onMenu: () => showTaskMenu(
            context,
            actions,
            task,
            onOpen: () => onOpen(task),
            onSelect: () => ref
                .read(taskSelectionProvider(query.scope).notifier)
                .toggle(task.ref),
          ),
          actions: actions,
          completeLabel: l10n.complete,
          snoozeLabel: l10n.snooze,
        ),
      },
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
    required this.onMenu,
    required this.actions,
    required this.completeLabel,
    required this.snoozeLabel,
    super.key,
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
  final VoidCallback onMenu;
  final TaskQuickActions actions;
  final String completeLabel;
  final String snoozeLabel;

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
      onLongPress: onMenu,
      onToggleDone: () => actions.toggleDone(task),
      onToggleStar: () => actions.toggleStar(task),
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
