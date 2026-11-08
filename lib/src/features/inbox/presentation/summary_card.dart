// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/features/inbox/application/inbox.dart';

/// tix's state [category] as the design system's [StatusCategory].
StatusCategory categoryOf(StateCategory category) => switch (category) {
  StateCategory.todo => StatusCategory.todo,
  StateCategory.inProgress => StatusCategory.inProgress,
  StateCategory.blocked => StatusCategory.blocked,
  StateCategory.waiting => StatusCategory.waiting,
  StateCategory.done => StatusCategory.done,
  StateCategory.cancelled => StatusCategory.cancelled,
};

/// The numbers at the top of the inbox: the caller's overdue and due-today
/// tasks, the tenant's open work and what was finished this week, and the
/// open work by state. Draws nothing when the numbers cannot be read: a
/// summary is never a reason to hide the inbox.
class InboxSummaryCard extends ConsumerWidget {
  /// Creates the card.
  const InboxSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(inboxSummaryProvider);
    final t = context.tix;
    final l10n = context.l10n;
    final s = summary.value;
    if (s == null) {
      if (summary.hasError) return const SizedBox.shrink();
      return const Padding(
        padding: EdgeInsets.fromLTRB(TixSpace.s4, TixSpace.s2, TixSpace.s4, 0),
        child: SkeletonBox(height: 92, radius: TixRadius.lg),
      );
    }
    final categories = [
      for (final c in StatusCategory.values)
        if (c != StatusCategory.done &&
            c != StatusCategory.cancelled &&
            c != StatusCategory.unknown)
          (
            c,
            s.byCategory.entries
                .where((e) => categoryOf(e.key) == c)
                .fold(0, (n, e) => n + e.value),
          ),
    ].where((e) => e.$2 > 0).toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        TixSpace.s4,
        TixSpace.s2,
        TixSpace.s4,
        0,
      ),
      child: Container(
        key: const Key('inbox.summary'),
        padding: const EdgeInsets.all(TixSpace.s3),
        decoration: BoxDecoration(
          color: t.bg,
          border: Border.all(color: t.line),
          borderRadius: BorderRadius.circular(TixRadius.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LayoutBuilder(
              builder: (context, box) {
                final columns = box.maxWidth >= 340 ? 4 : 2;
                final width =
                    (box.maxWidth - TixSpace.s2 * (columns - 1)) / columns;
                return Wrap(
                  spacing: TixSpace.s2,
                  runSpacing: TixSpace.s2,
                  children: [
                    for (final stat in <Widget>[
                      _Stat(
                        key: const Key('inbox.summary.overdue'),
                        label: l10n.inboxSummaryOverdue,
                        value: s.overdue,
                        colour: s.overdue > 0 ? t.danger : t.muted,
                      ),
                      _Stat(
                        key: const Key('inbox.summary.today'),
                        label: l10n.inboxSummaryDueToday,
                        value: s.dueToday,
                        colour: s.dueToday > 0 ? t.warn : t.muted,
                      ),
                      _Stat(
                        key: const Key('inbox.summary.open'),
                        label: l10n.inboxSummaryOpen,
                        value: s.open,
                        colour: t.ink,
                      ),
                      _Stat(
                        key: const Key('inbox.summary.done'),
                        label: l10n.inboxSummaryDoneWeek,
                        value: s.completed,
                        colour: t.ok,
                      ),
                    ])
                      SizedBox(width: width, child: stat),
                  ],
                );
              },
            ),
            if (categories.isNotEmpty) ...[
              const SizedBox(height: TixSpace.s3),
              ClipRRect(
                borderRadius: BorderRadius.circular(TixRadius.pill),
                child: SizedBox(
                  height: 6,
                  child: Row(
                    children: [
                      for (final (c, n) in categories)
                        Expanded(
                          flex: n,
                          child: ColoredBox(color: t.status(c)),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: TixSpace.s2),
              Wrap(
                spacing: TixSpace.s3,
                runSpacing: TixSpace.s1,
                children: [
                  for (final (c, n) in categories)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: t.status(c),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: TixSpace.s1),
                        Text(
                          '${l10n.inboxCategory(c.name)} $n',
                          style: TextStyle(
                            fontSize: TixText.xs,
                            color: t.muted,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    required this.colour,
    super.key,
  });

  final String label;
  final int value;
  final Color colour;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TixSpace.s3,
        vertical: TixSpace.s2,
      ),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(TixRadius.md),
      ),
      child: Semantics(
        label: '$label: $value',
        excludeSemantics: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$value',
              style: TextStyle(
                fontSize: TixText.xl,
                fontWeight: FontWeight.w700,
                height: 1.1,
                color: colour,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: TixText.xs, color: t.muted),
            ),
          ],
        ),
      ),
    );
  }
}
