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
  final edit = await showTixSheet<(String, Task)>(
    context,
    builder: (context) => _DescriptionEditor(task: task),
  );
  if (edit == null || !context.mounted) return;
  final (body, base) = edit;
  if (body == base.body) return;
  await patchTask(context, ref, base, TaskPatch.body(body), checkVersion: true);
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

// Edits the description of a task that may change elsewhere meanwhile.
// The person's text is never replaced under them: a newer version shows
// ChangedElsewhereBanner, and saving goes against the version they chose to
// keep editing over, so tix's version check still catches anything later.
class _DescriptionEditor extends ConsumerStatefulWidget {
  const _DescriptionEditor({required this.task});

  final Task task;

  @override
  ConsumerState<_DescriptionEditor> createState() => _DescriptionEditorState();
}

class _DescriptionEditorState extends ConsumerState<_DescriptionEditor> {
  late final _controller = TextEditingController(text: widget.task.body);
  late Task _base = widget.task;
  var _preview = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() => Navigator.of(context).pop((_controller.text, _base));

  void _reload(Task latest) => setState(() {
    _base = latest;
    _controller.text = latest.body;
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final latest = ref
        .watch(taskDetailControllerProvider(widget.task.ref))
        .value;
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
          if (latest != null &&
              latest.version != _base.version &&
              latest.body != _base.body) ...[
            ChangedElsewhereBanner(
              key: const Key('description.changed'),
              onReload: () => _reload(latest),
              onDismiss: () => setState(() => _base = latest),
            ),
            const SizedBox(height: TixSpace.s3),
          ],
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

/// A list of related tasks, such as dependencies.
class _TaskList extends ConsumerWidget {
  const _TaskList({required this.tasks, this.onRemove, this.removeLabel});

  final List<Task> tasks;
  final void Function(Task task)? onRemove;
  final String Function(Task task)? removeLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockProvider)();
    return _Bordered(
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
    );
  }
}

/// The subtask tree under the task, folding by node, and a way to add one.
///
/// Draws [SubtaskTree.drawDepth] levels as the web does; a node on the last
/// level with subtasks of its own offers them, and loads that node's tree in
/// place. Every node starts open; folds last as long as the screen.
class SubtasksSection extends ConsumerStatefulWidget {
  /// The subtasks of [task].
  const SubtasksSection({required this.task, super.key});

  /// The parent task.
  final Task task;

  @override
  ConsumerState<SubtasksSection> createState() => _SubtasksSectionState();
}

class _SubtasksSectionState extends ConsumerState<SubtasksSection> {
  final _folded = <String>{};
  final _loaded = <String>{};

  bool _open(SubtaskNode node) =>
      !_folded.contains(node.task.ref) &&
      (node.children.isNotEmpty || _loaded.contains(node.task.ref));

  void _toggle(SubtaskNode node) => setState(() {
    final ref = node.task.ref;
    if (_open(node)) {
      _folded.add(ref);
    } else {
      _folded.remove(ref);
      if (node.more > 0) _loaded.add(ref);
    }
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final task = widget.task;
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

    final direct = subtasks.value?.nodes.length ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: l10n.taskDetailSubtasks,
          info: l10n.taskDetailSubtasksInfo,
          subtitle: direct > 0 ? l10n.taskDetailCount(direct) : null,
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
          AsyncData(:final value) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: TixSpace.s2,
            children: [
              if (value.shallow)
                Text(
                  l10n.taskDetailSubtasksShallow,
                  key: const Key('subtask.shallow'),
                  style: TextStyle(color: context.tix.muted),
                ),
              _Bordered(
                child: _SubtaskLevel(
                  nodes: value.nodes,
                  above: 0,
                  folds: value.nested,
                  tree: this,
                ),
              ),
            ],
          ),
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

/// The rounded outline a list of related tasks sits in.
class _Bordered extends StatelessWidget {
  const _Bordered({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      border: Border.all(color: context.tix.line),
      borderRadius: BorderRadius.circular(TixRadius.base),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(TixRadius.base),
      child: child,
    ),
  );
}

/// One level of the subtask tree, each node followed by what is open under
/// it. [above] is how many levels sit above [nodes]' own, for a level loaded
/// from a deeper node; [folds] reserves the fold column.
class _SubtaskLevel extends StatelessWidget {
  const _SubtaskLevel({
    required this.nodes,
    required this.above,
    required this.folds,
    required this.tree,
  });

  final List<SubtaskNode> nodes;
  final int above;
  final bool folds;
  final _SubtasksSectionState tree;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final node in nodes) ...[
        _SubtaskRow(
          node: node,
          level: above + node.level,
          folds: folds,
          tree: tree,
        ),
        if (!tree._folded.contains(node.task.ref)) ...[
          if (node.children.isNotEmpty)
            _SubtaskLevel(
              nodes: node.children,
              above: above,
              folds: folds,
              tree: tree,
            )
          else if (node.more > 0 && tree._loaded.contains(node.task.ref))
            _LoadedLevel(
              taskRef: node.task.ref,
              above: above + node.level,
              tree: tree,
            )
          else if (node.more > 0)
            _Indented(
              level: above + node.level + 1,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: TixButton.quiet(
                  key: Key('subtask.more.${node.task.ref}'),
                  label: context.l10n.taskDetailShowSubtasks(node.more),
                  size: TixButtonSize.small,
                  onPressed: () => tree._toggle(node),
                ),
              ),
            ),
        ],
      ],
    ],
  );
}

/// The levels under [taskRef], read from its own tree when asked for.
class _LoadedLevel extends ConsumerWidget {
  const _LoadedLevel({
    required this.taskRef,
    required this.above,
    required this.tree,
  });

  final String taskRef;
  final int above;
  final _SubtasksSectionState tree;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = taskSubtasksProvider(taskRef);
    return switch (ref.watch(provider)) {
      AsyncData(:final value) => _SubtaskLevel(
        nodes: value.nodes,
        above: above,
        folds: true,
        tree: tree,
      ),
      AsyncError(:final error) => _Indented(
        level: above + 1,
        child: ErrorState(
          error: error,
          compact: true,
          onRetry: () => ref.invalidate(provider),
        ),
      ),
      _ => const SkeletonList(rows: 1, leading: false, inline: true),
    };
  }
}

/// [child] moved in by its depth, up to a few levels so a deep row keeps
/// room for its title.
class _Indented extends StatelessWidget {
  const _Indented({required this.level, required this.child});

  static const _deepest = 5;

  final int level;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsetsDirectional.only(
      start: TixSpace.s5 * ((level < _deepest ? level : _deepest) - 1),
    ),
    child: child,
  );
}

/// One subtask: its fold control, then the row that opens it.
class _SubtaskRow extends ConsumerWidget {
  const _SubtaskRow({
    required this.node,
    required this.level,
    required this.folds,
    required this.tree,
  });

  final SubtaskNode node;
  final int level;
  final bool folds;
  final _SubtasksSectionState tree;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final task = node.task;
    final now = ref.watch(clockProvider)();
    final open = tree._open(node);
    return _Indented(
      level: level,
      child: Row(
        children: [
          if (node.children.isNotEmpty || node.more > 0)
            Semantics(
              expanded: open,
              child: TixIconButton(
                key: Key('subtask.fold.${task.ref}'),
                icon: open ? Icons.expand_more : Icons.chevron_right,
                tooltip: context.l10n.taskDetailSubtasksOf(task.ref),
                onPressed: () => tree._toggle(node),
              ),
            )
          else if (folds)
            const SizedBox(width: TixSize.target),
          Expanded(
            child: TaskRow(
              key: Key('related.${task.ref}'),
              task: task,
              now: now,
              onTap: () =>
                  context.go(Routes.task(projectKeyOf(task.ref), task.ref)),
            ),
          ),
        ],
      ),
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
