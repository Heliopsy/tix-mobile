// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/platform/files.dart';
import 'package:tix_mobile/src/core/router/router.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/widgets/confirm.dart';
import 'package:tix_mobile/src/data/models/connection.dart';
import 'package:tix_mobile/src/data/models/instance.dart';

/// Every saved instance with its connections.
class InstancesScreen extends ConsumerWidget {
  /// Creates the screen.
  const InstancesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final directory = ref.watch(contextDirectoryProvider);
    final active = ref.watch(sessionControllerProvider).value?.connection.id;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.instancesTitle)),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('instances.add'),
        onPressed: () => context.go(Routes.addServer),
        icon: const Icon(Icons.add),
        label: Text(l10n.addInstance),
      ),
      body: directory.groups.isEmpty
          ? Center(child: Text(l10n.instancesEmpty))
          : ListView(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 96),
              children: [
                for (final g in directory.groups)
                  InstanceCard(group: g, activeConnectionId: active),
              ],
            ),
    );
  }
}

enum _InstanceAction { addConnection, export, remove }

enum _ConnectionAction { use, pin, unpin, reconnect, remove }

/// One instance and its connections, with what can be done to them.
class InstanceCard extends ConsumerWidget {
  /// Draws [group], marking [activeConnectionId].
  const InstanceCard({
    required this.group,
    required this.activeConnectionId,
    super.key,
  });

  /// The instance and its connections.
  final InstanceGroup group;

  /// The active connection, if any.
  final String? activeConnectionId;

  Future<void> _onInstance(
    BuildContext context,
    WidgetRef ref,
    _InstanceAction action,
  ) async {
    final l10n = context.l10n;
    final instance = group.instance;
    switch (action) {
      case _InstanceAction.addConnection:
        context.go(Routes.addConnection(instance.id));
      case _InstanceAction.export:
        final messenger = ScaffoldMessenger.of(context);
        final box = context.findRenderObject() as RenderBox?;
        final origin = box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size;
        final done = await ref
            .read(sessionControllerProvider.notifier)
            .exportLocal(instance.id, origin: origin);
        if (done) {
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.databaseExported)),
          );
        }
      case _InstanceAction.remove:
        final ok = await confirmDestructive(
          context,
          title: l10n.removeInstance,
          body: l10n.removeInstanceBody(instance.name),
          action: l10n.remove,
        );
        if (ok) {
          await ref
              .read(sessionControllerProvider.notifier)
              .removeInstance(instance.id);
        }
    }
  }

  Future<void> _onConnection(
    BuildContext context,
    WidgetRef ref,
    Connection c,
    _ConnectionAction action,
  ) async {
    final l10n = context.l10n;
    final session = ref.read(sessionControllerProvider.notifier);
    switch (action) {
      case _ConnectionAction.use:
        await session.activate(c.ref);
      case _ConnectionAction.pin:
        await session.setPinned(c.id, pinned: true);
      case _ConnectionAction.unpin:
        await session.setPinned(c.id, pinned: false);
      case _ConnectionAction.reconnect:
        context.go(Routes.reconnect(c.id));
      case _ConnectionAction.remove:
        final ok = await confirmDestructive(
          context,
          title: l10n.removeConnection,
          body: l10n.removeConnectionBody(connectionTitle(c)),
          action: l10n.remove,
        );
        if (ok) await session.removeConnection(c.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final instance = group.instance;
    final local = instance.kind == InstanceKind.local;
    final copy = local && !ref.watch(filePickingProvider).opensInPlace;
    return Card(
      key: Key('instances.instance.${instance.id}'),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          ListTile(
            leading: Icon(local ? Icons.storage : Icons.cloud_outlined),
            title: Text(instance.name),
            subtitle: Text(
              copy
                  ? '${l10n.localCopyNote} · ${instance.location}'
                  : instance.location,
            ),
            trailing: PopupMenuButton<_InstanceAction>(
              key: Key('instances.instance.${instance.id}.menu'),
              onSelected: (a) => _onInstance(context, ref, a),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: _InstanceAction.addConnection,
                  child: Text(local ? l10n.openTenant : l10n.addConnection),
                ),
                if (copy)
                  PopupMenuItem(
                    value: _InstanceAction.export,
                    child: Text(l10n.exportDatabase),
                  ),
                PopupMenuItem(
                  value: _InstanceAction.remove,
                  child: Text(l10n.removeInstance),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          for (final c in group.connections)
            ListTile(
              key: Key('instances.connection.${c.id}'),
              leading: Icon(
                c.id == activeConnectionId
                    ? Icons.check_circle
                    : c.kind == ConnectionKind.token
                    ? Icons.key
                    : Icons.person_outline,
              ),
              selected: c.id == activeConnectionId,
              title: Text(connectionTitle(c)),
              subtitle: Text(connectionSummary(l10n, c)),
              onTap: c.id == activeConnectionId
                  ? null
                  : () => _onConnection(context, ref, c, _ConnectionAction.use),
              trailing: PopupMenuButton<_ConnectionAction>(
                key: Key('instances.connection.${c.id}.menu'),
                onSelected: (a) => _onConnection(context, ref, c, a),
                itemBuilder: (_) => [
                  if (c.id != activeConnectionId)
                    PopupMenuItem(
                      value: _ConnectionAction.use,
                      child: Text(l10n.useConnection),
                    ),
                  if (c.kind == ConnectionKind.signIn) ...[
                    PopupMenuItem(
                      value: c.pinned
                          ? _ConnectionAction.unpin
                          : _ConnectionAction.pin,
                      child: Text(c.pinned ? l10n.makeSwitchable : l10n.pin),
                    ),
                    PopupMenuItem(
                      value: _ConnectionAction.reconnect,
                      child: Text(l10n.signInAgain),
                    ),
                  ],
                  PopupMenuItem(
                    value: _ConnectionAction.remove,
                    child: Text(l10n.removeConnection),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// What a person calls connection [c]: its label, else its handle or email.
String connectionTitle(Connection c) => c.label.isNotEmpty
    ? c.label
    : c.handle.isNotEmpty
    ? '@${c.handle}'
    : c.email;

/// Tenant, kind and whether it follows tenants, in a line.
String connectionSummary(AppLocalizations l10n, Connection c) => [
  if (c.tenantKey.isNotEmpty) c.tenantLabel,
  if (c.label.isNotEmpty && c.handle.isNotEmpty) '@${c.handle}',
  if (c.kind == ConnectionKind.token) l10n.methodToken,
  if (c.kind == ConnectionKind.signIn && c.email.isEmpty) l10n.methodSignIn,
  if (c.kind == ConnectionKind.signIn && c.email.isNotEmpty) c.email,
  if (c.switchable) l10n.switchable else l10n.pinned,
].join(' · ');
