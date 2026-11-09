// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/router/router.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/widgets/confirm.dart';
import 'package:tix_mobile/src/core/widgets/live_details.dart';
import 'package:tix_mobile/src/data/models/connection.dart';
import 'package:tix_mobile/src/data/models/instance.dart';
import 'package:tix_mobile/src/features/shell/presentation/live_status.dart';

/// "Instance › Tenant" for [session].
String contextTitle(Session session) {
  final tenant = session.connection.tenantLabel;
  return tenant.isEmpty
      ? session.instance.name
      : '${session.instance.name} › $tenant';
}

/// Whether [entry] is the context [session] is in.
bool isActiveEntry(ContextEntry entry, Session? session) =>
    session != null &&
    entry.connection.id == session.connection.id &&
    entry.tenantKey == session.connection.tenantKey;

/// The active context, opening the switcher when tapped: a full-width bar on
/// phones, the top of the rail elsewhere.
class ContextSwitcherButton extends ConsumerWidget {
  /// Creates the button; [rail] draws it for a navigation rail, [extended]
  /// for a rail that shows labels.
  const ContextSwitcherButton({
    this.rail = false,
    this.extended = false,
    super.key,
  });

  /// Whether it sits at the top of a navigation rail.
  final bool rail;

  /// Whether the rail shows labels beside its icons.
  final bool extended;

  Future<void> _open(BuildContext context, WidgetRef ref) async {
    final picked = await showModalBottomSheet<ContextEntry>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => const ContextSwitcherSheet(),
    );
    if (picked == null || !context.mounted) return;
    if (picked.elsewhere.isNotEmpty) {
      final scheme = Uri.tryParse(picked.instance.baseUrl)?.scheme ?? 'https';
      context.go(
        Routes.addInstanceAt(
          '$scheme://${picked.elsewhere}',
          email: picked.connection.email,
        ),
      );
      return;
    }
    await activateEntry(context, ref, picked);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final session = ref.watch(sessionControllerProvider).value;
    if (session == null) return const SizedBox.shrink();
    final title = contextTitle(session);
    final handle = session.connection.handle;
    final avatar = _ContextAvatar(session.instance);
    final badged = Stack(
      clipBehavior: Clip.none,
      children: [
        avatar,
        const PositionedDirectional(
          end: -2,
          bottom: -2,
          child: LiveStatusIndicator(compact: true),
        ),
      ],
    );
    void details() => unawaited(showLiveDetails(context));
    if (rail && !extended) {
      return Tooltip(
        message: title,
        child: InkWell(
          key: const Key('switcher.open'),
          borderRadius: BorderRadius.circular(16),
          onTap: () => _open(context, ref),
          onLongPress: details,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: SizedBox(
              width: 64,
              child: Column(
                children: [
                  badged,
                  const SizedBox(height: 4),
                  Text(
                    session.connection.tenantLabel.isEmpty
                        ? session.instance.name
                        : session.connection.tenantLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return Semantics(
      button: true,
      label: l10n.switchContext,
      onLongPressHint: l10n.liveDetailsShow,
      child: Material(
        color: rail ? Colors.transparent : context.tix.surface,
        shape: rail ? null : Border(top: BorderSide(color: context.tix.line)),
        child: InkWell(
          key: const Key('switcher.open'),
          onTap: () => _open(context, ref),
          onLongPress: details,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: 56,
              maxWidth: rail ? 240 : double.infinity,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  if (rail) badged else avatar,
                  const SizedBox(width: 12),
                  Expanded(
                    child: _LabelWithStatus(
                      status: !rail,
                      label: Column(
                        key: const Key('switcher.label'),
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            key: const Key('switcher.title'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          if (handle.isNotEmpty)
                            Text(
                              '@$handle',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const Icon(Icons.unfold_more),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The context's name and handle, followed on the same line by how live
/// updates arrive when [status], so the indicator starts where the text
/// ends instead of floating in the middle of the bar. The indicator never
/// takes more than half the width; the name keeps the rest.
class _LabelWithStatus extends StatelessWidget {
  const _LabelWithStatus({required this.label, required this.status});

  final Widget label;
  final bool status;

  @override
  Widget build(BuildContext context) {
    if (!status) return label;
    return LayoutBuilder(
      builder: (context, box) => Row(
        children: [
          Flexible(child: label),
          const SizedBox(width: TixSpace.s2),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: box.maxWidth / 2),
            child: const LiveStatusIndicator(leading: true),
          ),
        ],
      ),
    );
  }
}

/// Makes [entry] active, asking for a second factor code when the switch
/// needs one and reporting a failure in a snack bar.
Future<void> activateEntry(
  BuildContext context,
  WidgetRef ref,
  ContextEntry entry,
) async {
  final session = ref.read(sessionControllerProvider.notifier);
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  try {
    try {
      await session.activate(entry.ref);
    } on TixException catch (e) {
      if (e.kind != TixErrorKind.codeRequired || !context.mounted) rethrow;
      final code = await askForCode(context);
      if (code == null) return;
      await session.activate(entry.ref, code: code);
    }
  } on Object catch (e) {
    if (context.mounted) {
      showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
    } else {
      messenger.showSnackBar(SnackBar(content: Text(errorMessage(l10n, e))));
    }
  }
}

/// The contexts to switch to: recent first, then every instance.
class ContextSwitcherSheet extends ConsumerWidget {
  /// Creates the sheet.
  const ContextSwitcherSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final directory = ref.watch(contextDirectoryProvider);
    final session = ref.watch(sessionControllerProvider).value;
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      child: ListView(
        key: const Key('switcher.sheet'),
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          if (directory.recent.isNotEmpty) ...[
            _Heading(l10n.recentContexts),
            for (final e in directory.recent)
              _EntryTile(
                key: Key('switcher.recent.${e.connection.id}.${e.tenantKey}'),
                entry: e,
                active: isActiveEntry(e, session),
                showInstance: true,
              ),
          ],
          for (final g in directory.groups) ...[
            _Heading(g.instance.name, subtitle: g.instance.location),
            for (final e in g.entries)
              _EntryTile(
                key: Key('switcher.entry.${e.connection.id}.${e.tenantKey}'),
                entry: e,
                active: isActiveEntry(e, session),
              ),
          ],
          const Divider(),
          ListTile(
            key: const Key('switcher.manage'),
            leading: const Icon(Icons.dns_outlined),
            title: Text(l10n.manageInstances),
            onTap: () {
              Navigator.of(context).pop();
              context.go(Routes.instances);
            },
          ),
          ListTile(
            key: const Key('switcher.add'),
            leading: Icon(Icons.add, color: theme.colorScheme.primary),
            title: Text(l10n.addInstance),
            onTap: () {
              Navigator.of(context).pop();
              context.go(Routes.addServer);
            },
          ),
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text, {this.subtitle = ''});

  final String text;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text.rich(
        TextSpan(
          text: text,
          children: [
            if (subtitle.isNotEmpty)
              TextSpan(text: '  $subtitle', style: theme.textTheme.bodySmall),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.labelMedium?.copyWith(
          color: context.tix.muted,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({
    required this.entry,
    required this.active,
    this.showInstance = false,
    super.key,
  });

  final ContextEntry entry;
  final bool active;
  final bool showInstance;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = entry.connection;
    final tenant = entry.tenantName.isEmpty
        ? entry.instance.name
        : entry.tenantName;
    final who = c.handle.isNotEmpty ? '@${c.handle}' : c.email;
    final details = entry.elsewhere.isNotEmpty
        ? l10n.servedAt(entry.elsewhere)
        : [
            if (showInstance) entry.instance.name,
            if (who.isNotEmpty) who,
            if (c.kind == ConnectionKind.token)
              l10n.methodToken
            else if (c.switchable)
              l10n.switchable
            else
              l10n.pinned,
          ].join(' · ');
    return ListTile(
      leading: TixAvatar(label: tenant, size: 32),
      title: Text(tenant),
      subtitle: Text(details, maxLines: 1, overflow: TextOverflow.ellipsis),
      selected: active,
      trailing: active
          ? const Icon(Icons.check)
          : entry.elsewhere.isNotEmpty
          ? const Icon(Icons.open_in_new)
          : null,
      onTap: active ? null : () => Navigator.of(context).pop(entry),
    );
  }
}

class _ContextAvatar extends StatelessWidget {
  const _ContextAvatar(this.instance);

  final Instance instance;

  @override
  Widget build(BuildContext context) {
    return TixAvatar(
      label: instance.name,
      size: 36,
      icon: instance.kind == InstanceKind.local
          ? Icons.storage
          : Icons.cloud_outlined,
    );
  }
}
