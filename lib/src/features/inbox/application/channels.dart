// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/paging/paged.dart';
import 'package:tix_mobile/src/features/inbox/application/inbox.dart';

part 'channels.g.dart';

/// The caller's own notification channels.
@riverpod
class Channels extends _$Channels {
  @override
  Future<List<InboxChannel>> build() =>
      ref.watch(inboxRepositoryProvider).channels();

  /// Adds a channel; the answer carries its secret, shown once.
  Future<IssuedInboxChannel> add(InboxChannelInput input) async {
    final created = await ref.read(inboxRepositoryProvider).addChannel(input);
    state = AsyncData([...?state.value, created.listed]);
    return created;
  }

  /// Changes channel [id].
  Future<InboxChannel> edit(String id, InboxChannelUpdate input) async {
    final changed = await ref
        .read(inboxRepositoryProvider)
        .editChannel(id, input);
    _replace(changed);
    return changed;
  }

  /// Turns channel [channel] on or off at once, rolling back on refusal.
  Future<void> setActive(InboxChannel channel, {required bool active}) async {
    _replace(channel.copyWith(active: active));
    try {
      await edit(channel.id, InboxChannelUpdate(active: active));
    } on Object {
      _replace(channel);
      rethrow;
    }
  }

  /// Deletes channel [id] and its deliveries.
  Future<void> delete(String id) async {
    await ref.read(inboxRepositoryProvider).deleteChannel(id);
    state = AsyncData([
      for (final c in state.value ?? const <InboxChannel>[])
        if (c.id != id) c,
    ]);
  }

  /// Queues a test message to channel [id].
  Future<ChannelDelivery> test(String id) async {
    final delivery = await ref.read(inboxRepositoryProvider).testChannel(id);
    ref.invalidate(channelDeliveriesProvider(id));
    return delivery;
  }

  void _replace(InboxChannel channel) => state = AsyncData([
    for (final c in state.value ?? const <InboxChannel>[])
      if (c.id == channel.id) channel else c,
  ]);
}

/// One channel's deliveries, newest first, a page at a time.
@riverpod
class ChannelDeliveries extends _$ChannelDeliveries {
  @override
  Future<Paged<ChannelDelivery>> build(String channelId) async {
    final page = await ref.watch(inboxRepositoryProvider).deliveries(channelId);
    return Paged(items: page.items, cursor: page.nextCursor);
  }

  /// Fetches the next page.
  Future<void> loadMore() => loadNextPage(
    current: state.value,
    fetch: (cursor) =>
        ref.read(inboxRepositoryProvider).deliveries(channelId, cursor: cursor),
    emit: (next) => state = AsyncData(next),
    idOf: (d) => d.id,
  );

  /// Queues another attempt of [delivery] and shows it pending.
  Future<void> redeliver(ChannelDelivery delivery) async {
    await ref.read(inboxRepositoryProvider).redeliver(delivery.id);
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        items: [
          for (final d in current.items)
            if (d.id == delivery.id)
              d.copyWith(status: DeliveryStatus.pending)
            else
              d,
        ],
        cursor: () => current.cursor,
      ),
    );
  }
}
