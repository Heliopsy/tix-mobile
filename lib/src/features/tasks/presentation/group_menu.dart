// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/data/models/group_pref.dart';
import 'package:tix_mobile/src/features/tasks/application/screen.dart';

enum _GroupAction { star, collapse, earlier, later, hide }

/// The three dots on a column, lane or heading: star, collapse, move and
/// hide, kept with the reader's account under [view].
class GroupMenu extends ConsumerWidget {
  /// The menu for [group] of [view], whose groups are [natural] in the
  /// view's own order.
  const GroupMenu({
    required this.view,
    required this.group,
    required this.label,
    required this.natural,
    this.horizontal = true,
    super.key,
  });

  /// The view: `board`, `lanes`, `mine` or `project:KEY`.
  final String view;

  /// The group.
  final String group;

  /// The group as the reader sees it, for the tooltip.
  final String label;

  /// Every group of the view in its natural order.
  final List<String> natural;

  /// Whether moving is left and right (columns) or up and down (headings).
  final bool horizontal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final provider = viewArrangementProvider(view);
    final pref = ref.watch(provider).value?[group] ?? GroupPref(group: group);
    Future<void> run(_GroupAction action) async {
      final n = ref.read(provider.notifier);
      try {
        await switch (action) {
          _GroupAction.star => n.star(group, starred: !pref.starred),
          _GroupAction.collapse => n.collapse(
            group,
            collapsed: !pref.collapsed,
          ),
          _GroupAction.earlier => n.move(group, -1, natural),
          _GroupAction.later => n.move(group, 1, natural),
          _GroupAction.hide => n.hide(group, hidden: true),
        };
      } on Object catch (e) {
        if (context.mounted) {
          showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
        }
      }
    }

    PopupMenuItem<_GroupAction> item(
      _GroupAction value,
      IconData icon,
      String text,
    ) => PopupMenuItem(
      key: Key('group.$group.${value.name}'),
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: TixSpace.s3),
          Text(text),
        ],
      ),
    );

    return PopupMenuButton<_GroupAction>(
      key: Key('group.$group.menu'),
      tooltip: l10n.boardGroupMenu(label),
      icon: Icon(Icons.more_horiz, size: 18, color: context.tix.muted),
      onSelected: run,
      itemBuilder: (_) => [
        item(
          _GroupAction.star,
          pref.starred ? Icons.star_outline : Icons.star,
          pref.starred ? l10n.unstar : l10n.star,
        ),
        item(
          _GroupAction.collapse,
          pref.collapsed ? Icons.unfold_more : Icons.unfold_less,
          pref.collapsed ? l10n.boardExpand : l10n.boardCollapse,
        ),
        item(
          _GroupAction.earlier,
          horizontal ? Icons.arrow_back : Icons.arrow_upward,
          horizontal ? l10n.boardMoveLeft : l10n.boardMoveUp,
        ),
        item(
          _GroupAction.later,
          horizontal ? Icons.arrow_forward : Icons.arrow_downward,
          horizontal ? l10n.boardMoveRight : l10n.boardMoveDown,
        ),
        item(_GroupAction.hide, Icons.visibility_off_outlined, l10n.boardHide),
      ],
    );
  }
}

/// "Hidden: N", listing the hidden groups of [view] to show again, and a
/// reset of the whole arrangement.
class HiddenGroups extends ConsumerWidget {
  /// Lists [hidden], labelled by [labelOf].
  const HiddenGroups({
    required this.view,
    required this.hidden,
    required this.labelOf,
    super.key,
  });

  /// The view.
  final String view;

  /// The hidden groups.
  final List<String> hidden;

  /// How a group reads.
  final String Function(String group) labelOf;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final provider = viewArrangementProvider(view);
    final prefs = ref.watch(provider).value ?? const {};
    if (prefs.isEmpty) return const SizedBox.shrink();
    Future<void> run(String? group) async {
      final n = ref.read(provider.notifier);
      try {
        await (group == null ? n.reset() : n.hide(group, hidden: false));
      } on Object catch (e) {
        if (context.mounted) {
          showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
        }
      }
    }

    return PopupMenuButton<String?>(
      key: Key('hidden.$view'),
      tooltip: l10n.boardArrangement,
      onSelected: run,
      itemBuilder: (_) => [
        for (final g in hidden)
          PopupMenuItem(
            key: Key('hidden.show.$g'),
            value: g,
            child: Row(
              children: [
                const Icon(Icons.visibility_outlined, size: 18),
                const SizedBox(width: TixSpace.s3),
                Text(l10n.boardShowGroup(labelOf(g))),
              ],
            ),
          ),
        PopupMenuItem(
          key: const Key('hidden.reset'),
          child: Row(
            children: [
              const Icon(Icons.restart_alt, size: 18),
              const SizedBox(width: TixSpace.s3),
              Text(l10n.boardResetArrangement),
            ],
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(TixSpace.s2),
        child: TixBadge(
          hidden.isEmpty
              ? l10n.boardArrangement
              : l10n.boardHiddenCount(hidden.length),
        ),
      ),
    );
  }
}

/// A heading over a run of rows in a grouped list: the name, its count, a
/// star when starred, and the [GroupMenu]. Tapping it collapses the group.
class GroupHeading extends ConsumerWidget {
  /// Heads [group] of [view].
  const GroupHeading({
    required this.view,
    required this.group,
    required this.label,
    required this.count,
    required this.natural,
    this.leading,
    super.key,
  });

  /// The view.
  final String view;

  /// The group.
  final String group;

  /// How it reads.
  final String label;

  /// How many rows it holds on the loaded pages.
  final int count;

  /// Every group of the view in its natural order.
  final List<String> natural;

  /// A mark before the name, such as a status pill or project mark.
  final Widget? leading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tix;
    final provider = viewArrangementProvider(view);
    final pref = ref.watch(provider).value?[group] ?? GroupPref(group: group);
    return Material(
      color: t.surface,
      child: InkWell(
        key: Key('heading.$group'),
        onTap: () => ref
            .read(provider.notifier)
            .collapse(group, collapsed: !pref.collapsed)
            .ignore(),
        child: Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: t.line)),
          ),
          padding: const EdgeInsets.only(left: TixSpace.s3),
          child: Row(
            children: [
              Icon(
                pref.collapsed ? Icons.chevron_right : Icons.expand_more,
                size: 18,
                color: t.muted,
              ),
              const SizedBox(width: TixSpace.s1),
              if (leading != null) ...[
                leading!,
                const SizedBox(width: TixSpace.s2),
              ],
              Flexible(
                child: Semantics(
                  header: true,
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: TixText.sm,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: TixSpace.s2),
              Text(
                '$count',
                style: TextStyle(fontSize: TixText.xs, color: t.muted),
              ),
              if (pref.starred) ...[
                const SizedBox(width: TixSpace.s1),
                Icon(Icons.star_rounded, size: 14, color: t.accent),
              ],
              const Spacer(),
              GroupMenu(
                view: view,
                group: group,
                label: label,
                natural: natural,
                horizontal: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
