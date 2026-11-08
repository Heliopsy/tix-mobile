// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'accent_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The active tenant's accent: the theme remembered for the context at
/// once, then whatever the server names now. tix's default without a
/// context, and when the credential may not read its tenant.

@ProviderFor(TenantAccent)
final tenantAccentProvider = TenantAccentProvider._();

/// The active tenant's accent: the theme remembered for the context at
/// once, then whatever the server names now. tix's default without a
/// context, and when the credential may not read its tenant.
final class TenantAccentProvider
    extends $NotifierProvider<TenantAccent, TixAccent> {
  /// The active tenant's accent: the theme remembered for the context at
  /// once, then whatever the server names now. tix's default without a
  /// context, and when the credential may not read its tenant.
  TenantAccentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tenantAccentProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tenantAccentHash();

  @$internal
  @override
  TenantAccent create() => TenantAccent();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TixAccent value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TixAccent>(value),
    );
  }
}

String _$tenantAccentHash() => r'dee788eff74199f77b3564d7923f1859e9b8793b';

/// The active tenant's accent: the theme remembered for the context at
/// once, then whatever the server names now. tix's default without a
/// context, and when the credential may not read its tenant.

abstract class _$TenantAccent extends $Notifier<TixAccent> {
  TixAccent build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<TixAccent, TixAccent>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TixAccent, TixAccent>,
              TixAccent,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
