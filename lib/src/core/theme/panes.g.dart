// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'panes.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The pane sizes, kept per device in the settings store.

@ProviderFor(Panes)
final panesProvider = PanesProvider._();

/// The pane sizes, kept per device in the settings store.
final class PanesProvider extends $NotifierProvider<Panes, PaneSizes> {
  /// The pane sizes, kept per device in the settings store.
  PanesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'panesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$panesHash();

  @$internal
  @override
  Panes create() => Panes();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaneSizes value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaneSizes>(value),
    );
  }
}

String _$panesHash() => r'd8ecf0df5f156c95189bb6f43f554cd16396e103';

/// The pane sizes, kept per device in the settings store.

abstract class _$Panes extends $Notifier<PaneSizes> {
  PaneSizes build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PaneSizes, PaneSizes>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PaneSizes, PaneSizes>,
              PaneSizes,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
