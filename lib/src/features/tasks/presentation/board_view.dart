// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/clock/clock.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/paging/paged.dart';
import 'package:tix_mobile/src/core/theme/layout.dart';
import 'package:tix_mobile/src/data/models/group_pref.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/data/models/workflow.dart';
import 'package:tix_mobile/src/features/tasks/application/listing.dart';
import 'package:tix_mobile/src/features/tasks/application/screen.dart';
import 'package:tix_mobile/src/features/tasks/presentation/group_menu.dart';
import 'package:tix_mobile/src/features/tasks/presentation/select_mode.dart';
import 'package:tix_mobile/src/features/tasks/presentation/task_actions.dart';

/// How wide a column is on a wide window.
const boardColumnWidth = 300.0;

/// How wide a collapsed column's strip is.
const boardStripWidth = 52.0;

/// A workflow's states as columns of cards. A card is dragged to another
/// column to move it; only the columns its own workflow reaches light up.
/// In select mode a tap picks a card and nothing drags.
class BoardView extends ConsumerStatefulWidget {
  /// Draws [paged] of the listing for [query] as [layout]'s columns.
  const BoardView({
    required this.query,
    required this.paged,
    required this.layout,
    required this.onOpen,
    this.focusedRef,
    super.key,
  });

  /// The listing.
  final TaskQuery query;

  /// The cards loaded so far.
  final Paged<Task> paged;

  /// The workflow whose states are the columns.
  final BoardColumns layout;

  /// Opens a task.
  final ValueChanged<Task> onOpen;

  /// The card under the keyboard cursor.
  final String? focusedRef;

  @override
  ConsumerState<BoardView> createState() => _BoardViewState();
}

class _BoardViewState extends ConsumerState<BoardView> {
  final _dragging = ValueNotifier<Task?>(null);

  @override
  void dispose() {
    _dragging.dispose();
    super.dispose();
  }

  Set<String> _reach(Task task, TaskIndex? context) {
    final workflow = context?.workflowOf(task) ?? widget.layout.workflow;
    return workflow.reachableFrom(task.status);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final workflow = widget.layout.workflow;
    final view = widget.layout.view;
    final prefs = ref.watch(viewArrangementProvider(view)).value ?? const {};
    final taskContext = ref.watch(taskContextProvider).value;
    final states = {for (final s in workflow.states) s.id: s};
    final natural = [for (final s in workflow.states) s.id];
    final arranged = arrangeGroups(natural, prefs);
    final byStatus = <String, List<Task>>{};
    final strays = <Task>[];
    for (final t in widget.paged.items) {
      if (states.containsKey(t.status)) {
        (byStatus[t.status] ??= []).add(t);
      } else {
        strays.add(t);
      }
    }
    final actions = TaskQuickActions(context, ref, widget.query);
    final scope = widget.query.scope;
    final selection = ref.watch(taskSelectionProvider(scope));
    final selector = ref.read(taskSelectionProvider(scope).notifier);
    final order = [
      for (final key in arranged.visible)
        if (!(prefs[key]?.collapsed ?? false))
          for (final t in byStatus[key] ?? const <Task>[]) t.ref,
    ];
    final compact = context.isCompact;
    final width = MediaQuery.sizeOf(context).width;
    final columnWidth = compact ? width * 0.86 : boardColumnWidth;
    Widget column(String key) {
      final state = states[key]!;
      final pref = prefs[key] ?? GroupPref(group: key);
      return _Column(
        key: ValueKey(('column', key)),
        state: state,
        category: statusCategoryOf(state.resolvedCategory(workflow.initial)),
        tasks: byStatus[key] ?? const [],
        more: widget.paged.hasMore,
        pref: pref,
        width: pref.collapsed ? boardStripWidth : columnWidth,
        view: view,
        natural: natural,
        dragging: _dragging,
        accepts: (task) =>
            task.status != key && _reach(task, taskContext).contains(key),
        onDrop: (task) => actions.move(task, state),
        card: (task) => _BoardCard(
          task: task,
          facts: factsFor(
            task,
            taskContext,
            handle: assigneeHandle(ref, task),
            holder: holderHandle(ref, task),
            sync: syncMarkOf(ref, task),
            showProject: widget.query.scope is! ProjectScope,
          ),
          now: ref.watch(clockProvider)(),
          focused: task.ref == widget.focusedRef,
          compact: compact,
          dragging: _dragging,
          picked: selection.active ? selection.contains(task.ref) : null,
          onTap: () => tapTask(
            ref,
            scope,
            task.ref,
            order: order,
            open: () => widget.onOpen(task),
          ),
          onPick: () => longPressTask(ref, scope, task.ref),
          onPicked: (_) => selector.toggle(task.ref),
          onMenu: () => showTaskMenu(
            context,
            actions,
            task,
            onOpen: () => widget.onOpen(task),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (strays.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: TixSpace.s4),
            child: Text(
              l10n.boardStrays(strays.map((t) => t.ref).join(', ')),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () =>
                ref.refresh(taskListingProvider(widget.query).future),
            notificationPredicate: (n) => n.depth == 1,
            child: ListView(
              key: const Key('board'),
              scrollDirection: Axis.horizontal,
              physics: compact ? _SnapPhysics(columnWidth + TixSpace.s3) : null,
              padding: const EdgeInsets.fromLTRB(
                TixSpace.s4,
                0,
                TixSpace.s4,
                TixSpace.s4,
              ),
              children: [
                for (final key in arranged.visible) ...[
                  column(key),
                  const SizedBox(width: TixSpace.s3),
                ],
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HiddenGroups(
                      view: view,
                      hidden: arranged.hidden,
                      labelOf: (g) => states[g]?.name ?? g,
                    ),
                    if (widget.paged.hasMore)
                      Padding(
                        padding: const EdgeInsets.all(TixSpace.s2),
                        child: TixButton(
                          key: const Key('board.more'),
                          label: l10n.boardLoadMore,
                          size: TixButtonSize.small,
                          busy: widget.paged.loadingMore,
                          onPressed: () => ref
                              .read(taskListingProvider(widget.query).notifier)
                              .loadMore(),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SnapPhysics extends ScrollPhysics {
  const _SnapPhysics(this.extent, {super.parent});

  final double extent;

  @override
  _SnapPhysics applyTo(ScrollPhysics? ancestor) =>
      _SnapPhysics(extent, parent: buildParent(ancestor));

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    if ((velocity <= 0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    var page = position.pixels / extent;
    if (velocity < -toleranceFor(position).velocity) {
      page = page.floorToDouble();
    } else if (velocity > toleranceFor(position).velocity) {
      page = page.ceilToDouble();
    } else {
      page = page.roundToDouble();
    }
    final target = (page * extent).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    final tolerance = toleranceFor(position);
    if ((target - position.pixels).abs() < tolerance.distance) return null;
    return ScrollSpringSimulation(
      spring,
      position.pixels,
      target,
      velocity,
      tolerance: toleranceFor(position),
    );
  }
}

class _Column extends ConsumerWidget {
  const _Column({
    required this.state,
    required this.category,
    required this.tasks,
    required this.more,
    required this.pref,
    required this.width,
    required this.view,
    required this.natural,
    required this.dragging,
    required this.accepts,
    required this.onDrop,
    required this.card,
    super.key,
  });

  final WorkflowState state;
  final StatusCategory category;
  final List<Task> tasks;
  final bool more;
  final GroupPref pref;
  final double width;
  final String view;
  final List<String> natural;
  final ValueNotifier<Task?> dragging;
  final bool Function(Task) accepts;
  final void Function(Task) onDrop;
  final Widget Function(Task) card;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tix;
    final count = more ? '${tasks.length}+' : '${tasks.length}';
    return DragTarget<Task>(
      onWillAcceptWithDetails: (d) => accepts(d.data),
      onMove: (_) {},
      onAcceptWithDetails: (d) => onDrop(d.data),
      builder: (context, candidates, _) => ValueListenableBuilder<Task?>(
        valueListenable: dragging,
        builder: (context, moving, _) {
          final open = moving != null && accepts(moving);
          final over = candidates.isNotEmpty;
          return AnimatedContainer(
            duration: TixMotion.of(context, TixMotion.fast),
            width: width,
            decoration: BoxDecoration(
              color: over ? t.accentSoft : t.surface,
              borderRadius: BorderRadius.circular(TixRadius.lg),
              border: Border.all(
                color: over
                    ? t.accent
                    : open
                    ? t.accent.withValues(alpha: 0.5)
                    : t.line,
                width: over || open ? 2 : 1,
              ),
            ),
            child: pref.collapsed
                ? _Strip(
                    state: state,
                    count: count,
                    view: view,
                    natural: natural,
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
                            StatusPill(label: state.name, category: category),
                            const SizedBox(width: TixSpace.s2),
                            Text(
                              count,
                              key: Key('column.${state.id}.count'),
                              style: TextStyle(
                                fontSize: TixText.xs,
                                color: t.muted,
                              ),
                            ),
                            if (pref.starred) ...[
                              const SizedBox(width: TixSpace.s1),
                              Icon(
                                Icons.star_rounded,
                                size: 14,
                                color: t.accent,
                              ),
                            ],
                            const Spacer(),
                            GroupMenu(
                              view: view,
                              group: state.id,
                              label: state.name,
                              natural: natural,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: tasks.isEmpty
                            ? Center(
                                child: Text(
                                  context.l10n.boardColumnEmpty,
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
                                itemBuilder: (_, i) => card(tasks[i]),
                              ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

class _Strip extends StatelessWidget {
  const _Strip({
    required this.state,
    required this.count,
    required this.view,
    required this.natural,
  });

  final WorkflowState state;
  final String count;
  final String view;
  final List<String> natural;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    return Column(
      children: [
        GroupMenu(
          view: view,
          group: state.id,
          label: state.name,
          natural: natural,
        ),
        Text(
          count,
          style: TextStyle(fontSize: TixText.xs, color: t.muted),
        ),
        const SizedBox(height: TixSpace.s2),
        Expanded(
          child: RotatedBox(
            quarterTurns: 1,
            child: Text(
              state.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: TixText.sm,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BoardCard extends StatelessWidget {
  const _BoardCard({
    required this.task,
    required this.facts,
    required this.now,
    required this.focused,
    required this.compact,
    required this.dragging,
    required this.picked,
    required this.onTap,
    required this.onPick,
    required this.onPicked,
    required this.onMenu,
  });

  final Task task;
  final TaskFacts facts;
  final DateTime now;
  final bool focused;
  final bool compact;
  final ValueNotifier<Task?> dragging;
  final bool? picked;
  final VoidCallback onTap;
  final VoidCallback onPick;
  final ValueChanged<bool> onPicked;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final card = TaskCard(
      key: Key('card.${task.ref}'),
      task: task,
      facts: facts,
      now: now,
      selected: focused,
      showStatus: false,
      picked: picked,
      onPicked: onPicked,
      onOpenRef: (r) => openTaskRef(context, r),
      onTap: onTap,
      onLongPress: compact ? null : onPick,
      onMore: onMenu,
    );
    if (picked != null) return card;
    final feedback = Material(
      color: Colors.transparent,
      child: SizedBox(
        width: compact
            ? MediaQuery.sizeOf(context).width * 0.8
            : boardColumnWidth - TixSpace.s4,
        child: Opacity(opacity: 0.92, child: card),
      ),
    );
    final ghost = Opacity(opacity: 0.35, child: card);
    void start() {
      dragging.value = task;
      unawaited(TixHaptics.tick());
    }

    void end() => dragging.value = null;
    if (compact) {
      return LongPressDraggable<Task>(
        data: task,
        feedback: feedback,
        childWhenDragging: ghost,
        onDragStarted: start,
        onDragEnd: (_) => end(),
        onDraggableCanceled: (_, offset) {
          end();
          if (_stayed(context, offset)) onPick();
        },
        child: card,
      );
    }
    return Draggable<Task>(
      data: task,
      feedback: feedback,
      childWhenDragging: ghost,
      onDragStarted: start,
      onDragEnd: (_) => end(),
      onDraggableCanceled: (_, _) => end(),
      child: card,
    );
  }
}

/// Whether a long press that started a drag was let go where the card is,
/// which picks the card instead of moving it.
bool _stayed(BuildContext context, Offset dropped) {
  final box = context.findRenderObject();
  if (box is! RenderBox || !box.attached) return false;
  return (dropped - box.localToGlobal(Offset.zero)).distance < kTouchSlop;
}

/// Shown in place of the board when the projects disagree about their
/// workflow: each workflow and its projects.
class BoardRefusedNotice extends StatelessWidget {
  /// Explains [layout].
  const BoardRefusedNotice({required this.layout, super.key});

  /// The workflows that disagree.
  final BoardRefused layout;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tix;
    return Container(
      key: const Key('board.refused'),
      margin: const EdgeInsets.fromLTRB(
        TixSpace.s4,
        0,
        TixSpace.s4,
        TixSpace.s3,
      ),
      padding: const EdgeInsets.all(TixSpace.s3),
      decoration: BoxDecoration(
        color: t.warnSoft,
        borderRadius: BorderRadius.circular(TixRadius.base),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.boardRefused,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: TixSpace.s1),
          for (final (w, projects) in layout.groups)
            Text(
              l10n.boardRefusedGroup(
                w.name.isEmpty ? w.key : '${w.name} (${w.key})',
                projects.map((p) => p.key).join(', '),
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }
}
