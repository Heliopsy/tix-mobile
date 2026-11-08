// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:io' show Platform;
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/platform/files.dart';
import 'package:tix_mobile/src/core/platform/local_access.dart';
import 'package:tix_mobile/src/core/session/local.dart';
import 'package:tix_mobile/src/core/storage/providers.dart';
import 'package:tix_mobile/src/data/local/ffi_local_engine.dart';
import 'package:tix_mobile/src/data/local/in_place.dart';
import 'package:tix_mobile/src/data/local/local_engine.dart';
import 'package:tix_mobile/src/data/models/instance.dart';

import '../../helpers/container.dart';
import '../../helpers/fake_local_access.dart';
import '../../helpers/stores.dart';

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

  group('idle', () {
    testWidgets('an idle engine rests and the next ensure brings it back', (
      tester,
    ) async {
      final engine = InMemoryLocalTixEngine(existing: ['/a.db']);
      final engines = LocalEngines(
        engine,
        idleAfter: const Duration(minutes: 10),
      );
      final a = local('a', '/a.db');
      final h = await engines.ensure(a);
      await tester.pump(const Duration(minutes: 9));
      engines.touch('a');
      await tester.pump(const Duration(minutes: 9));
      expect(engine.running, hasLength(1));
      await tester.pump(const Duration(minutes: 1));
      await tester.pump();
      expect(engine.running, isEmpty);
      expect(engines.statuses['a']?.state, LocalEngineState.resting);
      final again = await engines.ensure(a);
      expect(again.baseUrl, h.baseUrl);
      expect(engines.statuses['a']?.state, LocalEngineState.running);
      engines.dispose();
    });

    testWidgets('a request in flight holds the engine awake', (tester) async {
      final engine = InMemoryLocalTixEngine(existing: ['/a.db']);
      final engines = LocalEngines(
        engine,
        idleAfter: const Duration(minutes: 1),
      );
      final a = local('a', '/a.db');
      await engines.wake(a);
      await engines.wake(a);
      await tester.pump(const Duration(minutes: 5));
      expect(engine.running, hasLength(1));
      engines.done('a');
      await tester.pump(const Duration(minutes: 5));
      expect(engine.running, hasLength(1));
      engines.done('a');
      await tester.pump(const Duration(minutes: 1));
      await tester.pump();
      expect(engine.running, isEmpty);
      engines.dispose();
    });

    testWidgets('never keeps the engine running', (tester) async {
      final engine = InMemoryLocalTixEngine(existing: ['/a.db']);
      final engines = LocalEngines(
        engine,
        idleAfter: const Duration(minutes: 10),
      )..idleAfter = null;
      await engines.ensure(local('a', '/a.db'));
      await tester.pump(const Duration(hours: 5));
      expect(engine.running, hasLength(1));
      engines.idleAfter = const Duration(minutes: 1);
      await tester.pump(const Duration(minutes: 1));
      await tester.pump();
      expect(engine.running, isEmpty);
      engines.dispose();
    });

    testWidgets('the setting reaches the engines, ten minutes by default', (
      tester,
    ) async {
      final c = makeContainer([
        keyValueStoreProvider.overrideWithValue(MemoryKeyValueStore()),
      ]);
      expect(c.read(localIdleTimeoutProvider), const Duration(minutes: 10));
      expect(c.read(localEnginesProvider).idleAfter, LocalIdleTimeout.fallback);
      await c.read(localIdleTimeoutProvider.notifier).set(null);
      expect(c.read(localEnginesProvider).idleAfter, isNull);
      await c
          .read(localIdleTimeoutProvider.notifier)
          .set(const Duration(minutes: 30));
      expect(
        c.read(localEnginesProvider).idleAfter,
        const Duration(minutes: 30),
      );
      final again = makeContainer([
        keyValueStoreProvider.overrideWithValue(
          MemoryKeyValueStore()..values['settings.local_idle_minutes'] = '0',
        ),
      ]);
      expect(again.read(localIdleTimeoutProvider), isNull);
    });
  });

  group('in place', () {
    Instance inPlace(String id, String path, {String bookmark = ''}) =>
        local(id, path).copyWith(inPlace: true, bookmark: bookmark);

    test('access opens before the engine and closes after it', () async {
      final engine = InMemoryLocalTixEngine(existing: ['/sync/a.db']);
      final access = FakeLocalFileAccess()
        ..found = const SyncFindings(conflicts: ['a (1).db']);
      final engines = LocalEngines(engine, access: access);
      await engines.ensure(inPlace('a', '/sync/a.db', bookmark: 'bm'));
      expect(access.opened.single.bookmark, 'bm');
      expect(engines.statuses['a']?.findings.conflicts, ['a (1).db']);
      await engines.stop('a');
      expect(access.closed.single.dbPath, '/sync/a.db');
      engines.dispose();
    });

    test('a renewed bookmark and a moved folder are reported', () async {
      final engine = InMemoryLocalTixEngine(existing: ['/moved/a.db']);
      final access = FakeLocalFileAccess()
        ..grant = const AccessGrant(dbPath: '/moved/a.db', bookmark: 'bm2');
      final engines = LocalEngines(engine, access: access);
      final renewed = <Instance>[];
      engines.renewed.listen(renewed.add);
      await engines.ensure(inPlace('a', '/old/a.db', bookmark: 'bm1'));
      await Future<void>.delayed(Duration.zero);
      expect(renewed.single.bookmark, 'bm2');
      expect(renewed.single.dbPath, '/moved/a.db');
      expect(engine.started, ['/moved/a.db']);
      expect(engines.statuses['a']?.dbPath, '/moved/a.db');
      engines.dispose();
    });

    test('access that is refused is the start error; nothing runs', () async {
      final engine = InMemoryLocalTixEngine(existing: ['/sync/a.db']);
      final access = FakeLocalFileAccess()
        ..denied = const TixException(TixErrorKind.localAccessDenied);
      final engines = LocalEngines(engine, access: access);
      await expectLater(
        engines.ensure(inPlace('a', '/sync/a.db')),
        throwsA(
          isA<TixException>().having(
            (e) => e.kind,
            'kind',
            TixErrorKind.localAccessDenied,
          ),
        ),
      );
      expect(engine.started, isEmpty);
      expect(engines.running, isEmpty);
      engines.dispose();
    });

    test('an engine that will not start closes the access', () async {
      final engine = InMemoryLocalTixEngine();
      final access = FakeLocalFileAccess();
      final engines = LocalEngines(engine, access: access);
      await expectLater(
        engines.ensure(inPlace('a', '/sync/missing.db')),
        throwsA(isA<TixException>()),
      );
      expect(access.closed, hasLength(1));
      engines.dispose();
    });

    testWidgets('a hidden desktop app rests in-place engines only', (
      tester,
    ) async {
      final engine = InMemoryLocalTixEngine(existing: ['/a.db', '/s/b.db']);
      final c = makeContainer([
        localTixEngineProvider.overrideWithValue(engine),
        localFileAccessProvider.overrideWithValue(FakeLocalFileAccess()),
        localEnginesStopInBackgroundProvider.overrideWithValue(false),
      ]);
      final engines = c.read(localEnginesProvider);
      await engines.ensure(local('a', '/a.db'));
      c.read(localEngineLifecycleProvider);
      tester.binding
        ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
        ..handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      await tester.pump();
      expect(engine.running, hasLength(1));
      tester.binding
        ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
        ..handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await engines.ensure(inPlace('b', '/s/b.db'));
      tester.binding
        ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
        ..handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      await tester.pump();
      expect(engine.running, isEmpty);
      expect(engines.statuses['b']?.state, LocalEngineState.resting);
    });
  });

  testWidgets('statuses follow engines as they start and stop', (tester) async {
    final engine = InMemoryLocalTixEngine(existing: ['/a.db']);
    final c = makeContainer([localTixEngineProvider.overrideWithValue(engine)]);
    final seen = <LocalEngineState?>[];
    c.listen(
      localEngineStatusesProvider,
      (_, next) => seen.add(next.value?['a']?.state),
      fireImmediately: true,
    );
    await c.read(localEnginesProvider).ensure(local('a', '/a.db'));
    await tester.pump();
    await c.read(localEnginesProvider).stop('a');
    await tester.pump();
    expect(seen.last, LocalEngineState.stopped);
    expect(seen, contains(LocalEngineState.running));
  });
}
