// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:io' show Platform;
import 'dart:ui' show AppExitResponse;

import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/platform/local_access.dart';
import 'package:tix_mobile/src/core/storage/providers.dart';
import 'package:tix_mobile/src/data/local/ffi_local_engine.dart';
import 'package:tix_mobile/src/data/local/in_place.dart';
import 'package:tix_mobile/src/data/local/local_engine.dart';
import 'package:tix_mobile/src/data/models/instance.dart';
import 'package:tix_mobile/src/data/repositories/settings_repository.dart';

part 'local.g.dart';

/// Whether the add-instance screen offers local databases: when this build
/// has the engine, unless `--dart-define=TIX_LOCAL_INSTANCES=false` (or
/// `true`, to show the screens in a build without it) says otherwise.
@Riverpod(keepAlive: true)
bool localInstancesEnabled(Ref ref) =>
    switch (const String.fromEnvironment('TIX_LOCAL_INSTANCES')) {
      'true' => true,
      'false' => false,
      _ => ref.watch(localTixEngineProvider) is! UnavailableLocalTixEngine,
    };

/// The embedded engine: libtix when this build bundles it, otherwise one
/// that says local databases are not available.
@Riverpod(keepAlive: true)
LocalTixEngine localTixEngine(Ref ref) =>
    FfiLocalTixEngine.load() ?? const UnavailableLocalTixEngine();

/// Whether engines stop while the app is in the background. Phones suspend
/// a backgrounded app anyway; desktops keep running when minimised.
@Riverpod(keepAlive: true)
bool localEnginesStopInBackground(Ref ref) =>
    Platform.isAndroid || Platform.isIOS;

/// How long a local engine may serve no request before it stops; null for
/// never. Ten minutes until the person picks another.
@Riverpod(keepAlive: true)
class LocalIdleTimeout extends _$LocalIdleTimeout {
  /// The default timeout.
  static const fallback = Duration(minutes: 10);

  SettingsRepository get _settings =>
      SettingsRepository(ref.read(keyValueStoreProvider));

  @override
  Duration? build() {
    ref.watch(keyValueStoreProvider);
    final minutes = _settings.localIdleMinutes();
    if (minutes == null) return fallback;
    return minutes <= 0 ? null : Duration(minutes: minutes);
  }

  /// Switches to [timeout], null for never, and remembers it.
  Future<void> set(Duration? timeout) async {
    state = timeout;
    await _settings.setLocalIdleMinutes(timeout?.inMinutes ?? 0);
  }
}

/// Where a local instance's engine stands.
enum LocalEngineState {
  /// Not running.
  stopped,

  /// Opening the database.
  starting,

  /// Serving its address.
  running,

  /// Stopped while idle or in the background; the next request starts it.
  resting,
}

/// A local instance's engine as the Instances screen shows it.
@immutable
class LocalEngineStatus {
  /// Creates a status.
  const LocalEngineStatus({
    this.state = LocalEngineState.stopped,
    this.baseUrl = '',
    this.dbPath = '',
    this.findings = SyncFindings.none,
  });

  /// Where the engine stands.
  final LocalEngineState state;

  /// The address it serves while running.
  final String baseUrl;

  /// The file it opened, empty when it never ran.
  final String dbPath;

  /// What was found next to a file used in place when it last started.
  final SyncFindings findings;

  /// Whether an engine is running or starting.
  bool get active =>
      state == LocalEngineState.running || state == LocalEngineState.starting;

  @override
  bool operator ==(Object other) =>
      other is LocalEngineStatus &&
      other.state == state &&
      other.baseUrl == baseUrl &&
      other.dbPath == dbPath &&
      other.findings == findings;

  @override
  int get hashCode => Object.hash(state, baseUrl, dbPath, findings);
}

/// The engines running for local instances, at most one at a time.
class LocalEngines {
  /// Starts and stops [engine], reaching files through [access].
  LocalEngines(this.engine, {LocalFileAccess? access, Duration? idleAfter})
    : access = access ?? const SystemLocalFileAccess() {
    this.idleAfter = idleAfter;
  }

  /// The engine every local instance runs on.
  final LocalTixEngine engine;

  /// How files outside the app are reached.
  final LocalFileAccess access;

  Duration? _idleAfter;
  final _handles = <String, Future<LocalHandle>>{};
  final _running = <String, LocalHandle>{};
  final _instances = <String, Instance>{};
  final _addresses = <String, String>{};
  final _suspended = <String>{};
  final _resting = <String>{};
  final _stopping = <String, Future<void>>{};
  final _timers = <String, Timer>{};
  final _busy = <String, int>{};
  final _findings = <String, SyncFindings>{};
  var _lifecycle = Future<void>.value();
  final _moved = StreamController<String>.broadcast();
  final _renewed = StreamController<Instance>.broadcast();
  final _changes = StreamController<void>.broadcast();

  /// Instances whose engine came back on another address after a rest or a
  /// suspend; whatever holds the old address must rebuild.
  Stream<String> get moved => _moved.stream;

  /// Instances whose file moved or whose bookmark was renewed when their
  /// engine started; the saved instance should be replaced.
  Stream<Instance> get renewed => _renewed.stream;

  /// Fires whenever a status changes.
  Stream<void> get changes => _changes.stream;

  /// The instances with an engine running or starting.
  Iterable<String> get running => _handles.keys;

  /// How long an engine may serve no request; null for never.
  Duration? get idleAfter => _idleAfter;

  set idleAfter(Duration? value) {
    _idleAfter = value == null || value <= Duration.zero ? null : value;
    [..._running.keys].forEach(touch);
  }

  /// The status of every instance an engine has run for.
  Map<String, LocalEngineStatus> get statuses => {
    for (final MapEntry(key: id, value: i) in _instances.entries)
      id: LocalEngineStatus(
        state: _running.containsKey(id)
            ? LocalEngineState.running
            : _handles.containsKey(id)
            ? LocalEngineState.starting
            : _resting.contains(id) || _suspended.contains(id)
            ? LocalEngineState.resting
            : LocalEngineState.stopped,
        baseUrl: _running[id]?.baseUrl ?? '',
        dbPath: i.dbPath,
        findings: _findings[id] ?? SyncFindings.none,
      ),
  };

  void _changed() {
    if (!_changes.isClosed) _changes.add(null);
  }

  /// The engine serving [instance], started if needed, on the address it
  /// last had when it rests. Every other instance's engine is stopped
  /// first: only the active instance runs. Resets the idle timer.
  Future<LocalHandle> ensure(Instance instance) async {
    await stopAllExcept(instance.id);
    var starting = _handles[instance.id];
    if (starting == null) {
      final known = _instances[instance.id];
      final current = known == null
          ? instance
          : instance.copyWith(dbPath: known.dbPath, bookmark: known.bookmark);
      _instances[instance.id] = current;
      starting = _start(current);
      _handles[instance.id] = starting;
      _resting.remove(instance.id);
      _changed();
    }
    try {
      final h = await starting;
      touch(instance.id);
      return h;
    } on Object {
      _handles.remove(instance.id)?.ignore();
      _changed();
      rethrow;
    }
  }

  Future<LocalHandle> _start(Instance instance) async {
    await _stopping[instance.id];
    final address = _addresses.remove(instance.id);
    final grant = await access.open(instance);
    var started = instance;
    if (grant.dbPath != instance.dbPath ||
        grant.bookmark != instance.bookmark) {
      started = instance.copyWith(
        dbPath: grant.dbPath,
        bookmark: grant.bookmark,
      );
      _instances[instance.id] = started;
      _renewed.add(started);
    }
    try {
      if (started.inPlace) {
        _findings[instance.id] = await access.findings(started.dbPath);
      }
      final h = await _startEngine(started.dbPath, address);
      _running[instance.id] = h;
      if (address != null && Uri.parse(h.baseUrl).authority != address) {
        _moved.add(instance.id);
      }
      _changed();
      return h;
    } on Object {
      await access.close(started);
      rethrow;
    }
  }

  Future<LocalHandle> _startEngine(String dbPath, String? address) async {
    if (address == null) {
      return await engine.start(dbPath: dbPath, initIfMissing: false);
    }
    try {
      return await engine.start(
        dbPath: dbPath,
        initIfMissing: false,
        listen: address,
      );
    } on TixException {
      return await engine.start(dbPath: dbPath, initIfMissing: false);
    }
  }

  /// Takes over [handle], started for [instance] while adding it, with
  /// what was [found] next to its file.
  void adopt(
    Instance instance,
    LocalHandle handle, {
    SyncFindings found = SyncFindings.none,
  }) {
    _handles[instance.id] = Future.value(handle);
    _running[instance.id] = handle;
    _instances[instance.id] = instance;
    _findings[instance.id] = found;
    _resting.remove(instance.id);
    touch(instance.id);
    _changed();
  }

  /// Marks a request to [instanceId]'s engine: the idle timer starts over,
  /// unless a request is still in flight.
  void touch(String instanceId) {
    _timers.remove(instanceId)?.cancel();
    final idle = _idleAfter;
    if (idle == null ||
        !_running.containsKey(instanceId) ||
        (_busy[instanceId] ?? 0) > 0) {
      return;
    }
    _timers[instanceId] = Timer(idle, () => unawaited(rest(instanceId)));
  }

  /// The engine serving [instance], started if needed, held awake until
  /// [done] says the request that needed it has finished.
  Future<LocalHandle> wake(Instance instance) async {
    final h = await ensure(instance);
    _busy[instance.id] = (_busy[instance.id] ?? 0) + 1;
    _timers.remove(instance.id)?.cancel();
    return h;
  }

  /// Ends a request [wake] started; the idle timer starts over when it was
  /// the last one.
  void done(String instanceId) {
    final n = (_busy[instanceId] ?? 1) - 1;
    if (n <= 0) {
      _busy.remove(instanceId);
    } else {
      _busy[instanceId] = n;
    }
    touch(instanceId);
  }

  /// Stops the engine of [instanceId] and remembers its address, so the
  /// next [ensure] brings it back where it was.
  Future<void> rest(String instanceId) async {
    final h = _running[instanceId];
    if (h == null) return;
    _addresses[instanceId] = Uri.parse(h.baseUrl).authority;
    _resting.add(instanceId);
    await _halt(instanceId);
    _changed();
  }

  /// Stops the engine of [instanceId], if one runs, and forgets its address.
  Future<void> stop(String instanceId) async {
    _addresses.remove(instanceId);
    _resting.remove(instanceId);
    _suspended.remove(instanceId);
    await _halt(instanceId);
    _changed();
  }

  Future<void> _halt(String instanceId) async {
    _timers.remove(instanceId)?.cancel();
    _running.remove(instanceId);
    final handle = _handles.remove(instanceId);
    if (handle == null) return;
    final instance = _instances[instanceId];
    final done = _stopAndClose(await handle, instance);
    _stopping[instanceId] = done;
    try {
      await done;
    } finally {
      _stopping.removeWhere((id, f) => id == instanceId && identical(f, done));
    }
  }

  Future<void> _stopAndClose(LocalHandle handle, Instance? instance) async {
    await engine.stop(handle);
    if (instance != null) await access.close(instance);
  }

  /// Stops every engine but the one of [instanceId].
  Future<void> stopAllExcept(String? instanceId) async {
    for (final id in [..._handles.keys]) {
      if (id != instanceId) await stop(id);
    }
  }

  /// Stops every engine.
  Future<void> stopAll() => stopAllExcept(null);

  /// Rests every running engine whose instance [where] picks.
  Future<void> restWhere(bool Function(Instance) where) async {
    for (final id in [..._running.keys]) {
      final i = _instances[id];
      if (i != null && where(i)) await rest(id);
    }
  }

  /// Stops every running engine gracefully, remembering each for [resume].
  Future<void> suspend() => _lifecycle = _lifecycle.then((_) async {
    for (final id in [..._handles.keys]) {
      await _handles[id];
      if (!_running.containsKey(id)) continue;
      await rest(id);
      _resting.remove(id);
      _suspended.add(id);
    }
  });

  /// Restarts what [suspend] stopped, on the same address when it is free.
  Future<void> resume() => _lifecycle = _lifecycle.then((_) async {
    final suspended = {..._suspended};
    _suspended.clear();
    for (final id in suspended) {
      final i = _instances[id];
      if (_handles.containsKey(id) || i == null) continue;
      await ensure(i);
    }
  });

  /// Releases the streams and timers.
  void dispose() {
    for (final t in _timers.values) {
      t.cancel();
    }
    unawaited(_moved.close());
    unawaited(_renewed.close());
    unawaited(_changes.close());
  }
}

/// The running engines; all stop when the container goes.
@Riverpod(keepAlive: true)
LocalEngines localEngines(Ref ref) {
  final engines = LocalEngines(
    ref.watch(localTixEngineProvider),
    access: ref.watch(localFileAccessProvider),
  );
  ref
    ..listen(
      localIdleTimeoutProvider,
      (_, timeout) => engines.idleAfter = timeout,
      fireImmediately: true,
    )
    ..onDispose(() {
      unawaited(engines.stopAll());
      engines.dispose();
    });
  return engines;
}

/// Every local engine's status, refreshed as engines start and stop.
@Riverpod(keepAlive: true)
Stream<Map<String, LocalEngineStatus>> localEngineStatuses(Ref ref) async* {
  final engines = ref.watch(localEnginesProvider);
  yield engines.statuses;
  await for (final _ in engines.changes) {
    yield engines.statuses;
  }
}

/// Stops every engine when the app exits, and on phones while it is in the
/// background, starting them again on resume. Engines of files used in
/// place rest whenever the app is hidden, on every platform, so a sync
/// client finds their log checkpointed into the file. Read when a local
/// instance first becomes active; exit is a request on desktop and a detach
/// on phones, where it is best effort.
@Riverpod(keepAlive: true)
AppLifecycleListener localEngineLifecycle(Ref ref) {
  final engines = ref.watch(localEnginesProvider);
  final background = ref.watch(localEnginesStopInBackgroundProvider);
  final listener = AppLifecycleListener(
    onExitRequested: () async {
      await engines.stopAll();
      return AppExitResponse.exit;
    },
    onDetach: () => unawaited(engines.stopAll()),
    onHide: () => unawaited(engines.restWhere((i) => i.inPlace)),
    onPause: background ? () => unawaited(engines.suspend()) : null,
    onResume: background ? () => unawaited(engines.resume()) : null,
  );
  ref.onDispose(listener.dispose);
  return listener;
}
