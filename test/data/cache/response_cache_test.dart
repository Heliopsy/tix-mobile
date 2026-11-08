// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/data/cache/response_cache.dart';

void main() {
  const work = CacheScope('c/1', 'default');
  const other = CacheScope('c2', '');

  group('FileCacheStore', () {
    late Directory dir;
    late FileCacheStore store;

    setUp(() {
      dir = Directory.systemTemp.createTempSync('tix-cache-test-');
      addTearDown(() => dir.deleteSync(recursive: true));
      store = FileCacheStore(() async => dir);
    });

    test('keeps one file per scope and key, safely named', () async {
      await store.write(work, 'tasks/INFRA*', '{"a":1}');
      expect(await store.read(work, 'tasks/INFRA*'), '{"a":1}');
      expect(await store.read(other, 'tasks/INFRA*'), isNull);
      final files = dir
          .listSync(recursive: true)
          .whereType<File>()
          .map((f) => f.path.substring(dir.path.length))
          .toList();
      final sep = Platform.pathSeparator;
      expect(files, [
        '${sep}v1${sep}c%2F1${sep}default${sep}tasks%2FINFRA%2A.json',
      ]);
    });

    test('forgetting a connection removes all its tenants', () async {
      await store.write(work, 'k', 'v');
      await store.write(const CacheScope('c/1', 'acme'), 'k', 'v');
      await store.write(other, 'k', 'v');
      await store.clearConnection('c/1');
      expect(await store.read(work, 'k'), isNull);
      expect(await store.read(other, 'k'), 'v');
      await store.clearConnection('never-cached');
    });
  });

  group('ResponseCache', () {
    late MemoryCacheStore store;
    late ResponseCache cache;

    setUp(() {
      store = MemoryCacheStore();
      cache = ResponseCache(store, work);
    });

    test('remembers a value and serves it once', () async {
      final v = await cache.remember('k', Future.value([1, 2]), (l) => l);
      expect(v, [1, 2]);
      final later = ResponseCache(store, work);
      expect(await later.peek('k', (j) => j), [1, 2]);
      expect(await later.peek('k', (j) => j), isNull);
    });

    test('a failed read is not cached and fails the caller', () async {
      await expectLater(
        cache.remember<int>('k', Future.error(StateError('x')), (v) => v),
        throwsStateError,
      );
      expect(store.entries, isEmpty);
    });

    test('an entry that no longer decodes is a miss', () async {
      await store.write(work, 'k', '{"data": "not a map"}');
      await store.write(work, 'j', 'not json');
      expect(
        await cache.peek('k', (j) => (j! as Map<String, Object?>)['x']),
        isNull,
      );
      expect(await cache.peek('j', (j) => j), isNull);
    });

    test('a store that fails neither breaks reads nor writes', () async {
      final broken = ResponseCache(_Broken(), work);
      expect(await broken.peek('k', (j) => j), isNull);
      expect(await broken.remember('k', Future.value(1), (v) => v), 1);
    });
  });
}

class _Broken implements CacheStore {
  @override
  Future<String?> read(CacheScope scope, String key) =>
      throw const FileSystemException('disk');

  @override
  Future<void> write(CacheScope scope, String key, String value) =>
      throw const FileSystemException('full');

  @override
  Future<void> clearConnection(String connectionId) async {}
}
