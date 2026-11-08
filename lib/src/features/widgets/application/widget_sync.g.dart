// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'widget_sync.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Keeps the home screen widgets current while the signed-in app runs:
/// after the session changes, events about tasks, the inbox or projects,
/// a quick add, a resume, and when the app goes out of sight. Runs the
/// queue of widget ticks first each time.

@ProviderFor(WidgetSync)
final widgetSyncProvider = WidgetSyncProvider._();

/// Keeps the home screen widgets current while the signed-in app runs:
/// after the session changes, events about tasks, the inbox or projects,
/// a quick add, a resume, and when the app goes out of sight. Runs the
/// queue of widget ticks first each time.
final class WidgetSyncProvider
    extends $AsyncNotifierProvider<WidgetSync, void> {
  /// Keeps the home screen widgets current while the signed-in app runs:
  /// after the session changes, events about tasks, the inbox or projects,
  /// a quick add, a resume, and when the app goes out of sight. Runs the
  /// queue of widget ticks first each time.
  WidgetSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'widgetSyncProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$widgetSyncHash();

  @$internal
  @override
  WidgetSync create() => WidgetSync();
}

String _$widgetSyncHash() => r'db0a2034b929e38a4edce69a41f2882e87222364';

/// Keeps the home screen widgets current while the signed-in app runs:
/// after the session changes, events about tasks, the inbox or projects,
/// a quick add, a resume, and when the app goes out of sight. Runs the
/// queue of widget ticks first each time.

abstract class _$WidgetSync extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
