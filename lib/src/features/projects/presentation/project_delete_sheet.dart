// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/data/models/project_admin.dart';
import 'package:tix_mobile/src/features/projects/application/project_admin.dart';
import 'package:tix_mobile/src/features/projects/application/projects.dart';

/// Asks how to delete [project] and deletes it; true once deleted.
///
/// tix's plan says how many tasks the project holds. An empty project only
/// confirms. One with tasks needs a choice: move them to another project,
/// with the status each one takes there, or delete them with it after the
/// project's key is typed.
Future<bool> showProjectDeleteSheet(
  BuildContext context,
  Project project,
) async =>
    await showTixSheet<bool>(
      context,
      builder: (_) => _DeleteSheet(project: project),
    ) ??
    false;

enum _Fate { move, delete }

class _DeleteSheet extends ConsumerStatefulWidget {
  const _DeleteSheet({required this.project});

  final Project project;

  @override
  ConsumerState<_DeleteSheet> createState() => _DeleteSheetState();
}

class _DeleteSheetState extends ConsumerState<_DeleteSheet> {
  final _typed = TextEditingController();
  _Fate _fate = _Fate.move;
  String? _target;
  Object? _error;
  var _busy = false;

  Project get _p => widget.project;

  @override
  void dispose() {
    _typed.dispose();
    super.dispose();
  }

  Future<void> _delete({required bool holdsTasks}) async {
    final l10n = context.l10n;
    final move = holdsTasks && _fate == _Fate.move ? _target : null;
    final ok = await confirmDestructive(
      context,
      title: l10n.projectDeleteTitle(_p.key),
      body: move != null
          ? l10n.projectDeleteMoveConfirm(move)
          : l10n.projectDeleteConfirm,
      action: l10n.projectDelete,
    );
    if (!ok || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(projectSettingsProvider(_p.key).notifier)
          .delete(
            moveTasksTo: move,
            deleteTasks: holdsTasks && _fate == _Fate.delete,
          );
      if (!mounted) return;
      showTixToast(context, l10n.projectDeleted(_p.key));
      Navigator.of(context).pop(true);
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = e;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final plan = ref.watch(deletionPlanProvider(_p.key, null));
    final holds = plan.value == null
        ? null
        : plan.value!.tasks + plan.value!.deleted > 0;
    final canDelete =
        holds != null &&
        !_busy &&
        (!holds ||
            (_fate == _Fate.move && _target != null) ||
            (_fate == _Fate.delete && _typed.text.trim() == _p.key));
    final error = _error;
    return TixSheetBody(
      title: l10n.projectDeleteTitle(_p.key),
      actions: [
        TixButton.quiet(
          label: l10n.cancel,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        TixButton.danger(
          key: const Key('project.delete.ok'),
          label: l10n.projectDelete,
          busy: _busy,
          onPressed: canDelete ? () => _delete(holdsTasks: holds) : null,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (error != null) ...[
            TixNotice(errorDetail(l10n, error), tone: TixNoticeTone.danger),
            const SizedBox(height: TixSpace.s3),
          ],
          switch (plan) {
            AsyncData(:final value) =>
              holds! ? _choices(context, value) : Text(l10n.projectDeleteEmpty),
            AsyncError(:final error) => TixNotice(
              errorDetail(l10n, error),
              tone: TixNoticeTone.danger,
            ),
            _ => const SkeletonList(rows: 2, inline: true),
          },
        ],
      ),
    );
  }

  Widget _choices(BuildContext context, ProjectDeletion plan) {
    final l10n = context.l10n;
    final others = [
      for (final p in ref.watch(projectsProvider).value?.items ?? <Project>[])
        if (p.key != _p.key && p.archivedAt == null) p,
    ];
    return RadioGroup<_Fate>(
      groupValue: _fate,
      onChanged: (f) => setState(() => _fate = f ?? _fate),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.projectDeleteHolds(plan.tasks, plan.deleted)),
          const SizedBox(height: TixSpace.s2),
          RadioListTile<_Fate>(
            key: const Key('project.delete.move'),
            value: _Fate.move,
            enabled: others.isNotEmpty,
            title: Text(l10n.projectDeleteMove),
            subtitle: others.isEmpty ? Text(l10n.projectDeleteNoTarget) : null,
          ),
          if (_fate == _Fate.move && others.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: TixSpace.s4),
              child: TixSelectField<String>(
                fieldKey: const Key('project.delete.target'),
                label: l10n.projectDeleteTarget,
                value: _target,
                options: [
                  for (final p in others)
                    TixOption(
                      p.key,
                      p.name.isEmpty ? p.key : '${p.name} (${p.key})',
                      leading: ProjectMark(
                        name: p.name.isEmpty ? p.key : p.name,
                        colour: p.color,
                        icon: p.icon,
                        iconName: p.iconName,
                        size: TixSize.controlSmall,
                      ),
                    ),
                ],
                onChanged: (k) => setState(() => _target = k),
              ),
            ),
            if (_target != null) _Mapping(project: _p.key, target: _target!),
          ],
          RadioListTile<_Fate>(
            key: const Key('project.delete.tasks'),
            value: _Fate.delete,
            title: Text(l10n.projectDeleteTasks),
          ),
          if (_fate == _Fate.delete)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: TixSpace.s4),
              child: TixTextField(
                fieldKey: const Key('project.delete.typed'),
                label: l10n.projectDeleteType(_p.key),
                controller: _typed,
                onChanged: (_) => setState(() {}),
              ),
            ),
        ],
      ),
    );
  }
}

class _Mapping extends ConsumerWidget {
  const _Mapping({required this.project, required this.target});

  final String project;
  final String target;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tix;
    final plan = ref.watch(deletionPlanProvider(project, target));
    return Padding(
      padding: const EdgeInsets.all(TixSpace.s4),
      child: switch (plan) {
        AsyncData(:final value) => Column(
          key: const Key('project.delete.mapping'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TixFieldLabel(l10n.projectDeleteMapping),
            for (final m in value.statuses)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: TixSpace.s1),
                child: Row(
                  children: [
                    Text(m.from, style: tixMono(context)),
                    const SizedBox(width: TixSpace.s2),
                    Icon(Icons.arrow_forward, size: 16, color: t.muted),
                    const SizedBox(width: TixSpace.s2),
                    Text(m.to, style: tixMono(context)),
                    if (m.from != m.to) ...[
                      const SizedBox(width: TixSpace.s2),
                      TixBadge(l10n.manageChanged, tone: TixTone.warn),
                    ],
                    const Spacer(),
                    Text(l10n.manageTaskCount(m.tasks)),
                  ],
                ),
              ),
          ],
        ),
        AsyncError(:final error) => TixNotice(
          errorDetail(l10n, error),
          tone: TixNoticeTone.danger,
        ),
        _ => const SkeletonList(rows: 2, inline: true),
      },
    );
  }
}
