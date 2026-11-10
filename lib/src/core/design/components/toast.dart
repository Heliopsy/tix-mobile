// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/components/marks.dart';
import 'package:tix_mobile/src/core/design/components/motion.dart';
import 'package:tix_mobile/src/core/design/tokens.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';

/// Shows [message] as tix's flash: the accent on its tint, or the danger
/// colours when [tone] is [TixTone.danger]. With [onUndo] it offers Undo,
/// and stays long enough to reach it. It is swiped away sideways (the
/// theme's direction) or down.
///
/// Use it to confirm what just happened and to undo it. Never for
/// something the person must read to continue; that belongs on the screen.
ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showTixToast(
  BuildContext context,
  String message, {
  TixTone tone = TixTone.accent,
  VoidCallback? onUndo,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final messenger = ScaffoldMessenger.of(context);
  final t = context.tix;
  final danger = tone == TixTone.danger;
  final fg = danger ? t.danger : t.accent;
  final label = onUndo != null ? context.l10n.undo : actionLabel;
  final action = onUndo ?? onAction;
  messenger.hideCurrentSnackBar();
  return messenger.showSnackBar(
    SnackBar(
      content: _SwipeDownToHide(
        child: Text(message, style: TextStyle(color: fg)),
      ),
      backgroundColor: danger ? t.dangerSoft : t.accentSoft,
      duration: Duration(seconds: action == null ? 4 : 7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(9),
        side: BorderSide(color: danger ? t.danger : t.line),
      ),
      action: action == null || label == null
          ? null
          : SnackBarAction(
              key: const Key('toast.action'),
              label: label,
              textColor: fg,
              onPressed: action,
            ),
    ),
  );
}

/// The speed of a downward fling that hides a toast, as [Dismissible] uses.
const double _hideFlingVelocity = 700;

/// Hides the current toast on a downward fling or a drag past half its
/// height. A snack bar takes one dismiss direction and the theme's is
/// horizontal, so this keeps the old downward swipe.
class _SwipeDownToHide extends StatefulWidget {
  const _SwipeDownToHide({required this.child});

  final Widget child;

  @override
  State<_SwipeDownToHide> createState() => _SwipeDownToHideState();
}

class _SwipeDownToHideState extends State<_SwipeDownToHide> {
  double _dragged = 0;

  void _end(DragEndDetails details) {
    final height = context.size?.height ?? 0;
    final flung = (details.primaryVelocity ?? 0) >= _hideFlingVelocity;
    if (flung || _dragged > height / 2) {
      ScaffoldMessenger.of(context)
          .hideCurrentSnackBar(reason: SnackBarClosedReason.swipe);
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onVerticalDragStart: (_) => _dragged = 0,
    onVerticalDragUpdate: (d) => _dragged += d.delta.dy,
    onVerticalDragEnd: _end,
    child: widget.child,
  );
}

/// Applies a change on screen at once and sends it after: the optimistic
/// update every quick action uses (complete, star, snooze, assign).
///
/// [apply] changes local state, [commit] asks the server. When the server
/// refuses, [rollback] restores the old state and an error toast says why.
/// When it agrees, [success] is shown with Undo, which rolls back locally
/// and calls [undo] on the server. Returns whether the change stuck.
Future<bool> runOptimistic(
  BuildContext context, {
  required VoidCallback apply,
  required VoidCallback rollback,
  required Future<void> Function() commit,
  required String Function(Object error) describe,
  String? success,
  Future<void> Function()? undo,
}) async {
  apply();
  try {
    await commit();
  } on Object catch (e) {
    rollback();
    unawaited(TixHaptics.refuse());
    if (context.mounted) {
      showTixToast(context, describe(e), tone: TixTone.danger);
    }
    return false;
  }
  if (success != null && context.mounted) {
    showTixToast(
      context,
      success,
      onUndo: undo == null
          ? null
          : () async {
              rollback();
              try {
                await undo();
              } on Object catch (e) {
                apply();
                if (context.mounted) {
                  showTixToast(context, describe(e), tone: TixTone.danger);
                }
              }
            },
    );
  }
  return true;
}
