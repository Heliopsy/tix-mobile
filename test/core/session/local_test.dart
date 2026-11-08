// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/platform/files.dart';
import 'package:tix_mobile/src/core/session/local.dart';
import 'package:tix_mobile/src/data/local/local_engine.dart';
import 'package:tix_mobile/src/data/models/instance.dart';

import '../../helpers/container.dart';

void main() {
  Instance local(String id, String path) => Instance(
    id: id,
    name: id,
    kind: InstanceKind.local,
    dbPath: path,
    createdAt: DateTime(2026),
  );

  test('one engine per instance, the others stopped', () async {
    final engine = InMemoryLocalTixEngine(existing: ['/a.db', '/b.db']);
    final engines = LocalEngines(engine);
    final a = await engines.ensure(local('a', '/a.db'));
    expect(await engines.ensure(local('a', '/a.db')), a);
    expect(engine.started, ['/a.db']);
    await engines.ensure(local('b', '/b.db'));
    expect(engine.stopped, [a]);
    expect(engines.running, ['b']);
    await engines.stopAll();
    expect(engine.running, isEmpty);
  });

  test('a failed start is forgotten so the next one retries', () async {
    final engine = InMemoryLocalTixEngine();
    final engines = LocalEngines(engine);
    await expectLater(
      engines.ensure(local('a', '/missing.db')),
      throwsA(isA<TixException>()),
    );
    expect(engines.running, isEmpty);
  });

  test('an adopted handle is not started again', () async {
    final engine = InMemoryLocalTixEngine();
    final engines = LocalEngines(engine);
    final h = await engine.start(dbPath: '/a.db');
    engines.adopt('a', h);
    expect(await engines.ensure(local('a', '/a.db')), h);
    expect(engine.started, ['/a.db']);
    await engines.stop('a');
    await engines.stop('a');
    expect(engine.stopped, [h]);
  });

  test('the defaults: no engine, no flag, the system dialogs', () async {
    final c = makeContainer(const []);
    expect(c.read(localInstancesEnabledProvider), isFalse);
    expect(c.read(localTixEngineProvider), isA<UnavailableLocalTixEngine>());
    expect(c.read(filePickingProvider), isA<SystemFilePicking>());
    expect(withDbExtension(' notes '), 'notes.db');
    expect(withDbExtension('x.DB'), 'x.DB');
    expect(withDbExtension(''), 'tix.db');
  });

  testWidgets('exiting the app stops every engine', (tester) async {
    final engine = InMemoryLocalTixEngine(existing: ['/a.db']);
    final c = makeContainer([localTixEngineProvider.overrideWithValue(engine)]);
    await c.read(localEnginesProvider).ensure(local('a', '/a.db'));
    final listener = c.read(localEngineLifecycleProvider);
    expect(listener, isA<AppLifecycleListener>());
    final response = await tester.binding.handleRequestAppExit();
    expect(response, AppExitResponse.exit);
    expect(engine.running, isEmpty);
  });

  testWidgets('a detached app stops every engine', (tester) async {
    final engine = InMemoryLocalTixEngine(existing: ['/a.db']);
    final c = makeContainer([localTixEngineProvider.overrideWithValue(engine)]);
    await c.read(localEnginesProvider).ensure(local('a', '/a.db'));
    c.read(localEngineLifecycleProvider);
    tester.binding
      ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
      ..handleAppLifecycleStateChanged(AppLifecycleState.hidden)
      ..handleAppLifecycleStateChanged(AppLifecycleState.paused)
      ..handleAppLifecycleStateChanged(AppLifecycleState.detached);
    await tester.pump();
    expect(engine.running, isEmpty);
  });
}
