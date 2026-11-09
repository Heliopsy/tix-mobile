// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/session/project_stars.dart';

/// Stars [project] for the reader, or takes the star off: on screen at once,
/// put back with a toast when the server refuses, and undone from the toast.
/// Draws nothing until the reader's stars are read, and nothing at all on a
/// server that keeps no project stars.
///
/// The button is keyed `project.<key>.star`.
class ProjectStarButton extends ConsumerWidget {
  /// A star toggle for [project].
  const ProjectStarButton({required this.project, super.key});

  /// The project.
  final Project project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stars = ref.watch(projectStarsProvider).value;
    if (stars == null) return const SizedBox.shrink();
    final l10n = context.l10n;
    final starred = stars.has(project.key);
    final name = project.name.isEmpty ? project.key : project.name;
    Future<void> toggle() async {
      final change = ref
          .read(projectStarsProvider.notifier)
          .star(project, starred: !starred);
      await runOptimistic(
        context,
        apply: change.apply,
        rollback: change.rollback,
        commit: change.commit,
        describe: (e) => errorMessage(context.l10n, e),
        success: starred
            ? l10n.projectUnstarred(name)
            : l10n.projectStarred(name),
        undo: change.undo,
      );
    }

    return TixIconButton(
      key: Key('project.${project.key}.star'),
      icon: starred ? Icons.star_rounded : Icons.star_outline_rounded,
      tooltip: starred ? l10n.projectUnstar : l10n.projectStar,
      selected: starred,
      onPressed: toggle,
    );
  }
}
