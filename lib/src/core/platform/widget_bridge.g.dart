// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'widget_bridge.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The platform's widget bridge. `main` hands it the background callback;
/// tests swap in a fake.

@ProviderFor(widgetBridge)
final widgetBridgeProvider = WidgetBridgeProvider._();

/// The platform's widget bridge. `main` hands it the background callback;
/// tests swap in a fake.

final class WidgetBridgeProvider
    extends $FunctionalProvider<WidgetBridge, WidgetBridge, WidgetBridge>
    with $Provider<WidgetBridge> {
  /// The platform's widget bridge. `main` hands it the background callback;
  /// tests swap in a fake.
  WidgetBridgeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'widgetBridgeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$widgetBridgeHash();

  @$internal
  @override
  $ProviderElement<WidgetBridge> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WidgetBridge create(Ref ref) {
    return widgetBridge(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WidgetBridge value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WidgetBridge>(value),
    );
  }
}

String _$widgetBridgeHash() => r'c0eb2d0c079fb87d7ebab4e0e9cea78e7726d8dd';

/// Ticks when something the widgets draw changed outside any event, such
/// as the theme, the language or the privacy setting, so they are written
/// again.

@ProviderFor(WidgetsStale)
final widgetsStaleProvider = WidgetsStaleProvider._();

/// Ticks when something the widgets draw changed outside any event, such
/// as the theme, the language or the privacy setting, so they are written
/// again.
final class WidgetsStaleProvider extends $NotifierProvider<WidgetsStale, int> {
  /// Ticks when something the widgets draw changed outside any event, such
  /// as the theme, the language or the privacy setting, so they are written
  /// again.
  WidgetsStaleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'widgetsStaleProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$widgetsStaleHash();

  @$internal
  @override
  WidgetsStale create() => WidgetsStale();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$widgetsStaleHash() => r'21d8bb23d48491ac9ef3ec9ef60b9a833d352c73';

/// Ticks when something the widgets draw changed outside any event, such
/// as the theme, the language or the privacy setting, so they are written
/// again.

abstract class _$WidgetsStale extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
