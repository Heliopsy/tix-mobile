// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:io' show Platform;
import 'dart:ui' show AppExitResponse;

import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/data/local/ffi_local_engine.dart';
import 'package:tix_mobile/src/data/local/local_engine.dart';
import 'package:tix_mobile/src/data/models/instance.dart';

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

/// The engines running for local instances, at most one per instance.
class LocalEngines {
  /// Starts and stops [engine].
  LocalEngines(this.engine);

  /// The engine every local instance runs on.
  final LocalTixEngine engine;
  final _handles = <String, Future<LocalHandle>>{};
  final _paths = <String, String>{};
  final _suspended = <String, (String, String)>{};
  var _lifecycle = Future<void>.value();
  final _moved = StreamController<String>.broadcast();

  /// Instances whose engine came back on another address after a suspend;
  /// whatever holds the old address must rebuild.
  Stream<String> get moved => _moved.stream;

  /// The instances with an engine running or starting.
  Iterable<String> get running => _handles.keys;

  /// The engine serving [instance], started if needed. Every other instance's
  /// engine is stopped first: only the active instance runs.
  Future<LocalHandle> ensure(Instance instance) async {
    await stopAllExcept(instance.id);
    var starting = _handles[instance.id];
    if (starting == null) {
      starting = engine.start(dbPath: instance.dbPath, initIfMissing: false);
      _handles[instance.id] = starting;
      _paths[instance.id] = instance.dbPath;
    }
    try {
      return await starting;
    } on Object {
      _handles.remove(instance.id)?.ignore();
      rethrow;
    }
  }

  /// Takes over [handle], started for [instance] while adding it.
  void adopt(Instance instance, LocalHandle handle) {
    _handles[instance.id] = Future.value(handle);
    _paths[instance.id] = instance.dbPath;
  }

  /// Stops the engine of [instanceId], if one runs.
  Future<void> stop(String instanceId) async {
    _paths.remove(instanceId);
    final handle = _handles.remove(instanceId);
    if (handle != null) await engine.stop(await handle);
  }

  /// Stops every engine but the one of [instanceId].
  Future<void> stopAllExcept(String? instanceId) async {
    for (final id in [..._handles.keys]) {
      if (id != instanceId) await stop(id);
    }
  }

  /// Stops every engine.
  Future<void> stopAll() => stopAllExcept(null);

  /// Stops every running engine gracefully, remembering each for [resume].
  Future<void> suspend() => _lifecycle = _lifecycle.then((_) async {
    for (final id in [..._handles.keys]) {
      final path = _paths[id];
      final h = await _handles[id];
      if (path == null || h == null) continue;
      _suspended[id] = (path, Uri.parse(h.baseUrl).authority);
      await stop(id);
    }
  });

  /// Restarts what [suspend] stopped, on the same address when it is free.
  Future<void> resume() => _lifecycle = _lifecycle.then((_) async {
    final suspended = {..._suspended};
    _suspended.clear();
    for (final MapEntry(key: id, value: (path, address)) in suspended.entries) {
      if (_handles.containsKey(id)) continue;
      LocalHandle h;
      try {
        h = await engine.start(
          dbPath: path,
          initIfMissing: false,
          listen: address,
        );
      } on TixException {
        h = await engine.start(dbPath: path, initIfMissing: false);
      }
      _handles[id] = Future.value(h);
      _paths[id] = path;
      if (Uri.parse(h.baseUrl).authority != address) _moved.add(id);
    }
  });

  /// Releases the [moved] stream.
  void dispose() => unawaited(_moved.close());
}

/// The running engines; all stop when the container goes.
@Riverpod(keepAlive: true)
LocalEngines localEngines(Ref ref) {
  final engines = LocalEngines(ref.watch(localTixEngineProvider));
  ref.onDispose(() {
    unawaited(engines.stopAll());
    engines.dispose();
  });
  return engines;
}

/// Stops every engine when the app exits, and on phones while it is in the
/// background, starting them again on resume. Read when a local instance
/// first becomes active; exit is a request on desktop and a detach on
/// phones, where it is best effort.
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
    onPause: background ? () => unawaited(engines.suspend()) : null,
    onResume: background ? () => unawaited(engines.resume()) : null,
  );
  ref.onDispose(listener.dispose);
  return listener;
}
