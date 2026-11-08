// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/data/local/local_engine.dart';

void main() {
  Matcher kind(TixErrorKind k) =>
      throwsA(isA<TixException>().having((e) => e.kind, 'kind', k));

  group('in memory', () {
    test('creates a database with the default tenant', () async {
      final engine = InMemoryLocalTixEngine();
      final h = await engine.start(dbPath: '/a.db');
      expect(h.baseUrl, startsWith('http://127.0.0.1:'));
      expect(engine.exists('/a.db'), isTrue);
      expect(await engine.tenants(h), [
        const TenantRef(key: 'default', name: 'Default'),
      ]);
      expect(await engine.version(), 'in-memory');
    });

    test('refuses a missing file without initIfMissing', () async {
      final engine = InMemoryLocalTixEngine();
      await expectLater(
        engine.start(dbPath: '/missing.db', initIfMissing: false),
        kind(TixErrorKind.notFound),
      );
      final existing = InMemoryLocalTixEngine(existing: ['/x.db']);
      final h = await existing.start(dbPath: '/x.db', initIfMissing: false);
      expect(existing.running, [h.id]);
    });

    test('creates tenants and mints tokens per tenant', () async {
      final engine = InMemoryLocalTixEngine();
      final h = await engine.start(dbPath: '/a.db');
      final home = await engine.createTenant(h, key: 'home', name: '');
      expect(home, const TenantRef(key: 'home', name: 'home'));
      expect(
        home.hashCode,
        const TenantRef(key: 'home', name: 'home').hashCode,
      );
      await expectLater(
        engine.createTenant(h, key: 'home', name: 'Again'),
        kind(TixErrorKind.conflict),
      );
      expect(
        await engine.token(h, tenant: 'home', name: 'app'),
        'local-home-1',
      );
      expect(
        await engine.token(h, tenant: 'home', name: 'app'),
        'local-home-2',
      );
      await expectLater(
        engine.token(h, tenant: 'nope', name: 'app'),
        kind(TixErrorKind.notFound),
      );
      expect(engine.minted['home'], hasLength(2));
    });

    test('a stopped handle answers nothing', () async {
      final engine = InMemoryLocalTixEngine();
      final h = await engine.start(dbPath: '/a.db');
      await engine.stop(h);
      await engine.stop(h);
      expect(engine.stopped, [h]);
      await expectLater(
        engine.tenants(h),
        kind(TixErrorKind.engineUnavailable),
      );
      final again = await engine.start(dbPath: '/a.db');
      expect(again, isNot(h));
      expect(again.hashCode, isNot(h.hashCode));
    });
  });

  test('the unavailable engine says so on every call', () async {
    const engine = UnavailableLocalTixEngine();
    const h = LocalHandle(id: 'h', baseUrl: 'http://127.0.0.1:1');
    final unavailable = kind(TixErrorKind.engineUnavailable);
    await expectLater(engine.start(dbPath: '/a.db'), unavailable);
    await expectLater(engine.tenants(h), unavailable);
    await expectLater(engine.createTenant(h, key: 'k', name: 'n'), unavailable);
    await expectLater(engine.token(h, tenant: 't', name: 'n'), unavailable);
    await expectLater(engine.version(), unavailable);
    await engine.stop(h);
  });
}
