// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'api.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// How bare API clients are built; tests swap in one with a fake adapter.

@ProviderFor(tixClientFactory)
final tixClientFactoryProvider = TixClientFactoryProvider._();

/// How bare API clients are built; tests swap in one with a fake adapter.

final class TixClientFactoryProvider
    extends $FunctionalProvider<TixApiFactory, TixApiFactory, TixApiFactory>
    with $Provider<TixApiFactory> {
  /// How bare API clients are built; tests swap in one with a fake adapter.
  TixClientFactoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tixClientFactoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tixClientFactoryHash();

  @$internal
  @override
  $ProviderElement<TixApiFactory> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TixApiFactory create(Ref ref) {
    return tixClientFactory(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TixApiFactory value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TixApiFactory>(value),
    );
  }
}

String _$tixClientFactoryHash() => r'8e06527bee4bc9f11f4c632780b061409eccbccc';

/// Where every client built by [tixApiFactory] reports a `401`.

@ProviderFor(credentialRefusals)
final credentialRefusalsProvider = CredentialRefusalsProvider._();

/// Where every client built by [tixApiFactory] reports a `401`.

final class CredentialRefusalsProvider
    extends
        $FunctionalProvider<
          CredentialRefusals,
          CredentialRefusals,
          CredentialRefusals
        >
    with $Provider<CredentialRefusals> {
  /// Where every client built by [tixApiFactory] reports a `401`.
  CredentialRefusalsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'credentialRefusalsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$credentialRefusalsHash();

  @$internal
  @override
  $ProviderElement<CredentialRefusals> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CredentialRefusals create(Ref ref) {
    return credentialRefusals(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CredentialRefusals value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CredentialRefusals>(value),
    );
  }
}

String _$credentialRefusalsHash() =>
    r'abe70c76bdadf26e0ccb1af7f666fb4905c0ab6a';

/// How API clients are built. Each one presenting a credential reports the
/// `401`s it gets to [credentialRefusals], so a refused session is noticed
/// once, whichever screen or background job sent the request.

@ProviderFor(tixApiFactory)
final tixApiFactoryProvider = TixApiFactoryProvider._();

/// How API clients are built. Each one presenting a credential reports the
/// `401`s it gets to [credentialRefusals], so a refused session is noticed
/// once, whichever screen or background job sent the request.

final class TixApiFactoryProvider
    extends $FunctionalProvider<TixApiFactory, TixApiFactory, TixApiFactory>
    with $Provider<TixApiFactory> {
  /// How API clients are built. Each one presenting a credential reports the
  /// `401`s it gets to [credentialRefusals], so a refused session is noticed
  /// once, whichever screen or background job sent the request.
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

String _$tixApiFactoryHash() => r'4429810cc0fa2f50f38869ca5a0adb8b2a2a0478';
