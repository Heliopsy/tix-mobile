// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/router/routes.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/features/inbox/application/alerts.dart';
import 'package:tix_mobile/src/features/inbox/application/channels.dart';
import 'package:tix_mobile/src/features/inbox/application/inbox.dart';
import 'package:tix_mobile/src/features/inbox/presentation/channel_form.dart';
import 'package:tix_mobile/src/features/inbox/presentation/inbox_screen.dart';

/// One line on what an inbox [kind] is.
String inboxKindHelp(AppLocalizations l10n, InboxKind kind) => switch (kind) {
  InboxKind.mention => l10n.inboxKindMentionHelp,
  InboxKind.assigned => l10n.inboxKindAssignedHelp,
  InboxKind.comment => l10n.inboxKindCommentHelp,
  InboxKind.status => l10n.inboxKindStatusHelp,
};

/// Notifications on this device, which kinds reach the inbox at all, and
/// the person's own channels.
class NotificationSettingsScreen extends ConsumerWidget {
  /// Creates the screen.
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final session = ref.watch(sessionControllerProvider).value;
    final where = session == null
        ? null
        : [
            session.instance.name,
            if (session.connection.tenantKey.isNotEmpty)
              session.connection.tenantLabel,
          ].join(' · ');
    return TixPage(
      title: l10n.notifSettingsTitle,
      subtitle: where,
      body: ListView(
        padding: const EdgeInsets.only(bottom: TixSpace.s6),
        children: const [
          _DeviceSection(),
          _InboxKindsSection(),
          _ChannelsSection(),
        ],
      ),
    );
  }
}

class _DeviceSection extends ConsumerWidget {
  const _DeviceSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tix;
    final prefs = ref.watch(notificationPrefsStateProvider);
    final notifier = ref.read(notificationPrefsStateProvider.notifier);
    return TixSection(
      title: l10n.notifDeviceTitle,
      subtitle: l10n.notifDeviceSubtitle,
      info: l10n.notifDeviceInfo,
      children: [
        TixSwitchRow(
          key: const Key('notif.enabled'),
          title: l10n.notifEnabled,
          subtitle: prefs.blocked ? l10n.notifBlocked : l10n.notifEnabledHelp,
          value: prefs.enabled,
          onChanged: (on) => unawaited(notifier.setEnabled(on: on)),
        ),
        if (prefs.blocked)
          Padding(
            key: const Key('notif.blocked'),
            padding: const EdgeInsets.all(TixSpace.s3),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: t.warn, size: 18),
                const SizedBox(width: TixSpace.s2),
                Expanded(
                  child: Text(
                    l10n.notifBlockedHelp,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        for (final kind in inboxKinds)
          TixSwitchRow(
            key: Key('notif.kind.${kind.value}'),
            title: inboxKindLabel(l10n, kind),
            value: prefs.kinds.contains(kind),
            onChanged: prefs.enabled
                ? (on) => unawaited(notifier.setKind(kind, on: on))
                : null,
          ),
      ],
    );
  }
}

class _InboxKindsSection extends ConsumerWidget {
  const _InboxKindsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final muted = ref.watch(inboxMutedProvider);
    return TixSection(
      title: l10n.inboxKindsTitle,
      subtitle: l10n.inboxKindsSubtitle,
      info: l10n.inboxKindsInfo,
      children: muted.when(
        loading: () => [
          const SizedBox(
            height: 160,
            child: SkeletonList(rows: 4, leading: false),
          ),
        ],
        error: (e, _) => [
          ErrorState(
            error: e,
            compact: true,
            onRetry: () => ref.invalidate(inboxMutedProvider),
          ),
        ],
        data: (muted) => [
          for (final kind in inboxKinds)
            TixSwitchRow(
              key: Key('inbox.receive.${kind.value}'),
              title: inboxKindLabel(l10n, kind),
              subtitle: inboxKindHelp(l10n, kind),
              value: !muted.contains(kind),
              onChanged: (on) async {
                try {
                  await ref
                      .read(inboxMutedProvider.notifier)
                      .setReceive(kind, receive: on);
                } on Object catch (e) {
                  if (context.mounted) {
                    showTixToast(
                      context,
                      errorMessage(l10n, e),
                      tone: TixTone.danger,
                    );
                  }
                }
              },
            ),
        ],
      ),
    );
  }
}

class _ChannelsSection extends ConsumerWidget {
  const _ChannelsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final channels = ref.watch(channelsProvider);
    return TixSection(
      title: l10n.inboxChannelsTitle,
      subtitle: l10n.inboxChannelsSubtitle,
      info: l10n.inboxChannelsInfo,
      trailing: TixButton.primary(
        key: const Key('channels.add'),
        label: l10n.inboxChannelAdd,
        icon: Icons.add,
        size: TixButtonSize.small,
        onPressed: () => unawaited(addChannel(context, ref)),
      ),
      children: channels.when(
        loading: () => [
          const SizedBox(
            height: 80,
            child: SkeletonList(rows: 2, leading: false),
          ),
        ],
        error: (e, _) => [
          ErrorState(
            error: e,
            compact: true,
            onRetry: () => ref.invalidate(channelsProvider),
          ),
        ],
        data: (list) => list.isEmpty
            ? [
                Padding(
                  padding: const EdgeInsets.all(TixSpace.s4),
                  child: Text(
                    l10n.inboxChannelsEmpty,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ]
            : [for (final c in list) _ChannelTile(channel: c)],
      ),
    );
  }
}

class _ChannelTile extends ConsumerWidget {
  const _ChannelTile({required this.channel});

  final InboxChannel channel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return ListTile(
      key: Key('channel.${channel.id}'),
      leading: Icon(channelFormatIcon(channel.format)),
      title: Text(channel.name),
      subtitle: Text(
        [
          channelFormatLabel(l10n, channel.format),
          if (!channel.active) l10n.inboxChannelOff,
        ].join(' · '),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.go(Routes.channel(channel.id)),
    );
  }
}
