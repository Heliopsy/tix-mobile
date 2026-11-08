// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'about.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The embedded engine's tix version, null when this build has none.

@ProviderFor(engineVersion)
final engineVersionProvider = EngineVersionProvider._();

/// The embedded engine's tix version, null when this build has none.

final class EngineVersionProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// The embedded engine's tix version, null when this build has none.
  EngineVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'engineVersionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$engineVersionHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return engineVersion(ref);
  }
}

String _$engineVersionHash() => r'57ca7e0964767a9ce2020b34ad046b4fdeb7ebf5';

/// The tix version of the active context's server, null when signed out.

@ProviderFor(serverVersion)
final serverVersionProvider = ServerVersionProvider._();

/// The tix version of the active context's server, null when signed out.

final class ServerVersionProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// The tix version of the active context's server, null when signed out.
  ServerVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serverVersionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serverVersionHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return serverVersion(ref);
  }
}

String _$serverVersionHash() => r'd150e35c38b633025d49eb64ea6640b2df56281e';

/// The address of the active remote server, empty for a local instance or
/// when signed out.

@ProviderFor(serverAddress)
final serverAddressProvider = ServerAddressProvider._();

/// The address of the active remote server, empty for a local instance or
/// when signed out.

final class ServerAddressProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// The address of the active remote server, empty for a local instance or
  /// when signed out.
  ServerAddressProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serverAddressProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serverAddressHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return serverAddress(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$serverAddressHash() => r'68f0937515aaf7fe689e5ad6a2f4a393e78a08b3';
