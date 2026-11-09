// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/cache/cached.dart';
import 'package:tix_mobile/src/core/events/invalidation.dart';
import 'package:tix_mobile/src/core/paging/paged.dart';
import 'package:tix_mobile/src/core/session/integrations.dart';
import 'package:tix_mobile/src/data/models/page.dart';
import 'package:tix_mobile/src/data/repositories/integrations_repository.dart';

export 'package:tix_mobile/src/data/repositories/integrations_repository.dart'
    show SavedWebhook;

part 'webhooks.g.dart';

/// The tenant's webhook endpoints: the cached list at once, then the
/// server's.
@riverpod
class WebhookEndpoints extends _$WebhookEndpoints {
  @override
  Future<List<WebhookEndpoint>> build() {
    final repo = ref.watch(integrationsRepositoryProvider);
    return cachedFirst(
      ref: ref,
      cached: repo.cachedWebhooks(),
      fresh: repo.webhooks,
      onFresh: (v) => state = AsyncData(v),
    );
  }

  /// Registers or updates an endpoint and reloads the list. The answer
  /// carries the secret tix generated, if it did, to show once; it never
  /// enters this provider's state.
  Future<SavedWebhook> save({
    required String url,
    required List<String> eventTypes,
    required bool active,
    String? id,
    String secret = '',
  }) async {
    final saved = await ref
        .read(integrationsRepositoryProvider)
        .saveWebhook(
          id: id,
          url: url,
          eventTypes: eventTypes,
          active: active,
          secret: secret,
        );
    if (!ref.mounted) return saved;
    final current = state.value ?? const <WebhookEndpoint>[];
    state = AsyncData([
      for (final e in current)
        if (e.id != saved.endpoint.id) e,
      saved.endpoint,
    ]);
    ref.invalidateSelf();
    return saved;
  }

  /// Sends endpoint [id] a test event and answers its delivery; the
  /// delivery log reloads to show it.
  Future<WebhookDelivery> ping(String id) async {
    final delivery = await ref.read(integrationsRepositoryProvider).ping(id);
    if (ref.mounted) ref.invalidate(webhookDeliveriesProvider);
    return delivery;
  }

  /// Removes endpoint [id].
  Future<void> delete(String id) async {
    await ref.read(integrationsRepositoryProvider).deleteWebhook(id);
    if (!ref.mounted) return;
    state = AsyncData([
      for (final e in state.value ?? const <WebhookEndpoint>[])
        if (e.id != id) e,
    ]);
  }
}

/// The delivery log, newest first, for [endpointId] (empty for every
/// endpoint) in [status] (empty for any), a page at a time; it reloads as
/// deliveries are made.
@riverpod
class WebhookDeliveries extends _$WebhookDeliveries {
  Future<Page<WebhookDelivery>> _fetch(String? cursor) {
    final status = DeliveryStatus.values
        .where((s) => s.value == this.status)
        .toSet();
    return ref
        .read(integrationsRepositoryProvider)
        .deliveries(
          cursor: cursor,
          endpointId: endpointId.isEmpty ? null : endpointId,
          statuses: status,
        );
  }

  @override
  Future<Paged<WebhookDelivery>> build({
    String endpointId = '',
    String status = '',
  }) async {
    ref.watch(integrationsRepositoryProvider);
    refreshOn(ref, EventTopics.webhooks);
    final page = await _fetch(null);
    return Paged(items: page.items, cursor: page.nextCursor);
  }

  /// Fetches the next page, if there is one and none is in flight.
  Future<void> loadMore() => loadNextPage(
    current: state.value,
    fetch: _fetch,
    emit: (next) => state = AsyncData(next),
    idOf: (d) => d.id,
  );

  /// Queues delivery [id] for another attempt and reloads the log.
  Future<void> redeliver(String id) async {
    await ref.read(integrationsRepositoryProvider).redeliver(id);
    if (ref.mounted) ref.invalidateSelf();
  }
}
