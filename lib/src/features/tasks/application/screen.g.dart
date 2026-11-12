// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The filter, drawing and options of the task screen over one scope, kept
/// while the app runs so going back finds them as they were.

@ProviderFor(TaskScreen)
final taskScreenProvider = TaskScreenFamily._();

/// The filter, drawing and options of the task screen over one scope, kept
/// while the app runs so going back finds them as they were.
final class TaskScreenProvider
    extends $NotifierProvider<TaskScreen, TaskScreenState> {
  /// The filter, drawing and options of the task screen over one scope, kept
  /// while the app runs so going back finds them as they were.
  TaskScreenProvider._({
    required TaskScreenFamily super.from,
    required TaskScope super.argument,
  }) : super(
         retry: null,
         name: r'taskScreenProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$taskScreenHash();

  @override
  String toString() {
    return r'taskScreenProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TaskScreen create() => TaskScreen();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TaskScreenState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TaskScreenState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TaskScreenProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$taskScreenHash() => r'218009124372d6d2995eea342752db3df8adeec9';

/// The filter, drawing and options of the task screen over one scope, kept
/// while the app runs so going back finds them as they were.

final class TaskScreenFamily extends $Family
    with
        $ClassFamilyOverride<
          TaskScreen,
          TaskScreenState,
          TaskScreenState,
          TaskScreenState,
          TaskScope
        > {
  TaskScreenFamily._()
    : super(
        retry: null,
        name: r'taskScreenProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// The filter, drawing and options of the task screen over one scope, kept
  /// while the app runs so going back finds them as they were.

  TaskScreenProvider call(TaskScope scope) =>
      TaskScreenProvider._(argument: scope, from: this);

  @override
  String toString() => r'taskScreenProvider';
}

/// The filter, drawing and options of the task screen over one scope, kept
/// while the app runs so going back finds them as they were.

abstract class _$TaskScreen extends $Notifier<TaskScreenState> {
  late final _$args = ref.$arg as TaskScope;
  TaskScope get scope => _$args;

  TaskScreenState build(TaskScope scope);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<TaskScreenState, TaskScreenState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TaskScreenState, TaskScreenState>,
              TaskScreenState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// Select mode on one scope. It is explicit state: the Select button turns
/// it on with nothing picked, and picking a task turns it on too.

@ProviderFor(TaskSelection)
final taskSelectionProvider = TaskSelectionFamily._();

/// Select mode on one scope. It is explicit state: the Select button turns
/// it on with nothing picked, and picking a task turns it on too.
final class TaskSelectionProvider
    extends $NotifierProvider<TaskSelection, TaskSelectionState> {
  /// Select mode on one scope. It is explicit state: the Select button turns
  /// it on with nothing picked, and picking a task turns it on too.
  TaskSelectionProvider._({
    required TaskSelectionFamily super.from,
    required TaskScope super.argument,
  }) : super(
         retry: null,
         name: r'taskSelectionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$taskSelectionHash();

  @override
  String toString() {
    return r'taskSelectionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TaskSelection create() => TaskSelection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TaskSelectionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TaskSelectionState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TaskSelectionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$taskSelectionHash() => r'ab4c2e794ba9be366d71b713bdc5bc3066804dc7';

/// Select mode on one scope. It is explicit state: the Select button turns
/// it on with nothing picked, and picking a task turns it on too.

final class TaskSelectionFamily extends $Family
    with
        $ClassFamilyOverride<
          TaskSelection,
          TaskSelectionState,
          TaskSelectionState,
          TaskSelectionState,
          TaskScope
        > {
  TaskSelectionFamily._()
    : super(
        retry: null,
        name: r'taskSelectionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Select mode on one scope. It is explicit state: the Select button turns
  /// it on with nothing picked, and picking a task turns it on too.

  TaskSelectionProvider call(TaskScope scope) =>
      TaskSelectionProvider._(argument: scope, from: this);

  @override
  String toString() => r'taskSelectionProvider';
}

/// Select mode on one scope. It is explicit state: the Select button turns
/// it on with nothing picked, and picking a task turns it on too.

abstract class _$TaskSelection extends $Notifier<TaskSelectionState> {
  late final _$args = ref.$arg as TaskScope;
  TaskScope get scope => _$args;

  TaskSelectionState build(TaskScope scope);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<TaskSelectionState, TaskSelectionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TaskSelectionState, TaskSelectionState>,
              TaskSelectionState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// The reader's arrangement of one view's groups, by group.

@ProviderFor(ViewArrangement)
final viewArrangementProvider = ViewArrangementFamily._();

/// The reader's arrangement of one view's groups, by group.
final class ViewArrangementProvider
    extends $AsyncNotifierProvider<ViewArrangement, Map<String, GroupPref>> {
  /// The reader's arrangement of one view's groups, by group.
  ViewArrangementProvider._({
    required ViewArrangementFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'viewArrangementProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$viewArrangementHash();

  @override
  String toString() {
    return r'viewArrangementProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ViewArrangement create() => ViewArrangement();

  @override
  bool operator ==(Object other) {
    return other is ViewArrangementProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$viewArrangementHash() => r'43d1d8fb882a520cb985d48b2670eeead0c624af';

/// The reader's arrangement of one view's groups, by group.

final class ViewArrangementFamily extends $Family
    with
        $ClassFamilyOverride<
          ViewArrangement,
          AsyncValue<Map<String, GroupPref>>,
          Map<String, GroupPref>,
          FutureOr<Map<String, GroupPref>>,
          String
        > {
  ViewArrangementFamily._()
    : super(
        retry: null,
        name: r'viewArrangementProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The reader's arrangement of one view's groups, by group.

  ViewArrangementProvider call(String view) =>
      ViewArrangementProvider._(argument: view, from: this);

  @override
  String toString() => r'viewArrangementProvider';
}

/// The reader's arrangement of one view's groups, by group.

abstract class _$ViewArrangement
    extends $AsyncNotifier<Map<String, GroupPref>> {
  late final _$args = ref.$arg as String;
  String get view => _$args;

  FutureOr<Map<String, GroupPref>> build(String view);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<Map<String, GroupPref>>, Map<String, GroupPref>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<Map<String, GroupPref>>,
                Map<String, GroupPref>
              >,
              AsyncValue<Map<String, GroupPref>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// The reader's saved filters, then the ones shared with them.

@ProviderFor(SavedFilters)
final savedFiltersProvider = SavedFiltersProvider._();

/// The reader's saved filters, then the ones shared with them.
final class SavedFiltersProvider
    extends $AsyncNotifierProvider<SavedFilters, List<SavedFilter>> {
  /// The reader's saved filters, then the ones shared with them.
  SavedFiltersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedFiltersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedFiltersHash();

  @$internal
  @override
  SavedFilters create() => SavedFilters();
}

String _$savedFiltersHash() => r'3125b7269010c965ff696d9f0faacc59b6e4b093';

/// The reader's saved filters, then the ones shared with them.

abstract class _$SavedFilters extends $AsyncNotifier<List<SavedFilter>> {
  FutureOr<List<SavedFilter>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<SavedFilter>>, List<SavedFilter>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<SavedFilter>>, List<SavedFilter>>,
              AsyncValue<List<SavedFilter>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
