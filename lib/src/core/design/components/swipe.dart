// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/semantics.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/components/motion.dart';
import 'package:tix_mobile/src/core/design/tokens.dart';

/// What a swipe does: an icon and a label on a colour, and the call.
@immutable
class TixSwipeAction {
  /// An action labelled [label].
  const TixSwipeAction({
    required this.label,
    required this.icon,
    required this.onTrigger,
    this.tone = TixSwipeTone.accent,
  });

  /// Complete the task: the ok colour, a tick.
  factory TixSwipeAction.complete(String label, VoidCallback onTrigger) =>
      TixSwipeAction(
        label: label,
        icon: Icons.check,
        onTrigger: onTrigger,
        tone: TixSwipeTone.ok,
      );

  /// Snooze it: the warn colour, a clock.
  factory TixSwipeAction.snooze(String label, VoidCallback onTrigger) =>
      TixSwipeAction(
        label: label,
        icon: Icons.snooze,
        onTrigger: onTrigger,
        tone: TixSwipeTone.warn,
      );

  /// Assign it: the accent, a person.
  factory TixSwipeAction.assign(String label, VoidCallback onTrigger) =>
      TixSwipeAction(
        label: label,
        icon: Icons.person_add_alt,
        onTrigger: onTrigger,
      );

  /// Star or unstar it: the accent, a star.
  factory TixSwipeAction.star(String label, VoidCallback onTrigger) =>
      TixSwipeAction(label: label, icon: Icons.star, onTrigger: onTrigger);

  /// What it does, shown under the icon and offered to screen readers.
  final String label;

  /// The icon.
  final IconData icon;

  /// Does it.
  final VoidCallback onTrigger;

  /// The colour family behind it.
  final TixSwipeTone tone;
}

/// The colour behind a swipe.
enum TixSwipeTone {
  /// The tenant's accent.
  accent,

  /// Success, for completing.
  ok,

  /// Attention, for snoozing.
  warn,

  /// Danger, for an action that still confirms.
  danger,
}

/// Swipe a row to act on it: [start] when swiped towards the end (right in
/// left-to-right), [end] the other way. The row snaps back; the action
/// runs. Crossing the threshold ticks on phones.
///
/// Swiping is a shortcut, never the only way: both actions are also custom
/// semantics actions, and the row's menu must offer them too.
class TixSwipeActions extends StatelessWidget {
  /// Wraps [child], keyed by [id], with [start] and [end].
  const TixSwipeActions({
    required this.id,
    required this.child,
    this.start,
    this.end,
    super.key,
  });

  /// A stable key for the row, such as the task's id.
  final Object id;

  /// The swipe towards the end.
  final TixSwipeAction? start;

  /// The swipe towards the start.
  final TixSwipeAction? end;

  /// The row.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final start = this.start;
    final end = this.end;
    if (start == null && end == null) return child;
    final direction = start != null && end != null
        ? DismissDirection.horizontal
        : start != null
        ? DismissDirection.startToEnd
        : DismissDirection.endToStart;
    return Semantics(
      customSemanticsActions: {
        if (start != null)
          CustomSemanticsAction(label: start.label): start.onTrigger,
        if (end != null) CustomSemanticsAction(label: end.label): end.onTrigger,
      },
      child: Dismissible(
        key: ValueKey(('swipe', id)),
        direction: direction,
        dismissThresholds: const {
          DismissDirection.startToEnd: 0.3,
          DismissDirection.endToStart: 0.3,
        },
        onUpdate: (d) {
          if (d.reached && !d.previousReached) unawaited(TixHaptics.tick());
        },
        confirmDismiss: (dir) async {
          final action = dir == DismissDirection.startToEnd ? start : end;
          if (action != null) {
            unawaited(TixHaptics.confirm());
            action.onTrigger();
          }
          return false;
        },
        background: start == null
            ? const SizedBox.shrink()
            : _Background(action: start, alignStart: true),
        secondaryBackground: end == null
            ? null
            : _Background(action: end, alignStart: false),
        child: child,
      ),
    );
  }
}

class _Background extends StatelessWidget {
  const _Background({required this.action, required this.alignStart});

  final TixSwipeAction action;
  final bool alignStart;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    final (bg, fg) = switch (action.tone) {
      TixSwipeTone.ok => (t.ok, t.onOk),
      TixSwipeTone.warn => (t.warn, t.isDark ? t.bg : t.onDanger),
      TixSwipeTone.danger => (t.danger, t.onDanger),
      TixSwipeTone.accent => (t.accent, t.onAccent),
    };
    return ColoredBox(
      color: bg,
      child: Align(
        alignment: alignStart
            ? AlignmentDirectional.centerStart
            : AlignmentDirectional.centerEnd,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: TixSpace.s5),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(action.icon, color: fg, size: 22),
                const SizedBox(height: 2),
                Text(
                  action.label,
                  style: TextStyle(
                    color: fg,
                    fontSize: TixText.xs,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
