// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/features/tasks/application/listing.dart';

/// My work's navigation icon with how many of the reader's tasks are
/// overdue, in the danger colour, as the web's sidebar badge: the part of
/// the list that wants attention rather than its length. Nothing shows
/// while none are, or while the count is not known.
class MyWorkNavIcon extends ConsumerWidget {
  /// Draws [icon] with the count.
  const MyWorkNavIcon({required this.icon, super.key});

  /// The destination's icon.
  final Widget icon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overdue = ref.watch(myOverdueProvider).value ?? 0;
    final t = context.tix;
    return Semantics(
      value: overdue > 0 ? context.l10n.myWorkOverdueBadge(overdue) : null,
      child: Badge(
        key: const Key('myWork.badge'),
        backgroundColor: t.danger,
        textColor: t.onDanger,
        isLabelVisible: overdue > 0,
        label: ExcludeSemantics(
          child: Text(
            overdue > overdueBadgeCap ? '$overdueBadgeCap+' : '$overdue',
            style: const TextStyle(
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
        child: icon,
      ),
    );
  }
}
