// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/data/cache/response_cache.dart';

void main() {
  const work = CacheScope('c/1', 'default');
  const other = CacheScope('c/1', 'acme');

  Future<void> exerciseScope(CacheStore store) async {
    await store.write(work, 'tasks/infra', 'aaaa');
    await store.write(work, 'sync/outbox/1', 'bb');
    await store.write(other, 'tasks/infra', 'cccccc');
    expect(await store.sizeOf(work), 6);
    await store.clearScope(work);
    expect(await store.read(work, 'tasks/infra'), isNull);
    expect(await store.read(work, 'sync/outbox/1'), 'bb');
    expect(await store.read(other, 'tasks/infra'), 'cccccc');
    expect(await store.sizeOf(work), 2);
    expect(await store.sizeOf(const CacheScope('none', '')), 0);
    await store.clearScope(const CacheScope('none', ''));
    await store.clearConnection('c/1');
    expect(await store.read(work, 'sync/outbox/1'), isNull);
  }

  test('MemoryCacheStore sizes and clears a scope, keeping sync/', () async {
    await exerciseScope(MemoryCacheStore());
  });

  test('FileCacheStore sizes and clears a scope, keeping sync/', () async {
    final dir = Directory.systemTemp.createTempSync('tix-offline-test-');
    addTearDown(() => dir.deleteSync(recursive: true));
    await exerciseScope(FileCacheStore(() async => dir));
  });

  group('ResponseCache offline fallback', () {
    late MemoryCacheStore store;
    late ResponseCache cache;
    final kept = DateTime.utc(2026, 11, 1, 9);

    setUp(() async {
      store = MemoryCacheStore();
      cache = ResponseCache(store, work, now: () => kept);
      addTearDown(cache.dispose);
      await cache.remember('k', Future.value([1, 2]), (l) => l);
    });

    List<int> decode(Object? j) => (j! as List).cast<int>();

    Future<List<int>> failWith(TixException e) =>
        cache.remember('k', Future.error(e), (l) => l, decode: decode);

    for (final kind in [
      TixErrorKind.network,
      TixErrorKind.timeout,
      TixErrorKind.upstream,
    ]) {
      test('serves the kept copy on ${kind.name}, after peek', () async {
        expect(await cache.peek('k', decode), [1, 2]);
        final changes = <DateTime?>[];
        final sub = cache.staleChanges.listen(changes.add);
        addTearDown(sub.cancel);
        expect(await failWith(TixException(kind)), [1, 2]);
        expect(cache.staleSince, kept);
        await cache.remember('k', Future.value([3]), (l) => l);
        expect(cache.staleSince, isNull);
        await pumpEventQueue();
        expect(changes, [kept, null]);
      });
    }

    for (final (kind, status) in [
      (TixErrorKind.forbidden, 403),
      (TixErrorKind.notFound, 404),
      (TixErrorKind.internal, 500),
    ]) {
      test('rethrows a $status', () async {
        await expectLater(
          failWith(TixException(kind, status: status)),
          throwsA(isA<TixException>().having((e) => e.kind, 'kind', kind)),
        );
        expect(cache.staleSince, isNull);
      });
    }

    test('rethrows without a decoder, a copy, or in strict mode', () async {
      const offline = TixException(TixErrorKind.network);
      await expectLater(
        cache.remember('k', Future<List<int>>.error(offline), (l) => l),
        throwsA(same(offline)),
      );
      await expectLater(
        cache.remember(
          'missing',
          Future<List<int>>.error(offline),
          (l) => l,
          decode: decode,
        ),
        throwsA(same(offline)),
      );
      await expectLater(
        ResponseCache.strict(() => failWith(offline)),
        throwsA(same(offline)),
      );
    });

    test('stored answers every time with when it was kept', () async {
      final a = await cache.stored('k', decode);
      final b = await cache.stored('k', decode);
      expect(a?.value, [1, 2]);
      expect(b?.at, kept);
      expect(await cache.stored('missing', decode), isNull);
      await store.write(work, 'bad', 'not json');
      expect(await cache.stored('bad', decode), isNull);
    });
  });
}
