// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'dav_handoff.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The platform's hand-off; tests swap in a fake.

@ProviderFor(davHandoff)
final davHandoffProvider = DavHandoffProvider._();

/// The platform's hand-off; tests swap in a fake.

final class DavHandoffProvider
    extends $FunctionalProvider<DavHandoff, DavHandoff, DavHandoff>
    with $Provider<DavHandoff> {
  /// The platform's hand-off; tests swap in a fake.
  DavHandoffProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'davHandoffProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$davHandoffHash();

  @$internal
  @override
  $ProviderElement<DavHandoff> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DavHandoff create(Ref ref) {
    return davHandoff(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DavHandoff value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DavHandoff>(value),
    );
  }
}

String _$davHandoffHash() => r'84f61e3c356415a17b881705ff7794c4a59ac2f1';
