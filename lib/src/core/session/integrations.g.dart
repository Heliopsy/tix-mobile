// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'integrations.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Webhooks and external sync, for the active session.

@ProviderFor(integrationsRepository)
final integrationsRepositoryProvider = IntegrationsRepositoryProvider._();

/// Webhooks and external sync, for the active session.

final class IntegrationsRepositoryProvider
    extends
        $FunctionalProvider<
          IntegrationsRepository,
          IntegrationsRepository,
          IntegrationsRepository
        >
    with $Provider<IntegrationsRepository> {
  /// Webhooks and external sync, for the active session.
  IntegrationsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'integrationsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$integrationsRepositoryHash();

  @$internal
  @override
  $ProviderElement<IntegrationsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IntegrationsRepository create(Ref ref) {
    return integrationsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IntegrationsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IntegrationsRepository>(value),
    );
  }
}

String _$integrationsRepositoryHash() =>
    r'864ef30a0c2d2aa9e47a39e69a0704bb993a9677';

/// Retention, housekeeping and the trash, for the active session.

@ProviderFor(maintenanceRepository)
final maintenanceRepositoryProvider = MaintenanceRepositoryProvider._();

/// Retention, housekeeping and the trash, for the active session.

final class MaintenanceRepositoryProvider
    extends
        $FunctionalProvider<
          MaintenanceRepository,
          MaintenanceRepository,
          MaintenanceRepository
        >
    with $Provider<MaintenanceRepository> {
  /// Retention, housekeeping and the trash, for the active session.
  MaintenanceRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'maintenanceRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$maintenanceRepositoryHash();

  @$internal
  @override
  $ProviderElement<MaintenanceRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MaintenanceRepository create(Ref ref) {
    return maintenanceRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MaintenanceRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MaintenanceRepository>(value),
    );
  }
}

String _$maintenanceRepositoryHash() =>
    r'1dbcf76a40c8f13950d436aacf20be9dc08b8e50';

/// The audit log, for the active session.

@ProviderFor(auditRepository)
final auditRepositoryProvider = AuditRepositoryProvider._();

/// The audit log, for the active session.

final class AuditRepositoryProvider
    extends
        $FunctionalProvider<AuditRepository, AuditRepository, AuditRepository>
    with $Provider<AuditRepository> {
  /// The audit log, for the active session.
  AuditRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'auditRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$auditRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuditRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuditRepository create(Ref ref) {
    return auditRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuditRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuditRepository>(value),
    );
  }
}

String _$auditRepositoryHash() => r'4920a2b7b946e1a982bbfd8668b001871ff318e9';
