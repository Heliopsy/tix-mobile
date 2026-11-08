// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/router/router.dart';
import 'package:tix_mobile/src/core/session/access.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/widgets/async_body.dart';
import 'package:tix_mobile/src/core/widgets/paged_list_view.dart';
import 'package:tix_mobile/src/data/models/project.dart';
import 'package:tix_mobile/src/features/projects/application/projects.dart';
import 'package:tix_mobile/src/features/projects/presentation/project_form.dart';

/// Every project on the active server.
class ProjectsScreen extends ConsumerWidget {
  /// Creates the screen.
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final session = ref.watch(sessionControllerProvider).value;
    final tenant = session == null
        ? ''
        : session.connection.tenantLabel.isNotEmpty
        ? session.connection.tenantLabel
        : session.instance.name;
    final access = ref.watch(currentAccessProvider).value ?? Access.none;
    final create = access.has(Scope.projectWrite)
        ? TixAction(
            key: const Key('project.new'),
            label: l10n.projectNew,
            icon: Icons.add,
            onPressed: () => showCreateProjectSheet(context),
          )
        : null;
    return TixPage(
      title: l10n.projectsTitle,
      subtitle: tenant.isEmpty ? null : l10n.projectsSubtitle(tenant),
      primaryAction: create,
      body: AsyncBody(
        value: ref.watch(projectsProvider),
        onRetry: () => ref.invalidate(projectsProvider),
        data: (paged) => PagedListView(
          paged: paged,
          header: const _ArchivedFilter(),
          empty: EmptyState(
            icon: Icons.folder_outlined,
            title: l10n.projectsEmpty,
            body: l10n.projectsEmptyBody,
            action: create,
          ),
          onRefresh: () => ref.refresh(projectsProvider.future),
          onLoadMore: () => ref.read(projectsProvider.notifier).loadMore(),
          itemBuilder: (context, project) => ProjectTile(project: project),
        ),
      ),
    );
  }
}

class _ArchivedFilter extends ConsumerWidget {
  const _ArchivedFilter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final on = ref.watch(showArchivedProjectsProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: TixSpace.s4,
        vertical: TixSpace.s2,
      ),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: TixFilterChip(
          key: const Key('projects.archived'),
          label: context.l10n.projectsShowArchived,
          icon: Icons.inventory_2_outlined,
          selected: on,
          onSelected: (_) =>
              ref.read(showArchivedProjectsProvider.notifier).toggle(),
        ),
      ),
    );
  }
}

/// One project in the list: its mark in its colour, its name and key, and
/// its description.
class ProjectTile extends ConsumerWidget {
  /// Draws [project].
  const ProjectTile({required this.project, super.key});

  /// The project.
  final Project project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tix;
    final name = project.name.isEmpty ? project.key : project.name;
    final open = ref.watch(projectOpenCountProvider(project.key)).value;
    final stripe = t.projectColour(project.color);
    return InkWell(
      onTap: () => context.go(Routes.project(project.key)),
      child: Container(
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.symmetric(
          horizontal: TixSpace.s4,
          vertical: TixSpace.s3,
        ),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: stripe ?? Colors.transparent, width: 3),
            bottom: BorderSide(color: t.line),
          ),
        ),
        child: Row(
          children: [
            ProjectMark(
              name: name,
              colour: project.color,
              icon: project.icon,
              iconName: project.iconName,
            ),
            const SizedBox(width: TixSpace.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: TixSpace.s2,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: TixText.md,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(project.key, style: tixMono(context)),
                    ],
                  ),
                  if (project.description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      project.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            if (open != null)
              Semantics(
                label: context.l10n.projectOpenCount(open),
                excludeSemantics: true,
                child: Padding(
                  padding: const EdgeInsets.only(left: TixSpace.s2),
                  child: Text(
                    '$open',
                    key: Key('project.${project.key}.open'),
                    style: TextStyle(
                      fontSize: TixText.sm,
                      fontWeight: FontWeight.w600,
                      color: t.muted,
                    ),
                  ),
                ),
              ),
            if (project.archivedAt != null)
              TixBadge(context.l10n.projectArchivedBadge),
            TixIconButton(
              key: Key('project.${project.key}.settings'),
              icon: Icons.settings_outlined,
              tooltip: context.l10n.projectSettingsTitle,
              onPressed: () => context.go(Routes.projectSettings(project.key)),
            ),
          ],
        ),
      ),
    );
  }
}
