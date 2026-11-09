// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'pinned_shortcuts.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The platform's pinned shortcuts; tests swap in a fake.

@ProviderFor(pinnedShortcuts)
final pinnedShortcutsProvider = PinnedShortcutsProvider._();

/// The platform's pinned shortcuts; tests swap in a fake.

final class PinnedShortcutsProvider
    extends
        $FunctionalProvider<PinnedShortcuts, PinnedShortcuts, PinnedShortcuts>
    with $Provider<PinnedShortcuts> {
  /// The platform's pinned shortcuts; tests swap in a fake.
  PinnedShortcutsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pinnedShortcutsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pinnedShortcutsHash();

  @$internal
  @override
  $ProviderElement<PinnedShortcuts> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PinnedShortcuts create(Ref ref) {
    return pinnedShortcuts(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PinnedShortcuts value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PinnedShortcuts>(value),
    );
  }
}

String _$pinnedShortcutsHash() => r'da9937b83aacccd08ee4091e1ff0f9572922c232';

/// Whether Add to home screen is offered on this device.

@ProviderFor(pinSupported)
final pinSupportedProvider = PinSupportedProvider._();

/// Whether Add to home screen is offered on this device.

final class PinSupportedProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether Add to home screen is offered on this device.
  PinSupportedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pinSupportedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pinSupportedHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return pinSupported(ref);
  }
}

String _$pinSupportedHash() => r'0f5d1bf00ca2a0fe52e7b9347b7d4552cf80992d';
