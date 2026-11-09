// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'outbox_owner.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// This engine's ownership of the outboxes: owned at once unless `main`
/// says another engine may hold them.

@ProviderFor(outboxOwnership)
final outboxOwnershipProvider = OutboxOwnershipProvider._();

/// This engine's ownership of the outboxes: owned at once unless `main`
/// says another engine may hold them.

final class OutboxOwnershipProvider
    extends
        $FunctionalProvider<OutboxOwnership, OutboxOwnership, OutboxOwnership>
    with $Provider<OutboxOwnership> {
  /// This engine's ownership of the outboxes: owned at once unless `main`
  /// says another engine may hold them.
  OutboxOwnershipProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'outboxOwnershipProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$outboxOwnershipHash();

  @$internal
  @override
  $ProviderElement<OutboxOwnership> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OutboxOwnership create(Ref ref) {
    return outboxOwnership(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OutboxOwnership value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OutboxOwnership>(value),
    );
  }
}

String _$outboxOwnershipHash() => r'a6cbeab2f16cc91103f7187262f0089a112f3848';
