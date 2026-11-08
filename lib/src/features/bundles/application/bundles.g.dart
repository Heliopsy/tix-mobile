// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'bundles.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Bundles out and in, and snapshots in, for the screens. It holds nothing:
/// each call is about one file.

@ProviderFor(BundleTransfer)
final bundleTransferProvider = BundleTransferProvider._();

/// Bundles out and in, and snapshots in, for the screens. It holds nothing:
/// each call is about one file.
final class BundleTransferProvider
    extends $NotifierProvider<BundleTransfer, void> {
  /// Bundles out and in, and snapshots in, for the screens. It holds nothing:
  /// each call is about one file.
  BundleTransferProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bundleTransferProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bundleTransferHash();

  @$internal
  @override
  BundleTransfer create() => BundleTransfer();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$bundleTransferHash() => r'96d5eb3a6732195f83902a19413433bef908bf42';

/// Bundles out and in, and snapshots in, for the screens. It holds nothing:
/// each call is about one file.

abstract class _$BundleTransfer extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
