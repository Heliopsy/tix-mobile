// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:tix_mobile/src/core/storage/stores.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('PrefsKeyValueStore reads back what it wrote', () async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    final prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );
    final store = PrefsKeyValueStore(prefs);
    expect(store.read('k'), isNull);
    await store.write('k', 'v');
    expect(store.read('k'), 'v');
    await store.delete('k');
    expect(store.read('k'), isNull);
  });

  test('SecureSecretStore reads back what it wrote', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final store = SecureSecretStore();
    expect(await store.read('t'), isNull);
    await store.write('t', 'secret');
    expect(await store.read('t'), 'secret');
    await store.delete('t');
    expect(await store.read('t'), isNull);
  });
}
