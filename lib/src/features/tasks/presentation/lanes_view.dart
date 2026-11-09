// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/clock/clock.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/paging/paged.dart';
import 'package:tix_mobile/src/core/theme/layout.dart';
import 'package:tix_mobile/src/data/models/group_pref.dart';
import 'package:tix_mobile/src/data/models/project.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/features/tasks/application/listing.dart';
import 'package:tix_mobile/src/features/tasks/application/screen.dart';
import 'package:tix_mobile/src/features/tasks/presentation/board_view.dart';
import 'package:tix_mobile/src/features/tasks/presentation/group_menu.dart';
import 'package:tix_mobile/src/features/tasks/presentation/select_mode.dart';
import 'package:tix_mobile/src/features/tasks/presentation/task_actions.dart';

/// One lane per project, the way the web draws Lanes: each lane the
/// project's cards, each card ticked, its status a badge, its menu on the
/// dots. A long press picks a card and turns select mode on.
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
    const view = 'lanes';
    final prefs = ref.watch(viewArrangementProvider(view)).value ?? const {};
    final projects = laneProjects(paged.items, query, taskContext);
    final byKey = {for (final p in projects) p.key: p};
    final natural = [for (final p in projects) p.key];
    final arranged = arrangeGroups(natural, prefs);
    final actions = TaskQuickActions(context, ref, query);
    final now = ref.watch(clockProvider)();
    final selection = ref.watch(taskSelectionProvider(query.scope));
    final selector = ref.read(taskSelectionProvider(query.scope).notifier);
    bool shown(Task task) => showFinished || !actions.isDone(task);
    final order = [
      for (final key in arranged.visible)
        if (byKey[key] case final Project p
            when !(prefs[key]?.collapsed ?? false))
          for (final task in paged.items)
            if (task.projectId == p.id && shown(task)) task.ref,
    ];
    final compact = context.isCompact;
    final width = compact
        ? MediaQuery.sizeOf(context).width * 0.86
        : boardColumnWidth;
    Widget lane(Project project) {
      final pref = prefs[project.key] ?? GroupPref(group: project.key);
      final tasks = [
        for (final task in paged.items)
          if (task.projectId == project.id && shown(task)) task,
      ];
      final name = project.name.isEmpty ? project.key : project.name;
      final stripe = t.projectColour(project.color);
      return Container(
        key: ValueKey(('lane', project.key)),
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
                      group: project.key,
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
                          ProjectMark(
                            name: name,
                            colour: project.color,
                            icon: project.icon,
                          ),
                          const SizedBox(width: TixSpace.s2),
                          Flexible(
                            child: Text(
                              name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: TixText.sm,
                                fontWeight: FontWeight.w600,
                              ),
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
                            group: project.key,
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
                                    showProject: false,
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
            if (byKey[key] case final Project p) ...[
              lane(p),
              const SizedBox(width: TixSpace.s3),
            ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HiddenGroups(
                view: view,
                hidden: arranged.hidden,
                labelOf: (g) {
                  final p = byKey[g];
                  return p == null || p.name.isEmpty ? g : p.name;
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
