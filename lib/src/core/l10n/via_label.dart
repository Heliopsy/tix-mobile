// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/data/api/gen/models.gen.dart' show Via;

/// The channel [via] names, worded as tix's web words it: "via token
/// ci-runner", "via MCP (token claude)", "via system (lease-sweep)"; null
/// when [via] records none, as an older server's entries do.
String? viaLabel(AppLocalizations l10n, Via? via) {
  if (via == null || via.kind.isEmpty) return null;
  final channel = switch (via.kind) {
    'web' => l10n.watchChannelWeb,
    'api' => l10n.watchChannelApi,
    'cli-local' || 'cli-remote' => l10n.watchChannelCli,
    'ssh' => l10n.watchChannelSsh,
    'mcp' => l10n.watchChannelMcp,
    'sync' => l10n.watchChannelSync,
    'import' => l10n.watchChannelImport,
    'system' => l10n.watchChannelSystem,
    _ => l10n.watchChannelUnknown,
  };
  final token = via.kind == 'system' ? '' : via.tokenName;
  if (token.isNotEmpty) {
    return via.kind == 'api'
        ? l10n.viaToken(token)
        : l10n.viaChannelToken(channel, token);
  }
  return via.job.isEmpty
      ? l10n.watchVia(channel)
      : l10n.watchViaNamed(channel, via.job);
}
