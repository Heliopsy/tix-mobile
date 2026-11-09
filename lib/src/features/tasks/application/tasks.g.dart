// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'tasks.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The tasks of one project, most urgent first, a page at a time: the
/// cached first page at once, then the server's, and again whenever a task
/// changes.

@ProviderFor(ProjectTasks)
final projectTasksProvider = ProjectTasksFamily._();

/// The tasks of one project, most urgent first, a page at a time: the
/// cached first page at once, then the server's, and again whenever a task
/// changes.
final class ProjectTasksProvider
    extends $AsyncNotifierProvider<ProjectTasks, Paged<Task>> {
  /// The tasks of one project, most urgent first, a page at a time: the
  /// cached first page at once, then the server's, and again whenever a task
  /// changes.
  ProjectTasksProvider._({
    required ProjectTasksFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'projectTasksProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$projectTasksHash();

  @override
  String toString() {
    return r'projectTasksProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ProjectTasks create() => ProjectTasks();

  @override
  bool operator ==(Object other) {
    return other is ProjectTasksProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$projectTasksHash() => r'dcdd4de99735154dcd4ded56635f1f20844dc14f';

/// The tasks of one project, most urgent first, a page at a time: the
/// cached first page at once, then the server's, and again whenever a task
/// changes.

final class ProjectTasksFamily extends $Family
    with
        $ClassFamilyOverride<
          ProjectTasks,
          AsyncValue<Paged<Task>>,
          Paged<Task>,
          FutureOr<Paged<Task>>,
          String
        > {
  ProjectTasksFamily._()
    : super(
        retry: null,
        name: r'projectTasksProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The tasks of one project, most urgent first, a page at a time: the
  /// cached first page at once, then the server's, and again whenever a task
  /// changes.

  ProjectTasksProvider call(String projectKey) =>
      ProjectTasksProvider._(argument: projectKey, from: this);

  @override
  String toString() => r'projectTasksProvider';
}

/// The tasks of one project, most urgent first, a page at a time: the
/// cached first page at once, then the server's, and again whenever a task
/// changes.

abstract class _$ProjectTasks extends $AsyncNotifier<Paged<Task>> {
  late final _$args = ref.$arg as String;
  String get projectKey => _$args;

  FutureOr<Paged<Task>> build(String projectKey);
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

/// Creates tasks from a quick-add line and refreshes every listing, so the
/// new task shows wherever the server sorts it. It holds itself alive while
/// a line is in flight, since the sheet that calls it may outlive every
/// listing watching the project.

@ProviderFor(TaskCreator)
final taskCreatorProvider = TaskCreatorProvider._();

/// Creates tasks from a quick-add line and refreshes every listing, so the
/// new task shows wherever the server sorts it. It holds itself alive while
/// a line is in flight, since the sheet that calls it may outlive every
/// listing watching the project.
final class TaskCreatorProvider extends $NotifierProvider<TaskCreator, void> {
  /// Creates tasks from a quick-add line and refreshes every listing, so the
  /// new task shows wherever the server sorts it. It holds itself alive while
  /// a line is in flight, since the sheet that calls it may outlive every
  /// listing watching the project.
  TaskCreatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taskCreatorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taskCreatorHash();

  @$internal
  @override
  TaskCreator create() => TaskCreator();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$taskCreatorHash() => r'e0ce68cde807038c5fef1c5fc54eef3fcdfbc8e8';

/// Creates tasks from a quick-add line and refreshes every listing, so the
/// new task shows wherever the server sorts it. It holds itself alive while
/// a line is in flight, since the sheet that calls it may outlive every
/// listing watching the project.

abstract class _$TaskCreator extends $Notifier<void> {
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

/// One task, by reference: the cached copy at once, then the server's, and
/// again whenever it or anything on it changes.

@ProviderFor(TaskDetail)
final taskDetailProvider = TaskDetailFamily._();

/// One task, by reference: the cached copy at once, then the server's, and
/// again whenever it or anything on it changes.
final class TaskDetailProvider
    extends $AsyncNotifierProvider<TaskDetail, Task> {
  /// One task, by reference: the cached copy at once, then the server's, and
  /// again whenever it or anything on it changes.
  TaskDetailProvider._({
    required TaskDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'taskDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$taskDetailHash();

  @override
  String toString() {
    return r'taskDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TaskDetail create() => TaskDetail();

  @override
  bool operator ==(Object other) {
    return other is TaskDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$taskDetailHash() => r'b6612dadac58a1ebe08443208dfc9edaf9d6a363';

/// One task, by reference: the cached copy at once, then the server's, and
/// again whenever it or anything on it changes.

final class TaskDetailFamily extends $Family
    with
        $ClassFamilyOverride<
          TaskDetail,
          AsyncValue<Task>,
          Task,
          FutureOr<Task>,
          String
        > {
  TaskDetailFamily._()
    : super(
        retry: null,
        name: r'taskDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One task, by reference: the cached copy at once, then the server's, and
  /// again whenever it or anything on it changes.

  TaskDetailProvider call(String taskRef) =>
      TaskDetailProvider._(argument: taskRef, from: this);

  @override
  String toString() => r'taskDetailProvider';
}

/// One task, by reference: the cached copy at once, then the server's, and
/// again whenever it or anything on it changes.

abstract class _$TaskDetail extends $AsyncNotifier<Task> {
  late final _$args = ref.$arg as String;
  String get taskRef => _$args;

  FutureOr<Task> build(String taskRef);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Task>, Task>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Task>, Task>,
              AsyncValue<Task>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// One actor, by id.

@ProviderFor(actor)
final actorProvider = ActorFamily._();

/// One actor, by id.

final class ActorProvider
    extends $FunctionalProvider<AsyncValue<Actor>, Actor, FutureOr<Actor>>
    with $FutureModifier<Actor>, $FutureProvider<Actor> {
  /// One actor, by id.
  ActorProvider._({
    required ActorFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'actorProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$actorHash();

  @override
  String toString() {
    return r'actorProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Actor> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Actor> create(Ref ref) {
    final argument = this.argument as String;
    return actor(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ActorProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$actorHash() => r'499ab7f74f10d9bb1e2882045d0a88aec6d49736';

/// One actor, by id.

final class ActorFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Actor>, String> {
  ActorFamily._()
    : super(
        retry: null,
        name: r'actorProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One actor, by id.

  ActorProvider call(String id) => ActorProvider._(argument: id, from: this);

  @override
  String toString() => r'actorProvider';
}
