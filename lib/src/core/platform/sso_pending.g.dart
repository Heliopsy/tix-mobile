// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'sso_pending.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Where the provider sign-in under way is kept.

@ProviderFor(pendingSso)
final pendingSsoProvider = PendingSsoProvider._();

/// Where the provider sign-in under way is kept.

final class PendingSsoProvider
    extends
        $FunctionalProvider<PendingSsoStore, PendingSsoStore, PendingSsoStore>
    with $Provider<PendingSsoStore> {
  /// Where the provider sign-in under way is kept.
  PendingSsoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingSsoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingSsoHash();

  @$internal
  @override
  $ProviderElement<PendingSsoStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PendingSsoStore create(Ref ref) {
    return pendingSso(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PendingSsoStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PendingSsoStore>(value),
    );
  }
}

String _$pendingSsoHash() => r'e1cfb4d210395d7cf67f6848e72213e6a3464928';
