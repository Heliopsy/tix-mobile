// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'sharing.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The platform's share sheet.

@ProviderFor(textSharing)
final textSharingProvider = TextSharingProvider._();

/// The platform's share sheet.

final class TextSharingProvider
    extends $FunctionalProvider<TextSharing, TextSharing, TextSharing>
    with $Provider<TextSharing> {
  /// The platform's share sheet.
  TextSharingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'textSharingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$textSharingHash();

  @$internal
  @override
  $ProviderElement<TextSharing> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TextSharing create(Ref ref) {
    return textSharing(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TextSharing value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TextSharing>(value),
    );
  }
}

String _$textSharingHash() => r'e1ad254a0b06600ad7e827da631627a48b669cba';
