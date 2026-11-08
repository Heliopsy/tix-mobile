// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'attachments.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The platform's attachments service.

@ProviderFor(attachments)
final attachmentsProvider = AttachmentsProvider._();

/// The platform's attachments service.

final class AttachmentsProvider
    extends $FunctionalProvider<Attachments, Attachments, Attachments>
    with $Provider<Attachments> {
  /// The platform's attachments service.
  AttachmentsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'attachmentsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$attachmentsHash();

  @$internal
  @override
  $ProviderElement<Attachments> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Attachments create(Ref ref) {
    return attachments(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Attachments value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Attachments>(value),
    );
  }
}

String _$attachmentsHash() => r'154cecb9afb28a4234586e8e5ae380066a6d70c9';
