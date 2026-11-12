// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/clock/clock.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/paging/paged.dart';
import 'package:tix_mobile/src/core/theme/layout.dart';
import 'package:tix_mobile/src/core/time/times.dart';
import 'package:tix_mobile/src/data/models/group_pref.dart';
import 'package:tix_mobile/src/data/models/project.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/features/tasks/application/listing.dart';
import 'package:tix_mobile/src/features/tasks/application/screen.dart';
import 'package:tix_mobile/src/features/tasks/presentation/board_view.dart';
import 'package:tix_mobile/src/features/tasks/presentation/group_menu.dart';
import 'package:tix_mobile/src/features/tasks/presentation/select_mode.dart';
import 'package:tix_mobile/src/features/tasks/presentation/task_actions.dart';

/// One lane per project, person, priority, tag or deadline, the way the web
/// draws Lanes: each lane its cards, each card ticked, its status a badge,
/// its menu on the dots. A lane's name narrows the screen to that lane. A
/// long press picks a card and turns select mode on.
class LanesView extends ConsumerWidget {
  /// Draws [paged] of the listing for [query] as lanes.
  const LanesView({
    required this.query,
    required this.paged,
    required this.onOpen,
    required this.showFinished,
    this.focusedRef,
    super.key,
  });

  /// The listing.
  final TaskQuery query;

  /// The cards loaded so far.
  final Paged<Task> paged;

  /// Opens a task.
  final ValueChanged<Task> onOpen;

  /// Whether finished cards are drawn.
  final bool showFinished;

  /// The card under the keyboard cursor.
  final String? focusedRef;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tix;
    final taskContext = ref.watch(taskContextProvider).value;
    if (taskContext == null) return const SkeletonList();
    final scope = query.scope;
    final by = lanesOf(ref.watch(taskScreenProvider(scope)), scope);
    final view = by.view;
    final prefs = ref.watch(viewArrangementProvider(view)).value ?? const {};
    final lanes = buildLanes(
      paged.items,
      by: by,
      query: query,
      context: taskContext,
      handleOf: (task) => assigneeHandle(ref, task),
      me: ref.watch(meProvider).value?.handle ?? '',
      now: ref.watch(clockProvider)(),
      style: context.times.style,
      prefs: prefs,
    );
    final byKey = {for (final l in lanes) l.key: l};
    final natural = [for (final l in lanes) l.key];
    final arranged = arrangeGroups(natural, prefs);
    String nameOf(Lane lane) => switch (by) {
      LaneGrouping.project => switch (lane.project) {
        final Project p when p.name.isNotEmpty => p.name,
        _ => lane.key,
      },
      LaneGrouping.assignee when lane.key == laneNone => l10n.unassigned,
      LaneGrouping.tag when lane.key == laneNone => l10n.lanesNoTag,
      LaneGrouping.priority => l10n.priorityLabel(
        '${lanePriorities.indexOf(lane.key) + 1}',
      ),
      LaneGrouping.due => switch (DueBucket.values.byName(lane.key)) {
        DueBucket.overdue => l10n.myWorkOverdue,
        DueBucket.today => l10n.myWorkToday,
        DueBucket.week => l10n.myWorkWeek,
        DueBucket.later => l10n.myWorkLater,
        DueBucket.none => l10n.myWorkNoDate,
      },
      _ => lane.label,
    };
    final actions = TaskQuickActions(context, ref, query);
    final now = ref.watch(clockProvider)();
    final selection = ref.watch(taskSelectionProvider(query.scope));
    final selector = ref.read(taskSelectionProvider(query.scope).notifier);
    bool shown(Task task) => showFinished || !actions.isDone(task);
    final order = [
      for (final key in arranged.visible)
        if (byKey[key] case final Lane l when !(prefs[key]?.collapsed ?? false))
          for (final task in l.tasks)
            if (shown(task)) task.ref,
    ];
    final compact = context.isCompact;
    final width = compact
        ? MediaQuery.sizeOf(context).width * 0.86
        : boardColumnWidth;
    Widget lane(Lane lane) {
      final pref = prefs[lane.key] ?? GroupPref(group: lane.key);
      final tasks = [
        for (final task in lane.tasks)
          if (shown(task)) task,
      ];
      final project = lane.project;
      final name = nameOf(lane);
      final stripe = project == null ? null : t.projectColour(project.color);
      return Container(
        key: ValueKey(('lane', lane.key)),
        width: pref.collapsed ? boardStripWidth : width,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(TixRadius.lg),
          border: Border.all(color: t.line),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: stripe ?? Colors.transparent, width: 3),
            ),
          ),
          child: pref.collapsed
              ? Column(
                  children: [
                    GroupMenu(
                      view: view,
                      group: lane.key,
                      label: name,
                      natural: natural,
                    ),
                    Text(
                      '${tasks.length}',
                      style: TextStyle(fontSize: TixText.xs, color: t.muted),
                    ),
                    Expanded(
                      child: RotatedBox(
                        quarterTurns: 1,
                        child: Text(name, maxLines: 1),
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        TixSpace.s3,
                        TixSpace.s1,
                        0,
                        0,
                      ),
                      child: Row(
                        children: [
                          if (project != null) ...[
                            ProjectMark(
                              name: name,
                              colour: project.color,
                              icon: project.icon,
                            ),
                            const SizedBox(width: TixSpace.s2),
                          ],
                          Flexible(
                            child: _LaneName(
                              key: Key('lane.head.${lane.key}'),
                              name: name,
                              onTap: lane.term.isEmpty
                                  ? null
                                  : () => ref
                                        .read(
                                          taskScreenProvider(scope).notifier,
                                        )
                                        .showLane(lane.term),
                            ),
                          ),
                          const SizedBox(width: TixSpace.s2),
                          Text(
                            '${tasks.length}',
                            style: TextStyle(
                              fontSize: TixText.xs,
                              color: t.muted,
                            ),
                          ),
                          if (pref.starred) ...[
                            const SizedBox(width: TixSpace.s1),
                            Icon(Icons.star_rounded, size: 14, color: t.accent),
                          ],
                          const Spacer(),
                          GroupMenu(
                            view: view,
                            group: lane.key,
                            label: name,
                            natural: natural,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: tasks.isEmpty
                          ? Center(
                              child: Text(
                                l10n.lanesEmpty,
                                style: TextStyle(
                                  color: t.muted,
                                  fontSize: TixText.xs,
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(
                                TixSpace.s2,
                                0,
                                TixSpace.s2,
                                TixSpace.s2,
                              ),
                              itemCount: tasks.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: TixSpace.s2),
                              itemBuilder: (_, i) {
                                final task = tasks[i];
                                return TaskCard(
                                  key: Key('card.${task.ref}'),
                                  task: task,
                                  facts: factsFor(
                                    task,
                                    taskContext,
                                    handle: assigneeHandle(ref, task),
                                    sync: syncMarkOf(ref, task),
                                    showProject:
                                        by != LaneGrouping.project &&
                                        scope is! ProjectScope,
                                  ),
                                  now: now,
                                  selected: task.ref == focusedRef,
                                  picked: selection.active
                                      ? selection.contains(task.ref)
                                      : null,
                                  onPicked: (_) => selector.toggle(task.ref),
                                  onTap: () => tapTask(
                                    ref,
                                    query.scope,
                                    task.ref,
                                    order: order,
                                    open: () => onOpen(task),
                                  ),
                                  onToggleDone: () => actions.toggleDone(task),
                                  onLongPress: () =>
                                      longPressTask(ref, query.scope, task.ref),
                                  onMore: () => showTaskMenu(
                                    context,
                                    actions,
                                    task,
                                    onOpen: () => onOpen(task),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.refresh(taskListingProvider(query).future),
      notificationPredicate: (n) => n.depth == 1,
      child: ListView(
        key: const Key('lanes'),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(
          TixSpace.s4,
          0,
          TixSpace.s4,
          TixSpace.s4,
        ),
        children: [
          for (final key in arranged.visible)
            if (byKey[key] case final Lane l) ...[
              lane(l),
              const SizedBox(width: TixSpace.s3),
            ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HiddenGroups(
                view: view,
                hidden: arranged.hidden,
                labelOf: (g) => switch (byKey[g]) {
                  final Lane l => nameOf(l),
                  null => g,
                },
              ),
              if (paged.hasMore)
                Padding(
                  padding: const EdgeInsets.all(TixSpace.s2),
                  child: TixButton(
                    key: const Key('lanes.more'),
                    label: l10n.boardLoadMore,
                    size: TixButtonSize.small,
                    busy: paged.loadingMore,
                    onPressed: () => ref
                        .read(taskListingProvider(query).notifier)
                        .loadMore(),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A lane's name: a link that narrows the screen to the lane when [onTap]
/// is given, as the web's lane heading is.
class _LaneName extends StatelessWidget {
  const _LaneName({required this.name, this.onTap, super.key});

  final String name;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      name,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: TixText.sm, fontWeight: FontWeight.w600),
    );
    final tap = onTap;
    if (tap == null) return text;
    final hint = context.l10n.lanesOnly(name);
    return Semantics(
      button: true,
      hint: hint,
      child: Tooltip(
        message: hint,
        child: InkWell(
          onTap: tap,
          borderRadius: BorderRadius.circular(TixRadius.sm),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 32),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              widthFactor: 1,
              child: text,
            ),
          ),
        ),
      ),
    );
  }
}
