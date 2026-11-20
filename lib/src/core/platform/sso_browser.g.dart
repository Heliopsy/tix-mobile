// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'sso_browser.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The platform's user agent for provider sign-ins; tests swap in a fake.

@ProviderFor(ssoBrowser)
final ssoBrowserProvider = SsoBrowserProvider._();

/// The platform's user agent for provider sign-ins; tests swap in a fake.

final class SsoBrowserProvider
    extends $FunctionalProvider<SsoBrowser, SsoBrowser, SsoBrowser>
    with $Provider<SsoBrowser> {
  /// The platform's user agent for provider sign-ins; tests swap in a fake.
  SsoBrowserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ssoBrowserProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ssoBrowserHash();

  @$internal
  @override
  $ProviderElement<SsoBrowser> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SsoBrowser create(Ref ref) {
    return ssoBrowser(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SsoBrowser value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SsoBrowser>(value),
    );
  }
}

String _$ssoBrowserHash() => r'dfc6c08a4d02d2b0fa3e89c95385cdf396b9d834';
