// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show NumberFormat;
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
    final locale = Localizations.localeOf(context).toLanguageTag();
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
                final tile = MediaQuery.textScalerOf(context)
                    .scale(_statMinWidth);
                final columns = box.maxWidth >= tile * 4 + TixSpace.s2 * 3
                    ? 4
                    : 2;
                final stats = <Widget>[
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
                ];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < stats.length; i += columns) ...[
                      if (i > 0) const SizedBox(height: TixSpace.s2),
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (var j = i; j < i + columns; j++) ...[
                              if (j > i) const SizedBox(width: TixSpace.s2),
                              Expanded(child: stats[j]),
                            ],
                          ],
                        ),
                      ),
                    ],
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
                        Flexible(
                          child: Text(
                            '${l10n.inboxCategory(c.name)} '
                            '${compactCount(n, locale)}',
                            style: TextStyle(
                              fontSize: TixText.xs,
                              color: t.muted,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
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

// The narrowest a stat may be at 100% text, so four share a row only when
// each keeps room for four figures; it grows with the text scale.
const double _statMinWidth = 79;

// The number's line height, as a multiple of its size. Its box is exactly
// one such line tall, so a count never changes a tile's height.
const double _numberLine = 1.1;

/// One count in a tile that takes its width from the row, never from the
/// number: tabular figures, abbreviated past 999, and scaled down rather
/// than wrapped if it still does not fit.
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
    final locale = Localizations.localeOf(context).toLanguageTag();
    final full = NumberFormat.decimalPattern(locale).format(value);
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
        label: '$label: $full',
        excludeSemantics: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              key: const Key('inbox.summary.number'),
              height:
                  MediaQuery.textScalerOf(context).scale(TixText.xl) *
                  _numberLine,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  compactCount(value, locale),
                  maxLines: 1,
                  softWrap: false,
                  style: TextStyle(
                    fontSize: TixText.xl,
                    fontWeight: FontWeight.w700,
                    height: _numberLine,
                    color: colour,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
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
