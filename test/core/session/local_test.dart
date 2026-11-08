// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:io' show Platform;
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/platform/files.dart';
import 'package:tix_mobile/src/core/session/local.dart';
import 'package:tix_mobile/src/data/local/ffi_local_engine.dart';
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
    engines.adopt(local('a', '/a.db'), h);
    expect(await engines.ensure(local('a', '/a.db')), h);
    expect(engine.started, ['/a.db']);
    await engines.stop('a');
    await engines.stop('a');
    expect(engine.stopped, [h]);
  });

  test('local databases are offered when the engine is there', () {
    final without = makeContainer([
      localTixEngineProvider.overrideWithValue(
        const UnavailableLocalTixEngine(),
      ),
    ]);
    expect(without.read(localInstancesEnabledProvider), isFalse);
    final with_ = makeContainer([
      localTixEngineProvider.overrideWithValue(InMemoryLocalTixEngine()),
    ]);
    expect(with_.read(localInstancesEnabledProvider), isTrue);
  });

  test('the defaults: the bundled engine if any, the system dialogs', () {
    final c = makeContainer(const []);
    expect(
      c.read(localTixEngineProvider),
      anyOf(isA<FfiLocalTixEngine>(), isA<UnavailableLocalTixEngine>()),
    );
    expect(c.read(localEnginesStopInBackgroundProvider), isFalse);
    expect(c.read(filePickingProvider), isA<SystemFilePicking>());
    expect(c.read(filePickingProvider).opensInPlace, isTrue);
    expect(withDbExtension(' notes '), 'notes.db');
    expect(withDbExtension('x.DB'), 'x.DB');
    expect(withDbExtension(''), 'tix.db');
    final sep = Platform.pathSeparator;
    final taken = {'/d${sep}notes.db', '/d${sep}notes-2.db'};
    expect(
      uniqueDatabasePath('/d', 'notes.db', taken.contains),
      '/d${sep}notes-3.db',
    );
    expect(uniqueDatabasePath('/d', 'x.db', taken.contains), '/d${sep}x.db');
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

  test('suspend stops engines and resume brings them back', () async {
    final engine = InMemoryLocalTixEngine(existing: ['/a.db']);
    final engines = LocalEngines(engine);
    final moved = <String>[];
    engines.moved.listen(moved.add);
    final h = await engines.ensure(local('a', '/a.db'));
    await engines.suspend();
    expect(engine.running, isEmpty);
    expect(engines.running, isEmpty);
    await engines.resume();
    final again = await engines.ensure(local('a', '/a.db'));
    expect(again.baseUrl, h.baseUrl);
    expect(again, isNot(h));
    await Future<void>.delayed(Duration.zero);
    expect(moved, isEmpty);
    await engines.resume();
    expect(engine.started, ['/a.db', '/a.db']);
    engines.dispose();
  });

  test('resume on a taken port moves the engine and says so', () async {
    final engine = InMemoryLocalTixEngine(existing: ['/a.db']);
    final engines = LocalEngines(engine);
    final moved = <String>[];
    engines.moved.listen(moved.add);
    final h = await engines.ensure(local('a', '/a.db'));
    await engines.suspend();
    engine.taken.add(Uri.parse(h.baseUrl).authority);
    await engines.resume();
    final again = await engines.ensure(local('a', '/a.db'));
    expect(again.baseUrl, isNot(h.baseUrl));
    await Future<void>.delayed(Duration.zero);
    expect(moved, ['a']);
    engines.dispose();
  });

  testWidgets('a phone stops engines in the background', (tester) async {
    final engine = InMemoryLocalTixEngine(existing: ['/a.db']);
    final c = makeContainer([
      localTixEngineProvider.overrideWithValue(engine),
      localEnginesStopInBackgroundProvider.overrideWithValue(true),
    ]);
    await c.read(localEnginesProvider).ensure(local('a', '/a.db'));
    c.read(localEngineLifecycleProvider);
    tester.binding
      ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
      ..handleAppLifecycleStateChanged(AppLifecycleState.hidden)
      ..handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();
    expect(engine.running, isEmpty);
    tester.binding
      ..handleAppLifecycleStateChanged(AppLifecycleState.hidden)
      ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
      ..handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();
    expect(engine.running, hasLength(1));
    expect(c.read(localEnginesProvider).running, ['a']);
  });

  testWidgets('a desktop keeps engines running in the background', (
    tester,
  ) async {
    final engine = InMemoryLocalTixEngine(existing: ['/a.db']);
    final c = makeContainer([
      localTixEngineProvider.overrideWithValue(engine),
      localEnginesStopInBackgroundProvider.overrideWithValue(false),
    ]);
    await c.read(localEnginesProvider).ensure(local('a', '/a.db'));
    c.read(localEngineLifecycleProvider);
    tester.binding
      ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
      ..handleAppLifecycleStateChanged(AppLifecycleState.hidden)
      ..handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(engine.running, hasLength(1));
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
