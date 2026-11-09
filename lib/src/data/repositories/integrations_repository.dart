// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:math';

import 'package:tix_mobile/src/core/config/config.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/cache/response_cache.dart';
import 'package:tix_mobile/src/data/models/integrations.dart';
import 'package:tix_mobile/src/data/models/page.dart';

export 'package:tix_mobile/src/data/models/integrations.dart';

/// An endpoint just saved, with the signing secret the app generated for it
/// when the person left the field blank. The secret is shown once and kept
/// nowhere.
typedef SavedWebhook = ({WebhookEndpoint endpoint, String? generatedSecret});

/// Webhook endpoints and their delivery log, and external sync sources.
///
/// Only the endpoint list is cached: it never carries a secret. Sync
/// sources are not, since they carry credential hints and mapping
/// documents, and deliveries change too fast to be worth it.
class IntegrationsRepository {
  /// Reads and writes through [_api], keeping copies in [_cache].
  IntegrationsRepository(this._api, this._cache, {Random? random})
    : _random = random ?? Random.secure();

  final TixApi _api;
  final ResponseCache _cache;
  final Random _random;

  static const _webhooksKey = 'webhooks';

  /// The audit subject and action a finished sync run is recorded under,
  /// as tix's own sync runs screen reads them.
  static const syncSubject = 'sync_source';

  /// See [syncSubject].
  static const syncRunAction = 'sync.run';

  static List<WebhookEndpoint> _endpoints(Object? json) => [
    for (final e in json! as List<Object?>)
      WebhookEndpoint.fromJson(e! as Map<String, dynamic>),
  ];

  /// Every endpoint of the tenant (`webhook.list`).
  Future<List<WebhookEndpoint>> webhooks() => _cache.remember(
    _webhooksKey,
    _api.webhook.list().then((p) => p.items),
    (v) => [for (final e in v) e.toJson()],
  );

  /// The endpoints as last read, null when never read.
  Future<List<WebhookEndpoint>?> cachedWebhooks() =>
      _cache.peek(_webhooksKey, _endpoints);

  /// A new signing secret: 32 random bytes in hex.
  String newSecret() => [
    for (var i = 0; i < 32; i++)
      _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ].join();

  /// Registers an endpoint, or updates [id] (`webhook.put`).
  ///
  /// tix's API generates a secret for a new endpoint saved without one but
  /// never returns it, so for a new endpoint with a blank [secret] the app
  /// makes one itself and hands it back to be shown once. A blank secret on
  /// an update keeps the stored one.
  Future<SavedWebhook> saveWebhook({
    required String url,
    required List<String> eventTypes,
    required bool active,
    String? id,
    String secret = '',
  }) async {
    final creating = id == null || id.isEmpty;
    final generated = creating && secret.isEmpty ? newSecret() : null;
    final sent = generated ?? secret;
    final issued = await _api.webhook.put(
      WebhookInput(
        id: creating ? null : id,
        url: url,
        eventTypes: eventTypes,
        active: active,
        secret: sent.isEmpty ? null : sent,
      ),
    );
    final endpoint = WebhookEndpoint(
      id: issued.id,
      tenantId: issued.tenantId,
      url: issued.url,
      eventTypes: issued.eventTypes,
      active: issued.active,
      createdAt: issued.createdAt,
    );
    return (endpoint: endpoint, generatedSecret: generated);
  }

  /// Removes endpoint [id] and its pending deliveries (`webhook.delete`).
  Future<void> deleteWebhook(String id) => _api.webhook.delete(id);

  /// One page of the delivery log, newest first, for one endpoint or all,
  /// in the given statuses or any (`webhook.deliveries`).
  Future<Page<WebhookDelivery>> deliveries({
    String? cursor,
    String? endpointId,
    Set<DeliveryStatus> statuses = const {},
  }) => _api.webhook.deliveries(
    cursor: cursor,
    limit: pageSize,
    direction: 'desc',
    endpointId: endpointId,
    status: statuses.isEmpty ? null : [for (final s in statuses) s.value],
  );

  /// Queues delivery [id] for another attempt (`webhook.redeliver`).
  Future<void> redeliver(String id) => _api.webhook.redeliver(id);

  /// Every sync source with what a run would use (`sync.source.list`).
  Future<List<SyncSource>> syncSources() =>
      _api.sync.sourceList().then((p) => p.items);

  /// Saves a source, or with `check` set validates it and saves nothing
  /// (`sync.source.put`).
  Future<SyncSource> saveSyncSource(SyncSourceInput input) =>
      _api.sync.sourcePut(input);

  /// Removes source [id] and its cursor (`sync.source.delete`).
  Future<void> deleteSyncSource(String id) => _api.sync.sourceDelete(id);

  /// Runs source [id] now, or previews it with [dryRun] (`sync.run`).
  Future<SyncResult> runSync(
    String id, {
    bool dryRun = false,
    bool full = false,
  }) => _api.sync.run(
    RunSyncInput(
      sourceId: id,
      dryRun: dryRun ? true : null,
      full: full ? true : null,
    ),
  );

  /// One page of finished sync runs, newest first (`audit.list`).
  Future<Page<AuditEntry>> syncRuns({String? cursor}) => _api.audit.list(
    cursor: cursor,
    limit: pageSize,
    sort: 'seq',
    direction: 'desc',
    subjectType: syncSubject,
    action: const [syncRunAction],
  );
}
