// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'server_info.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The installation's status and the caller's date display, for the active
/// session.

@ProviderFor(serverInfoRepository)
final serverInfoRepositoryProvider = ServerInfoRepositoryProvider._();

/// The installation's status and the caller's date display, for the active
/// session.

final class ServerInfoRepositoryProvider
    extends
        $FunctionalProvider<
          ServerInfoRepository,
          ServerInfoRepository,
          ServerInfoRepository
        >
    with $Provider<ServerInfoRepository> {
  /// The installation's status and the caller's date display, for the active
  /// session.
  ServerInfoRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serverInfoRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serverInfoRepositoryHash();

  @$internal
  @override
  $ProviderElement<ServerInfoRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ServerInfoRepository create(Ref ref) {
    return serverInfoRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ServerInfoRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ServerInfoRepository>(value),
    );
  }
}

String _$serverInfoRepositoryHash() =>
    r'0aa11c24172e73dff562052da89961a5a6c85310';

/// Bundles and snapshot imports for the active session. It has no cache:
/// every answer is about one file.

@ProviderFor(bundleRepository)
final bundleRepositoryProvider = BundleRepositoryProvider._();

/// Bundles and snapshot imports for the active session. It has no cache:
/// every answer is about one file.

final class BundleRepositoryProvider
    extends
        $FunctionalProvider<
          BundleRepository,
          BundleRepository,
          BundleRepository
        >
    with $Provider<BundleRepository> {
  /// Bundles and snapshot imports for the active session. It has no cache:
  /// every answer is about one file.
  BundleRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bundleRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bundleRepositoryHash();

  @$internal
  @override
  $ProviderElement<BundleRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BundleRepository create(Ref ref) {
    return bundleRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BundleRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BundleRepository>(value),
    );
  }
}

String _$bundleRepositoryHash() => r'21698c4fd377b4fb210c5f5d1f3239127627c736';
