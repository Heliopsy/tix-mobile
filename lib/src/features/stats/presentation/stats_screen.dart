// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/durations.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/router/routes.dart';
import 'package:tix_mobile/src/core/time/times.dart';
import 'package:tix_mobile/src/core/widgets/actor_link.dart';
import 'package:tix_mobile/src/core/widgets/async_body.dart';
import 'package:tix_mobile/src/data/models/project.dart';
import 'package:tix_mobile/src/features/stats/application/stats.dart';

/// Throughput, lead times, where the work is, who moved it and what waits
/// longest, over a window ending now, as tix's web Statistics screen.
class StatsScreen extends ConsumerWidget {
  /// Creates the screen.
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final query = ref.watch(statsFilterProvider);
    final report = ref.watch(statsReportProvider(query));
    return TixPage(
      title: l10n.statsTitle,
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(statsReportProvider(query).future),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: TixSpace.s7),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                TixSpace.gutter,
                TixSpace.s2,
                TixSpace.gutter,
                0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.statsIntro,
                      style: TextStyle(color: context.tix.muted),
                    ),
                  ),
                  InfoTip(l10n.statsInfo),
                ],
              ),
            ),
            _Controls(query: query),
            AsyncBody(
              value: report,
              onRetry: () => ref.invalidate(statsReportProvider(query)),
              loading: const SkeletonList(rows: 6, inline: true),
              data: (stats) => _Report(stats: stats),
            ),
          ],
        ),
      ),
    );
  }
}

class _Controls extends ConsumerWidget {
  const _Controls({required this.query});

  final StatsQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final filter = ref.read(statsFilterProvider.notifier);
    final projects = ref.watch(statsProjectsProvider).value;
    final list = projects?.projects ?? const <Project>[];
    final chosen = list.any((p) => p.key == query.project) ? query.project : '';
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        TixSpace.gutter,
        TixSpace.s3,
        TixSpace.gutter,
        TixSpace.s2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.statsWindow, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: TixSpace.s2),
          TixChoices<int>(
            key: const Key('stats.window'),
            choices: [
              for (final d in statsWindows) TixChoice(d, l10n.statsDays(d)),
            ],
            selected: query.days,
            onSelected: filter.window,
          ),
          const SizedBox(height: TixSpace.s3),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: TixMeasure.field),
            child: DropdownButtonFormField<String>(
              key: const Key('stats.project'),
              initialValue: chosen,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.statsProject),
              items: [
                DropdownMenuItem(
                  value: '',
                  child: Text(l10n.statsEveryProject),
                ),
                for (final p in list)
                  DropdownMenuItem(
                    value: p.key,
                    child: ProjectOption(project: p, selected: p.key == chosen),
                  ),
              ],
              onChanged: (v) => filter.project(v ?? ''),
            ),
          ),
          if (projects != null && !projects.whole) ...[
            const SizedBox(height: TixSpace.s2),
            Text(
              l10n.statsShortProjects,
              key: const Key('stats.shortProjects'),
              style: TextStyle(color: context.tix.muted, fontSize: TixText.sm),
            ),
          ],
        ],
      ),
    );
  }
}

class _Report extends StatelessWidget {
  const _Report({required this.stats});

  final Stats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Figures(stats: stats),
        TixSection(
          title: l10n.statsPerDay,
          info: l10n.statsPerDayInfo,
          children: [
            if (stats.perDay.every((d) => d.completed == 0))
              _Empty(l10n.statsNoneCompleted, id: 'stats.perDay.empty')
            else
              _DayBars(days: stats.perDay),
          ],
        ),
        TixSection(
          title: l10n.statsWhere,
          info: l10n.statsWhereInfo,
          children: [
            if (stats.byCategory.every((c) => c.count == 0))
              _Empty(l10n.statsNoTasks, id: 'stats.where.empty')
            else
              _Spread(categories: stats.byCategory),
          ],
        ),
        TixSection(
          title: l10n.statsActive,
          info: l10n.statsActiveInfo,
          subtitle: l10n.statsCounting(
            _measure(l10n, stats.leaderboardMeasure),
          ),
          children: [
            if (stats.topActors.isEmpty)
              _Empty(l10n.statsNobody, id: 'stats.active.empty')
            else
              _Leaders(actors: stats.topActors),
          ],
        ),
        TixSection(
          title: l10n.statsWaiting,
          info: l10n.statsWaitingInfo,
          children: [
            if (stats.oldest.isEmpty)
              _Empty(l10n.statsNothingWaiting, id: 'stats.waiting.empty')
            else
              for (final task in stats.oldest) _Waiting(task: task),
          ],
        ),
      ],
    );
  }

  /// The leaderboard's measure in the reader's language when the app knows
  /// it, else as the server wrote it.
  static String _measure(AppLocalizations l10n, String measure) =>
      measure.isEmpty || measure == 'tasks moved to a terminal state'
      ? l10n.statsMeasureMoved
      : measure;
}

class _Empty extends StatelessWidget {
  const _Empty(this.text, {required this.id});

  final String text;
  final String id;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(TixSpace.s4),
    child: Text(
      text,
      key: Key(id),
      style: TextStyle(color: context.tix.muted),
    ),
  );
}

class _Figures extends StatelessWidget {
  const _Figures({required this.stats});

  final Stats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    String lead(String d) => d.isEmpty ? '–' : humanDuration(l10n, d);
    final figures = [
      ('completed', '${stats.completed}', l10n.statsCompleted),
      ('created', '${stats.created}', l10n.statsCreated),
      ('median', lead(stats.medianLeadTime), l10n.statsMedianLead),
      ('slowest', lead(stats.slowestLeadTime), l10n.statsSlowest),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: TixSpace.s4,
        vertical: TixSpace.s2,
      ),
      child: LayoutBuilder(
        builder: (context, box) {
          final wide =
              box.maxWidth >=
              MediaQuery.textScalerOf(context).scale(TixMeasure.text);
          final columns = wide ? 4 : 2;
          return Wrap(
            runSpacing: TixSpace.s3,
            children: [
              for (final (id, value, caption) in figures)
                SizedBox(
                  width: box.maxWidth / columns,
                  child: _Figure(id: id, value: value, caption: caption),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.id, required this.value, required this.caption});

  final String id;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    return MergeSemantics(
      child: Column(
        key: Key('stats.figure.$id'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: t.ink,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          Text(
            caption,
            style: TextStyle(color: t.muted, fontSize: TixText.sm),
          ),
        ],
      ),
    );
  }
}

/// Completed tasks per day as columns, time running across.
class _DayBars extends StatelessWidget {
  const _DayBars({required this.days});

  final List<StatsDay> days;

  static const double _barHeight = TixSpace.s7 * 2;
  static const double _labelWidth = TixSpace.s7;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tix;
    final style = context.times.style.plain;
    final top = days.fold(0, (n, d) => math.max(n, d.completed));
    DateTime? day(String s) {
      final d = DateTime.tryParse(s);
      return d == null ? null : DateTime.utc(d.year, d.month, d.day);
    }

    return Semantics(
      label: l10n.statsPerDayLabel,
      container: true,
      child: Padding(
        padding: const EdgeInsets.all(TixSpace.s3),
        child: LayoutBuilder(
          builder: (context, box) {
            final every = math.max(
              1,
              (days.length * _labelWidth / box.maxWidth).ceil(),
            );
            return Row(
              key: const Key('stats.perDay'),
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < days.length; i++)
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final d = days[i];
                        final date = day(d.date);
                        final label = date == null
                            ? d.date
                            : style.dayMonth(date);
                        final full = date == null ? d.date : style.date(date);
                        final labelled = i % every == 0 || i == days.length - 1;
                        return Tooltip(
                          message: l10n.statsDayCompleted(full, d.completed),
                          child: Semantics(
                            label: l10n.statsDayCompleted(full, d.completed),
                            excludeSemantics: true,
                            child: Column(
                              key: Key('stats.day.${d.date}'),
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (every == 1)
                                  Text(
                                    '${d.completed}',
                                    style: TextStyle(
                                      fontSize: TixText.xs,
                                      color: t.muted,
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: TixSpace.s1 / 4,
                                  ),
                                  child: Container(
                                    height: top == 0
                                        ? 0
                                        : math.max(
                                            d.completed == 0 ? 0 : 2,
                                            _barHeight * d.completed / top,
                                          ),
                                    decoration: BoxDecoration(
                                      color: t.accent,
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(TixRadius.sm),
                                      ),
                                    ),
                                  ),
                                ),
                                const Divider(height: 1),
                                SizedBox(
                                  height: TixSpace.s5,
                                  child: labelled
                                      ? OverflowBox(
                                          maxWidth: _labelWidth,
                                          child: Text(
                                            label,
                                            maxLines: 1,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: TixText.xs,
                                              color: t.muted,
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// The tasks in each state category now, as one divided bar and its key.
class _Spread extends StatelessWidget {
  const _Spread({required this.categories});

  final List<StatsCategory> categories;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tix;
    final shown = [
      for (final c in categories)
        if (c.category case final cat?) (cat, c.count),
    ];
    return Padding(
      padding: const EdgeInsets.all(TixSpace.s3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            label: l10n.statsSpread,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(TixRadius.pill),
              child: SizedBox(
                height: TixSpace.s2,
                child: Row(
                  children: [
                    for (final (c, n) in shown)
                      if (n > 0)
                        Expanded(
                          flex: n,
                          child: ColoredBox(color: t.status(_category(c))),
                        ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: TixSpace.s3),
          Wrap(
            spacing: TixSpace.s4,
            runSpacing: TixSpace.s2,
            children: [
              for (final (c, n) in shown)
                Row(
                  key: Key('stats.category.${c.value}'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: TixSpace.s2,
                      height: TixSpace.s2,
                      decoration: BoxDecoration(
                        color: t.status(_category(c)),
                        borderRadius: BorderRadius.circular(TixRadius.sm),
                      ),
                    ),
                    const SizedBox(width: TixSpace.s2),
                    Text(_name(l10n, c)),
                    const SizedBox(width: TixSpace.s2),
                    Text(
                      '$n',
                      style: TextStyle(
                        color: t.muted,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  static StatusCategory _category(StateCategory c) => switch (c) {
    StateCategory.todo => StatusCategory.todo,
    StateCategory.inProgress => StatusCategory.inProgress,
    StateCategory.blocked => StatusCategory.blocked,
    StateCategory.waiting => StatusCategory.waiting,
    StateCategory.done => StatusCategory.done,
    StateCategory.cancelled => StatusCategory.cancelled,
  };

  static String _name(AppLocalizations l10n, StateCategory c) => switch (c) {
    StateCategory.todo => l10n.categoryTodo,
    StateCategory.inProgress => l10n.categoryInProgress,
    StateCategory.blocked => l10n.categoryBlocked,
    StateCategory.waiting => l10n.categoryWaiting,
    StateCategory.done => l10n.categoryDone,
    StateCategory.cancelled => l10n.categoryCancelled,
  };
}

/// Who moved the most tasks to a terminal state, each against the busiest.
class _Leaders extends StatelessWidget {
  const _Leaders({required this.actors});

  final List<StatsActor> actors;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    final top = actors.fold(1, (n, a) => math.max(n, a.moved));
    return Column(
      children: [
        for (final a in actors)
          ActorLink(
            key: Key('stats.actor.${a.actorId}'),
            actor: a.actorId,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: TixSpace.s3,
                vertical: TixSpace.s2,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: TixSpace.s7 * 2.5,
                    child: Text(
                      a.handle.isEmpty ? a.actorId : a.handle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(
                    width: TixSpace.s6,
                    child: Text(
                      '${a.moved}',
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  const SizedBox(width: TixSpace.s3),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(TixRadius.pill),
                      child: LinearProgressIndicator(
                        value: a.moved / top,
                        minHeight: TixSpace.s2,
                        color: t.accent,
                        backgroundColor: t.surface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// One task that has waited longest: reference, title, state and age.
class _Waiting extends StatelessWidget {
  const _Waiting({required this.task});

  final StatsAgeing task;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tix;
    final project = task.ref.contains('-')
        ? task.ref.substring(0, task.ref.lastIndexOf('-'))
        : '';
    return ListTile(
      key: Key('stats.waiting.${task.ref}'),
      title: Text(task.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        [
          task.ref.toUpperCase(),
          task.status,
          l10n.statsAge(humanDuration(l10n, task.age)),
        ].join(' · '),
        style: TextStyle(color: t.muted),
      ),
      onTap: project.isEmpty
          ? null
          : () => context.push(Routes.task(project, task.ref)),
    );
  }
}
