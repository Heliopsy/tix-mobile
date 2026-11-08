// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/widgets/async_body.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/features/tasks/application/tasks.dart';

/// One task on a screen of its own, as phones show it.
class TaskDetailScreen extends StatelessWidget {
  /// Shows the task [taskRef].
  const TaskDetailScreen({required this.taskRef, super.key});

  /// The task's reference, such as `infra-8`.
  final String taskRef;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(taskRef)),
    body: TaskDetailView(taskRef: taskRef),
  );
}

/// A task's fields and description, without a frame.
class TaskDetailView extends ConsumerWidget {
  /// Shows the task [taskRef].
  const TaskDetailView({required this.taskRef, super.key});

  /// The task's reference.
  final String taskRef;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = taskDetailProvider(taskRef);
    return AsyncBody(
      value: ref.watch(provider),
      onRetry: () => ref.invalidate(provider),
      data: (task) => RefreshIndicator(
        onRefresh: () => ref.refresh(provider.future),
        child: _TaskBody(task: task),
      ),
    );
  }
}

class _TaskBody extends StatelessWidget {
  const _TaskBody({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final due = task.dueAt;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        SelectableText(task.title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 16),
        _Field(
          label: l10n.fieldStatus,
          child: Text(task.status, key: const Key('task.status')),
        ),
        _Field(
          label: l10n.fieldPriority,
          child: Text(l10n.priorityLabel('${task.priority}')),
        ),
        _Field(
          label: l10n.fieldAssignee,
          child: task.assigneeActorId.isEmpty
              ? Text(l10n.unassigned)
              : AssigneeName(actorId: task.assigneeActorId),
        ),
        _Field(
          label: l10n.fieldDue,
          child: Text(
            due == null
                ? l10n.noDueDate
                : DateFormat.yMMMEd(locale).add_Hm().format(due.toLocal()),
          ),
        ),
        if (task.tags.isNotEmpty)
          _Field(
            label: l10n.fieldTags,
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [for (final t in task.tags) Chip(label: Text('#$t'))],
            ),
          ),
        const Divider(height: 32),
        Text(l10n.fieldDescription, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        if (task.body.trim().isEmpty)
          Text(l10n.noDescription)
        else
          // flutter_markdown_plus still reads package:flutter/material.dart's
          // theme; the bridge hands it ours until it moves to material_ui.
          // ignore: deprecated_member_use
          MaterialUiCompatibilityBridge(
            child: MarkdownBody(data: task.body, selectable: true),
          ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: Theme.of(context).textTheme.labelLarge),
        ),
        Expanded(child: child),
      ],
    ),
  );
}

/// An actor's name, looked up by id; the id stands in until it arrives.
class AssigneeName extends ConsumerWidget {
  /// Names the actor [actorId].
  const AssigneeName({required this.actorId, super.key});

  /// The actor's id.
  final String actorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actor = ref.watch(actorProvider(actorId)).value;
    return Text(actor == null ? actorId : actor.label);
  }
}
