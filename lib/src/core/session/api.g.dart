// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'api.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// How API clients are built; tests swap in one with a fake adapter.

@ProviderFor(tixApiFactory)
final tixApiFactoryProvider = TixApiFactoryProvider._();

/// How API clients are built; tests swap in one with a fake adapter.

final class TixApiFactoryProvider
    extends $FunctionalProvider<TixApiFactory, TixApiFactory, TixApiFactory>
    with $Provider<TixApiFactory> {
  /// How API clients are built; tests swap in one with a fake adapter.
  TixApiFactoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tixApiFactoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tixApiFactoryHash();

  @$internal
  @override
  $ProviderElement<TixApiFactory> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TixApiFactory create(Ref ref) {
    return tixApiFactory(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TixApiFactory value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TixApiFactory>(value),
    );
  }
}

String _$tixApiFactoryHash() => r'616888be52415edcf6ebcd26edc909a5e68e5e4b';
