// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/session/admin.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/time/times.dart';
import 'package:tix_mobile/src/core/widgets/async_body.dart';
import 'package:tix_mobile/src/features/admin/application/tenant_admin.dart';

/// The server this context talks to: its version and address, and the
/// tenant's live connections (event streams and SSH sessions), each of
/// which an admin can end.
class ServerScreen extends ConsumerWidget {
  /// Creates the screen.
  const ServerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final value = ref.watch(serverStatusProvider);
    final version = value.value?.health.version;
    return TixPage(
      title: l10n.serverTitle,
      subtitle: version == null ? null : l10n.serverVersion(version),
      actions: [
        TixIconButton(
          icon: Icons.refresh,
          tooltip: l10n.refresh,
          onPressed: () => ref.invalidate(serverStatusProvider),
        ),
      ],
      body: AsyncBody(
        value: value,
        onRetry: () => ref.invalidate(serverStatusProvider),
        data: (overview) => RefreshIndicator(
          onRefresh: () => ref.refresh(serverStatusProvider.future),
          child: ListView(
            padding: const EdgeInsets.only(bottom: TixSpace.s7),
            children: [
              _StatusSection(overview: overview),
              _ConnectionsSection(overview: overview),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusSection extends ConsumerWidget {
  const _StatusSection({required this.overview});

  final ServerOverview overview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final session = ref.watch(sessionControllerProvider).value;
    final counts = overview.connections.counts;
    return TixSection(
      title: l10n.serverStatusTitle,
      children: [
        TixPropertyList(
          children: [
            _Fact(l10n.serverVersionLabel, overview.health.version),
            _Fact(l10n.serverHealth, overview.health.status),
            if (session != null)
              _Fact(l10n.serverAddress, session.instance.baseUrl),
            _Fact(l10n.serverId, overview.connections.serverId, mono: true),
            if (counts != null) ...[
              _Fact(l10n.serverCountTenant, '${counts.tenant}'),
              _Fact(l10n.serverCountEvents, '${counts.events}'),
              _Fact(l10n.serverCountSsh, '${counts.ssh}'),
              _Fact(
                l10n.serverCountProcess,
                '${counts.process}',
                info: l10n.serverCountProcessInfo,
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact(this.label, this.value, {this.mono = false, this.info});

  final String label;
  final String value;
  final bool mono;
  final String? info;

  @override
  Widget build(BuildContext context) => TixPropertyRow(
    label: label,
    info: info,
    child: SelectableText(
      value.isEmpty ? '—' : value,
      style: mono ? tixMono(context, size: TixText.sm) : null,
    ),
  );
}

class _ConnectionsSection extends ConsumerWidget {
  const _ConnectionsSection({required this.overview});

  final ServerOverview overview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final rows = overview.connections.connections;
    return TixSection(
      title: l10n.connectionsTitle,
      info: l10n.connectionsInfo,
      children: [
        if (rows.isEmpty)
          Padding(
            padding: const EdgeInsets.all(TixSpace.s4),
            child: Text(
              l10n.connectionsEmpty,
              key: const Key('connections.empty'),
            ),
          )
        else
          for (final c in rows) _ConnectionRow(connection: c),
      ],
    );
  }
}

class _ConnectionRow extends ConsumerWidget {
  const _ConnectionRow({required this.connection});

  final LiveConnection connection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final since = connection.since;
    final ssh = connection.surface == ConnectionSurface.ssh;
    return ListTile(
      key: Key('connection.${connection.id}'),
      leading: Icon(ssh ? Icons.terminal : Icons.sensors),
      title: Text(
        [
          if (connection.actorHandle.isNotEmpty) '@${connection.actorHandle}',
          if (ssh) l10n.connectionSsh else l10n.connectionEvents,
        ].join(' · '),
      ),
      subtitle: Text(
        [
          if (connection.remote.isNotEmpty) connection.remote,
          if (since != null) l10n.connectionSince(context.times.stamp(since)),
          if (connection.fingerprint.isNotEmpty) connection.fingerprint,
        ].join(' · '),
      ),
      trailing: TixButton.danger(
        key: Key('connection.end.${connection.id}'),
        label: l10n.connectionEnd,
        size: TixButtonSize.small,
        onPressed: () => _end(context, ref),
      ),
    );
  }

  Future<void> _end(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final ok = await confirmDestructive(
      context,
      title: l10n.connectionEnd,
      body: l10n.connectionEndBody,
      action: l10n.connectionEnd,
    );
    if (!ok || !context.mounted) return;
    try {
      await ref.read(serverStatusProvider.notifier).end(connection.id);
      if (context.mounted) showTixToast(context, l10n.connectionEnded);
    } on Object catch (e) {
      if (context.mounted) {
        showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
      }
    }
  }
}
