// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'tasks.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The tasks of one project, most urgent first, a page at a time.

@ProviderFor(ProjectTasks)
final projectTasksProvider = ProjectTasksFamily._();

/// The tasks of one project, most urgent first, a page at a time.
final class ProjectTasksProvider
    extends $AsyncNotifierProvider<ProjectTasks, Paged<Task>> {
  /// The tasks of one project, most urgent first, a page at a time.
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

String _$projectTasksHash() => r'fa2a3762472c0c30c31813e7c217b488c6058082';

/// The tasks of one project, most urgent first, a page at a time.

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

  /// The tasks of one project, most urgent first, a page at a time.

  ProjectTasksProvider call(String projectKey) =>
      ProjectTasksProvider._(argument: projectKey, from: this);

  @override
  String toString() => r'projectTasksProvider';
}

/// The tasks of one project, most urgent first, a page at a time.

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

/// One task, by reference.

@ProviderFor(taskDetail)
final taskDetailProvider = TaskDetailFamily._();

/// One task, by reference.

final class TaskDetailProvider
    extends $FunctionalProvider<AsyncValue<Task>, Task, FutureOr<Task>>
    with $FutureModifier<Task>, $FutureProvider<Task> {
  /// One task, by reference.
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
  $FutureProviderElement<Task> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Task> create(Ref ref) {
    final argument = this.argument as String;
    return taskDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TaskDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$taskDetailHash() => r'0dcc9cf686e1fd54e02d495c239b0842cd4aa1ee';

/// One task, by reference.

final class TaskDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Task>, String> {
  TaskDetailFamily._()
    : super(
        retry: null,
        name: r'taskDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One task, by reference.

  TaskDetailProvider call(String taskRef) =>
      TaskDetailProvider._(argument: taskRef, from: this);

  @override
  String toString() => r'taskDetailProvider';
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
