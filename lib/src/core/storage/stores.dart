// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Non-secret settings, kept in shared preferences.
abstract interface class KeyValueStore {
  /// The value under [key], null when unset.
  String? read(String key);

  /// Stores [value] under [key].
  Future<void> write(String key, String value);

  /// Removes [key].
  Future<void> delete(String key);
}

/// Secrets such as API tokens, kept in the platform keychain.
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
  /// Wraps the given preferences.
  PrefsKeyValueStore(this._prefs);

  final SharedPreferencesWithCache _prefs;

  @override
  String? read(String key) => _prefs.getString(key);

  @override
  Future<void> write(String key, String value) => _prefs.setString(key, value);

  @override
  Future<void> delete(String key) => _prefs.remove(key);
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
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}
