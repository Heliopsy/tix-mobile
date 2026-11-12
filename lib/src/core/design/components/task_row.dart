// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/components/marks.dart';
import 'package:tix_mobile/src/core/design/components/motion.dart';
import 'package:tix_mobile/src/core/design/components/sync.dart';
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
    this.holderHandle = '',
    this.statusCategory,
    this.sync,
  });

  /// The project's key, empty to leave the project off.
  final String projectKey;

  /// The project's stored colour, which draws the stripe.
  final String projectColour;

  /// The project's text icon.
  final String projectIcon;

  /// The assignee's handle, empty for nobody or not yet known.
  final String assigneeHandle;

  /// The handle of whoever holds the claim, or let it run out last; empty
  /// for nobody or not yet known.
  final String holderHandle;

  /// The status's category when the workflow is known.
  final StatusCategory? statusCategory;

  /// What the outbox says about the task, null when it is in sync.
  final SyncMarkKind? sync;
}

/// How long a lapsed claim keeps showing on a row: tix's
/// `LeaseExpiryEvidenceWindow`.
const claimEvidenceWindow = Duration(hours: 24);

/// How a task's claim reads on a row.
enum ClaimState {
  /// Nobody holds it, and no claim ran out recently.
  none,

  /// Held: claimed with a lease still running, or with no lease at all.
  held,

  /// The last claim ran out within [claimEvidenceWindow] and nothing has
  /// claimed it since.
  expired,
}

/// [task]'s claim at [now], read as tix's web reads it.
ClaimState claimStateOf(Task task, DateTime now) {
  if (task.claimedByActorId.isNotEmpty) {
    final until = task.leaseExpiresAt;
    if (until == null || until.isAfter(now)) return ClaimState.held;
  }
  final lapsed = task.leaseExpiredAt;
  if (lapsed != null && now.difference(lapsed) < claimEvidenceWindow) {
    return ClaimState.expired;
  }
  return ClaimState.none;
}

/// The marks a row and a card carry after the deadline, in tix's order:
/// the claim, waiting on a dependency, the repeat rule and the checklist.
List<Widget> taskFlagMarks(
  Task task,
  TaskFacts facts,
  DateTime now, {
  ValueChanged<String>? onOpenRef,
}) {
  final checklist = task.checklist;
  return [
    switch (claimStateOf(task, now)) {
      ClaimState.held => HeldMark(
        holder: facts.holderHandle,
        until: task.leaseExpiresAt,
      ),
      ClaimState.expired => ClaimExpiredMark(
        ago: now.difference(task.leaseExpiredAt!),
        at: task.leaseExpiredAt,
        holder: facts.holderHandle,
        claims: task.claimCount,
      ),
      ClaimState.none => null,
    },
    if (task.blocked) WaitMark(task.waitingOn, onOpen: onOpenRef),
    if (task.recurrence.isNotEmpty) RepeatMark(task.recurrence),
    if (checklist != null && checklist.total > 0)
      ChecklistMark(done: checklist.done, total: checklist.total),
  ].nonNulls.toList();
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
/// In select mode ([picked] non-null) a square checkbox leads the row and
/// the tick is drawn muted, without a tap target or semantics, so it still
/// shows whether the task is done but cannot be mistaken for the picker.
///
/// When the task turns done the tick fills and draws its check, the title is
/// struck through from left to right and the row washes green and fades
/// back; turning it open again plays the same backwards. Only a change
/// animates, never a row drawn already done, and with reduced motion the
/// change is instant.
///
/// Wrap it in `TixSwipeActions` for touch shortcuts.
class TaskRow extends StatefulWidget {
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
    this.onMore,
    this.picked,
    this.onPicked,
    this.onOpenRef,
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

  /// What a long press does; also a secondary click when [onMore] is null.
  final VoidCallback? onLongPress;

  /// Opens the row's actions from the trailing dots and a secondary click;
  /// null leaves the dots off. The dots are left off in select mode.
  final VoidCallback? onMore;

  /// Whether the row is picked for a bulk action; non-null is select mode,
  /// which draws a checkbox and mutes the tick.
  final bool? picked;

  /// Picks or unpicks the row.
  final ValueChanged<bool>? onPicked;

  /// Opens another task by reference, as the waiting mark names it; null
  /// leaves the mark as text.
  final ValueChanged<String>? onOpenRef;

  /// Whether the keyboard cursor is on the row.
  final bool focused;

  /// The clock for due marks.
  final DateTime? now;

  /// From this width the markings line up beside the title.
  static const columnsMinWidth = 1100.0;

  @override
  State<TaskRow> createState() => _TaskRowState();
}

class _TaskRowState extends State<TaskRow> with SingleTickerProviderStateMixin {
  late final AnimationController _motion = AnimationController(
    vsync: this,
    value: _done(widget) ? 1 : 0,
  )..addListener(() => setState(() {}));

  static bool _done(TaskRow w) => isTaskDone(w.task, w.facts.statusCategory);

  @override
  void didUpdateWidget(TaskRow old) {
    super.didUpdateWidget(old);
    final done = _done(widget);
    if (done == _done(old)) return;
    _motion.duration = TixMotion.of(context, TixMotion.settle);
    if (old.task.id != widget.task.id ||
        identical(old.task, widget.task) ||
        _motion.duration == Duration.zero) {
      _motion.value = done ? 1 : 0;
    } else if (done) {
      _motion.forward(from: 0);
    } else {
      _motion.reverse(from: 1);
    }
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final motion = _motion.value;
    final TaskRow(
      :task,
      :facts,
      :selected,
      :picked,
      :focused,
      :onTap,
      :onLongPress,
      :onMore,
      :onPicked,
      :onToggleDone,
      :onToggleStar,
      :onStatusTap,
      :onPriorityTap,
      :onOpenRef,
      :now,
    ) = widget;
    final t = context.tix;
    final stripe = t.projectColour(facts.projectColour);
    final done = isTaskDone(task, facts.statusCategory);
    final strike = _strikeCurve.transform(motion);
    final wash = motion == 0 || motion == 1 ? 0.0 : math.sin(math.pi * motion);
    return LayoutBuilder(
      builder: (context, box) {
        final wide = box.maxWidth >= TaskRow.columnsMinWidth;
        final narrow = box.maxWidth < 600;
        final title = _Title(
          task: task,
          done: done,
          strike: strike,
          sync: facts.sync,
        );
        final meta = _Meta(
          task: task,
          facts: facts,
          wide: wide,
          showTags: !narrow,
          showProject: box.maxWidth >= 480,
          onStatusTap: onStatusTap,
          onPriorityTap: onPriorityTap,
          onOpenRef: onOpenRef,
          now: now,
        );
        return Material(
          color: selected || (picked ?? false)
              ? t.accentSoft
              : Color.lerp(Colors.transparent, t.okSoft, wash),
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            onSecondaryTap: onMore ?? onLongPress,
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
                  if (picked case final bool on) ...[
                    TaskPick(
                      key: ValueKey(('pick', task.ref)),
                      picked: on,
                      onChanged: onPicked,
                    ),
                    TaskCheck(done: done, inert: true),
                  ] else
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
                  if (onMore != null && picked == null)
                    _More(onTap: onMore)
                  else
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

const _strikeCurve = Interval(0.2, 0.85, curve: Curves.easeInOut);

class _Title extends StatelessWidget {
  const _Title({
    required this.task,
    required this.done,
    required this.strike,
    this.sync,
  });

  final Task task;
  final bool done;

  /// How far the strike-through has swept, 1 when it is drawn whole.
  final double strike;
  final SyncMarkKind? sync;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    final sweeping = strike > 0 && strike < 1;
    final style = TextStyle(
      fontSize: TixText.md,
      height: 1.35,
      color: task.blocked ? t.muted : Color.lerp(t.ink, t.muted, strike),
      decoration: done && !sweeping ? TextDecoration.lineThrough : null,
      decorationColor: t.muted,
    );
    final text = Text(
      task.title,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: sweeping
              ? CustomPaint(
                  key: const Key('row.strike'),
                  foregroundPainter: _StrikePainter(
                    text: task.title,
                    style: DefaultTextStyle.of(context).style.merge(style),
                    scaler: MediaQuery.textScalerOf(context),
                    direction: Directionality.of(context),
                    progress: strike,
                    colour: t.muted,
                  ),
                  child: text,
                )
              : text,
        ),
        if (sync case final SyncMarkKind kind) ...[
          const SizedBox(width: TixSpace.s1),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: SyncMark(kind),
          ),
        ],
      ],
    );
  }
}

/// A strike-through drawn line by line up to [progress] of the title's
/// length, laid out as the [Text] under it is.
class _StrikePainter extends CustomPainter {
  _StrikePainter({
    required this.text,
    required this.style,
    required this.scaler,
    required this.direction,
    required this.progress,
    required this.colour,
  });

  final String text;
  final TextStyle style;
  final TextScaler scaler;
  final TextDirection direction;
  final double progress;
  final Color colour;

  @override
  void paint(Canvas canvas, Size size) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: direction,
      textScaler: scaler,
      maxLines: 2,
      ellipsis: '…',
    )..layout(maxWidth: size.width);
    final lines = painter.computeLineMetrics();
    painter.dispose();
    var left = progress * lines.fold(0.0, (sum, l) => sum + l.width);
    final paint = Paint()
      ..color = colour
      ..strokeWidth = 1.5;
    for (final line in lines) {
      if (left <= 0) break;
      final run = math.min(left, line.width);
      final y = line.baseline - line.ascent * 0.32;
      final rtl = direction == TextDirection.rtl;
      final from = rtl ? line.left + line.width : line.left;
      canvas.drawLine(
        Offset(from, y),
        Offset(rtl ? from - run : from + run, y),
        paint,
      );
      left -= run;
    }
  }

  @override
  bool shouldRepaint(_StrikePainter old) =>
      old.progress != progress ||
      old.text != text ||
      old.style != style ||
      old.colour != colour;
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
    required this.onOpenRef,
    required this.now,
  });

  final Task task;
  final TaskFacts facts;
  final bool wide;
  final bool showTags;
  final bool showProject;
  final VoidCallback? onStatusTap;
  final VoidCallback? onPriorityTap;
  final ValueChanged<String>? onOpenRef;
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
    final clock = now ?? DateTime.now();
    final flags = <Widget>[
      if (due != null && !isTaskDone(task, facts.statusCategory))
        DueMark(due: due, now: now),
      ...taskFlagMarks(task, facts, clock, onOpenRef: onOpenRef),
      if (snoozed != null && snoozed.isAfter(clock)) SnoozeMark(until: snoozed),
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
        cell(160, Wrap(spacing: TixSpace.s1, runSpacing: 2, children: flags))
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

class _More extends StatelessWidget {
  const _More({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => IconButton(
    key: const Key('row.more'),
    onPressed: onTap,
    tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
    icon: Icon(Icons.more_horiz, size: 20, color: context.tix.muted),
    style: IconButton.styleFrom(
      minimumSize: const Size.square(32),
      tapTargetSize: MaterialTapTargetSize.padded,
    ),
  );
}

/// The square checkbox that picks a row or card in select mode, read as
/// "Select" so it is never confused with the tick.
class TaskPick extends StatelessWidget {
  /// A checkbox that is ticked when [picked].
  const TaskPick({required this.picked, this.onChanged, super.key});

  /// Whether the task is picked.
  final bool picked;

  /// Picks or unpicks it.
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: 40,
    child: Checkbox(
      value: picked,
      semanticLabel: context.l10n.bulkSelect,
      onChanged: onChanged == null ? null : (v) => onChanged!(v ?? false),
    ),
  );
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

/// The completion circle: empty, or filled in the ok colour with a check.
/// Ticking it fills the circle with a small bounce and draws the check from
/// left to right; unticking plays it backwards. Null [onChanged] draws an
/// open task as a dashed placeholder, tix's mark for a row that cannot be
/// ticked from here. [inert] draws it small and muted with no tap target and
/// no semantics, as select mode does.
class TaskCheck extends StatefulWidget {
  /// A circle that is ticked when [done].
  const TaskCheck({
    required this.done,
    this.onChanged,
    this.inert = false,
    super.key,
  });

  /// Whether the task is done.
  final bool done;

  /// Toggles it.
  final VoidCallback? onChanged;

  /// Whether it only shows the state, as in select mode.
  final bool inert;

  @override
  State<TaskCheck> createState() => _TaskCheckState();
}

final _bounce = TweenSequence<double>([
  TweenSequenceItem(tween: Tween<double>(begin: 1, end: 0.85), weight: 25),
  TweenSequenceItem(
    tween: Tween(
      begin: 0.85,
      end: 1.12,
    ).chain(CurveTween(curve: Curves.easeOut)),
    weight: 40,
  ),
  TweenSequenceItem(
    tween: Tween<double>(
      begin: 1.12,
      end: 1,
    ).chain(CurveTween(curve: Curves.easeIn)),
    weight: 35,
  ),
]);

const _fillCurve = Interval(0, 0.45, curve: Curves.easeOut);

const _drawCurve = Interval(0.3, 1, curve: Curves.easeOut);

class _TaskCheckState extends State<TaskCheck>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion = AnimationController(
    vsync: this,
    value: widget.done ? 1 : 0,
  );

  @override
  void didUpdateWidget(TaskCheck old) {
    super.didUpdateWidget(old);
    if (old.done == widget.done) return;
    _motion.duration = TixMotion.of(context, TixMotion.slow);
    if (_motion.duration == Duration.zero) {
      _motion.value = widget.done ? 1 : 0;
    } else if (widget.done) {
      _motion.forward(from: 0);
    } else {
      _motion.reverse(from: 1);
    }
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    final l10n = context.l10n;
    final TaskCheck(:done, :onChanged, :inert) = widget;
    final circle = AnimatedBuilder(
      animation: _motion,
      builder: (context, _) {
        final v = _motion.value;
        final fill = _fillCurve.transform(v);
        final draw = _drawCurve.transform(v);
        final icon = Icon(Icons.check, size: 14, color: t.onOk);
        return Transform.scale(
          scale: _bounce.transform(v),
          child: Container(
            key: const Key('check.circle'),
            width: TixSize.check,
            height: TixSize.check,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color.lerp(Colors.transparent, t.ok, fill),
              border: Border.all(
                color: Color.lerp(t.lineStrong, t.ok, fill)!,
                width: 2,
              ),
            ),
            child: draw == 0
                ? null
                : draw == 1
                ? icon
                : ClipRect(clipper: _Reveal(draw), child: icon),
          ),
        );
      },
    );
    if (inert) {
      return ExcludeSemantics(
        child: IgnorePointer(
          child: Opacity(
            opacity: 0.45,
            child: SizedBox(
              width: TixSize.check + TixSpace.s2,
              height: 40,
              child: Center(child: circle),
            ),
          ),
        ),
      );
    }
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
      if (!done) unawaited(TixHaptics.light());
      onChanged!();
    }

    return Semantics(
      container: true,
      checked: done,
      label: done ? l10n.reopen : l10n.markDone,
      button: onChanged != null,
      onTap: onChanged == null ? null : toggle,
      excludeSemantics: true,
      child: onChanged == null
          ? hit
          : InkResponse(radius: 22, onTap: toggle, child: hit),
    );
  }
}

/// Shows the leading [fraction] of its child's width, in reading order.
class _Reveal extends CustomClipper<Rect> {
  const _Reveal(this.fraction);

  final double fraction;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, 0, size.width * fraction, size.height);

  @override
  bool shouldReclip(_Reveal old) => old.fraction != fraction;
}
