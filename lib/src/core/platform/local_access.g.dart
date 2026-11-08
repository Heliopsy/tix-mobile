// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'local_access.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The platform's access to files outside the app.

@ProviderFor(localFileAccess)
final localFileAccessProvider = LocalFileAccessProvider._();

/// The platform's access to files outside the app.

final class LocalFileAccessProvider
    extends
        $FunctionalProvider<LocalFileAccess, LocalFileAccess, LocalFileAccess>
    with $Provider<LocalFileAccess> {
  /// The platform's access to files outside the app.
  LocalFileAccessProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localFileAccessProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localFileAccessHash();

  @$internal
  @override
  $ProviderElement<LocalFileAccess> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LocalFileAccess create(Ref ref) {
    return localFileAccess(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalFileAccess value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalFileAccess>(value),
    );
  }
}

String _$localFileAccessHash() => r'c3e4b3f011d1d79effacb72f500bcf2dfc4e7836';

/// How this platform reaches a database used in place.

@ProviderFor(localInPlaceKind)
final localInPlaceKindProvider = LocalInPlaceKindProvider._();

/// How this platform reaches a database used in place.

final class LocalInPlaceKindProvider
    extends
        $FunctionalProvider<
          AsyncValue<InPlaceKind>,
          InPlaceKind,
          FutureOr<InPlaceKind>
        >
    with $FutureModifier<InPlaceKind>, $FutureProvider<InPlaceKind> {
  /// How this platform reaches a database used in place.
  LocalInPlaceKindProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localInPlaceKindProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localInPlaceKindHash();

  @$internal
  @override
  $FutureProviderElement<InPlaceKind> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<InPlaceKind> create(Ref ref) {
    return localInPlaceKind(ref);
  }
}

String _$localInPlaceKindHash() => r'4762982cf4f9286e6e6a9c90ac371bc0a7e9e30b';
