// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ProviderListenableSelect;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/clock/clock.dart';
import 'package:tix_mobile/src/core/offline/connectivity.dart';
import 'package:tix_mobile/src/core/session/api.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/storage/providers.dart';
import 'package:tix_mobile/src/data/cache/response_cache.dart';
import 'package:tix_mobile/src/data/models/instance.dart';
import 'package:tix_mobile/src/data/offline/connection_jobs.dart';
import 'package:tix_mobile/src/data/offline/offline_prefs.dart';
import 'package:tix_mobile/src/data/offline/prefetch.dart';
import 'package:tix_mobile/src/data/repositories/task_detail_repository.dart';
import 'package:tix_mobile/src/data/repositories/task_list_repository.dart';
import 'package:tix_mobile/src/data/repositories/tasks_repository.dart';

export 'package:tix_mobile/src/data/offline/offline_prefs.dart'
    show OfflineChoice;

part 'sync.g.dart';

/// How often background sync runs while the app is open.
const syncEvery = Duration(minutes: 30);

/// One step of a sync, run before the prefetch.
typedef SyncStep = Future<void> Function();

/// Starts a repeating timer; `Timer.periodic` unless a test swaps it.
typedef PeriodicTimer = Timer Function(
  Duration period,
  void Function(Timer timer) tick,
);

/// What each context keeps offline, in preferences.
@Riverpod(keepAlive: true)
OfflinePrefsRepository offlinePrefsRepository(Ref ref) =>
    OfflinePrefsRepository(ref.watch(keyValueStoreProvider));

/// Whether sync runs on its own (on activation, every [syncEvery], and when
/// the network comes back). Tests turn it off unless they test it.
@Riverpod(keepAlive: true)
bool autoSync(Ref ref) => true;

/// The timer background sync repeats on.
@Riverpod(keepAlive: true)
PeriodicTimer periodicTimer(Ref ref) => Timer.periodic;

/// The steps [OfflineSync.syncNow] awaits, in order, before it prefetches.
///
/// Sending queued changes belongs here, so the prefetch then reads the
/// server's answer to them: `ref.read(syncStepsProvider.notifier).add(step)`
/// registers one and returns what unregisters it. A step that throws stops
/// the sync, and its error becomes [OfflineSyncState.error].
@Riverpod(keepAlive: true)
class SyncSteps extends _$SyncSteps {
  @override
  List<SyncStep> build() => const [];

  /// Runs [step] on every sync from now on, after the steps added before
  /// it; the returned function takes it out again.
  void Function() add(SyncStep step) {
    state = [...state, step];
    return () => state = [
      for (final s in state)
        if (!identical(s, step)) s,
    ];
  }
}

/// Where the active context's offline sync stands.
@immutable
class OfflineSyncState {
  /// A state last synced at [lastSyncedAt].
  const OfflineSyncState({this.lastSyncedAt, this.running = false, this.error});

  /// When the last sync finished, null when it never has.
  final DateTime? lastSyncedAt;

  /// Whether a sync is running.
  final bool running;

  /// Why the last sync failed, null when it did not.
  final Object? error;
}

/// Keeps what the active context chose available offline: runs the
/// [SyncSteps], then fetches every listing, task, comment and subtask the
/// choice names into the response cache, where reads find it when the
/// server cannot be reached.
///
/// It runs when asked ([syncNow]) and, for a remote instance, on its own:
/// when the context becomes active, every [syncEvery] and when the network
/// comes back, unless a phone is on mobile data, in battery saver or low on
/// battery. A local instance is on this device and is never prefetched.
@Riverpod(keepAlive: true)
class OfflineSync extends _$OfflineSync {
  Future<void>? _running;

  @override
  OfflineSyncState build() {
    final scope = ref.watch(activeCacheScopeProvider);
    final remote = ref.watch(
      sessionControllerProvider.select(
        (s) => s.value?.instance.kind == InstanceKind.remote,
      ),
    );
    _running = null;
    if (scope == null) return const OfflineSyncState();
    if (remote && ref.watch(autoSyncProvider)) {
      final timer = ref.read(periodicTimerProvider)(
        syncEvery,
        (_) => unawaited(runAutomatic()),
      );
      ref
        ..onDispose(timer.cancel)
        ..listen(onlineProvider, (was, now) {
          if (was == false && now) unawaited(runAutomatic());
        });
      unawaited(Future(runAutomatic));
    }
    return OfflineSyncState(
      lastSyncedAt: ref.read(offlinePrefsRepositoryProvider).syncedAt(scope),
    );
  }

  bool get _remote =>
      ref.read(sessionControllerProvider).value?.instance.kind ==
      InstanceKind.remote;

  /// Syncs when the device allows background work: a remote instance, a
  /// network, and on a phone neither mobile data, battery saver nor a low
  /// battery. Answers whether it ran.
  Future<bool> runAutomatic() async {
    if (!ref.mounted || !_remote) return false;
    final network = await ref.read(networkStateProvider.future);
    if (!ref.mounted || network == NetworkState.offline) return false;
    final device = await ref.read(deviceProbeProvider)();
    if (!ref.mounted) return false;
    if (device.phone &&
        (network == NetworkState.metered ||
            device.batterySaver ||
            device.batteryLow)) {
      return false;
    }
    await syncNow();
    return true;
  }

  /// Runs the [SyncSteps] and the prefetch now, whatever the network; a
  /// call while one runs joins it. A failure is kept in
  /// [OfflineSyncState.error], not thrown. Does nothing for a local
  /// instance.
  Future<void> syncNow() =>
      _running ??= _sync().whenComplete(() => _running = null);

  Future<void> _sync() async {
    final scope = ref.read(activeCacheScopeProvider);
    if (scope == null || !_remote) return;
    try {
      await ref
          .read(connectionJobsProvider)
          .run(scope.connectionId, (job) => _syncAs(scope, job));
    } on JobCancelled {
      if (ref.mounted) {
        state = OfflineSyncState(lastSyncedAt: state.lastSyncedAt);
      }
    }
  }

  Future<void> _syncAs(CacheScope scope, ConnectionJob job) async {
    final prefs = ref.read(offlinePrefsRepositoryProvider);
    state = OfflineSyncState(lastSyncedAt: state.lastSyncedAt, running: true);
    final session = ref.read(sessionControllerProvider).value!;
    final api = ref.read(tixApiFactoryProvider)(
      session.baseUrl,
      session.credential,
    );
    final cache = ResponseCache(
      ref.read(cacheStoreProvider),
      scope,
      now: ref.read(clockProvider),
    );
    try {
      for (final step in ref.read(syncStepsProvider)) {
        job.check();
        await step();
      }
      await Prefetcher(
        tasks: TasksRepository(api, cache),
        lists: TaskListRepository(api, cache),
        detail: TaskDetailRepository(api, cache),
        now: ref.read(clockProvider),
        job: job,
      ).run(prefs.choice(scope));
      job.check();
      final at = ref.read(clockProvider)();
      await prefs.setSyncedAt(scope, at);
      if (ref.mounted) state = OfflineSyncState(lastSyncedAt: at);
    } on JobCancelled {
      rethrow;
    } on Object catch (e) {
      if (ref.mounted) {
        state = OfflineSyncState(lastSyncedAt: state.lastSyncedAt, error: e);
      }
    } finally {
      unawaited(cache.dispose());
    }
  }

  /// Forgets every copy kept for the active context, entries under
  /// `sync/` excepted, and when it last synced.
  Future<void> clear() async {
    final scope = ref.read(activeCacheScopeProvider);
    if (scope == null) return;
    await ref.read(cacheStoreProvider).clearScope(scope);
    await ref.read(offlinePrefsRepositoryProvider).clearSyncedAt(scope);
    if (ref.mounted) state = const OfflineSyncState();
  }
}

/// When the oldest copy a screen is drawing in place of the unreachable
/// server was kept, null while everything shown came from the server.
@riverpod
Stream<DateTime?> savedCopySince(Ref ref) async* {
  if (ref.watch(activeCacheScopeProvider) == null) {
    yield null;
    return;
  }
  final cache = ref.watch(responseCacheProvider);
  yield cache.staleSince;
  yield* cache.staleChanges;
}
