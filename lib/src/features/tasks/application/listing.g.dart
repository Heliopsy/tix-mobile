// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'listing.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The projects and workflows of the active session: the cached copies at
/// once, then the server's, and again when a project or workflow changes.

@ProviderFor(TaskContext)
final taskContextProvider = TaskContextProvider._();

/// The projects and workflows of the active session: the cached copies at
/// once, then the server's, and again when a project or workflow changes.
final class TaskContextProvider
    extends $AsyncNotifierProvider<TaskContext, TaskIndex> {
  /// The projects and workflows of the active session: the cached copies at
  /// once, then the server's, and again when a project or workflow changes.
  TaskContextProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taskContextProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taskContextHash();

  @$internal
  @override
  TaskContext create() => TaskContext();
}

String _$taskContextHash() => r'4bc9c762ad49d3037bf73ff772eac523927471e4';

/// The projects and workflows of the active session: the cached copies at
/// once, then the server's, and again when a project or workflow changes.

abstract class _$TaskContext extends $AsyncNotifier<TaskIndex> {
  FutureOr<TaskIndex> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<TaskIndex>, TaskIndex>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TaskIndex>, TaskIndex>,
              AsyncValue<TaskIndex>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The signed-in reader.

@ProviderFor(me)
final meProvider = MeProvider._();

/// The signed-in reader.

final class MeProvider
    extends $FunctionalProvider<AsyncValue<Actor>, Actor, FutureOr<Actor>>
    with $FutureModifier<Actor>, $FutureProvider<Actor> {
  /// The signed-in reader.
  MeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'meProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$meHash();

  @$internal
  @override
  $FutureProviderElement<Actor> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Actor> create(Ref ref) {
    return me(ref);
  }
}

String _$meHash() => r'a72b0d85ff4b23787a8a9f00fb76de8bff5ee4fd';

/// The tasks one query selects, a page at a time: the cached first page at
/// once, then the server's, again whenever a task changes, and kept for a
/// few minutes after the last screen leaves it.

@ProviderFor(TaskListing)
final taskListingProvider = TaskListingFamily._();

/// The tasks one query selects, a page at a time: the cached first page at
/// once, then the server's, again whenever a task changes, and kept for a
/// few minutes after the last screen leaves it.
final class TaskListingProvider
    extends $AsyncNotifierProvider<TaskListing, Paged<Task>> {
  /// The tasks one query selects, a page at a time: the cached first page at
  /// once, then the server's, again whenever a task changes, and kept for a
  /// few minutes after the last screen leaves it.
  TaskListingProvider._({
    required TaskListingFamily super.from,
    required TaskQuery super.argument,
  }) : super(
         retry: null,
         name: r'taskListingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$taskListingHash();

  @override
  String toString() {
    return r'taskListingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TaskListing create() => TaskListing();

  @override
  bool operator ==(Object other) {
    return other is TaskListingProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$taskListingHash() => r'da3b47662e9ff321c2b7c5f713cfeee81e37fd8e';

/// The tasks one query selects, a page at a time: the cached first page at
/// once, then the server's, again whenever a task changes, and kept for a
/// few minutes after the last screen leaves it.

final class TaskListingFamily extends $Family
    with
        $ClassFamilyOverride<
          TaskListing,
          AsyncValue<Paged<Task>>,
          Paged<Task>,
          FutureOr<Paged<Task>>,
          TaskQuery
        > {
  TaskListingFamily._()
    : super(
        retry: null,
        name: r'taskListingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The tasks one query selects, a page at a time: the cached first page at
  /// once, then the server's, again whenever a task changes, and kept for a
  /// few minutes after the last screen leaves it.

  TaskListingProvider call(TaskQuery query) =>
      TaskListingProvider._(argument: query, from: this);

  @override
  String toString() => r'taskListingProvider';
}

/// The tasks one query selects, a page at a time: the cached first page at
/// once, then the server's, again whenever a task changes, and kept for a
/// few minutes after the last screen leaves it.

abstract class _$TaskListing extends $AsyncNotifier<Paged<Task>> {
  late final _$args = ref.$arg as TaskQuery;
  TaskQuery get query => _$args;

  FutureOr<Paged<Task>> build(TaskQuery query);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Paged<Task>>, Paged<Task>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Paged<Task>>, Paged<Task>>,
              AsyncValue<Paged<Task>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
