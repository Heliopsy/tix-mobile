// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/data/local/in_place.dart';

/// Says what was found next to a database used in place: sync-conflict
/// copies and a leftover write-ahead log. Draws nothing when all is clear.
class SyncFindingsNote extends StatelessWidget {
  /// Shows [findings].
  const SyncFindingsNote({required this.findings, super.key});

  /// What was found.
  final SyncFindings findings;

  @override
  Widget build(BuildContext context) {
    if (findings.isEmpty) return const SizedBox.shrink();
    final l10n = context.l10n;
    final style = TextStyle(color: context.tix.warn, fontSize: TixText.sm);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TixSpace.s2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber, color: context.tix.warn),
          const SizedBox(width: TixSpace.s2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (findings.conflicts.isNotEmpty)
                  Text(
                    l10n.localInstanceConflicts(findings.conflicts.join(', ')),
                    style: style,
                  ),
                if (findings.walLeftOver)
                  Text(l10n.localInstanceWalLeftOver, style: style),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
