// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'quick_add.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Where every feature asks for quick add. The quick-add host, mounted around
/// the signed-in screens, opens the sheet for each draft and takes it; a
/// draft written while nobody is signed in waits.

@ProviderFor(QuickAddDrafts)
final quickAddDraftsProvider = QuickAddDraftsProvider._();

/// Where every feature asks for quick add. The quick-add host, mounted around
/// the signed-in screens, opens the sheet for each draft and takes it; a
/// draft written while nobody is signed in waits.
final class QuickAddDraftsProvider
    extends $NotifierProvider<QuickAddDrafts, QuickAddDraft?> {
  /// Where every feature asks for quick add. The quick-add host, mounted around
  /// the signed-in screens, opens the sheet for each draft and takes it; a
  /// draft written while nobody is signed in waits.
  QuickAddDraftsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'quickAddDraftsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$quickAddDraftsHash();

  @$internal
  @override
  QuickAddDrafts create() => QuickAddDrafts();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(QuickAddDraft? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<QuickAddDraft?>(value),
    );
  }
}

String _$quickAddDraftsHash() => r'9680072e36f923b5a9d120dc9a391a0a74df4909';

/// Where every feature asks for quick add. The quick-add host, mounted around
/// the signed-in screens, opens the sheet for each draft and takes it; a
/// draft written while nobody is signed in waits.

abstract class _$QuickAddDrafts extends $Notifier<QuickAddDraft?> {
  QuickAddDraft? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<QuickAddDraft?, QuickAddDraft?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<QuickAddDraft?, QuickAddDraft?>,
              QuickAddDraft?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Ticks when a task is created outside the screen listing it, so lists
/// that watch it reload.

@ProviderFor(TasksChanged)
final tasksChangedProvider = TasksChangedProvider._();

/// Ticks when a task is created outside the screen listing it, so lists
/// that watch it reload.
final class TasksChangedProvider extends $NotifierProvider<TasksChanged, int> {
  /// Ticks when a task is created outside the screen listing it, so lists
  /// that watch it reload.
  TasksChangedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tasksChangedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tasksChangedHash();

  @$internal
  @override
  TasksChanged create() => TasksChanged();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$tasksChangedHash() => r'3ef0d423df9c66d7ae292ea8ca379d5790104e85';

/// Ticks when a task is created outside the screen listing it, so lists
/// that watch it reload.

abstract class _$TasksChanged extends $Notifier<int> {
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
