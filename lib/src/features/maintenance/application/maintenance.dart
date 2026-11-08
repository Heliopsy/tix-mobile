// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/cache/cached.dart';
import 'package:tix_mobile/src/core/events/invalidation.dart';
import 'package:tix_mobile/src/core/paging/paged.dart';
import 'package:tix_mobile/src/core/session/integrations.dart';
import 'package:tix_mobile/src/data/models/page.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/data/repositories/maintenance_repository.dart';

part 'maintenance.g.dart';

/// The tenant's retention windows.
@riverpod
class Retention extends _$Retention {
  @override
  Future<RetentionPolicy> build() {
    final repo = ref.watch(maintenanceRepositoryProvider);
    return cachedFirst(
      ref: ref,
      cached: repo.cachedRetention(),
      fresh: repo.retention,
      onFresh: (v) => state = AsyncData(v),
    );
  }

  /// Saves the windows given; null leaves one alone.
  Future<void> save({
    String? events,
    String? auditEntries,
    String? webhookDeliveries,
  }) async {
    final saved = await ref
        .read(maintenanceRepositoryProvider)
        .saveRetention(
          events: events,
          auditEntries: auditEntries,
          webhookDeliveries: webhookDeliveries,
        );
    if (ref.mounted) state = AsyncData(saved);
  }

  /// Removes what is past its window, or counts it with [dryRun].
  Future<PruneResult> prune({bool dryRun = false}) =>
      ref.read(maintenanceRepositoryProvider).prune(dryRun: dryRun);
}

/// The tenant's housekeeping rules and what they would act on now.
@riverpod
class Housekeeping extends _$Housekeeping {
  @override
  Future<HousekeepingView> build() {
    final repo = ref.watch(maintenanceRepositoryProvider);
    return cachedFirst(
      ref: ref,
      cached: repo.cachedHousekeeping(),
      fresh: repo.housekeeping,
      onFresh: (v) => state = AsyncData(v),
    );
  }

  /// Sets the rules given: `off`, a number of days, or null to leave one.
  Future<void> save({String? done, String? cancelled, String? trash}) async {
    final saved = await ref
        .read(maintenanceRepositoryProvider)
        .saveHousekeeping(done: done, cancelled: cancelled, trash: trash);
    if (ref.mounted) state = AsyncData(saved);
  }

  /// Applies the rules once, or previews them with [dryRun]; a real run
  /// reloads the counts and the trash.
  Future<HousekeepingResult> run({bool dryRun = false}) async {
    final result = await ref
        .read(maintenanceRepositoryProvider)
        .runHousekeeping(dryRun: dryRun);
    if (!dryRun && ref.mounted) {
      ref
        ..invalidateSelf()
        ..invalidate(trashProvider);
    }
    return result;
  }
}

/// The tasks in the trash, a page at a time.
@riverpod
class Trash extends _$Trash {
  @override
  Future<Paged<Task>> build() async {
    final repo = ref.watch(maintenanceRepositoryProvider);
    refreshOn(ref, EventTopics.tasks);
    final page = await cachedFirst(
      ref: ref,
      cached: repo.cachedTrash(),
      fresh: repo.trash,
      onFresh: (p) => state = AsyncData(_paged(p)),
    );
    return _paged(page);
  }

  static Paged<Task> _paged(Page<Task> p) =>
      Paged(items: p.items, cursor: p.nextCursor);

  /// Fetches the next page, if there is one and none is in flight.
  Future<void> loadMore() => loadNextPage(
    current: state.value,
    fetch: (cursor) =>
        ref.read(maintenanceRepositoryProvider).trash(cursor: cursor),
    emit: (next) => state = AsyncData(next),
    idOf: (t) => t.id,
  );

  /// Brings [task] back and drops it from the list.
  Future<Task> restore(Task task) async {
    final restored = await ref
        .read(maintenanceRepositoryProvider)
        .restore(task.ref);
    final current = ref.mounted ? state.value : null;
    if (current != null) {
      state = AsyncData(
        current.copyWith(
          items: [
            for (final t in current.items)
              if (t.id != task.id) t,
          ],
        ),
      );
    }
    return restored;
  }
}
