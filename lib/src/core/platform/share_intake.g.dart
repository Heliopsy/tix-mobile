// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'share_intake.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The platform's share intake; tests swap in one on a mocked channel.

@ProviderFor(shareIntake)
final shareIntakeProvider = ShareIntakeProvider._();

/// The platform's share intake; tests swap in one on a mocked channel.

final class ShareIntakeProvider
    extends $FunctionalProvider<ShareIntake, ShareIntake, ShareIntake>
    with $Provider<ShareIntake> {
  /// The platform's share intake; tests swap in one on a mocked channel.
  ShareIntakeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shareIntakeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shareIntakeHash();

  @$internal
  @override
  $ProviderElement<ShareIntake> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ShareIntake create(Ref ref) {
    return shareIntake(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShareIntake value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShareIntake>(value),
    );
  }
}

String _$shareIntakeHash() => r'1d6053642b78a598794cd4aa4e238e9651c866a8';
