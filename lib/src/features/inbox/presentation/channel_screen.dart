// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/router/routes.dart';
import 'package:tix_mobile/src/core/time/times.dart';
import 'package:tix_mobile/src/core/widgets/async_body.dart';
import 'package:tix_mobile/src/core/widgets/paged_list_view.dart';
import 'package:tix_mobile/src/features/inbox/application/channels.dart';
import 'package:tix_mobile/src/features/inbox/application/inbox.dart';
import 'package:tix_mobile/src/features/inbox/presentation/channel_form.dart';
import 'package:tix_mobile/src/features/inbox/presentation/inbox_screen.dart';

/// One personal channel: what it receives, its deliveries newest first,
/// a test message, and deleting it.
class ChannelScreen extends ConsumerWidget {
  /// Shows the channel [channelId].
  const ChannelScreen({required this.channelId, super.key});

  /// The channel's id.
  final String channelId;

  Future<void> _test(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    try {
      await ref.read(channelsProvider.notifier).test(channelId);
      if (context.mounted) showTixToast(context, l10n.inboxChannelTestQueued);
    } on Object catch (e) {
      if (context.mounted) {
        showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
      }
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    InboxChannel channel,
  ) async {
    final l10n = context.l10n;
    final ok = await confirmDestructive(
      context,
      title: l10n.inboxChannelDeleteTitle(channel.name),
      body: l10n.inboxChannelDeleteBody,
      action: l10n.inboxChannelDelete,
    );
    if (!ok || !context.mounted) return;
    try {
      await ref.read(channelsProvider.notifier).delete(channel.id);
      if (context.mounted) {
        showTixToast(context, l10n.inboxChannelDeleted(channel.name));
        context.go(Routes.notificationSettings);
      }
    } on Object catch (e) {
      if (context.mounted) {
        showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
      }
    }
  }

  Future<void> _setActive(
    BuildContext context,
    WidgetRef ref,
    InboxChannel channel, {
    required bool active,
  }) async {
    try {
      await ref
          .read(channelsProvider.notifier)
          .setActive(channel, active: active);
    } on Object catch (e) {
      if (context.mounted) {
        showTixToast(
          context,
          errorMessage(context.l10n, e),
          tone: TixTone.danger,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final channels = ref.watch(channelsProvider);
    final channel = channels.value?.where((c) => c.id == channelId).firstOrNull;
    return TixPage(
      title: channel?.name ?? l10n.inboxChannelsTitle,
      subtitle: channel == null
          ? null
          : channelFormatLabel(l10n, channel.format),
      actions: [
        if (channel != null) ...[
          TixButton(
            key: const Key('channel.test'),
            label: l10n.inboxChannelTest,
            icon: Icons.send_outlined,
            onPressed: () => unawaited(_test(context, ref)),
          ),
          TixIconButton(
            key: const Key('channel.edit'),
            icon: Icons.edit_outlined,
            tooltip: l10n.inboxChannelEdit,
            onPressed: () => unawaited(editChannel(context, channel)),
          ),
        ],
      ],
      body: AsyncBody(
        value: channels,
        onRetry: () => ref.invalidate(channelsProvider),
        data: (_) {
          if (channel == null) {
            return EmptyState(
              icon: Icons.link_off,
              title: l10n.inboxChannelGone,
              action: TixAction(
                label: l10n.back,
                icon: Icons.arrow_back,
                onPressed: () => context.go(Routes.notificationSettings),
              ),
            );
          }
          final deliveries = ref.watch(channelDeliveriesProvider(channelId));
          final danger = TixSection(
            title: l10n.inboxChannelDangerZone,
            danger: true,
            children: [
              ListTile(
                title: Text(l10n.inboxChannelDelete),
                subtitle: Text(l10n.inboxChannelDeleteBody),
                trailing: TixButton.danger(
                  key: const Key('channel.delete'),
                  label: l10n.inboxChannelDelete,
                  size: TixButtonSize.small,
                  onPressed: () => unawaited(_delete(context, ref, channel)),
                ),
              ),
            ],
          );
          final header = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TixSection(
                title: l10n.inboxChannelAbout,
                children: [
                  TixSwitchRow(
                    key: const Key('channel.active'),
                    title: l10n.inboxChannelActive,
                    subtitle: l10n.inboxChannelActiveHelp,
                    value: channel.active,
                    onChanged: (on) => unawaited(
                      _setActive(context, ref, channel, active: on),
                    ),
                  ),
                  ListTile(
                    title: Text(l10n.inboxChannelUrl),
                    subtitle: Text(
                      channel.url,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: tixMono(context),
                    ),
                  ),
                  ListTile(
                    title: Text(l10n.inboxChannelKinds),
                    subtitle: Text(
                      channel.kinds.isEmpty
                          ? l10n.inboxChannelAllKinds
                          : [
                              for (final k in channel.kinds)
                                if (inboxKindNamed(k) case final kind?)
                                  inboxKindLabel(l10n, kind),
                            ].join(', '),
                    ),
                  ),
                ],
              ),
              danger,
              SectionHeader(
                title: l10n.inboxChannelDeliveries,
                subtitle: l10n.inboxChannelDeliveriesSubtitle,
              ),
            ],
          );
          return deliveries.when(
            loading: () => ListView(
              children: [
                header,
                const SizedBox(height: 150, child: SkeletonList(rows: 3)),
              ],
            ),
            error: (e, _) => ListView(
              children: [
                header,
                ErrorState(
                  error: e,
                  compact: true,
                  onRetry: () =>
                      ref.invalidate(channelDeliveriesProvider(channelId)),
                ),
              ],
            ),
            data: (paged) => PagedListView<ChannelDelivery>(
              paged: paged,
              header: header,
              padding: const EdgeInsets.only(bottom: TixSpace.s6),
              empty: Align(
                alignment: AlignmentDirectional.topStart,
                child: Padding(
                  padding: const EdgeInsets.all(TixSpace.s4),
                  child: Text(
                    l10n.inboxChannelNoDeliveries,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
              onRefresh: () =>
                  ref.refresh(channelDeliveriesProvider(channelId).future),
              onLoadMore: () => unawaited(
                ref
                    .read(channelDeliveriesProvider(channelId).notifier)
                    .loadMore(),
              ),
              itemBuilder: (context, d) =>
                  _DeliveryRow(delivery: d, channelId: channelId),
            ),
          );
        },
      ),
    );
  }
}

class _DeliveryRow extends ConsumerWidget {
  const _DeliveryRow({required this.delivery, required this.channelId});

  final ChannelDelivery delivery;
  final String channelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tix;
    final times = context.times;
    final at = delivery.createdAt;
    final (label, tone) = switch (delivery.status) {
      DeliveryStatus.delivered => (l10n.inboxDeliveryDelivered, TixTone.ok),
      DeliveryStatus.failed => (l10n.inboxDeliveryFailed, TixTone.danger),
      DeliveryStatus.pending ||
      null => (l10n.inboxDeliveryPending, TixTone.neutral),
    };
    final detail = [
      if (at != null) times.shortStamp(at),
      l10n.inboxDeliveryAttempts(delivery.attempts),
      if (delivery.lastStatusCode > 0) 'HTTP ${delivery.lastStatusCode}',
    ].join(' · ');
    return Container(
      key: Key('delivery.${delivery.id}'),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: t.line)),
      ),
      padding: const EdgeInsets.fromLTRB(
        TixSpace.s4,
        TixSpace.s2,
        TixSpace.s2,
        TixSpace.s2,
      ),
      child: Row(
        children: [
          TixBadge(label, tone: tone),
          const SizedBox(width: TixSpace.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  delivery.itemId.isEmpty
                      ? l10n.inboxDeliveryTest
                      : l10n.inboxDeliveryItem,
                  style: const TextStyle(
                    fontSize: TixText.sm,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  detail,
                  style: TextStyle(fontSize: TixText.xs, color: t.muted),
                ),
                if (delivery.lastError.isNotEmpty)
                  Text(
                    delivery.lastError,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: TixText.xs, color: t.danger),
                  ),
              ],
            ),
          ),
          if (delivery.status != DeliveryStatus.pending)
            TixButton.quiet(
              key: Key('delivery.redeliver.${delivery.id}'),
              label: l10n.inboxDeliveryRedeliver,
              size: TixButtonSize.small,
              onPressed: () async {
                try {
                  await ref
                      .read(channelDeliveriesProvider(channelId).notifier)
                      .redeliver(delivery);
                  if (context.mounted) {
                    showTixToast(context, l10n.inboxDeliveryRequeued);
                  }
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
