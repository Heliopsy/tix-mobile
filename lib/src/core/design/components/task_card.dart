// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/components/avatar.dart';
import 'package:tix_mobile/src/core/design/components/marks.dart';
import 'package:tix_mobile/src/core/design/components/sync.dart';
import 'package:tix_mobile/src/core/design/components/task_row.dart';
import 'package:tix_mobile/src/core/design/tokens.dart';
import 'package:tix_mobile/src/data/models/task.dart';

/// One task on a board column, as `050-board.css` draws a card: the
/// project's colour across the top, the reference and priority, the title
/// in up to three lines, then status, assignee, due, the claim, waiting,
/// repeat and checklist marks, and two tags.
///
/// In select mode ([picked] non-null) a checkbox leads the card, the tick
/// is muted and inert, and the dots are left off, as on [TaskRow].
///
/// Use it on boards and lanes; lists use [TaskRow].
class TaskCard extends StatelessWidget {
  /// Draws [task] with [facts].
  const TaskCard({
    required this.task,
    required this.onTap,
    this.facts = const TaskFacts(),
    this.selected = false,
    this.now,
    this.onToggleDone,
    this.onLongPress,
    this.onMore,
    this.picked,
    this.onPicked,
    this.onOpenRef,
    this.showStatus = true,
    super.key,
  });

  /// The task.
  final Task task;

  /// What the screen knows about it.
  final TaskFacts facts;

  /// Opens it.
  final VoidCallback onTap;

  /// Whether it is the focused card.
  final bool selected;

  /// The clock for due marks.
  final DateTime? now;

  /// Completes or reopens; null leaves the tick off, as on a board where
  /// the column is the status.
  final VoidCallback? onToggleDone;

  /// What a long press does; also a secondary click when [onMore] is null.
  final VoidCallback? onLongPress;

  /// Opens the card's actions from the three dots and a secondary click;
  /// null leaves them off.
  final VoidCallback? onMore;

  /// Whether the card is picked for a bulk action; non-null is select mode.
  final bool? picked;

  /// Picks or unpicks the card.
  final ValueChanged<bool>? onPicked;

  /// Opens another task by reference, as the waiting mark names it.
  final ValueChanged<String>? onOpenRef;

  /// Whether the status pill is drawn; a board column already says it.
  final bool showStatus;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    final stripe = t.projectColour(facts.projectColour);
    final due = task.dueAt;
    final done = isTaskDone(task, facts.statusCategory);
    final picking = picked != null;
    final more = picking ? null : onMore;
    return Material(
      color: selected || (picked ?? false) ? t.accentSoft : t.bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TixRadius.lg),
        side: BorderSide(color: selected ? t.accent : t.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        onSecondaryTap: onMore ?? onLongPress,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: stripe == null
                ? null
                : Border(top: BorderSide(color: stripe, width: 3)),
            gradient: stripe == null
                ? null
                : LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      stripe.withValues(alpha: 0.12),
                      stripe.withValues(alpha: 0),
                    ],
                    stops: const [0, 0.42],
                  ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(TixSpace.s3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (picked case final bool on)
                      Transform.translate(
                        offset: const Offset(-TixSpace.s2, 0),
                        child: SizedBox(
                          width: 32,
                          height: 24,
                          child: OverflowBox(
                            maxWidth: 40,
                            maxHeight: 40,
                            child: TaskPick(
                              key: ValueKey(('pick', task.ref)),
                              picked: on,
                              onChanged: onPicked,
                            ),
                          ),
                        ),
                      ),
                    if (picking && onToggleDone != null)
                      SizedBox(
                        width: TixSize.check + TixSpace.s2,
                        height: 24,
                        child: OverflowBox(
                          maxHeight: 40,
                          child: TaskCheck(done: done, inert: true),
                        ),
                      )
                    else if (onToggleDone != null)
                      Transform.translate(
                        offset: const Offset(-TixSpace.s2, 0),
                        child: SizedBox(
                          width: 32,
                          height: 24,
                          child: OverflowBox(
                            maxWidth: 40,
                            maxHeight: 40,
                            child: TaskCheck(
                              done: done,
                              onChanged: onToggleDone,
                            ),
                          ),
                        ),
                      ),
                    if (facts.projectIcon.isNotEmpty) ...[
                      Text(facts.projectIcon),
                      const SizedBox(width: TixSpace.s1),
                    ],
                    RefText(task.ref, size: TixText.xs),
                    if (facts.sync case final SyncMarkKind kind) ...[
                      const SizedBox(width: TixSpace.s1),
                      SyncMark(kind),
                    ],
                    const Spacer(),
                    if (task.starred)
                      Icon(Icons.star_rounded, size: 16, color: t.accent),
                    PriorityMark(priority: task.priority),
                    if (more != null)
                      SizedBox(
                        width: 28,
                        height: 24,
                        child: OverflowBox(
                          maxWidth: 40,
                          maxHeight: 40,
                          child: IconButton(
                            onPressed: more,
                            tooltip: MaterialLocalizations.of(context)
                                .moreButtonTooltip,
                            icon: Icon(
                              Icons.more_horiz,
                              size: 18,
                              color: t.muted,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: TixSpace.s1),
                Text(
                  task.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: TixText.md,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                    color: task.blocked || done ? t.muted : t.ink,
                  ),
                ),
                const SizedBox(height: TixSpace.s2),
                Wrap(
                  spacing: TixSpace.s2,
                  runSpacing: TixSpace.s1,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (showStatus && task.status.isNotEmpty)
                      StatusPill(
                        label: task.status,
                        category: facts.statusCategory,
                      ),
                    if (facts.assigneeHandle.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TixAvatar(
                            label: facts.assigneeHandle,
                            size: 20,
                            hued: true,
                          ),
                          const SizedBox(width: TixSpace.s1),
                          AssigneeRef(facts.assigneeHandle),
                        ],
                      ),
                    if (due != null && !done) DueMark(due: due, now: now),
                    ...taskFlagMarks(
                      task,
                      facts,
                      now ?? DateTime.now(),
                      onOpenRef: onOpenRef,
                    ),
                    for (final tag in task.tags.take(2)) TagChip(tag),
                    if (task.tags.length > 2) MoreMark(task.tags.length - 2),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
