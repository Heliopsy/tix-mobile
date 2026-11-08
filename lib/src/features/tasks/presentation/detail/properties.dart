// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/clock/clock.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/router/routes.dart';
import 'package:tix_mobile/src/data/models/actor.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/features/tasks/application/task_detail.dart';
import 'package:tix_mobile/src/features/tasks/application/tasks.dart';
import 'package:tix_mobile/src/features/tasks/presentation/detail/actions.dart';
import 'package:tix_mobile/src/features/tasks/presentation/detail/editors.dart';

/// The edits a task's properties and its keys share.
extension TaskEdits on WidgetRef {
  /// Opens the move sheet for [task] and moves it.
  Future<void> moveTask(BuildContext context, Task task) async {
    final l10n = context.l10n;
    final Workflow workflow;
    try {
      workflow = await read(projectWorkflowProvider(task.projectId).future);
    } on Object catch (e) {
      if (context.mounted) {
        showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
      }
      return;
    }
    if (!context.mounted) return;
    final picked = await pickMove(
      context,
      status: task.status,
      workflow: workflow,
    );
    if (picked == null || !context.mounted) return;
    final controller = read(taskDetailControllerProvider(task.ref).notifier);
    final from = task.status;
    try {
      final result = await controller.move(picked.to, comment: picked.comment);
      final status = result.task?.status ?? picked.to;
      final category = statusCategoryOf(workflow.state(status));
      unawaited(
        category == StatusCategory.done
            ? TixHaptics.confirm()
            : TixHaptics.tick(),
      );
      if (!context.mounted) return;
      if (result.stopped.isNotEmpty) {
        showTixToast(
          context,
          l10n.taskDetailMoveStopped(result.stopped, result.reason),
          tone: TixTone.danger,
        );
        return;
      }
      showTixToast(
        context,
        l10n.taskDetailMoved(task.ref, status),
        onUndo: () => tryAction(context, () => controller.move(from)),
      );
    } on Object catch (e) {
      unawaited(TixHaptics.refuse());
      if (context.mounted) {
        showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
      }
    }
  }

  /// Asks for a priority and sets it.
  Future<void> setPriority(BuildContext context, Task task) async {
    final p = await pickPriority(context, task.priority);
    if (p == null || p == task.priority || !context.mounted) return;
    await patchTask(context, this, task, TaskPatch.priority(p));
  }

  /// Asks for an assignee and sets it.
  Future<void> setAssignee(BuildContext context, Task task) async {
    final picked = await pickActor(
      context,
      current: task.assigneeActorId,
      title: context.l10n.taskDetailAssigneeTitle,
    );
    if (picked == null ||
        picked.value == task.assigneeActorId ||
        !context.mounted) {
      return;
    }
    await patchTask(context, this, task, TaskPatch.assignee(picked.value));
  }

  /// Asks for a due date and sets it.
  Future<void> setDue(BuildContext context, Task task) async {
    final picked = await pickDue(context, this, current: task.dueAt);
    if (picked == null || !context.mounted) return;
    await patchTask(context, this, task, TaskPatch.due(picked.value));
  }

  /// Asks for a tag and puts it on [task].
  Future<void> addTag(BuildContext context, Task task) async {
    final name = await pickTag(context, task);
    if (name == null || !context.mounted) return;
    await changeTask(
      context,
      this,
      task,
      _tagChange(name, add: true),
      undo: _tagChange(name, add: false),
      success: context.l10n.taskDetailTagAdded(name),
    );
  }

  /// Takes [name] off [task].
  Future<void> removeTag(BuildContext context, Task task, String name) =>
      changeTask(
        context,
        this,
        task,
        _tagChange(name, add: false),
        undo: _tagChange(name, add: true),
        success: context.l10n.taskDetailTagRemoved(name),
      );

  /// Stars or unstars [task].
  Future<void> toggleStar(BuildContext context, Task task) {
    final l10n = context.l10n;
    final on = !task.starred;
    unawaited(TixHaptics.tick());
    return changeTask(
      context,
      this,
      task,
      TaskChange.star(starred: on),
      undo: TaskChange.star(starred: !on),
      success: on ? l10n.taskDetailStarred : l10n.taskDetailUnstarred,
    );
  }

  /// Asks until when and snoozes [task], or wakes it when snoozed.
  Future<void> snooze(BuildContext context, Task task) async {
    final l10n = context.l10n;
    final now = read(clockProvider)();
    final until = task.snoozedUntil;
    if (until != null && until.isAfter(now)) {
      await changeTask(
        context,
        this,
        task,
        TaskChange.snooze(null),
        undo: TaskChange.snooze(until),
        success: l10n.taskDetailWoken,
      );
      return;
    }
    final picked = await pickSnooze(context, now);
    if (picked == null || !context.mounted) return;
    final locale = Localizations.localeOf(context).toLanguageTag();
    await changeTask(
      context,
      this,
      task,
      TaskChange.snooze(picked),
      undo: TaskChange.snooze(null),
      success: l10n.taskDetailSnoozed(
        DateFormat.MMMEd(locale).add_Hm().format(picked),
      ),
    );
  }

  /// Asks for a repeat rule and sets it.
  Future<void> setRecurrence(BuildContext context, Task task) async {
    final l10n = context.l10n;
    final rule = await askText(
      context,
      title: l10n.taskDetailRepeatTitle,
      label: l10n.taskDetailRepeat,
      initial: task.recurrence,
      hint: l10n.taskDetailRepeatHint,
      help: l10n.taskDetailRepeatHelp,
    );
    if (rule == null || rule.trim() == task.recurrence || !context.mounted) {
      return;
    }
    await patchTask(context, this, task, TaskPatch.recurrence(rule.trim()));
  }
}

TaskChange _tagChange(String name, {required bool add}) => TaskChange(
  apply: (t) => t.copyWith(
    tags: add
        ? {...t.tags, name}.toList()
        : [
            for (final x in t.tags)
              if (x.toLowerCase() != name.toLowerCase()) x,
          ],
  ),
  send: (repo, server) async {
    if (add) {
      await repo.addTag(server.ref, name);
    } else {
      await repo.removeTag(server.ref, name);
    }
    return null;
  },
);

/// A task's attributes, each edited where it is shown.
class TaskProperties extends ConsumerWidget {
  /// The properties of [task].
  const TaskProperties({required this.task, super.key});

  /// The task.
  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tix;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final workflow = ref.watch(projectWorkflowProvider(task.projectId)).value;
    final fields =
        ref.watch(projectFieldsProvider(task.projectId)).value ?? const [];
    final project = ref.watch(projectByIdProvider(task.projectId)).value;
    final due = task.dueAt;
    final muted = TextStyle(color: t.muted);
    return TixPropertyList(
      children: [
        TixPropertyRow(
          key: const Key('prop.status'),
          label: l10n.fieldStatus,
          editLabel: l10n.taskDetailMoveTitle,
          onTap: () => ref.moveTask(context, task),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: StatusPill(
              key: const Key('task.status'),
              label: _statusLabel(workflow, task.status),
              category: statusCategoryOf(
                workflow?.state(task.status),
                task.status,
              ),
            ),
          ),
        ),
        TixPropertyRow(
          key: const Key('prop.priority'),
          label: l10n.fieldPriority,
          editLabel: l10n.taskDetailPriorityTitle,
          onTap: () => ref.setPriority(context, task),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: PriorityMark(priority: task.priority, emphasizeNormal: true),
          ),
        ),
        TixPropertyRow(
          key: const Key('prop.assignee'),
          label: l10n.fieldAssignee,
          editLabel: l10n.taskDetailAssigneeTitle,
          onTap: () => ref.setAssignee(context, task),
          child: task.assigneeActorId.isEmpty
              ? Text(l10n.unassigned, style: muted)
              : AssigneeName(actorId: task.assigneeActorId),
        ),
        TixPropertyRow(
          key: const Key('prop.due'),
          label: l10n.fieldDue,
          editLabel: l10n.taskDetailDueTitle,
          onTap: () => ref.setDue(context, task),
          child: due == null
              ? Text(l10n.noDueDate, style: muted)
              : Text(
                  DateFormat.yMMMEd(locale).format(due.toLocal()),
                  style: due.isBefore(ref.watch(clockProvider)())
                      ? TextStyle(color: t.danger, fontWeight: FontWeight.w500)
                      : null,
                ),
        ),
        TixPropertyRow(
          key: const Key('prop.tags'),
          label: l10n.fieldTags,
          child: Wrap(
            spacing: TixSpace.s1,
            runSpacing: TixSpace.s1,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final tag in task.tags)
                _RemovableTag(
                  tag: tag,
                  onRemove: () => ref.removeTag(context, task, tag),
                ),
              TixButton.quiet(
                key: const Key('tag.open'),
                label: l10n.taskDetailAddTag,
                icon: Icons.add,
                size: TixButtonSize.small,
                onPressed: () => ref.addTag(context, task),
              ),
            ],
          ),
        ),
        TixPropertyRow(
          key: const Key('prop.repeat'),
          label: l10n.taskDetailRepeat,
          info: l10n.taskDetailRepeatInfo,
          editLabel: l10n.taskDetailRepeatTitle,
          onTap: () => ref.setRecurrence(context, task),
          child: task.recurrence.isEmpty
              ? Text(l10n.taskDetailNoRepeat, style: muted)
              : Row(
                  children: [
                    Icon(Icons.repeat, size: 16, color: t.muted),
                    const SizedBox(width: TixSpace.s1),
                    Flexible(child: Text(task.recurrence)),
                  ],
                ),
        ),
        for (final def in fields) _FieldRow(task: task, def: def),
        TixPropertyRow(
          label: l10n.taskDetailProject,
          child: Text(
            project == null
                ? projectKeyOf(task.ref)
                : project.name.isEmpty
                ? project.key
                : project.name,
          ),
        ),
        if (task.parentId.isNotEmpty)
          TixPropertyRow(
            key: const Key('prop.parent'),
            label: l10n.taskDetailParent,
            child: RelatedTaskLink(id: task.parentId),
          ),
        if (task.copiedFromId.isNotEmpty)
          TixPropertyRow(
            key: const Key('prop.copied'),
            label: l10n.taskDetailCopiedFrom,
            child: RelatedTaskLink(id: task.copiedFromId),
          ),
        if (task.createdAt != null)
          TixPropertyRow(
            label: l10n.taskDetailCreated,
            child: Text(
              DateFormat.yMMMd(locale)
                  .add_Hm()
                  .format(task.createdAt!.toLocal()),
            ),
          ),
        if (task.updatedAt != null)
          TixPropertyRow(
            label: l10n.taskDetailUpdated,
            child: Text(
              DateFormat.yMMMd(locale)
                  .add_Hm()
                  .format(task.updatedAt!.toLocal()),
            ),
          ),
      ],
    );
  }
}

String _statusLabel(Workflow? workflow, String status) {
  final s = workflow?.state(status);
  return s == null ? status : s.name;
}

class _RemovableTag extends StatelessWidget {
  const _RemovableTag({required this.tag, required this.onRemove});

  final String tag;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      TagChip(tag),
      SizedBox.square(
        dimension: 32,
        child: IconButton(
          key: Key('tag.remove.$tag'),
          padding: EdgeInsets.zero,
          iconSize: 14,
          tooltip: context.l10n.taskDetailRemoveTag(tag),
          icon: const Icon(Icons.close),
          onPressed: onRemove,
        ),
      ),
    ],
  );
}

class _FieldRow extends ConsumerWidget {
  const _FieldRow({required this.task, required this.def});

  final Task task;
  final FieldDef def;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final value = task.customFields[def.key];
    Future<void> edit() async {
      final picked = await editField(context, ref, def, value);
      if (picked == null || picked.value == value || !context.mounted) return;
      await patchTask(
        context,
        ref,
        task,
        TaskPatch.field(def.key, picked.value),
      );
    }

    final Widget shown;
    if (def.typeName == 'bool') {
      shown = Align(
        alignment: AlignmentDirectional.centerStart,
        child: Switch(
          key: Key('field.${def.key}.switch'),
          value: value == true,
          onChanged: (_) => edit(),
        ),
      );
    } else if (def.typeName == 'actor' && value is String && value.isNotEmpty) {
      shown = AssigneeName(actorId: value);
    } else {
      final text = fieldText(context, def, value);
      shown = text.isEmpty
          ? Text('—', style: TextStyle(color: context.tix.muted))
          : Text(text, maxLines: 4, overflow: TextOverflow.ellipsis);
    }
    return TixPropertyRow(
      key: Key('field.${def.key}'),
      label: def.required ? '${def.name} *' : def.name,
      editLabel: l10n.taskDetailEditField(def.name),
      onTap: def.typeName == 'bool' ? null : edit,
      child: shown,
    );
  }
}

/// A link to the task [id]: its reference and title once read.
class RelatedTaskLink extends ConsumerWidget {
  /// Links the task [id].
  const RelatedTaskLink({required this.id, super.key});

  /// The task's id or reference.
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final task = ref.watch(relatedTaskProvider(id)).value;
    if (task == null) return RefText(id, size: TixText.sm);
    return InkWell(
      onTap: () => context.go(Routes.task(projectKeyOf(task.ref), task.ref)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: TixSpace.s1),
        child: Row(
          children: [
            RefText(task.ref, size: TixText.sm),
            const SizedBox(width: TixSpace.s2),
            Flexible(
              child: Text(
                task.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: context.tix.accent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// An actor's name with their avatar, looked up by id; the id stands in
/// until it arrives.
class AssigneeName extends ConsumerWidget {
  /// Names the actor [actorId].
  const AssigneeName({required this.actorId, super.key});

  /// The actor's id.
  final String actorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actor = ref.watch(actorProvider(actorId)).value;
    final name = actor == null ? actorId : actor.label;
    return Row(
      children: [
        TixAvatar(label: name, seed: actor?.handle ?? actorId, size: 22),
        const SizedBox(width: TixSpace.s2),
        Flexible(child: Text(name)),
      ],
    );
  }
}
