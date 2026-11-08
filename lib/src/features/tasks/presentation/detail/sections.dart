// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/clock/clock.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/router/routes.dart';
import 'package:tix_mobile/src/core/theme/layout.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/features/tasks/application/task_detail.dart';
import 'package:tix_mobile/src/features/tasks/presentation/detail/actions.dart';
import 'package:tix_mobile/src/features/tasks/presentation/detail/editors.dart';
import 'package:tix_mobile/src/features/tasks/presentation/detail/mentions.dart';

/// Opens the description editor for [task] and saves what it returns.
Future<void> editDescription(
  BuildContext context,
  WidgetRef ref,
  Task task,
) async {
  final body = await showTixSheet<String>(
    context,
    builder: (context) => _DescriptionEditor(initial: task.body),
  );
  if (body == null || body == task.body || !context.mounted) return;
  await patchTask(context, ref, task, TaskPatch.body(body), checkVersion: true);
}

/// The description as Markdown, its checklist ticked in place.
class DescriptionSection extends ConsumerWidget {
  /// The description of [task].
  const DescriptionSection({required this.task, super.key});

  /// The task.
  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final checklist = task.checklist;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: l10n.fieldDescription,
          subtitle: checklist == null || checklist.total == 0
              ? null
              : l10n.taskDetailChecklist(checklist.done, checklist.total),
          padding: const EdgeInsets.only(top: TixSpace.s5, bottom: TixSpace.s2),
          trailing: _SectionAction(
            key: const Key('description.edit'),
            label: l10n.taskDetailEdit,
            icon: Icons.edit_outlined,
            onPressed: () => editDescription(context, ref, task),
          ),
        ),
        if (task.body.trim().isEmpty)
          InkWell(
            onTap: () => editDescription(context, ref, task),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: TixSpace.s3),
              child: Text(
                l10n.noDescription,
                style: TextStyle(color: context.tix.muted),
              ),
            ),
          )
        else
          TixMarkdown(
            key: const Key('task.description'),
            data: task.body,
            onLink: (uri) => openLink(ref, uri),
            onToggle: (item, {required done}) => changeTask(
              context,
              ref,
              task,
              TaskChange.check(item, done: done),
            ),
          ),
      ],
    );
  }
}

class _DescriptionEditor extends StatefulWidget {
  const _DescriptionEditor({required this.initial});

  final String initial;

  @override
  State<_DescriptionEditor> createState() => _DescriptionEditorState();
}

class _DescriptionEditorState extends State<_DescriptionEditor> {
  late final _controller = TextEditingController(text: widget.initial);
  var _preview = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() => Navigator.of(context).pop(_controller.text);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TixSheetBody(
      title: l10n.taskDetailEditDescription,
      actions: [
        TixButton.quiet(
          label: l10n.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        TixButton.primary(
          key: const Key('description.save'),
          label: l10n.taskDetailSave,
          onPressed: _save,
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: SegmentedButton<bool>(
              key: const Key('description.mode'),
              segments: [
                ButtonSegment(value: false, label: Text(l10n.taskDetailWrite)),
                ButtonSegment(value: true, label: Text(l10n.taskDetailPreview)),
              ],
              selected: {_preview},
              onSelectionChanged: (s) => setState(() => _preview = s.first),
            ),
          ),
          const SizedBox(height: TixSpace.s3),
          if (_preview && _controller.text.trim().isEmpty)
            Text(l10n.noDescription)
          else if (_preview)
            TixMarkdown(data: _controller.text)
          else
            MentionTextField(
              fieldKey: const Key('description.field'),
              controller: _controller,
              label: l10n.fieldDescription,
              hint: l10n.taskDetailDescriptionHint,
              minLines: 6,
              maxLines: 16,
              autofocus: true,
              onSubmit: _save,
            ),
        ],
      ),
    );
  }
}

/// A section heading's action: a labelled small button, or only its icon
/// on a phone at large text sizes, where the label would push the heading
/// off the screen.
class _SectionAction extends StatelessWidget {
  const _SectionAction({
    required this.label,
    required this.icon,
    required this.onPressed,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final large = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    if (large && context.isCompact) {
      return TixIconButton(icon: icon, tooltip: label, onPressed: onPressed);
    }
    return TixButton(
      label: label,
      icon: icon,
      size: TixButtonSize.small,
      onPressed: onPressed,
    );
  }
}

/// A list of related tasks: subtasks or dependencies.
class _TaskList extends ConsumerWidget {
  const _TaskList({required this.tasks, this.onRemove, this.removeLabel});

  final List<Task> tasks;
  final void Function(Task task)? onRemove;
  final String Function(Task task)? removeLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockProvider)();
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: context.tix.line),
        borderRadius: BorderRadius.circular(TixRadius.base),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(TixRadius.base),
        child: Column(
          children: [
            for (final task in tasks)
              Row(
                children: [
                  Expanded(
                    child: TaskRow(
                      key: Key('related.${task.ref}'),
                      task: task,
                      now: now,
                      onTap: () => context.go(
                        Routes.task(projectKeyOf(task.ref), task.ref),
                      ),
                    ),
                  ),
                  if (onRemove != null)
                    TixIconButton(
                      key: Key('related.remove.${task.ref}'),
                      icon: Icons.link_off,
                      tooltip: removeLabel!(task),
                      onPressed: () => onRemove!(task),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// The task's direct subtasks and a way to add one.
class SubtasksSection extends ConsumerWidget {
  /// The subtasks of [task].
  const SubtasksSection({required this.task, super.key});

  /// The parent task.
  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final provider = taskSubtasksProvider(task.ref);
    final subtasks = ref.watch(provider);
    Future<void> add() async {
      final title = await askText(
        context,
        title: l10n.taskDetailAddSubtask,
        label: l10n.taskDetailTitleLabel,
        allowEmpty: false,
        action: l10n.taskDetailAdd,
      );
      if (title == null || !context.mounted) return;
      await tryAction(
        context,
        () => ref
            .read(provider.notifier)
            .add(projectKeyOf(task.ref), title.trim()),
        success: l10n.taskDetailSubtaskAdded,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: l10n.taskDetailSubtasks,
          subtitle: subtasks.value?.isNotEmpty ?? false
              ? l10n.taskDetailCount(subtasks.value!.length)
              : null,
          padding: const EdgeInsets.only(top: TixSpace.s5, bottom: TixSpace.s2),
          trailing: _SectionAction(
            key: const Key('subtask.add'),
            label: l10n.taskDetailAddSubtask,
            icon: Icons.add,
            onPressed: add,
          ),
        ),
        switch (subtasks) {
          AsyncData(:final value) when value.isEmpty => Text(
            l10n.taskDetailNoSubtasks,
            style: TextStyle(color: context.tix.muted),
          ),
          AsyncData(:final value) => _TaskList(tasks: value),
          AsyncError(:final error) => ErrorState(
            error: error,
            compact: true,
            onRetry: () => ref.invalidate(provider),
          ),
          _ => const SkeletonList(rows: 2, leading: false, inline: true),
        },
      ],
    );
  }
}

/// The tasks this one waits for, with add and remove.
class DependenciesSection extends ConsumerWidget {
  /// The dependencies of [task].
  const DependenciesSection({required this.task, super.key});

  /// The waiting task.
  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final provider = taskDependenciesProvider(task.ref);
    final deps = ref.watch(provider);
    Future<void> add() async {
      final dep = await askText(
        context,
        title: l10n.taskDetailAddDependency,
        label: l10n.taskDetailDependsOn,
        hint: l10n.taskDetailDependsOnHint,
        allowEmpty: false,
        action: l10n.taskDetailAdd,
      );
      if (dep == null || !context.mounted) return;
      await tryAction(
        context,
        () => ref.read(provider.notifier).add(dep.trim()),
        success: l10n.taskDetailDependencyAdded(dep.trim()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: l10n.taskDetailDependencies,
          info: l10n.taskDetailDependenciesInfo,
          subtitle: task.blocked ? l10n.taskDetailBlocked : null,
          padding: const EdgeInsets.only(top: TixSpace.s5, bottom: TixSpace.s2),
          trailing: _SectionAction(
            key: const Key('dependency.add'),
            label: l10n.taskDetailAddDependency,
            icon: Icons.add,
            onPressed: add,
          ),
        ),
        switch (deps) {
          AsyncData(:final value) when value.isEmpty => Text(
            l10n.taskDetailNoDependencies,
            style: TextStyle(color: context.tix.muted),
          ),
          AsyncData(:final value) => _TaskList(
            tasks: value,
            removeLabel: (t) => l10n.taskDetailRemoveDependency(t.ref),
            onRemove: (t) => tryAction(
              context,
              () => ref.read(provider.notifier).remove(t),
              success: l10n.taskDetailDependencyRemoved(t.ref),
            ),
          ),
          AsyncError(:final error) => ErrorState(
            error: error,
            compact: true,
            onRetry: () => ref.invalidate(provider),
          ),
          _ => const SkeletonList(rows: 1, leading: false, inline: true),
        },
      ],
    );
  }
}
