// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'release.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The server's release check, for the active session.

@ProviderFor(releaseRepository)
final releaseRepositoryProvider = ReleaseRepositoryProvider._();

/// The server's release check, for the active session.

final class ReleaseRepositoryProvider
    extends
        $FunctionalProvider<
          ReleaseRepository,
          ReleaseRepository,
          ReleaseRepository
        >
    with $Provider<ReleaseRepository> {
  /// The server's release check, for the active session.
  ReleaseRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'releaseRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$releaseRepositoryHash();

  @$internal
  @override
  $ProviderElement<ReleaseRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReleaseRepository create(Ref ref) {
    return releaseRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReleaseRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReleaseRepository>(value),
    );
  }
}

String _$releaseRepositoryHash() => r'd28332f54d8a46bc51514c5538f3b94ddf99d289';

/// What the active server knows about its version and the newest release.

@ProviderFor(serverRelease)
final serverReleaseProvider = ServerReleaseProvider._();

/// What the active server knows about its version and the newest release.

final class ServerReleaseProvider
    extends
        $FunctionalProvider<
          AsyncValue<ServerRelease>,
          ServerRelease,
          FutureOr<ServerRelease>
        >
    with $FutureModifier<ServerRelease>, $FutureProvider<ServerRelease> {
  /// What the active server knows about its version and the newest release.
  ServerReleaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serverReleaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serverReleaseHash();

  @$internal
  @override
  $FutureProviderElement<ServerRelease> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ServerRelease> create(Ref ref) {
    return serverRelease(ref);
  }
}

String _$serverReleaseHash() => r'80ec7b555412404ab991abfdcb174834f9d75b2b';
