// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'dart:ui' show AppExitResponse;

import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/data/local/local_engine.dart';
import 'package:tix_mobile/src/data/models/instance.dart';

part 'local.g.dart';

/// Whether the add-instance screen offers local databases. Set with
/// `--dart-define=TIX_LOCAL_INSTANCES=true` until the engine ships.
@Riverpod(keepAlive: true)
bool localInstancesEnabled(Ref ref) =>
    const bool.fromEnvironment('TIX_LOCAL_INSTANCES');

/// The embedded engine. This build has none; the FFI library replaces this.
@Riverpod(keepAlive: true)
LocalTixEngine localTixEngine(Ref ref) => const UnavailableLocalTixEngine();

/// The engines running for local instances, at most one per instance.
class LocalEngines {
  /// Starts and stops [engine].
  LocalEngines(this.engine);

  /// The engine every local instance runs on.
  final LocalTixEngine engine;
  final _handles = <String, Future<LocalHandle>>{};

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
    }
    try {
      return await starting;
    } on Object {
      _handles.remove(instance.id)?.ignore();
      rethrow;
    }
  }

  /// Takes over [handle], started for [instanceId] while adding it.
  void adopt(String instanceId, LocalHandle handle) =>
      _handles[instanceId] = Future.value(handle);

  /// Stops the engine of [instanceId], if one runs.
  Future<void> stop(String instanceId) async {
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
}

/// The running engines; all stop when the container goes.
@Riverpod(keepAlive: true)
LocalEngines localEngines(Ref ref) {
  final engines = LocalEngines(ref.watch(localTixEngineProvider));
  ref.onDispose(() => unawaited(engines.stopAll()));
  return engines;
}

/// Stops every engine when the app exits. Read when a local instance first
/// becomes active; exit is a request on desktop and a detach on phones,
/// where it is best effort.
@Riverpod(keepAlive: true)
AppLifecycleListener localEngineLifecycle(Ref ref) {
  final engines = ref.watch(localEnginesProvider);
  final listener = AppLifecycleListener(
    onExitRequested: () async {
      await engines.stopAll();
      return AppExitResponse.exit;
    },
    onDetach: () => unawaited(engines.stopAll()),
  );
  ref.onDispose(listener.dispose);
  return listener;
}
