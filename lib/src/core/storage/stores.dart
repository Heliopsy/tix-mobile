// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';

/// Non-secret settings, kept in shared preferences.
abstract interface class KeyValueStore {
  /// The value under [key], null when unset.
  String? read(String key);

  /// Stores [value] under [key].
  Future<void> write(String key, String value);

  /// Removes [key].
  Future<void> delete(String key);

  /// Reads again what another isolate, such as the widgets' headless run,
  /// may have written since.
  Future<void> reload();
}

/// Secrets such as API tokens, kept in the platform keychain. A keychain
/// that refuses, such as a locked keyring, throws a [TixException] of
/// [TixErrorKind.secretStorageUnavailable].
abstract interface class SecretStore {
  /// The secret under [key], null when unset.
  Future<String?> read(String key);

  /// Stores [value] under [key].
  Future<void> write(String key, String value);

  /// Removes [key].
  Future<void> delete(String key);
}

/// [KeyValueStore] over [SharedPreferencesWithCache].
class PrefsKeyValueStore implements KeyValueStore {
  /// Wraps the given preferences, made with [options].
  PrefsKeyValueStore(
    this._prefs, {
    this.options = const SharedPreferencesWithCacheOptions(),
  });

  /// The options [reload] makes the preferences with again.
  final SharedPreferencesWithCacheOptions options;

  SharedPreferencesWithCache _prefs;

  @override
  String? read(String key) => _prefs.getString(key);

  @override
  Future<void> write(String key, String value) => _prefs.setString(key, value);

  @override
  Future<void> delete(String key) => _prefs.remove(key);

  /// Swaps in freshly read preferences. `reloadCache` would empty the cache
  /// while it waits, and a read in that gap would find nothing saved.
  @override
  Future<void> reload() async {
    _prefs = await SharedPreferencesWithCache.create(cacheOptions: options);
  }
}

/// [SecretStore] over [FlutterSecureStorage].
class SecureSecretStore implements SecretStore {
  /// Wraps [storage]; the default skips the macOS data protection keychain,
  /// which would need a provisioning profile for keychain sharing.
  SecureSecretStore([FlutterSecureStorage? storage])
    : _storage =
          storage ??
          const FlutterSecureStorage(
            mOptions: MacOsOptions(usesDataProtectionKeychain: false),
          );

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _mapped(() => _storage.read(key: key));

  @override
  Future<void> write(String key, String value) =>
      _mapped(() => _storage.write(key: key, value: value));

  @override
  Future<void> delete(String key) => _mapped(() => _storage.delete(key: key));

  /// Runs [op], turning a keychain refusal into a typed error. The
  /// platform's message is dropped: it never carries a value, but it is not
  /// ours to vouch for either.
  static Future<T> _mapped<T>(Future<T> Function() op) async {
    try {
      return await op();
    } on PlatformException {
      throw const TixException(TixErrorKind.secretStorageUnavailable);
    }
  }
}
