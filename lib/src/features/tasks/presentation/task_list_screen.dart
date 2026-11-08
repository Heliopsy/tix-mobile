// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/clock/clock.dart';
import 'package:tix_mobile/src/core/design/design.dart';
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
  static const listPaneWidth = 420.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final provider = projectTasksProvider(projectKey);
    void add() => showQuickAdd(context, projectKey);
    final addAction = TixAction(
      key: const Key('tasks.quickAdd'),
      label: l10n.newTask,
      icon: Icons.add,
      onPressed: add,
    );
    final list = AsyncBody(
      value: ref.watch(provider),
      onRetry: () => ref.invalidate(provider),
      data: (paged) => PagedListView(
        paged: paged,
        padding: EdgeInsets.only(bottom: context.isCompact ? 96 : 0),
        empty: EmptyState(
          icon: Icons.task_alt,
          title: l10n.tasksEmpty,
          body: l10n.tasksEmptyBody,
          action: TixAction(
            key: const Key('tasks.empty.add'),
            label: l10n.newTask,
            icon: Icons.add,
            onPressed: add,
          ),
        ),
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
    return CommandScope(
      commands: [
        TixCommand(
          id: 'tasks.new',
          label: l10n.newTask,
          group: l10n.commandsTasks,
          icon: Icons.add,
          shortcut: const SingleActivator(LogicalKeyboardKey.keyN),
          run: add,
        ),
        TixCommand(
          id: 'tasks.refresh',
          label: l10n.refresh,
          group: l10n.commandsTasks,
          icon: Icons.refresh,
          shortcut: const SingleActivator(LogicalKeyboardKey.keyR),
          run: () => ref.invalidate(provider),
        ),
      ],
      child: TixPage(
        title: projectKey,
        titleWidget: Text(projectKey),
        primaryAction: addAction,
        body: context.isTwoPane
            ? Row(
                children: [
                  SizedBox(width: listPaneWidth, child: list),
                  const VerticalDivider(width: 1),
                  Expanded(
                    child: selected == null
                        ? EmptyState(
                            icon: Icons.touch_app_outlined,
                            title: l10n.noTaskSelected,
                          )
                        : TaskDetailView(
                            key: ValueKey(selected),
                            taskRef: selected,
                          ),
                  ),
                ],
              )
            : list,
      ),
    );
  }
}

/// One task in a list: a [TaskRow] with its assignee's handle looked up.
class TaskTile extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final handle = task.assigneeActorId.isEmpty
        ? ''
        : ref.watch(actorProvider(task.assigneeActorId)).value?.handle ?? '';
    return TaskRow(
      task: task,
      selected: selected,
      onTap: onTap,
      now: ref.watch(clockProvider)(),
      facts: TaskFacts(assigneeHandle: handle),
    );
  }
}
