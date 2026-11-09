// SPDX-License-Identifier: AGPL-3.0-or-later

// Drives the real libtix that hook/build.dart bundled into this test run,
// over a throwaway database. Skipped when the build has no engine (no Go),
// unless TIX_ENGINE_REQUIRED=1, which CI sets so a missing library fails.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/session/local.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/local/ffi_local_engine.dart';
import 'package:tix_mobile/src/data/local/in_place.dart';
import 'package:tix_mobile/src/data/local/local_wake.dart';
import 'package:tix_mobile/src/data/models/instance.dart';

void main() {
  final engine = FfiLocalTixEngine.load();
  final required = Platform.environment['TIX_ENGINE_REQUIRED'] == '1';
  final skip = engine == null && !required
      ? 'this build has no libtix (Go not on PATH)'
      : null;

  late Directory dir;
  setUp(() async {
    dir = await Directory.systemTemp.createTemp('tix-mobile-engine-');
  });
  tearDown(() => dir.delete(recursive: true));

  Matcher kind(TixErrorKind k) =>
      throwsA(isA<TixException>().having((e) => e.kind, 'kind', k));

  test('the library is bundled', () {
    expect(engine, isNotNull);
  }, skip: skip);

  test('start, create a tenant, mint a token, call the API, stop', () async {
    final e = engine!;
    expect(await e.version(), isNotEmpty);
    final db = '${dir.path}${Platform.pathSeparator}new.db';
    await expectLater(
      e.start(dbPath: db, initIfMissing: false),
      kind(TixErrorKind.notFound),
    );
    final h = await e.start(dbPath: db);
    expect(File(db).existsSync(), isTrue);
    expect(h.baseUrl, startsWith('http://127.0.0.1:'));
    try {
      expect((await e.tenants(h)).map((t) => t.key), contains('default'));
      final home = await e.createTenant(h, key: 'home', name: 'Home');
      expect(home.key, 'home');
      await expectLater(
        e.createTenant(h, key: 'home', name: 'Again'),
        throwsA(isA<TixException>()),
      );
      final token = await e.token(h, tenant: 'home', name: 'tix-mobile');
      final api = TixApi(
        baseUrl: h.baseUrl,
        credential: BearerCredential(token),
      );
      final me = await api.identity.whoami();
      expect(me.tenantKey, 'home');
      final projects = await api.project.list();
      expect(projects.items, isA<List<Object?>>());

      final starter = await e.token(h, tenant: 'default', name: 'starter');
      final defaults = await TixApi(
        baseUrl: h.baseUrl,
        credential: BearerCredential(starter),
      ).project.list();
      expect(defaults.items, isNotEmpty);
    } finally {
      await e.stop(h);
    }
    await expectLater(e.tenants(h), kind(TixErrorKind.notFound));
    final again = await e.start(dbPath: db, initIfMissing: false);
    expect(
      (await e.tenants(again)).map((t) => t.key),
      containsAll(['default', 'home']),
    );
    await e.stop(again);
  }, skip: skip);

  test('restarts on the address it asked for', () async {
    final e = engine!;
    final db = '${dir.path}${Platform.pathSeparator}port.db';
    final first = await e.start(dbPath: db);
    final address = Uri.parse(first.baseUrl).authority;
    await e.stop(first);
    final second = await e.start(dbPath: db, listen: address);
    expect(second.baseUrl, first.baseUrl);
    await expectLater(
      e.start(dbPath: db, listen: address),
      throwsA(isA<TixException>()),
    );
    await e.stop(second);
  }, skip: skip);

  test('a stop leaves one whole file, no write-ahead log beside it', () async {
    final e = engine!;
    final db = '${dir.path}${Platform.pathSeparator}synced.db';
    final h = await e.start(dbPath: db);
    final token = await e.token(h, tenant: 'default', name: 'wal');
    await TixApi(
      baseUrl: h.baseUrl,
      credential: BearerCredential(token),
    ).project.list();
    await e.stop(h);
    expect(File(db).existsSync(), isTrue);
    expect(File('$db-wal').existsSync(), isFalse);
    expect(await syncFindings(db), SyncFindings.none);
    await probeInPlace(db);
  }, skip: skip);

  test(
    'an idle engine stops and the next request restarts it',
    () async {
      final e = engine!;
      final db = '${dir.path}${Platform.pathSeparator}idle.db';
      final seed = await e.start(dbPath: db);
      final token = await e.token(seed, tenant: 'default', name: 'idle');
      await e.stop(seed);
      final engines = LocalEngines(e, idleAfter: const Duration(seconds: 3));
      final instance = Instance(
        id: 'idle',
        name: 'idle',
        kind: InstanceKind.local,
        dbPath: db,
        createdAt: DateTime(2026),
      );
      final h = await engines.ensure(instance);
      final api =
          TixApi(baseUrl: h.baseUrl, credential: BearerCredential(token))
            ..transport.dio.interceptors.insert(
              0,
              LocalWakeInterceptor(
                wake: ({required background}) async {
                  final (h, held) = await engines.attend(
                    instance,
                    background: background,
                  );
                  return (h.baseUrl, held);
                },
                done: () => engines.done(instance.id),
              ),
            );
      expect((await api.identity.whoami()).tenantKey, 'default');
      // The idle timer stops the engine on its own; wait for the stop to
      // finish, which is when tix has closed the database and SQLite removed
      // the write-ahead log.
      final wal = File('$db-wal');
      for (var i = 0; i < 300; i++) {
        if (engines.statuses['idle']?.state == LocalEngineState.resting &&
            !engines.running.contains('idle') &&
            !wal.existsSync()) {
          break;
        }
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      expect(engines.statuses['idle']?.state, LocalEngineState.resting);
      expect(wal.existsSync(), isFalse);
      await expectLater(e.tenants(h), kind(TixErrorKind.notFound));
      expect((await api.identity.whoami()).tenantKey, 'default');
      expect(engines.statuses['idle']?.state, LocalEngineState.running);
      expect(engines.statuses['idle']?.baseUrl, h.baseUrl);
      await engines.stopAll();
      engines.dispose();
    },
    skip: skip,
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
