// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/components/avatar.dart';
import 'package:tix_mobile/src/core/design/components/buttons.dart';
import 'package:tix_mobile/src/core/design/components/live.dart';
import 'package:tix_mobile/src/core/design/components/marks.dart';
import 'package:tix_mobile/src/core/design/tokens.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/data/models/inbox.dart';

/// The icon for an inbox [kind].
IconData inboxKindIcon(InboxKind? kind) => switch (kind) {
  InboxKind.mention => Icons.alternate_email,
  InboxKind.assigned => Icons.person_add_alt,
  InboxKind.comment => Icons.chat_bubble_outline,
  InboxKind.status => Icons.swap_horiz,
  null => Icons.notifications_none,
};

/// "raj mentioned you", "raj moved it", in the reader's language.
String inboxWhat(AppLocalizations l10n, InboxItem item) {
  final who = item.actorHandle.isEmpty
      ? l10n.inboxSomebody
      : '@${item.actorHandle}';
  return switch (item.kind) {
    InboxKind.mention => l10n.inboxWhatMention(who),
    InboxKind.assigned => l10n.inboxWhatAssigned(who),
    InboxKind.comment => l10n.inboxWhatComment(who),
    InboxKind.status => l10n.inboxWhatStatus(who),
    null => l10n.inboxWhatOther(who),
  };
}

/// When [at] was, as an inbox row says it: "now", "5 min", "3 h" today, the
/// time yesterday, the date before that.
String inboxWhen(BuildContext context, DateTime? at, DateTime now) {
  if (at == null) return '';
  final l10n = context.l10n;
  final locale = Localizations.localeOf(context).toLanguageTag();
  final local = at.toLocal();
  final today = DateUtils.dateOnly(now.toLocal());
  final day = DateUtils.dateOnly(local);
  if (day == today) {
    final ago = now.difference(at);
    if (ago.inMinutes < 1) return l10n.inboxNow;
    if (ago.inHours < 1) return l10n.inboxMinutesAgo(ago.inMinutes);
    return l10n.inboxHoursAgo(ago.inHours);
  }
  if (today.difference(day).inDays == 1) {
    return DateFormat.Hm(locale).format(local);
  }
  return DateFormat.MMMd(locale).format(local);
}

/// One inbox item, as tix's inbox draws it: who did what, the task, the
/// excerpt or the move, and when. Unread items carry the accent dot and a
/// heavier first line.
///
/// Wrap it in `TixSwipeActions` for read and unread; [onMenu] must offer
/// the same.
class InboxRow extends StatelessWidget {
  /// Draws [item].
  const InboxRow({
    required this.item,
    required this.onTap,
    required this.now,
    this.onMenu,
    this.fresh = false,
    this.selected = false,
    super.key,
  });

  /// The item.
  final InboxItem item;

  /// Opens its task; called for a deleted task too, which only marks it.
  final VoidCallback onTap;

  /// Opens the row's actions.
  final VoidCallback? onMenu;

  /// The clock for the time.
  final DateTime now;

  /// Whether it just arrived live.
  final bool fresh;

  /// Whether it is the item open beside the list.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    final l10n = context.l10n;
    final unread = !item.read;
    final kind = item.kind;
    final showExcerpt = item.excerpt.isNotEmpty && kind != InboxKind.assigned;
    return FreshHighlight(
      fresh: fresh,
      child: Material(
        color: selected ? t.accentSoft : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onMenu,
          child: Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: t.line)),
            ),
            padding: const EdgeInsets.fromLTRB(
              TixSpace.s2,
              TixSpace.s3,
              TixSpace.s1,
              TixSpace.s3,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: TixSpace.s4,
                  height: 34,
                  child: Center(
                    child: AnimatedContainer(
                      duration: TixMotion.of(context, TixMotion.fast),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: unread ? t.accent : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                _KindAvatar(item: item),
                const SizedBox(width: TixSpace.s3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              inboxWhat(l10n, item),
                              semanticsLabel: unread
                                  ? '${inboxWhat(l10n, item)}, '
                                        '${l10n.inboxUnread}'
                                  : null,
                              style: TextStyle(
                                fontSize: TixText.sm,
                                fontWeight: unread
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: unread ? t.ink : t.muted,
                              ),
                            ),
                          ),
                          const SizedBox(width: TixSpace.s2),
                          Text(
                            inboxWhen(context, item.createdAt, now),
                            style: TextStyle(
                              fontSize: TixText.xs,
                              color: t.muted,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      if (item.opensTask)
                        Text.rich(
                          TextSpan(
                            children: [
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: RefText(item.taskRef),
                              ),
                              const TextSpan(text: '  '),
                              TextSpan(text: item.taskTitle),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: TixText.md,
                            fontWeight: FontWeight.w500,
                            color: t.ink,
                          ),
                        )
                      else
                        Text(
                          l10n.inboxTaskGone,
                          style: TextStyle(
                            fontSize: TixText.sm,
                            fontStyle: FontStyle.italic,
                            color: t.muted,
                          ),
                        ),
                      if (kind == InboxKind.status &&
                          item.toStatus.isNotEmpty) ...[
                        const SizedBox(height: TixSpace.s1),
                        Wrap(
                          spacing: TixSpace.s1,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (item.fromStatus.isNotEmpty) ...[
                              StatusPill(label: item.fromStatus),
                              Icon(
                                Icons.arrow_forward,
                                size: 14,
                                color: t.muted,
                                semanticLabel: l10n.inboxMovedTo,
                              ),
                            ],
                            StatusPill(label: item.toStatus),
                          ],
                        ),
                      ],
                      if (showExcerpt) ...[
                        const SizedBox(height: TixSpace.s1),
                        Container(
                          padding: const EdgeInsets.only(left: TixSpace.s2),
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(color: t.lineStrong, width: 2),
                            ),
                          ),
                          child: Text(
                            item.excerpt,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: TixText.sm,
                              color: t.muted,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (onMenu != null)
                  TixIconButton(
                    key: Key('inbox.menu.${item.id}'),
                    icon: Icons.more_vert,
                    tooltip: l10n.inboxItemActions,
                    onPressed: onMenu,
                  )
                else
                  const SizedBox(width: TixSpace.s2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _KindAvatar extends StatelessWidget {
  const _KindAvatar({required this.item});

  final InboxItem item;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    final handle = item.actorHandle;
    return SizedBox(
      width: 38,
      height: 38,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          TixAvatar(
            label: handle.isEmpty ? '?' : handle,
            hued: true,
            icon: handle.isEmpty ? Icons.person_outline : null,
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: ExcludeSemantics(
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: t.bg,
                  shape: BoxShape.circle,
                  border: Border.all(color: t.line),
                ),
                child: Icon(
                  inboxKindIcon(item.kind),
                  size: 11,
                  color: t.accent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
