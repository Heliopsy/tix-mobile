// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/router/routes.dart';
import 'package:tix_mobile/src/core/widgets/async_body.dart';
import 'package:tix_mobile/src/core/widgets/paged_list_view.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/data/models/template.dart';
import 'package:tix_mobile/src/features/templates/application/templates.dart';
import 'package:tix_mobile/src/features/templates/presentation/template_sheets.dart';

/// Every template the person can read, with Use one tap away.
class TemplatesScreen extends ConsumerWidget {
  /// Creates the screen.
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    void create() => unawaited(showNewTemplate(context));
    final createAction = TixAction(
      key: const Key('templates.new'),
      label: l10n.templateNew,
      icon: Icons.add,
      onPressed: create,
    );
    return CommandScope(
      commands: [
        TixCommand(
          id: 'templates.new',
          label: l10n.templateNew,
          group: l10n.paletteGroupTemplates,
          icon: Icons.add,
          run: create,
        ),
      ],
      child: TixPage(
        title: l10n.templatesTitle,
        subtitle: l10n.templatesSubtitle,
        primaryAction: createAction,
        body: AsyncBody(
          value: ref.watch(templatesProvider),
          onRetry: () => ref.invalidate(templatesProvider),
          data: (paged) => PagedListView(
            paged: paged,
            padding: const EdgeInsets.only(bottom: 96),
            empty: EmptyState(
              icon: Icons.bolt,
              title: l10n.templatesEmpty,
              body: l10n.templatesEmptyBody,
              action: TixAction(
                key: const Key('templates.empty.new'),
                label: l10n.templateNew,
                icon: Icons.add,
                onPressed: create,
              ),
            ),
            onRefresh: () => ref.refresh(templatesProvider.future),
            onLoadMore: () => ref.read(templatesProvider.notifier).loadMore(),
            itemBuilder: (context, template) =>
                TemplateTile(template: template),
          ),
        ),
      ),
    );
  }
}

/// Creates a task from [template] and says so, offering to open it.
Future<void> useTemplate(
  BuildContext context,
  WidgetRef ref,
  TaskTemplate template,
) async {
  final l10n = context.l10n;
  final Task task;
  try {
    task = await ref.read(templatesProvider.notifier).use(template);
  } on Object catch (e) {
    if (context.mounted) {
      showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
    }
    return;
  }
  if (!context.mounted) return;
  final router = GoRouter.of(context);
  final key = task.ref.substring(0, task.ref.lastIndexOf('-').clamp(0, 999));
  showTixToast(
    context,
    l10n.taskCreated(task.ref),
    actionLabel: l10n.openButton,
    onAction: () => router.go(Routes.task(key, task.ref)),
  );
}

/// One template: its name, where it applies, what it creates, how often it
/// was used, and Use.
class TemplateTile extends ConsumerWidget {
  /// Draws [template].
  const TemplateTile({required this.template, super.key});

  /// The template.
  final TaskTemplate template;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final ok = await confirmDestructive(
      context,
      title: l10n.templateDeleteTitle(template.name),
      body: l10n.templateDeleteBody,
      action: l10n.templateDeleteAction,
    );
    if (!ok || !context.mounted) return;
    try {
      await ref.read(templatesProvider.notifier).delete(template);
      if (context.mounted) {
        showTixToast(context, l10n.templateDeleted(template.name));
      }
    } on Object catch (e) {
      if (context.mounted) {
        showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tix;
    final subtasks = template.subtaskCount;
    final facts = [
      if (subtasks > 0) l10n.templateSubtasks(subtasks),
      l10n.templateUses(template.uses),
    ].join(' · ');
    return InkWell(
      key: Key('templates.row.${template.name}'),
      onTap: () => unawaited(showEditTemplate(context, template)),
      child: Container(
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.symmetric(
          horizontal: TixSpace.s4,
          vertical: TixSpace.s3,
        ),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: t.line)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: TixSpace.s2,
                    runSpacing: TixSpace.s1,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        template.name,
                        style: const TextStyle(
                          fontSize: TixText.md,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (template.tenantWide)
                        TixBadge(l10n.templateEveryProject)
                      else
                        ProjectChip(projectKey: template.projectKey),
                    ],
                  ),
                  if (template.shape.title.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      template.shape.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 2),
                  Text(facts, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: TixSpace.s2),
            TixButton(
              key: Key('templates.use.${template.name}'),
              label: l10n.templateUse,
              icon: Icons.bolt,
              size: TixButtonSize.small,
              onPressed: () => unawaited(useTemplate(context, ref, template)),
            ),
            PopupMenuButton<String>(
              key: Key('templates.menu.${template.name}'),
              tooltip: l10n.templateMore,
              onSelected: (v) => unawaited(
                v == 'edit'
                    ? showEditTemplate(context, template)
                    : _delete(context, ref),
              ),
              itemBuilder: (_) => [
                PopupMenuItem(value: 'edit', child: Text(l10n.templateEdit)),
                PopupMenuItem(
                  key: Key('templates.delete.${template.name}'),
                  value: 'delete',
                  child: Text(
                    l10n.templateDelete,
                    style: TextStyle(color: t.danger),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
