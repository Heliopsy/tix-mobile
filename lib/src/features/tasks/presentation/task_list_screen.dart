// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/router/router.dart';
import 'package:tix_mobile/src/core/theme/layout.dart';
import 'package:tix_mobile/src/core/widgets/async_body.dart';
import 'package:tix_mobile/src/core/widgets/paged_list_view.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/features/tasks/application/tasks.dart';
import 'package:tix_mobile/src/features/tasks/presentation/quick_add_sheet.dart';
import 'package:tix_mobile/src/features/tasks/presentation/task_detail_screen.dart';

/// The tasks of one project; on wide screens beside the selected task.
class TaskListScreen extends ConsumerWidget {
  /// Lists the tasks of [projectKey], highlighting [selectedRef].
  const TaskListScreen({required this.projectKey, this.selectedRef, super.key});

  /// The project's key.
  final String projectKey;

  /// The task open beside the list on wide screens.
  final String? selectedRef;

  /// The width of the list pane in the two-pane layout.
  static const listPaneWidth = 380.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final provider = projectTasksProvider(projectKey);
    final list = AsyncBody(
      value: ref.watch(provider),
      onRetry: () => ref.invalidate(provider),
      data: (paged) => PagedListView(
        paged: paged,
        empty: l10n.tasksEmpty,
        onRefresh: () => ref.refresh(provider.future),
        onLoadMore: () => ref.read(provider.notifier).loadMore(),
        itemBuilder: (context, task) => TaskTile(
          task: task,
          selected: task.ref == selectedRef,
          onTap: () => context.go(Routes.task(projectKey, task.ref)),
        ),
      ),
    );
    final selected = selectedRef;
    return Scaffold(
      appBar: AppBar(title: Text(projectKey)),
      floatingActionButton: FloatingActionButton(
        key: const Key('tasks.quickAdd'),
        tooltip: l10n.quickAddTitle,
        onPressed: () => showQuickAdd(context, projectKey),
        child: const Icon(Icons.add),
      ),
      body: context.isTwoPane
          ? Row(
              children: [
                SizedBox(width: listPaneWidth, child: list),
                const VerticalDivider(width: 1),
                Expanded(
                  child: selected == null
                      ? Center(child: Text(l10n.noTaskSelected))
                      : TaskDetailView(
                          key: ValueKey(selected),
                          taskRef: selected,
                        ),
                ),
              ],
            )
          : list,
    );
  }
}

/// One task in a list.
class TaskTile extends StatelessWidget {
  /// Draws [task].
  const TaskTile({
    required this.task,
    required this.onTap,
    this.selected = false,
    super.key,
  });

  /// The task.
  final Task task;

  /// Opens the task.
  final VoidCallback onTap;

  /// Whether the task is the one open beside the list.
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final due = task.dueAt;
    return ListTile(
      selected: selected,
      leading: PriorityIcon(priority: task.priority),
      title: Text(task.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        [
          task.ref,
          task.status,
          if (due != null) DateFormat.MMMd(locale).format(due.toLocal()),
        ].join(' · '),
      ),
      onTap: onTap,
    );
  }
}

/// A task's priority as an icon: arrows for high and low, nothing for normal.
class PriorityIcon extends StatelessWidget {
  /// Draws [priority], 1 the highest and 5 the lowest.
  const PriorityIcon({required this.priority, super.key});

  /// The priority.
  final int priority;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label = context.l10n.priorityLabel('$priority');
    return switch (priority) {
      1 => Icon(
        Icons.keyboard_double_arrow_up,
        color: scheme.error,
        semanticLabel: label,
      ),
      2 => Icon(
        Icons.keyboard_arrow_up,
        color: scheme.error,
        semanticLabel: label,
      ),
      4 => Icon(
        Icons.keyboard_arrow_down,
        color: scheme.outline,
        semanticLabel: label,
      ),
      5 => Icon(
        Icons.keyboard_double_arrow_down,
        color: scheme.outline,
        semanticLabel: label,
      ),
      _ => Icon(
        Icons.remove,
        color: scheme.outlineVariant,
        semanticLabel: label,
      ),
    };
  }
}
