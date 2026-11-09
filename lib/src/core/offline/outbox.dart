// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/clock/clock.dart';
import 'package:tix_mobile/src/core/events/events.dart';
import 'package:tix_mobile/src/core/offline/connectivity.dart';
import 'package:tix_mobile/src/core/offline/sync.dart';
import 'package:tix_mobile/src/core/session/api.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/storage/providers.dart';
import 'package:tix_mobile/src/core/storage/stores.dart';
import 'package:tix_mobile/src/data/cache/cache_store.dart';
import 'package:tix_mobile/src/data/models/connection.dart';
import 'package:tix_mobile/src/data/offline/connection_jobs.dart';
import 'package:tix_mobile/src/data/offline/outbox.dart';
import 'package:tix_mobile/src/data/offline/sender.dart';

export 'package:tix_mobile/src/data/offline/outbox.dart';

part 'outbox.g.dart';

/// How long replay waits after the server comes back before it sends, so a
/// flapping network sends once.
const replaySettle = Duration(seconds: 2);

/// How often waiting writes are tried again while the server is reachable.
const replayRetry = Duration(minutes: 1);

/// Everything waiting to sync in the active context, kept current.
@Riverpod(keepAlive: true)
Stream<SyncSnapshot> syncState(Ref ref) async* {
  final store = ref.watch(syncStoreProvider);
  yield await store.load();
  yield* store.changes;
}

/// Where an unreadable sync state of the active context was set aside, or
/// an empty string when it could not be; null when it was read.
@riverpod
String? syncSetAside(Ref ref) {
  if (ref.watch(syncStateProvider).value == null) return null;
  final store = ref.watch(syncStoreProvider);
  if (!store.unreadable) return null;
  return store.setAside ?? '';
}

/// The lock that keeps replays of one context from overlapping, shared by
/// every replayer [OutboxSync] builds.
@Riverpod(keepAlive: true)
ReplayLocks replayLocks(Ref ref) => ReplayLocks();

/// The writes waiting for the task [ref], for its unsynced mark and banner.
@riverpod
List<OutboxEntry> pendingWrites(Ref ref, String taskRef) {
  final snap = ref.watch(syncStateProvider).value;
  if (snap == null) return const [];
  final real = snap.drafts[taskRef] ?? taskRef;
  return [
    for (final e in snap.entries)
      if ((snap.drafts[e.target] ?? e.target) == real) e,
  ];
}

/// The references of every task with a write waiting, for rows.
@riverpod
Set<String> unsyncedRefs(Ref ref) {
  final snap = ref.watch(syncStateProvider).value;
  return {for (final e in snap?.entries ?? const <OutboxEntry>[]) e.target};
}

/// The conflicts nobody has settled yet, newest first.
@riverpod
List<ConflictRecord> openConflicts(Ref ref) => [
  for (final r
      in ref.watch(syncStateProvider).value?.conflicts ??
          const <ConflictRecord>[])
    if (r.resolution == null) r,
];

/// How conflicts found during replay are settled in the active context:
/// asking by default.
@Riverpod(keepAlive: true)
class ConflictPolicySetting extends _$ConflictPolicySetting {
  static String _keyOf(CacheScope scope) =>
      'sync.policy.${scope.connectionId}.${scope.tenantKey}';

  /// The policy kept for [scope] in [settings].
  static ConflictPolicy storedFor(KeyValueStore settings, CacheScope scope) =>
      ConflictPolicy.values.asNameMap()[settings.read(_keyOf(scope))] ??
      ConflictPolicy.ask;

  String? get _key {
    final scope = ref.read(activeCacheScopeProvider);
    return scope == null ? null : _keyOf(scope);
  }

  @override
  ConflictPolicy build() {
    final scope = ref.watch(activeCacheScopeProvider);
    if (scope == null) return ConflictPolicy.ask;
    return storedFor(ref.read(keyValueStoreProvider), scope);
  }

  /// Settles conflicts found from now on by [policy].
  Future<void> set(ConflictPolicy policy) async {
    final key = _key;
    if (key == null) return;
    state = policy;
    await ref.read(keyValueStoreProvider).write(key, policy.name);
  }
}

/// Where replay stands.
@immutable
class ReplayStatus {
  /// A status.
  const ReplayStatus({this.running = false, this.last, this.error});

  /// Whether writes are being sent.
  final bool running;

  /// What the last replay did.
  final ReplayReport? last;

  /// Why the last replay could not run.
  final Object? error;
}

/// Sends the active context's outbox: when the network comes back, when
/// the event stream goes live again, when a write is queued while the
/// server is reachable, every [replayRetry] while writes wait, and first
/// in every sync. After writes go out it reports a gap on the event
/// stream, so every screen reloads from the server.
@Riverpod(keepAlive: true)
class OutboxSync extends _$OutboxSync {
  OutboxReplayer? _replayer;
  CacheScope? _scope;
  Timer? _soon;
  bool _auto = false;
  bool _registered = false;

  @override
  ReplayStatus build() {
    _replayer = null;
    _scope = null;
    final session = ref.watch(sessionControllerProvider).value;
    if (session == null || session.problem != null) return const ReplayStatus();
    final store = ref.watch(syncStoreProvider);
    final settings = ref.read(keyValueStoreProvider);
    _auto = ref.watch(autoSyncProvider);
    _scope = store.scope;
    _replayer = OutboxReplayer(
      store,
      ApiOutboxSender(
        ref.watch(tixApiFactoryProvider)(session.baseUrl, session.credential),
      ),
      policy: () => ConflictPolicySetting.storedFor(settings, store.scope),
      locks: ref.read(replayLocksProvider),
      clock: ref.read(clockProvider),
    );
    scheduleMicrotask(() {
      if (!ref.mounted) return;
      if (!_registered) {
        _registered = true;
        ref.read(syncStepsProvider.notifier).add(() async {
          await replayNow();
        });
      }
      ref
          .read(serverOfflineProvider.notifier)
          .set(offline: !ref.read(onlineProvider));
    });
    final retry = _auto ? Timer.periodic(replayRetry, (_) => _maybe()) : null;
    ref
      ..onDispose(() => retry?.cancel())
      ..onDispose(() => _soon?.cancel())
      ..listen(onlineProvider, (was, now) {
        ref.read(serverOfflineProvider.notifier).set(offline: !now);
        if (was == false && now) _schedule();
      })
      ..listen(liveStatusProvider, (was, now) {
        bool live(LiveStatus? s) =>
            s?.mode == LiveMode.websocket || s?.mode == LiveMode.polling;
        if (live(now.value) && !live(was?.value)) _schedule();
      })
      ..listen(syncStateProvider, (was, now) {
        final before = was?.value?.nextSeq ?? 0;
        final after = now.value?.nextSeq ?? 0;
        if (after > before && before > 0) _schedule();
      });
    unawaited(store.load().then((_) => _schedule()));
    return const ReplayStatus();
  }

  void _schedule() {
    if (!_auto) return;
    _soon?.cancel();
    _soon = Timer(replaySettle, _maybe);
  }

  void _maybe() {
    if (!ref.mounted || !ref.read(onlineProvider)) return;
    final store = ref.read(syncStoreProvider);
    final waiting = store.now.entries.any(
      (e) =>
          e.state == OutboxState.pending || e.state == OutboxState.needsCheck,
    );
    if (waiting) unawaited(replayNow());
  }

  /// Sends every waiting write now and answers with what happened. A
  /// replay stopped because its connection is being forgotten answers null.
  Future<ReplayReport?> replayNow() async {
    final replayer = _replayer;
    final scope = _scope;
    if (replayer == null || scope == null) return null;
    final jobs = ref.read(connectionJobsProvider);
    state = ReplayStatus(running: true, last: state.last);
    try {
      final report = await jobs.run(
        scope.connectionId,
        (job) => replayer.replay(job: job),
      );
      if (!ref.mounted) return report;
      state = ReplayStatus(last: report);
      if (report.sent > 0 || report.conflicts > 0) {
        ref.read(tixEventStreamProvider)?.reportGap();
      }
      return report;
    } on JobCancelled {
      if (ref.mounted) state = ReplayStatus(last: state.last);
      return null;
    } on Object catch (e) {
      if (ref.mounted) state = ReplayStatus(last: state.last, error: e);
      return null;
    }
  }

  /// How many writes wait to be sent for the connection [connectionId], in
  /// every tenant it reaches, for a warning before it is forgotten.
  Future<int> unsentForConnection(String connectionId) async {
    final c = ref.read(instancesRepositoryProvider).connection(connectionId);
    return c == null ? 0 : await _unsent([c]);
  }

  /// How many writes wait to be sent for every connection of the instance
  /// [instanceId].
  Future<int> unsentForInstance(String instanceId) =>
      _unsent(ref.read(instancesRepositoryProvider).connectionsOf(instanceId));

  Future<int> _unsent(List<Connection> connections) async {
    final cache = ref.read(cacheStoreProvider);
    final active = ref.read(activeCacheScopeProvider);
    var total = 0;
    for (final c in connections) {
      final scopes = {
        CacheScope(c.id, ''),
        CacheScope(c.id, c.tenantKey),
        for (final m in c.memberships) CacheScope(c.id, m.tenantKey),
      };
      for (final scope in scopes) {
        final snap = scope == active
            ? await ref.read(syncStoreProvider).load()
            : await SyncStore.peek(cache, scope);
        total += snap?.entries.length ?? 0;
      }
    }
    return total;
  }

  Outbox get _outbox => ref.read(outboxProvider);

  Future<void> _then(Future<void> change) async {
    await change;
    if (ref.mounted && ref.read(onlineProvider)) await replayNow();
  }

  /// Settles the open conflict [recordId] as [resolution], with [edited]
  /// values for an edit, and sends what that leaves.
  Future<void> resolve(
    String recordId,
    Resolution resolution, {
    Map<String, Object?> edited = const {},
  }) => _then(_outbox.resolve(recordId, resolution, edited: edited));

  /// Settles every open conflict over attributes as [resolution].
  Future<void> resolveAll(Resolution resolution) =>
      _then(_outbox.resolveAll(resolution));

  /// Puts back the side the settled conflict [recordId] did not keep.
  Future<void> reverse(String recordId) => _then(_outbox.reverse(recordId));

  /// Drops the waiting write [entryId].
  Future<void> discard(String entryId) => _outbox.discard(entryId);

  /// Drops every waiting write in the active context.
  Future<void> discardAll() => _outbox.discardAll();

  /// Sends the refused or to-be-checked write [entryId] again, with
  /// [values] when the person edited it.
  Future<void> retry(String entryId, {Map<String, Object?>? values}) =>
      _then(_outbox.retry(entryId, values: values));

  /// Takes the person's word that the create [entryId] already happened.
  Future<void> forgetCreate(String entryId) => _outbox.forgetCreate(entryId);
}
