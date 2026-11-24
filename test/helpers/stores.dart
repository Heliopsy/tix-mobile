// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:tix_mobile/src/core/storage/stores.dart';

class MemoryKeyValueStore implements KeyValueStore {
  final values = <String, String>{};

  @override
  String? read(String key) => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<void> reload() async {}
}

/// A [MemoryKeyValueStore] that caches [disk] as one isolate's preferences
/// do: it writes through, but sees what another writer put on [disk] only
/// after [reload].
class CachedKeyValueStore extends MemoryKeyValueStore {
  CachedKeyValueStore(this.disk) {
    values.addAll(disk);
  }

  final Map<String, String> disk;

  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
    disk[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    values.remove(key);
    disk.remove(key);
  }

  @override
  Future<void> reload() async => values
    ..clear()
    ..addAll(disk);
}

class MemorySecretStore implements SecretStore {
  final values = <String, String>{};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}
