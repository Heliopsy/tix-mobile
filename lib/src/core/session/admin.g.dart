// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'admin.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Tenant and server administration for the active session.

@ProviderFor(adminRepository)
final adminRepositoryProvider = AdminRepositoryProvider._();

/// Tenant and server administration for the active session.

final class AdminRepositoryProvider
    extends
        $FunctionalProvider<AdminRepository, AdminRepository, AdminRepository>
    with $Provider<AdminRepository> {
  /// Tenant and server administration for the active session.
  AdminRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminRepositoryHash();

  @$internal
  @override
  $ProviderElement<AdminRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AdminRepository create(Ref ref) {
    return adminRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdminRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdminRepository>(value),
    );
  }
}

String _$adminRepositoryHash() => r'1cd138f44817d615e23a10b482213cce1ab59be6';

/// The signed-in person's second factor and SSH keys, for the active
/// session.

@ProviderFor(securityRepository)
final securityRepositoryProvider = SecurityRepositoryProvider._();

/// The signed-in person's second factor and SSH keys, for the active
/// session.

final class SecurityRepositoryProvider
    extends
        $FunctionalProvider<
          SecurityRepository,
          SecurityRepository,
          SecurityRepository
        >
    with $Provider<SecurityRepository> {
  /// The signed-in person's second factor and SSH keys, for the active
  /// session.
  SecurityRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'securityRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$securityRepositoryHash();

  @$internal
  @override
  $ProviderElement<SecurityRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SecurityRepository create(Ref ref) {
    return securityRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SecurityRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SecurityRepository>(value),
    );
  }
}

String _$securityRepositoryHash() =>
    r'7b1ea1c236da432586584819434515f07d8831b8';
