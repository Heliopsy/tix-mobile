// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'tenant_icons.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The uploaded icon of tenant [tenantRef] on the active connection, whose
/// digest is [digest]; a new digest reads it again.

@ProviderFor(tenantIconImage)
final tenantIconImageProvider = TenantIconImageFamily._();

/// The uploaded icon of tenant [tenantRef] on the active connection, whose
/// digest is [digest]; a new digest reads it again.

final class TenantIconImageProvider
    extends
        $FunctionalProvider<
          AsyncValue<Uint8List>,
          Uint8List,
          FutureOr<Uint8List>
        >
    with $FutureModifier<Uint8List>, $FutureProvider<Uint8List> {
  /// The uploaded icon of tenant [tenantRef] on the active connection, whose
  /// digest is [digest]; a new digest reads it again.
  TenantIconImageProvider._({
    required TenantIconImageFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'tenantIconImageProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tenantIconImageHash();

  @override
  String toString() {
    return r'tenantIconImageProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<Uint8List> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Uint8List> create(Ref ref) {
    final argument = this.argument as (String, String);
    return tenantIconImage(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is TenantIconImageProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tenantIconImageHash() => r'50a5945515eb70374670fe9b7e999f091d0837df';

/// The uploaded icon of tenant [tenantRef] on the active connection, whose
/// digest is [digest]; a new digest reads it again.

final class TenantIconImageFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Uint8List>, (String, String)> {
  TenantIconImageFamily._()
    : super(
        retry: null,
        name: r'tenantIconImageProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The uploaded icon of tenant [tenantRef] on the active connection, whose
  /// digest is [digest]; a new digest reads it again.

  TenantIconImageProvider call(String tenantRef, String digest) =>
      TenantIconImageProvider._(argument: (tenantRef, digest), from: this);

  @override
  String toString() => r'tenantIconImageProvider';
}

/// Whether the active server has tenant icons, judged by its version.

@ProviderFor(tenantIconsSupported)
final tenantIconsSupportedProvider = TenantIconsSupportedProvider._();

/// Whether the active server has tenant icons, judged by its version.

final class TenantIconsSupportedProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether the active server has tenant icons, judged by its version.
  TenantIconsSupportedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tenantIconsSupportedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tenantIconsSupportedHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return tenantIconsSupported(ref);
  }
}

String _$tenantIconsSupportedHash() =>
    r'58f3c136f8f0d92c4f8b02dad80a575f40603e5b';
