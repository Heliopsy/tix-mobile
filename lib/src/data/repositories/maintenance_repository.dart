// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:tix_mobile/src/core/config/config.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/cache/response_cache.dart';
import 'package:tix_mobile/src/data/models/integrations.dart';
import 'package:tix_mobile/src/data/models/page.dart';
import 'package:tix_mobile/src/data/models/task.dart';

export 'package:tix_mobile/src/data/models/integrations.dart';

/// The tenant's retention windows, housekeeping rules and trash.
class MaintenanceRepository {
  /// Reads and writes through [_api], keeping copies in [_cache].
  MaintenanceRepository(this._api, this._cache);

  final TixApi _api;
  final ResponseCache _cache;

  static Page<Task> _tasks(Object? json) => Page.fromJson(
    json! as Map<String, dynamic>,
    (e) => Task.fromJson(e! as Map<String, dynamic>),
  );

  /// The retention policy in force (`retention.get`).
  Future<RetentionPolicy> retention() =>
      _cache.remember('retention', _api.retention.get(), (v) => v.toJson());

  /// The retention policy as last read.
  Future<RetentionPolicy?> cachedRetention() => _cache.peek(
    'retention',
    (j) => RetentionPolicy.fromJson(j! as Map<String, dynamic>),
  );

  /// Changes the windows given, as durations such as `720h`; null leaves
  /// one alone (`retention.put`).
  Future<RetentionPolicy> saveRetention({
    String? events,
    String? auditEntries,
    String? webhookDeliveries,
  }) => _api.retention.put(
    RetentionPolicy(
      events: events,
      auditEntries: auditEntries,
      webhookDeliveries: webhookDeliveries,
    ),
  );

  /// Removes what is past its window, or counts it with [dryRun]
  /// (`retention.prune`).
  Future<PruneResult> prune({bool dryRun = false}) =>
      _api.retention.prune(body: PruneInput(dryRun: dryRun ? true : null));

  /// The tenant's housekeeping policy and what it would act on now
  /// (`housekeeping.get`).
  Future<HousekeepingView> housekeeping() => _cache.remember(
    'housekeeping',
    _api.housekeeping.get(),
    (v) => v.toJson(),
  );

  /// The housekeeping policy as last read.
  Future<HousekeepingView?> cachedHousekeeping() => _cache.peek(
    'housekeeping',
    (j) => HousekeepingView.fromJson(j! as Map<String, dynamic>),
  );

  /// Sets the tenant's rules: each `off`, a number of days, or null to
  /// leave it (`housekeeping.put`).
  Future<HousekeepingView> saveHousekeeping({
    String? done,
    String? cancelled,
    String? trash,
  }) => _api.housekeeping.put(
    HousekeepingInput(done: done, cancelled: cancelled, trash: trash),
  );

  /// Applies the policy once, or previews it with [dryRun]
  /// (`housekeeping.run`).
  Future<HousekeepingResult> runHousekeeping({bool dryRun = false}) => _api
      .housekeeping
      .run(body: HousekeepingRunInput(dryRun: dryRun ? true : null));

  /// One page of the tasks in the trash (`task.list`, `trashed=true`).
  Future<Page<Task>> trash({String? cursor}) {
    final fresh = _api.task.list(
      trashed: 'true',
      cursor: cursor,
      limit: pageSize,
    );
    if (cursor != null) return fresh;
    return _cache.remember('trash', fresh, (p) => p.toJson((e) => e.toJson()));
  }

  /// The first page of the trash as last read.
  Future<Page<Task>?> cachedTrash() => _cache.peek('trash', _tasks);

  /// Brings [ref] back from the trash (`task.restore`).
  Future<Task> restore(String ref) => _api.task.restore(ref);

  /// Deletes the trashed task [ref] for good, with its trashed subtasks
  /// (`task.purge`), and drops it from the kept first page so a reload
  /// does not show it again before the server answers.
  Future<void> purge(String ref) async {
    await _api.task.purge(ref);
    final kept = await cachedTrash();
    if (kept == null) return;
    await _cache.keep(
      'trash',
      Page(
        items: [
          for (final t in kept.items)
            if (t.ref != ref) t,
        ],
        nextCursor: kept.nextCursor,
      ),
      (p) => p.toJson((e) => e.toJson()),
    );
  }
}
