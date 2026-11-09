// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/components/dialogs.dart';
import 'package:tix_mobile/src/core/design/components/marks.dart';
import 'package:tix_mobile/src/core/design/theme.dart';
import 'package:tix_mobile/src/core/design/tokens.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/data/models/project.dart';

/// A project as a choice in a picker: its mark in its colour, its name and
/// key, a star when the reader [starred] it, an archived badge, and a check
/// when [selected], as the project list draws it.
///
/// The mark is decorative; the row reads as the project's name.
class ProjectOption extends StatelessWidget {
  /// Draws [project].
  const ProjectOption({
    required this.project,
    this.selected = false,
    this.starred = false,
    this.markSize = TixSize.controlSmall,
    super.key,
  });

  /// The project.
  final Project project;

  /// Whether it is the current choice, drawn with a check.
  final bool selected;

  /// Whether the reader starred it, drawn with a star.
  final bool starred;

  /// The mark's width and height.
  final double markSize;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    final l10n = context.l10n;
    final name = project.name.isEmpty ? project.key : project.name;
    final archived = project.archivedAt != null;
    final marks = [
      if (starred) l10n.starred,
      if (archived) l10n.projectArchivedBadge,
    ];
    return Semantics(
      container: true,
      label: name,
      value: marks.isEmpty ? null : marks.join(', '),
      selected: selected,
      excludeSemantics: true,
      child: Row(
        children: [
          ProjectMark(
            key: Key('projectOption.${project.key}.mark'),
            name: name,
            colour: project.color,
            icon: project.icon,
            iconName: project.iconName,
            size: markSize,
          ),
          const SizedBox(width: TixSpace.s3),
          Flexible(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: TixText.md,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (project.name.isNotEmpty) ...[
            const SizedBox(width: TixSpace.s2),
            Text(project.key, style: tixMono(context)),
          ],
          if (starred) ...[
            const SizedBox(width: TixSpace.s2),
            Icon(
              Icons.star_rounded,
              key: Key('projectOption.${project.key}.star'),
              size: 16,
              color: t.accent,
            ),
          ],
          if (archived) ...[
            const SizedBox(width: TixSpace.s2),
            TixBadge(l10n.projectArchivedBadge),
          ],
          if (selected) ...[
            const SizedBox(width: TixSpace.s2),
            Icon(
              Icons.check,
              key: Key('projectOption.${project.key}.check'),
              size: 18,
              color: t.accent,
            ),
          ],
        ],
      ),
    );
  }
}

/// Opens a sheet titled [title] listing [projects] as [ProjectOption]s,
/// those whose keys are in [starred] first and marked, [current] checked;
/// returns the chosen key, or null when dismissed.
///
/// Each row is keyed `<keyPrefix>.<project key>`.
Future<String?> showProjectPicker(
  BuildContext context, {
  required String title,
  required List<Project> projects,
  required String keyPrefix,
  String? current,
  Set<String> starred = const {},
}) => showTixSheet<String>(
  context,
  builder: (context) => TixSheetBody(
    title: title,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final p in starredFirst(projects, (p) => starred.contains(p.key)))
          ListTile(
            key: Key('$keyPrefix.${p.key}'),
            contentPadding: const EdgeInsets.symmetric(horizontal: TixSpace.s2),
            minTileHeight: TixSize.target,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(TixRadius.md)),
            ),
            title: ProjectOption(
              project: p,
              selected: p.key == current,
              starred: starred.contains(p.key),
            ),
            onTap: () => Navigator.of(context).pop(p.key),
          ),
      ],
    ),
  ),
);
