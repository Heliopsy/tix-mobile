// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/data/cache/cache_store.dart';
import 'package:tix_mobile/src/data/offline/sync_store.dart';

class _NoCorruptCopies extends MemoryCacheStore {
  @override
  Future<void> write(CacheScope scope, String key, String value) {
    if (key.contains('corrupt')) throw const FileSystemException('full');
    return super.write(scope, key, value);
  }
}

void main() {
  const scope = CacheScope('c1', '');
  final at = DateTime.utc(2026, 11, 9, 8);
  const garbage = '{"entries": [{"id": 3';

  Future<void> addOne(SyncStore store) => store.update(
    (s) => s.copyWith(
      entries: [
        OutboxEntry(
          id: 'e1',
          seq: 1,
          op: OutboxOp.comment,
          target: 'infra-1',
          idempotencyKey: 'k',
          createdAt: at,
        ),
      ],
    ),
  );

  test(
    'an unreadable state is set aside and kept, then a new one starts',
    () async {
      final cache = MemoryCacheStore();
      await cache.write(scope, SyncStore.key, garbage);
      final store = SyncStore(cache, scope, now: () => at);

      expect((await store.load()).entries, isEmpty);
      expect(store.unreadable, isTrue);
      final aside = SyncStore.corruptKey(at);
      expect(store.setAside, aside);
      expect(await cache.read(scope, aside), garbage);

      await addOne(store);
      expect(await cache.read(scope, aside), garbage);
      final kept = await SyncStore.peek(cache, scope);
      expect(kept!.entries.single.id, 'e1');
    },
  );

  test('when it cannot be set aside, nothing is written over it', () async {
    final cache = _NoCorruptCopies();
    await cache.write(scope, SyncStore.key, garbage);
    final store = SyncStore(cache, scope, now: () => at);

    await store.load();
    expect((store.unreadable, store.setAside), (true, null));
    await addOne(store);

    expect(store.now.entries, hasLength(1));
    expect(await cache.read(scope, SyncStore.key), garbage);
  });

  test('peek reads without setting anything aside', () async {
    final cache = MemoryCacheStore();
    await cache.write(scope, SyncStore.key, garbage);
    expect(await SyncStore.peek(cache, scope), isNull);
    expect(cache.entries['c1/']!.keys, [SyncStore.key]);
  });

  test('a forgotten connection is not written back', () async {
    final cache = MemoryCacheStore();
    final store = SyncStore(cache, scope);
    await addOne(store);
    await cache.clearConnection('c1');

    await store.update((s) => s.copyWith(nextSeq: 9));

    expect(cache.entries, isEmpty);
  });

  test('one store per context: coming back sets nothing aside twice', () async {
    final cache = MemoryCacheStore();
    await cache.write(scope, SyncStore.key, garbage);
    var tick = 0;
    final stores = SyncStores(
      cache,
      now: () => at.add(Duration(seconds: tick++)),
    );
    final first = stores.of(scope);
    await first.load();
    stores.of(const CacheScope('c2', ''));
    final again = stores.of(scope);
    await again.load();
    expect(identical(first, again), isTrue);
    final copies = cache.entries['c1/']!.keys.where(
      (k) => k.contains('corrupt'),
    );
    expect(copies, hasLength(1));

    await stores.forget('c1');
    expect(identical(stores.of(scope), first), isFalse);
  });

  group('ownership', () {
    test('nothing is read until the store is owned, so what another engine '
        'wrote last is what loads', () async {
      final cache = MemoryCacheStore();
      final owned = Completer<void>();
      final stores = SyncStores(cache, now: () => at, owned: owned.future);
      final store = stores.of(scope);
      final loading = store.load();
      var loaded = false;
      unawaited(loading.then((_) => loaded = true));
      await pumpEventQueue();
      expect(loaded, isFalse);

      final other = SyncStore(cache, scope, now: () => at);
      await addOne(other);
      owned.complete();

      expect((await loading).entries.single.id, 'e1');
      await store.update((s) => s.copyWith(nextSeq: 5));
      final kept = await SyncStore.peek(cache, scope);
      expect(kept!.entries.single.id, 'e1');
      expect(kept.nextSeq, 5);
    });

    test('a write waits for ownership too', () async {
      final cache = MemoryCacheStore();
      final owned = Completer<void>();
      final store = SyncStore(cache, scope, now: () => at, owned: owned.future);
      var written = false;
      unawaited(addOne(store).then((_) => written = true));
      await pumpEventQueue();
      expect(written, isFalse);
      expect(await cache.read(scope, SyncStore.key), isNull);
      owned.complete();
      await pumpEventQueue();
      expect(written, isTrue);
    });
  });
}
