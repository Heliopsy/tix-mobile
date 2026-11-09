// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'deep_links.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The platform's link intake; tests swap in one on a mocked channel.

@ProviderFor(deepLinkIntake)
final deepLinkIntakeProvider = DeepLinkIntakeProvider._();

/// The platform's link intake; tests swap in one on a mocked channel.

final class DeepLinkIntakeProvider
    extends $FunctionalProvider<DeepLinkIntake, DeepLinkIntake, DeepLinkIntake>
    with $Provider<DeepLinkIntake> {
  /// The platform's link intake; tests swap in one on a mocked channel.
  DeepLinkIntakeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deepLinkIntakeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deepLinkIntakeHash();

  @$internal
  @override
  $ProviderElement<DeepLinkIntake> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeepLinkIntake create(Ref ref) {
    return deepLinkIntake(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeepLinkIntake value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeepLinkIntake>(value),
    );
  }
}

String _$deepLinkIntakeHash() => r'69a9259ebda7f7de7eb827be8d36b969008f7049';
