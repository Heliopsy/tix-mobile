// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The settings store, overridden in `main` once preferences are loaded.

@ProviderFor(keyValueStore)
final keyValueStoreProvider = KeyValueStoreProvider._();

/// The settings store, overridden in `main` once preferences are loaded.

final class KeyValueStoreProvider
    extends $FunctionalProvider<KeyValueStore, KeyValueStore, KeyValueStore>
    with $Provider<KeyValueStore> {
  /// The settings store, overridden in `main` once preferences are loaded.
  KeyValueStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'keyValueStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$keyValueStoreHash();

  @$internal
  @override
  $ProviderElement<KeyValueStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  KeyValueStore create(Ref ref) {
    return keyValueStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KeyValueStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KeyValueStore>(value),
    );
  }
}

String _$keyValueStoreHash() => r'527630d230df90b4e647465f1f2a8d36dce09565';

/// The secret store for API tokens.

@ProviderFor(secretStore)
final secretStoreProvider = SecretStoreProvider._();

/// The secret store for API tokens.

final class SecretStoreProvider
    extends $FunctionalProvider<SecretStore, SecretStore, SecretStore>
    with $Provider<SecretStore> {
  /// The secret store for API tokens.
  SecretStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'secretStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$secretStoreHash();

  @$internal
  @override
  $ProviderElement<SecretStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SecretStore create(Ref ref) {
    return secretStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SecretStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SecretStore>(value),
    );
  }
}

String _$secretStoreHash() => r'27bd0832caf2fb0780f2a77d20ec76a650137fba';
