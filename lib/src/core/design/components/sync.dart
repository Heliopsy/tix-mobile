// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/components/buttons.dart';
import 'package:tix_mobile/src/core/design/tokens.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';

/// What a [SyncMark] says about a task or a comment.
enum SyncMarkKind {
  /// Changed on this device and not yet sent.
  unsynced,

  /// Created on this device; its reference is temporary until it is sent.
  draft,

  /// Waiting for the person: someone else changed it too.
  conflict,

  /// The server refused the change.
  failed,

  /// A create that may already have reached the server, to be checked.
  check,
}

/// A small mark beside a reference or a title saying that what is shown is
/// not yet what the server has: unsynced, a draft, a conflict, a refusal.
///
/// Put it on rows, cards, the task header and comments. A conflict and a
/// refusal are in the warning and danger colours; the rest stay muted, so a
/// list full of offline edits does not shout.
class SyncMark extends StatelessWidget {
  /// A mark of [kind].
  const SyncMark(this.kind, {super.key});

  /// What it says.
  final SyncMarkKind kind;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    final l10n = context.l10n;
    final (icon, label, fg, bg) = switch (kind) {
      SyncMarkKind.unsynced => (
        Icons.cloud_off_outlined,
        l10n.syncMarkUnsynced,
        t.muted,
        t.surface,
      ),
      SyncMarkKind.draft => (
        Icons.edit_note,
        l10n.syncMarkDraft,
        t.muted,
        t.surface,
      ),
      SyncMarkKind.check => (
        Icons.help_outline,
        l10n.syncMarkCheck,
        t.warn,
        t.warnSoft,
      ),
      SyncMarkKind.conflict => (
        Icons.call_split,
        l10n.syncMarkConflict,
        t.warn,
        t.warnSoft,
      ),
      SyncMarkKind.failed => (
        Icons.error_outline,
        l10n.syncMarkFailed,
        t.danger,
        t.dangerSoft,
      ),
    };
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: TixSpace.s1,
          vertical: 1,
        ),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: t.line),
          borderRadius: BorderRadius.circular(TixRadius.sm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: TixText.sm, color: fg),
            const SizedBox(width: 2),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: TixText.xs2,
                  fontWeight: FontWeight.w600,
                  color: fg,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A strip at the top of a record saying its changes wait to sync, or wait
/// for the person, with the one action that helps.
///
/// The task screen shows it while the task has writes in the outbox: muted
/// while they only wait, in the warning colour for a conflict or a refusal.
class SyncBanner extends StatelessWidget {
  /// A banner saying [message], warning when [attention], with [onAction]
  /// labelled [actionLabel].
  const SyncBanner({
    required this.message,
    this.attention = false,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  /// What it says.
  final String message;

  /// Whether the person has to act.
  final bool attention;

  /// The action's label.
  final String? actionLabel;

  /// The action.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    final (fg, bg, border) = attention
        ? (t.warn, t.warnSoft, t.warn.withValues(alpha: 0.4))
        : (t.muted, t.surface, t.line);
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          TixSpace.s3,
          TixSpace.s2,
          TixSpace.s2,
          TixSpace.s2,
        ),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(TixRadius.base),
        ),
        child: Wrap(
          spacing: TixSpace.s2,
          runSpacing: TixSpace.s1,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  attention ? Icons.call_split : Icons.cloud_off_outlined,
                  size: 18,
                  color: fg,
                ),
                const SizedBox(width: TixSpace.s2),
                Flexible(
                  child: Text(
                    message,
                    style: TextStyle(fontSize: TixText.sm, color: t.ink),
                  ),
                ),
              ],
            ),
            if (actionLabel != null && onAction != null)
              TixButton(
                key: const Key('sync.banner.action'),
                label: actionLabel!,
                size: TixButtonSize.small,
                onPressed: onAction,
              ),
          ],
        ),
      ),
    );
  }
}
