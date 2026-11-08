// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/router/router.dart';
import 'package:tix_mobile/src/core/widgets/async_body.dart';
import 'package:tix_mobile/src/core/widgets/paged_list_view.dart';
import 'package:tix_mobile/src/data/models/project.dart';
import 'package:tix_mobile/src/features/projects/application/projects.dart';

/// Every project on the active server.
class ProjectsScreen extends ConsumerWidget {
  /// Creates the screen.
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.projectsTitle)),
      body: AsyncBody(
        value: ref.watch(projectsProvider),
        onRetry: () => ref.invalidate(projectsProvider),
        data: (paged) => PagedListView(
          paged: paged,
          empty: l10n.projectsEmpty,
          onRefresh: () => ref.refresh(projectsProvider.future),
          onLoadMore: () => ref.read(projectsProvider.notifier).loadMore(),
          itemBuilder: (context, project) => ProjectTile(project: project),
        ),
      ),
    );
  }
}

/// One project in the list.
class ProjectTile extends StatelessWidget {
  /// Draws [project].
  const ProjectTile({required this.project, super.key});

  /// The project.
  final Project project;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final monogram = project.icon.isNotEmpty
        ? project.icon
        : project.key.characters.take(2).toString().toUpperCase();
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
        child: Text(monogram),
      ),
      title: Text(project.name.isEmpty ? project.key : project.name),
      subtitle: Text(project.key),
      onTap: () => context.go(Routes.project(project.key)),
    );
  }
}
