// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/platform/files.dart';
import 'package:tix_mobile/src/core/router/router.dart';
import 'package:tix_mobile/src/core/session/local.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/widgets/sync_findings_note.dart';
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
    void add() => context.go(Routes.addServer);
    return TixPage(
      title: l10n.instancesTitle,
      primaryAction: TixAction(
        key: const Key('instances.add'),
        label: l10n.addInstance,
        icon: Icons.add,
        onPressed: add,
      ),
      body: directory.groups.isEmpty
          ? EmptyState(
              icon: Icons.dns_outlined,
              title: l10n.instancesEmpty,
              body: l10n.instancesEmptyBody,
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                TixSpace.s4,
                TixSpace.s2,
                TixSpace.s4,
                96,
              ),
              children: [
                for (final g in directory.groups)
                  Align(
                    alignment: AlignmentDirectional.topStart,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: TixMeasure.form,
                      ),
                      child: InstanceCard(group: g, activeConnectionId: active),
                    ),
                  ),
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
    final copy =
        local &&
        !instance.inPlace &&
        !ref.watch(filePickingProvider).opensInPlace;
    return Card(
      key: Key('instances.instance.${instance.id}'),
      margin: const EdgeInsets.only(bottom: TixSpace.s3),
      child: Column(
        children: [
          ListTile(
            leading: TixAvatar(
              label: instance.name,
              icon: local ? Icons.storage : Icons.cloud_outlined,
            ),
            title: Text(
              instance.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              copy
                  ? '${l10n.localCopyNote} · ${instance.location}'
                  : instance.inPlace
                  ? '${l10n.localInstanceInPlaceNote} · ${instance.location}'
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
                  child: Text(
                    l10n.removeInstance,
                    style: TextStyle(color: context.tix.danger),
                  ),
                ),
              ],
            ),
          ),
          if (local) LocalEngineRow(instance: instance),
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
                    child: Text(
                      l10n.removeConnection,
                      style: TextStyle(color: context.tix.danger),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// A local instance's engine: running or stopped, the file it serves when
/// that is not the one the card names, a Stop button while it runs, and
/// what was found next to a file used in place.
class LocalEngineRow extends ConsumerWidget {
  /// Shows the engine of [instance].
  const LocalEngineRow({required this.instance, super.key});

  /// The local instance.
  final Instance instance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final status =
        ref.watch(localEngineStatusesProvider).value?[instance.id] ??
        const LocalEngineStatus();
    final running = status.state == LocalEngineState.running;
    final label = switch (status.state) {
      LocalEngineState.running => l10n.localInstanceEngineRunning(
        Uri.parse(status.baseUrl).authority,
      ),
      LocalEngineState.starting => l10n.localInstanceEngineStarting,
      LocalEngineState.resting => l10n.localInstanceEngineResting,
      LocalEngineState.stopped => l10n.localInstanceEngineStopped,
    };
    return Column(
      key: Key('instances.engine.${instance.id}'),
      children: [
        ListTile(
          leading: Icon(
            running ? Icons.play_circle_outline : Icons.pause_circle_outline,
            color: running ? context.tix.ok : context.tix.muted,
          ),
          title: Text(label, key: Key('instances.engine.${instance.id}.state')),
          subtitle: status.dbPath.isEmpty || status.dbPath == instance.dbPath
              ? null
              : Text(status.dbPath),
          trailing: running
              ? TixButton(
                  key: Key('instances.engine.${instance.id}.stop'),
                  label: l10n.localInstanceEngineStop,
                  icon: Icons.stop,
                  size: TixButtonSize.small,
                  onPressed: () =>
                      ref.read(localEnginesProvider).rest(instance.id),
                )
              : null,
        ),
        if (instance.inPlace)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: TixSpace.s4),
            child: SyncFindingsNote(findings: status.findings),
          ),
      ],
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
