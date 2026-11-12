// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/clock/clock.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/data/query/filter_expression.dart';
import 'package:tix_mobile/src/features/tasks/application/listing.dart';
import 'package:tix_mobile/src/features/tasks/application/screen.dart';

/// The line under the task screen's filter that says what the loaded tasks
/// add up to, as tix's web summary does: "12 to go, 3 done · across 4
/// projects · 2 held by an agent · 5 waiting on other tasks". The waiting
/// count narrows the list to those tasks, and a list hiding finished work
/// says so and offers them back.
class TaskSummaryLine extends ConsumerWidget {
  /// Sums up [tasks], the loaded rows of [query].
  const TaskSummaryLine({
    required this.query,
    required this.tasks,
    required this.view,
    super.key,
  });

  /// The listing the rows come from.
  final TaskQuery query;

  /// The loaded rows.
  final List<Task> tasks;

  /// The drawing in force; only the list hides finished work.
  final TaskView view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tix;
    final index = ref.watch(taskContextProvider).value;
    final now = ref.watch(clockProvider)();
    final s = summariseTasks(
      tasks,
      now,
      isDone: (Task task) => index?.isFinished(task) ?? isTaskDone(task),
    );
    final scope = query.scope;
    final screen = ref.read(taskScreenProvider(scope).notifier);
    final style = TextStyle(fontSize: TixText.sm, color: t.muted);
    final total = s.open + s.done;
    final offerFinished =
        scope is! MineScope && view == TaskView.list && query.openOnly;
    final expression = query.expression;
    final waitingShown =
        hasFilterTerm(expression, 'is:waiting-on') ||
        hasFilterTerm(expression, 'is:blocked');
    final InlineSpan lead = switch (total) {
      0 when query.openOnly => TextSpan(text: l10n.tasksSummaryNothingOpen),
      0 => TextSpan(text: l10n.tasksSummaryNothing),
      _ when s.open == 0 => TextSpan(text: l10n.tasksSummaryAllDone),
      _ => TextSpan(
        children: [
          TextSpan(
            text: '${s.open}',
            style: TextStyle(color: t.ink, fontWeight: FontWeight.w600),
          ),
          TextSpan(text: ' ${l10n.tasksSummaryToGo}'),
          if (s.done > 0) TextSpan(text: ', ${l10n.tasksSummaryDone(s.done)}'),
          if (s.projects > 0 && scope is! ProjectScope)
            TextSpan(text: ' · ${l10n.tasksSummaryProjects(s.projects)}'),
          if (s.held > 0) ...[
            const TextSpan(text: ' · '),
            TextSpan(
              text: l10n.tasksHeldByAgent(s.held),
              style: TextStyle(color: t.accent),
            ),
          ],
        ],
      ),
    };
    final counting = total > 0 && s.open > 0;
    return Padding(
      key: const Key('tasks.summary'),
      padding: const EdgeInsets.symmetric(horizontal: TixSpace.s4),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: TixSpace.s1,
        children: [
          Text.rich(lead, style: style),
          if (counting && s.waiting > 0) ...[
            Text('·', style: style),
            Tooltip(
              message: l10n.tasksSummaryWaitingHint,
              child: TixButton.quiet(
                key: const Key('tasks.summary.waiting'),
                label: l10n.tasksSummaryWaiting(s.waiting),
                size: TixButtonSize.small,
                onPressed: waitingShown
                    ? null
                    : () => screen.setExpression(
                        '$expression is:waiting-on'.trim(),
                      ),
              ),
            ),
          ],
          if (offerFinished) ...[
            Text('· ${l10n.tasksSummaryOpenOnly} ·', style: style),
            TixButton.quiet(
              key: const Key('tasks.summary.showFinished'),
              label: l10n.tasksSummaryShowFinished,
              size: TixButtonSize.small,
              onPressed: () => screen.setShowFinished(show: true),
            ),
          ],
        ],
      ),
    );
  }
}
