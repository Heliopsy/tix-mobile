// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
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
  Widget build(BuildContext context) => TixPage(
    title: taskRef,
    titleWidget: Text(
      taskRef,
      style: tixMono(context, size: TixText.md, color: context.tix.muted),
    ),
    body: TaskDetailView(taskRef: taskRef, showRef: false),
  );
}

/// A task's fields and description, without a frame.
class TaskDetailView extends ConsumerWidget {
  /// Shows the task [taskRef].
  const TaskDetailView({required this.taskRef, this.showRef = true, super.key});

  /// The task's reference.
  final String taskRef;

  /// Whether the reference heads the view; off when a page header has it.
  final bool showRef;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = taskDetailProvider(taskRef);
    return AsyncBody(
      value: ref.watch(provider),
      onRetry: () => ref.invalidate(provider),
      loading: const _DetailSkeleton(),
      data: (task) => RefreshIndicator(
        onRefresh: () => ref.refresh(provider.future),
        child: _TaskBody(task: task, showRef: showRef),
      ),
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) => Semantics(
    label: context.l10n.loading,
    child: const Padding(
      padding: EdgeInsets.all(TixSpace.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 64),
          SizedBox(height: TixSpace.s3),
          SkeletonBox(width: 280, height: 22),
          SizedBox(height: TixSpace.s5),
          SkeletonBox(width: 200),
          SizedBox(height: TixSpace.s3),
          SkeletonBox(width: 160),
          SizedBox(height: TixSpace.s3),
          SkeletonBox(width: 220),
        ],
      ),
    ),
  );
}

class _TaskBody extends StatelessWidget {
  const _TaskBody({required this.task, required this.showRef});

  final Task task;
  final bool showRef;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final t = context.tix;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final due = task.dueAt;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        TixSpace.s5,
        TixSpace.s4,
        TixSpace.s5,
        TixSpace.s6,
      ),
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: TixMeasure.form),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showRef) ...[
                  RefText(task.ref, size: TixText.sm),
                  const SizedBox(height: TixSpace.s1),
                ],
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (task.starred)
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 3,
                          right: TixSpace.s2,
                        ),
                        child: Icon(
                          Icons.star_rounded,
                          color: t.accent,
                          semanticLabel: l10n.starred,
                        ),
                      ),
                    Expanded(
                      child: SelectableText(
                        task.title,
                        style: theme.textTheme.headlineSmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: TixSpace.s5),
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: t.line),
                    borderRadius: BorderRadius.circular(TixRadius.lg),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: TixSpace.s4,
                      vertical: TixSpace.s2,
                    ),
                    child: Column(
                      children: [
                        _Field(
                          label: l10n.fieldStatus,
                          child: Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: StatusPill(
                              key: const Key('task.status'),
                              label: task.status,
                            ),
                          ),
                        ),
                        _Field(
                          label: l10n.fieldPriority,
                          child: Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: PriorityMark(
                              priority: task.priority,
                              emphasizeNormal: true,
                            ),
                          ),
                        ),
                        _Field(
                          label: l10n.fieldAssignee,
                          child: task.assigneeActorId.isEmpty
                              ? Text(
                                  l10n.unassigned,
                                  style: TextStyle(
                                    color: t.muted,
                                    fontStyle: FontStyle.italic,
                                  ),
                                )
                              : AssigneeName(actorId: task.assigneeActorId),
                        ),
                        _Field(
                          label: l10n.fieldDue,
                          last: task.tags.isEmpty,
                          child: Text(
                            due == null
                                ? l10n.noDueDate
                                : DateFormat.yMMMEd(locale)
                                      .add_Hm()
                                      .format(due.toLocal()),
                            style: due == null
                                ? TextStyle(color: t.muted)
                                : null,
                          ),
                        ),
                        if (task.tags.isNotEmpty)
                          _Field(
                            label: l10n.fieldTags,
                            last: true,
                            child: Wrap(
                              spacing: TixSpace.s2,
                              runSpacing: TixSpace.s1,
                              children: [
                                for (final tag in task.tags) TagChip(tag),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SectionHeader(
                  title: l10n.fieldDescription,
                  padding: const EdgeInsets.only(
                    top: TixSpace.s5,
                    bottom: TixSpace.s2,
                  ),
                ),
                if (task.body.trim().isEmpty)
                  Text(l10n.noDescription, style: TextStyle(color: t.muted))
                else
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: TixMeasure.text,
                    ),
                    // flutter_markdown_plus still reads
                    // package:flutter/material.dart's theme; the bridge
                    // hands it ours until it moves to material_ui.
                    // ignore: deprecated_member_use
                    child: MaterialUiCompatibilityBridge(
                      child: MarkdownBody(data: task.body, selectable: true),
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

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child, this.last = false});

  final String label;
  final Widget child;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    return Container(
      constraints: const BoxConstraints(minHeight: 40),
      padding: const EdgeInsets.symmetric(vertical: TixSpace.s2),
      decoration: BoxDecoration(
        border: last ? null : Border(bottom: BorderSide(color: t.line)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: TixText.xs,
                fontWeight: FontWeight.w500,
                color: t.muted,
              ),
            ),
          ),
          Expanded(child: child),
        ],
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
