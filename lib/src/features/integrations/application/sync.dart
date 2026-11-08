// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/paging/paged.dart';
import 'package:tix_mobile/src/core/session/integrations.dart';
import 'package:tix_mobile/src/data/repositories/integrations_repository.dart';

part 'sync.g.dart';

/// The tenant's external sync sources, each with what a run would use and
/// what it lacks. Not cached: sources carry credential hints.
@riverpod
class SyncSources extends _$SyncSources {
  @override
  Future<List<SyncSource>> build() =>
      ref.watch(integrationsRepositoryProvider).syncSources();

  /// Validates [input] on the server and saves nothing: what a run would
  /// use, what it lacks, and the mapping's summary.
  Future<SyncSource> check(SyncSourceInput input) => ref
      .read(integrationsRepositoryProvider)
      .saveSyncSource(input.copyWith(check: true));

  /// Saves [input] and reloads the list.
  Future<SyncSource> save(SyncSourceInput input) async {
    final saved = await ref
        .read(integrationsRepositoryProvider)
        .saveSyncSource(input.copyWith(check: null));
    if (ref.mounted) ref.invalidateSelf();
    return saved;
  }

  /// Removes source [id].
  Future<void> delete(String id) async {
    await ref.read(integrationsRepositoryProvider).deleteSyncSource(id);
    if (!ref.mounted) return;
    state = AsyncData([
      for (final s in state.value ?? const <SyncSource>[])
        if (s.id != id) s,
    ]);
  }

  /// Runs source [id] now, or previews it with [dryRun]; a real run
  /// reloads the sources and the run history.
  Future<SyncResult> run(
    String id, {
    bool dryRun = false,
    bool full = false,
  }) async {
    final result = await ref
        .read(integrationsRepositoryProvider)
        .runSync(id, dryRun: dryRun, full: full);
    if (!dryRun && ref.mounted) {
      ref
        ..invalidateSelf()
        ..invalidate(syncRunsProvider);
    }
    return result;
  }
}

/// Finished sync runs, newest first, a page at a time.
@riverpod
class SyncRuns extends _$SyncRuns {
  @override
  Future<Paged<AuditEntry>> build() async {
    final page = await ref.watch(integrationsRepositoryProvider).syncRuns();
    return Paged(items: page.items, cursor: page.nextCursor);
  }

  /// Fetches the next page, if there is one and none is in flight.
  Future<void> loadMore() => loadNextPage(
    current: state.value,
    fetch: (cursor) =>
        ref.read(integrationsRepositoryProvider).syncRuns(cursor: cursor),
    emit: (next) => state = AsyncData(next),
    idOf: (e) => e.seq,
  );
}

/// The counts a run kept for one kind of record, tasks by default.
extension SyncResultCounts on SyncResult {
  /// How many records of [entity] the run created, updated, skipped and
  /// deleted.
  ({int created, int updated, int skipped, int deleted}) counts([
    String entity = 'task',
  ]) => (
    created: created[entity] ?? 0,
    updated: updated[entity] ?? 0,
    skipped: skipped[entity] ?? 0,
    deleted: deleted[entity] ?? 0,
  );
}

/// The run an audit entry for `sync.run` records, or null when it
/// carries none.
SyncResult? syncRunOf(AuditEntry entry) {
  final after = entry.after;
  if (after is! Map<String, dynamic>) return null;
  try {
    return SyncResult.fromJson(after);
  } on Object {
    return null;
  }
}
