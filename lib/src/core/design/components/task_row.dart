// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/components/marks.dart';
import 'package:tix_mobile/src/core/design/components/motion.dart';
import 'package:tix_mobile/src/core/design/tokens.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/data/models/task.dart';

/// What a row or card needs beyond the task itself: the facts the task
/// names by id, resolved by the screen.
@immutable
class TaskFacts {
  /// Facts about one task.
  const TaskFacts({
    this.projectKey = '',
    this.projectColour = '',
    this.projectIcon = '',
    this.assigneeHandle = '',
    this.statusCategory,
  });

  /// The project's key, empty to leave the project off.
  final String projectKey;

  /// The project's stored colour, which draws the stripe.
  final String projectColour;

  /// The project's text icon.
  final String projectIcon;

  /// The assignee's handle, empty for nobody or not yet known.
  final String assigneeHandle;

  /// The status's category when the workflow is known.
  final StatusCategory? statusCategory;
}

/// Whether [task] is finished, by its completion time or its status.
bool isTaskDone(Task task, [StatusCategory? category]) =>
    task.completedAt != null ||
    (category ?? StatusCategory.guess(task.status)) == StatusCategory.done;

/// One task in a list, as `180-task-list.css` draws it.
///
/// The tick, the star, the title (two lines at most) and the markings:
/// status pill, priority caret, tags (three, then a count), assignee,
/// project, due and snooze marks, and the reference. A project colour runs
/// down the left edge and washes a quarter of the way in. On a narrow row
/// the markings sit under the title and tags are left out; on a wide one
/// they line up in columns.
///
/// Wrap it in `TixSwipeActions` for touch shortcuts.
class TaskRow extends StatelessWidget {
  /// Draws [task] with [facts].
  const TaskRow({
    required this.task,
    required this.onTap,
    this.facts = const TaskFacts(),
    this.selected = false,
    this.onToggleDone,
    this.onToggleStar,
    this.onStatusTap,
    this.onPriorityTap,
    this.onLongPress,
    this.picked,
    this.onPicked,
    this.focused = false,
    this.now,
    super.key,
  });

  /// The task.
  final Task task;

  /// What the screen knows about the task's project, assignee and status.
  final TaskFacts facts;

  /// Opens the task.
  final VoidCallback onTap;

  /// Whether it is the task open beside the list.
  final bool selected;

  /// Completes or reopens; null draws the tick as a placeholder.
  final VoidCallback? onToggleDone;

  /// Stars or unstars; null leaves the star off unless starred.
  final VoidCallback? onToggleStar;

  /// Opens the status menu; null draws the pill as a label.
  final VoidCallback? onStatusTap;

  /// Opens the priority menu.
  final VoidCallback? onPriorityTap;

  /// Opens the row's actions: a long press, or a secondary click.
  final VoidCallback? onLongPress;

  /// Whether the row is picked for a bulk action; non-null draws a checkbox
  /// in place of the tick.
  final bool? picked;

  /// Picks or unpicks the row.
  final ValueChanged<bool>? onPicked;

  /// Whether the keyboard cursor is on the row.
  final bool focused;

  /// The clock for due marks.
  final DateTime? now;

  /// From this width the markings line up beside the title.
  static const columnsMinWidth = 1100.0;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    final stripe = t.projectColour(facts.projectColour);
    final done = isTaskDone(task, facts.statusCategory);
    return LayoutBuilder(
      builder: (context, box) {
        final wide = box.maxWidth >= columnsMinWidth;
        final narrow = box.maxWidth < 600;
        final title = _Title(task: task, done: done);
        final meta = _Meta(
          task: task,
          facts: facts,
          wide: wide,
          showTags: !narrow,
          showProject: box.maxWidth >= 480,
          onStatusTap: onStatusTap,
          onPriorityTap: onPriorityTap,
          now: now,
        );
        return Material(
          color: selected || (picked ?? false)
              ? t.accentSoft
              : Colors.transparent,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            onSecondaryTap: onLongPress,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: focused ? t.accent : stripe ?? Colors.transparent,
                    width: 3,
                  ),
                  bottom: BorderSide(color: t.line),
                ),
                gradient: stripe == null || selected
                    ? null
                    : LinearGradient(
                        colors: [
                          stripe.withValues(alpha: 0.10),
                          stripe.withValues(alpha: 0),
                        ],
                        stops: const [0, 0.22],
                      ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: TixSpace.s2,
                vertical: narrow ? TixSpace.s1 : 2,
              ),
              child: Row(
                crossAxisAlignment: wide
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                children: [
                  if (picked case final bool on)
                    SizedBox.square(
                      dimension: 40,
                      child: Checkbox(
                        value: on,
                        onChanged: onPicked == null
                            ? null
                            : (v) => onPicked!(v ?? false),
                      ),
                    )
                  else
                    TaskCheck(done: done, onChanged: onToggleDone),
                  if (task.starred || onToggleStar != null)
                    _Star(starred: task.starred, onTap: onToggleStar),
                  const SizedBox(width: TixSpace.s1),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: TixSpace.s2,
                      ),
                      child: wide
                          ? Row(
                              children: [
                                Expanded(child: title),
                                const SizedBox(width: TixSpace.s3),
                                meta,
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                title,
                                const SizedBox(height: TixSpace.s1),
                                meta,
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(width: TixSpace.s2),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.task, required this.done});

  final Task task;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    final muted = task.blocked || done;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (task.blocked) ...[
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Tooltip(
              message: context.l10n.blockedByOther,
              child: Icon(Icons.block, size: 14, color: t.warn),
            ),
          ),
          const SizedBox(width: TixSpace.s1),
        ],
        Expanded(
          child: Text(
            task.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: TixText.md,
              height: 1.35,
              color: muted ? t.muted : t.ink,
              decoration: done ? TextDecoration.lineThrough : null,
              decorationColor: t.muted,
            ),
          ),
        ),
      ],
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({
    required this.task,
    required this.facts,
    required this.wide,
    required this.showTags,
    required this.showProject,
    required this.onStatusTap,
    required this.onPriorityTap,
    required this.now,
  });

  final Task task;
  final TaskFacts facts;
  final bool wide;
  final bool showTags;
  final bool showProject;
  final VoidCallback? onStatusTap;
  final VoidCallback? onPriorityTap;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    Widget cell(double width, Widget child, {bool end = false}) => wide
        ? SizedBox(
            width: width,
            child: Align(
              alignment: end
                  ? AlignmentDirectional.centerEnd
                  : AlignmentDirectional.centerStart,
              child: child,
            ),
          )
        : child;
    final status = task.status.isEmpty
        ? null
        : _Tappable(
            onTap: onStatusTap,
            label: l10n.fieldStatus,
            child: StatusPill(
              label: task.status,
              category: facts.statusCategory,
            ),
          );
    final shown = task.tags.take(3).toList();
    final due = task.dueAt;
    final snoozed = task.snoozedUntil;
    final flags = <Widget>[
      if (due != null && !isTaskDone(task, facts.statusCategory))
        DueMark(due: due, now: now),
      if (snoozed != null && snoozed.isAfter(now ?? DateTime.now()))
        SnoozeMark(until: snoozed),
    ];
    final children = <Widget>[
      if (status != null) cell(86, status),
      cell(
        72,
        _Tappable(
          onTap: onPriorityTap,
          label: l10n.fieldPriority,
          child: PriorityMark(priority: task.priority),
        ),
      ),
      if (showTags && (wide || shown.isNotEmpty))
        cell(
          120,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final tag in shown.take(wide ? 2 : 3))
                Flexible(child: TagChip(tag)),
              if (task.tags.length > (wide ? 2 : 3))
                MoreMark(task.tags.length - (wide ? 2 : 3)),
            ],
          ),
        ),
      if (facts.assigneeHandle.isNotEmpty || wide)
        cell(92, AssigneeRef(facts.assigneeHandle)),
      if (showProject && facts.projectKey.isNotEmpty)
        cell(
          80,
          ProjectChip(
            projectKey: facts.projectKey,
            colour: facts.projectColour,
            icon: facts.projectIcon,
          ),
        ),
      if (wide)
        cell(112, Wrap(spacing: TixSpace.s1, children: flags))
      else
        ...flags,
      cell(84, RefText(task.ref), end: true),
    ];
    if (wide) return Row(mainAxisSize: MainAxisSize.min, children: children);
    return Wrap(
      spacing: TixSpace.s2,
      runSpacing: TixSpace.s1,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }
}

class _Tappable extends StatelessWidget {
  const _Tappable({
    required this.onTap,
    required this.label,
    required this.child,
  });

  final VoidCallback? onTap;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (onTap == null) return child;
    return Semantics(
      button: true,
      hint: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(TixRadius.pill),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 32),
          child: Align(widthFactor: 1, child: child),
        ),
      ),
    );
  }
}

class _Star extends StatelessWidget {
  const _Star({required this.starred, required this.onTap});

  final bool starred;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    final l10n = context.l10n;
    final icon = Icon(
      starred ? Icons.star_rounded : Icons.star_outline_rounded,
      size: 20,
      color: starred ? t.accent : t.muted,
    );
    if (onTap == null) {
      return Semantics(
        label: l10n.starred,
        child: SizedBox.square(dimension: 32, child: Center(child: icon)),
      );
    }
    return IconButton(
      onPressed: onTap,
      isSelected: starred,
      tooltip: starred ? l10n.unstar : l10n.star,
      icon: icon,
      style: IconButton.styleFrom(
        minimumSize: const Size.square(32),
        tapTargetSize: MaterialTapTargetSize.padded,
      ),
    );
  }
}

/// The completion circle: empty, or filled in the ok colour with a tick
/// that pops in. Null [onChanged] draws an open task as a dashed
/// placeholder, tix's mark for a row that cannot be ticked from here.
class TaskCheck extends StatelessWidget {
  /// A circle that is ticked when [done].
  const TaskCheck({required this.done, this.onChanged, super.key});

  /// Whether the task is done.
  final bool done;

  /// Toggles it.
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    final l10n = context.l10n;
    final duration = TixMotion.of(context, TixMotion.slow);
    final circle = AnimatedContainer(
      duration: TixMotion.of(context, TixMotion.fast),
      curve: TixMotion.ease,
      width: TixSize.check,
      height: TixSize.check,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? t.ok : Colors.transparent,
        border: Border.all(color: done ? t.ok : t.lineStrong, width: 2),
      ),
      child: done
          ? TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.75, end: 1),
              duration: duration,
              curve: TixMotion.pop,
              builder: (context, s, child) =>
                  Transform.scale(scale: s, child: child),
              child: Icon(Icons.check, size: 14, color: t.onOk),
            )
          : null,
    );
    final hit = SizedBox.square(
      dimension: 40,
      child: Center(
        child: onChanged == null && !done
            ? CustomPaint(
                painter: DashedBorder(
                  colour: t.lineStrong,
                  radius: TixRadius.pill,
                ),
                child: const SizedBox.square(dimension: TixSize.check),
              )
            : circle,
      ),
    );
    void toggle() {
      if (!done) unawaited(TixHaptics.confirm());
      onChanged!();
    }

    return Semantics(
      container: true,
      checked: done,
      label: done ? l10n.reopen : l10n.complete,
      button: onChanged != null,
      onTap: onChanged == null ? null : toggle,
      excludeSemantics: true,
      child: onChanged == null
          ? hit
          : InkResponse(radius: 22, onTap: toggle, child: hit),
    );
  }
}
