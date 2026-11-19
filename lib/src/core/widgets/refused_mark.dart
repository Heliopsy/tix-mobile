// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/data/models/connection.dart';

/// What a refused [connection] needs, in a line: sign in again for a
/// sign-in, a new token for a token.
String refusedState(AppLocalizations l10n, Connection connection) =>
    switch (connection.kind) {
      ConnectionKind.signIn => l10n.connectionSignedOut,
      ConnectionKind.token => l10n.connectionTokenRefused,
    };

/// A warning icon and [refusedState] for a refused [connection], read out as
/// one label; nothing for one that is not refused. Every list of connections
/// draws it under the row's title, so they all say it the same way.
class RefusedMark extends StatelessWidget {
  /// Marks [connection].
  const RefusedMark({required this.connection, super.key});

  /// The connection the row shows.
  final Connection connection;

  @override
  Widget build(BuildContext context) {
    if (!connection.refused) return const SizedBox.shrink();
    final l10n = context.l10n;
    final t = context.tix;
    final state = refusedState(l10n, connection);
    return Semantics(
      key: Key('refused.${connection.id}'),
      label: l10n.connectionAttention(state),
      excludeSemantics: true,
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, size: TixSpace.s4, color: t.warn),
          const SizedBox(width: TixSpace.s2),
          Flexible(
            child: Text(
              state,
              style: TextStyle(
                color: t.warn,
                fontSize: TixText.sm,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
