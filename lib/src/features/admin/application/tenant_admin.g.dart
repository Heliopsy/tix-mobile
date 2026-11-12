// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'tenant_admin.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The tenant the active context targets: its key when the connection
/// names one, else the id `whoami` reports, which is all a token knows.

@ProviderFor(currentTenantRef)
final currentTenantRefProvider = CurrentTenantRefProvider._();

/// The tenant the active context targets: its key when the connection
/// names one, else the id `whoami` reports, which is all a token knows.

final class CurrentTenantRefProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// The tenant the active context targets: its key when the connection
  /// names one, else the id `whoami` reports, which is all a token knows.
  CurrentTenantRefProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentTenantRefProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentTenantRefHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return currentTenantRef(ref);
  }
}

String _$currentTenantRefHash() => r'3997d6b75f1a927433195b8167f7d3eef13f404e';

/// The settings of tenant [tenantRef]: the cached copy at once, then the
/// server's.

@ProviderFor(TenantSettings)
final tenantSettingsProvider = TenantSettingsFamily._();

/// The settings of tenant [tenantRef]: the cached copy at once, then the
/// server's.
final class TenantSettingsProvider
    extends $AsyncNotifierProvider<TenantSettings, Tenant> {
  /// The settings of tenant [tenantRef]: the cached copy at once, then the
  /// server's.
  TenantSettingsProvider._({
    required TenantSettingsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'tenantSettingsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tenantSettingsHash();

  @override
  String toString() {
    return r'tenantSettingsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TenantSettings create() => TenantSettings();

  @override
  bool operator ==(Object other) {
    return other is TenantSettingsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tenantSettingsHash() => r'65da77da9332e52609fd6f877c0bb2fcff3d9812';

/// The settings of tenant [tenantRef]: the cached copy at once, then the
/// server's.

final class TenantSettingsFamily extends $Family
    with
        $ClassFamilyOverride<
          TenantSettings,
          AsyncValue<Tenant>,
          Tenant,
          FutureOr<Tenant>,
          String
        > {
  TenantSettingsFamily._()
    : super(
        retry: null,
        name: r'tenantSettingsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The settings of tenant [tenantRef]: the cached copy at once, then the
  /// server's.

  TenantSettingsProvider call(String tenantRef) =>
      TenantSettingsProvider._(argument: tenantRef, from: this);

  @override
  String toString() => r'tenantSettingsProvider';
}

/// The settings of tenant [tenantRef]: the cached copy at once, then the
/// server's.

abstract class _$TenantSettings extends $AsyncNotifier<Tenant> {
  late final _$args = ref.$arg as String;
  String get tenantRef => _$args;

  FutureOr<Tenant> build(String tenantRef);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Tenant>, Tenant>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Tenant>, Tenant>,
              AsyncValue<Tenant>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// The server's own session settings, which a tenant may only tighten.

@ProviderFor(serverSessionPolicy)
final serverSessionPolicyProvider = ServerSessionPolicyProvider._();

/// The server's own session settings, which a tenant may only tighten.

final class ServerSessionPolicyProvider
    extends
        $FunctionalProvider<
          AsyncValue<SessionPolicy>,
          SessionPolicy,
          FutureOr<SessionPolicy>
        >
    with $FutureModifier<SessionPolicy>, $FutureProvider<SessionPolicy> {
  /// The server's own session settings, which a tenant may only tighten.
  ServerSessionPolicyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serverSessionPolicyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serverSessionPolicyHash();

  @$internal
  @override
  $FutureProviderElement<SessionPolicy> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SessionPolicy> create(Ref ref) {
    return serverSessionPolicy(ref);
  }
}

String _$serverSessionPolicyHash() =>
    r'52720999bf56c7b31599b81b69123840d3f102ca';

/// The server's own artifact limits, which a tenant may only tighten.

@ProviderFor(serverArtifactLimits)
final serverArtifactLimitsProvider = ServerArtifactLimitsProvider._();

/// The server's own artifact limits, which a tenant may only tighten.

final class ServerArtifactLimitsProvider
    extends
        $FunctionalProvider<
          AsyncValue<ArtifactLimits>,
          ArtifactLimits,
          FutureOr<ArtifactLimits>
        >
    with $FutureModifier<ArtifactLimits>, $FutureProvider<ArtifactLimits> {
  /// The server's own artifact limits, which a tenant may only tighten.
  ServerArtifactLimitsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serverArtifactLimitsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serverArtifactLimitsHash();

  @$internal
  @override
  $FutureProviderElement<ArtifactLimits> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ArtifactLimits> create(Ref ref) {
    return serverArtifactLimits(ref);
  }
}

String _$serverArtifactLimitsHash() =>
    r'78190b3a42c5b0f7bb5eabd08f561709b15f1a2c';

/// The hostnames mapped to the caller's tenant.

@ProviderFor(TenantDomainList)
final tenantDomainListProvider = TenantDomainListProvider._();

/// The hostnames mapped to the caller's tenant.
final class TenantDomainListProvider
    extends $AsyncNotifierProvider<TenantDomainList, List<Domain>> {
  /// The hostnames mapped to the caller's tenant.
  TenantDomainListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tenantDomainListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tenantDomainListHash();

  @$internal
  @override
  TenantDomainList create() => TenantDomainList();
}

String _$tenantDomainListHash() => r'b089000515ef6e1116f337eaa94faa897619cf43';

/// The hostnames mapped to the caller's tenant.

abstract class _$TenantDomainList extends $AsyncNotifier<List<Domain>> {
  FutureOr<List<Domain>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Domain>>, List<Domain>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Domain>>, List<Domain>>,
              AsyncValue<List<Domain>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The server's version and the tenant's live connections.

@ProviderFor(ServerStatus)
final serverStatusProvider = ServerStatusProvider._();

/// The server's version and the tenant's live connections.
final class ServerStatusProvider
    extends $AsyncNotifierProvider<ServerStatus, ServerOverview> {
  /// The server's version and the tenant's live connections.
  ServerStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serverStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serverStatusHash();

  @$internal
  @override
  ServerStatus create() => ServerStatus();
}

String _$serverStatusHash() => r'db0802eecf0f24fff9d8428f03d525674e5621bc';

/// The server's version and the tenant's live connections.

abstract class _$ServerStatus extends $AsyncNotifier<ServerOverview> {
  FutureOr<ServerOverview> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ServerOverview>, ServerOverview>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ServerOverview>, ServerOverview>,
              AsyncValue<ServerOverview>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
