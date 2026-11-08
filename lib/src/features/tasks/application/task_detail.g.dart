// GENERATED CODE - DO NOT MODIFY BY HAND

// SPDX-License-Identifier: AGPL-3.0-or-later

part of 'task_detail.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One task, as the task screen edits it.
///
/// Changes show at once ([begin]) and are sent one after another
/// ([commit]), each against the server's last answer, so a version-checked
/// write never races the change before it. A refused change disappears and
/// the task is drawn as the server last had it, with the changes still in
/// flight on top.

@ProviderFor(TaskDetailController)
final taskDetailControllerProvider = TaskDetailControllerFamily._();

/// One task, as the task screen edits it.
///
/// Changes show at once ([begin]) and are sent one after another
/// ([commit]), each against the server's last answer, so a version-checked
/// write never races the change before it. A refused change disappears and
/// the task is drawn as the server last had it, with the changes still in
/// flight on top.
final class TaskDetailControllerProvider
    extends $AsyncNotifierProvider<TaskDetailController, Task> {
  /// One task, as the task screen edits it.
  ///
  /// Changes show at once ([begin]) and are sent one after another
  /// ([commit]), each against the server's last answer, so a version-checked
  /// write never races the change before it. A refused change disappears and
  /// the task is drawn as the server last had it, with the changes still in
  /// flight on top.
  TaskDetailControllerProvider._({
    required TaskDetailControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'taskDetailControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$taskDetailControllerHash();

  @override
  String toString() {
    return r'taskDetailControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TaskDetailController create() => TaskDetailController();

  @override
  bool operator ==(Object other) {
    return other is TaskDetailControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$taskDetailControllerHash() =>
    r'45adc8d8ed4b84570420a60a84dd57af903e5df4';

/// One task, as the task screen edits it.
///
/// Changes show at once ([begin]) and are sent one after another
/// ([commit]), each against the server's last answer, so a version-checked
/// write never races the change before it. A refused change disappears and
/// the task is drawn as the server last had it, with the changes still in
/// flight on top.

final class TaskDetailControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          TaskDetailController,
          AsyncValue<Task>,
          Task,
          FutureOr<Task>,
          String
        > {
  TaskDetailControllerFamily._()
    : super(
        retry: null,
        name: r'taskDetailControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One task, as the task screen edits it.
  ///
  /// Changes show at once ([begin]) and are sent one after another
  /// ([commit]), each against the server's last answer, so a version-checked
  /// write never races the change before it. A refused change disappears and
  /// the task is drawn as the server last had it, with the changes still in
  /// flight on top.

  TaskDetailControllerProvider call(String taskRef) =>
      TaskDetailControllerProvider._(argument: taskRef, from: this);

  @override
  String toString() => r'taskDetailControllerProvider';
}

/// One task, as the task screen edits it.
///
/// Changes show at once ([begin]) and are sent one after another
/// ([commit]), each against the server's last answer, so a version-checked
/// write never races the change before it. A refused change disappears and
/// the task is drawn as the server last had it, with the changes still in
/// flight on top.

abstract class _$TaskDetailController extends $AsyncNotifier<Task> {
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

/// A task's comments, oldest first.

@ProviderFor(TaskComments)
final taskCommentsProvider = TaskCommentsFamily._();

/// A task's comments, oldest first.
final class TaskCommentsProvider
    extends $AsyncNotifierProvider<TaskComments, List<Comment>> {
  /// A task's comments, oldest first.
  TaskCommentsProvider._({
    required TaskCommentsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'taskCommentsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$taskCommentsHash();

  @override
  String toString() {
    return r'taskCommentsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TaskComments create() => TaskComments();

  @override
  bool operator ==(Object other) {
    return other is TaskCommentsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$taskCommentsHash() => r'a99c619ff6dc116721d895ab4082c31c304522f9';

/// A task's comments, oldest first.

final class TaskCommentsFamily extends $Family
    with
        $ClassFamilyOverride<
          TaskComments,
          AsyncValue<List<Comment>>,
          List<Comment>,
          FutureOr<List<Comment>>,
          String
        > {
  TaskCommentsFamily._()
    : super(
        retry: null,
        name: r'taskCommentsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A task's comments, oldest first.

  TaskCommentsProvider call(String taskRef) =>
      TaskCommentsProvider._(argument: taskRef, from: this);

  @override
  String toString() => r'taskCommentsProvider';
}

/// A task's comments, oldest first.

abstract class _$TaskComments extends $AsyncNotifier<List<Comment>> {
  late final _$args = ref.$arg as String;
  String get taskRef => _$args;

  FutureOr<List<Comment>> build(String taskRef);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Comment>>, List<Comment>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Comment>>, List<Comment>>,
              AsyncValue<List<Comment>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// The tasks a task waits for, each read in full.

@ProviderFor(TaskDependencies)
final taskDependenciesProvider = TaskDependenciesFamily._();

/// The tasks a task waits for, each read in full.
final class TaskDependenciesProvider
    extends $AsyncNotifierProvider<TaskDependencies, List<Task>> {
  /// The tasks a task waits for, each read in full.
  TaskDependenciesProvider._({
    required TaskDependenciesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'taskDependenciesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$taskDependenciesHash();

  @override
  String toString() {
    return r'taskDependenciesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TaskDependencies create() => TaskDependencies();

  @override
  bool operator ==(Object other) {
    return other is TaskDependenciesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$taskDependenciesHash() => r'bcc949ce9e178dbf5df9497edad9380353cdd45a';

/// The tasks a task waits for, each read in full.

final class TaskDependenciesFamily extends $Family
    with
        $ClassFamilyOverride<
          TaskDependencies,
          AsyncValue<List<Task>>,
          List<Task>,
          FutureOr<List<Task>>,
          String
        > {
  TaskDependenciesFamily._()
    : super(
        retry: null,
        name: r'taskDependenciesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The tasks a task waits for, each read in full.

  TaskDependenciesProvider call(String taskRef) =>
      TaskDependenciesProvider._(argument: taskRef, from: this);

  @override
  String toString() => r'taskDependenciesProvider';
}

/// The tasks a task waits for, each read in full.

abstract class _$TaskDependencies extends $AsyncNotifier<List<Task>> {
  late final _$args = ref.$arg as String;
  String get taskRef => _$args;

  FutureOr<List<Task>> build(String taskRef);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Task>>, List<Task>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Task>>, List<Task>>,
              AsyncValue<List<Task>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// A task's direct subtasks.

@ProviderFor(TaskSubtasks)
final taskSubtasksProvider = TaskSubtasksFamily._();

/// A task's direct subtasks.
final class TaskSubtasksProvider
    extends $AsyncNotifierProvider<TaskSubtasks, List<Task>> {
  /// A task's direct subtasks.
  TaskSubtasksProvider._({
    required TaskSubtasksFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'taskSubtasksProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$taskSubtasksHash();

  @override
  String toString() {
    return r'taskSubtasksProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TaskSubtasks create() => TaskSubtasks();

  @override
  bool operator ==(Object other) {
    return other is TaskSubtasksProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$taskSubtasksHash() => r'3cb0974df4c3ea98b0913867bde920f9a3e26d50';

/// A task's direct subtasks.

final class TaskSubtasksFamily extends $Family
    with
        $ClassFamilyOverride<
          TaskSubtasks,
          AsyncValue<List<Task>>,
          List<Task>,
          FutureOr<List<Task>>,
          String
        > {
  TaskSubtasksFamily._()
    : super(
        retry: null,
        name: r'taskSubtasksProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A task's direct subtasks.

  TaskSubtasksProvider call(String taskRef) =>
      TaskSubtasksProvider._(argument: taskRef, from: this);

  @override
  String toString() => r'taskSubtasksProvider';
}

/// A task's direct subtasks.

abstract class _$TaskSubtasks extends $AsyncNotifier<List<Task>> {
  late final _$args = ref.$arg as String;
  String get taskRef => _$args;

  FutureOr<List<Task>> build(String taskRef);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Task>>, List<Task>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Task>>, List<Task>>,
              AsyncValue<List<Task>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// A task's artifacts, oldest first.

@ProviderFor(TaskArtifacts)
final taskArtifactsProvider = TaskArtifactsFamily._();

/// A task's artifacts, oldest first.
final class TaskArtifactsProvider
    extends $AsyncNotifierProvider<TaskArtifacts, List<Artifact>> {
  /// A task's artifacts, oldest first.
  TaskArtifactsProvider._({
    required TaskArtifactsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'taskArtifactsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$taskArtifactsHash();

  @override
  String toString() {
    return r'taskArtifactsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TaskArtifacts create() => TaskArtifacts();

  @override
  bool operator ==(Object other) {
    return other is TaskArtifactsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$taskArtifactsHash() => r'0c4f50c028df17b0cec84923c48b25d1a3f6b297';

/// A task's artifacts, oldest first.

final class TaskArtifactsFamily extends $Family
    with
        $ClassFamilyOverride<
          TaskArtifacts,
          AsyncValue<List<Artifact>>,
          List<Artifact>,
          FutureOr<List<Artifact>>,
          String
        > {
  TaskArtifactsFamily._()
    : super(
        retry: null,
        name: r'taskArtifactsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A task's artifacts, oldest first.

  TaskArtifactsProvider call(String taskRef) =>
      TaskArtifactsProvider._(argument: taskRef, from: this);

  @override
  String toString() => r'taskArtifactsProvider';
}

/// A task's artifacts, oldest first.

abstract class _$TaskArtifacts extends $AsyncNotifier<List<Artifact>> {
  late final _$args = ref.$arg as String;
  String get taskRef => _$args;

  FutureOr<List<Artifact>> build(String taskRef);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Artifact>>, List<Artifact>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Artifact>>, List<Artifact>>,
              AsyncValue<List<Artifact>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// A task's history, newest first, a page at a time.

@ProviderFor(TaskHistory)
final taskHistoryProvider = TaskHistoryFamily._();

/// A task's history, newest first, a page at a time.
final class TaskHistoryProvider
    extends $AsyncNotifierProvider<TaskHistory, Paged<AuditEntry>> {
  /// A task's history, newest first, a page at a time.
  TaskHistoryProvider._({
    required TaskHistoryFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'taskHistoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$taskHistoryHash();

  @override
  String toString() {
    return r'taskHistoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TaskHistory create() => TaskHistory();

  @override
  bool operator ==(Object other) {
    return other is TaskHistoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$taskHistoryHash() => r'98fae7c4af54576738f58566f5f5cc98068ba731';

/// A task's history, newest first, a page at a time.

final class TaskHistoryFamily extends $Family
    with
        $ClassFamilyOverride<
          TaskHistory,
          AsyncValue<Paged<AuditEntry>>,
          Paged<AuditEntry>,
          FutureOr<Paged<AuditEntry>>,
          String
        > {
  TaskHistoryFamily._()
    : super(
        retry: null,
        name: r'taskHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A task's history, newest first, a page at a time.

  TaskHistoryProvider call(String taskRef) =>
      TaskHistoryProvider._(argument: taskRef, from: this);

  @override
  String toString() => r'taskHistoryProvider';
}

/// A task's history, newest first, a page at a time.

abstract class _$TaskHistory extends $AsyncNotifier<Paged<AuditEntry>> {
  late final _$args = ref.$arg as String;
  String get taskRef => _$args;

  FutureOr<Paged<AuditEntry>> build(String taskRef);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<Paged<AuditEntry>>, Paged<AuditEntry>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Paged<AuditEntry>>, Paged<AuditEntry>>,
              AsyncValue<Paged<AuditEntry>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// One task by id or reference, read once: a parent, a copy's original.

@ProviderFor(relatedTask)
final relatedTaskProvider = RelatedTaskFamily._();

/// One task by id or reference, read once: a parent, a copy's original.

final class RelatedTaskProvider
    extends $FunctionalProvider<AsyncValue<Task>, Task, FutureOr<Task>>
    with $FutureModifier<Task>, $FutureProvider<Task> {
  /// One task by id or reference, read once: a parent, a copy's original.
  RelatedTaskProvider._({
    required RelatedTaskFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'relatedTaskProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$relatedTaskHash();

  @override
  String toString() {
    return r'relatedTaskProvider'
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
    return relatedTask(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RelatedTaskProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$relatedTaskHash() => r'0246394fc5b2e6c5a251b678b78e536f573bc93a';

/// One task by id or reference, read once: a parent, a copy's original.

final class RelatedTaskFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Task>, String> {
  RelatedTaskFamily._()
    : super(
        retry: null,
        name: r'relatedTaskProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One task by id or reference, read once: a parent, a copy's original.

  RelatedTaskProvider call(String id) =>
      RelatedTaskProvider._(argument: id, from: this);

  @override
  String toString() => r'relatedTaskProvider';
}

/// One project by id or key.

@ProviderFor(projectById)
final projectByIdProvider = ProjectByIdFamily._();

/// One project by id or key.

final class ProjectByIdProvider
    extends $FunctionalProvider<AsyncValue<Project>, Project, FutureOr<Project>>
    with $FutureModifier<Project>, $FutureProvider<Project> {
  /// One project by id or key.
  ProjectByIdProvider._({
    required ProjectByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'projectByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$projectByIdHash();

  @override
  String toString() {
    return r'projectByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Project> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Project> create(Ref ref) {
    final argument = this.argument as String;
    return projectById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProjectByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$projectByIdHash() => r'5e1f213fc0f92bb2d2253b63ab6b20d0a5c0675b';

/// One project by id or key.

final class ProjectByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Project>, String> {
  ProjectByIdFamily._()
    : super(
        retry: null,
        name: r'projectByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One project by id or key.

  ProjectByIdProvider call(String id) =>
      ProjectByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'projectByIdProvider';
}

/// The custom fields of a project, by id or key.

@ProviderFor(ProjectFields)
final projectFieldsProvider = ProjectFieldsFamily._();

/// The custom fields of a project, by id or key.
final class ProjectFieldsProvider
    extends $AsyncNotifierProvider<ProjectFields, List<FieldDef>> {
  /// The custom fields of a project, by id or key.
  ProjectFieldsProvider._({
    required ProjectFieldsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'projectFieldsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$projectFieldsHash();

  @override
  String toString() {
    return r'projectFieldsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ProjectFields create() => ProjectFields();

  @override
  bool operator ==(Object other) {
    return other is ProjectFieldsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$projectFieldsHash() => r'5db3d5ba7a3a89d4ee70dea45e7450b7a5e5a975';

/// The custom fields of a project, by id or key.

final class ProjectFieldsFamily extends $Family
    with
        $ClassFamilyOverride<
          ProjectFields,
          AsyncValue<List<FieldDef>>,
          List<FieldDef>,
          FutureOr<List<FieldDef>>,
          String
        > {
  ProjectFieldsFamily._()
    : super(
        retry: null,
        name: r'projectFieldsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The custom fields of a project, by id or key.

  ProjectFieldsProvider call(String project) =>
      ProjectFieldsProvider._(argument: project, from: this);

  @override
  String toString() => r'projectFieldsProvider';
}

/// The custom fields of a project, by id or key.

abstract class _$ProjectFields extends $AsyncNotifier<List<FieldDef>> {
  late final _$args = ref.$arg as String;
  String get project => _$args;

  FutureOr<List<FieldDef>> build(String project);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<FieldDef>>, List<FieldDef>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<FieldDef>>, List<FieldDef>>,
              AsyncValue<List<FieldDef>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// The workflow a project follows, by the project's id or key.

@ProviderFor(projectWorkflow)
final projectWorkflowProvider = ProjectWorkflowFamily._();

/// The workflow a project follows, by the project's id or key.

final class ProjectWorkflowProvider
    extends
        $FunctionalProvider<AsyncValue<Workflow>, Workflow, FutureOr<Workflow>>
    with $FutureModifier<Workflow>, $FutureProvider<Workflow> {
  /// The workflow a project follows, by the project's id or key.
  ProjectWorkflowProvider._({
    required ProjectWorkflowFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'projectWorkflowProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$projectWorkflowHash();

  @override
  String toString() {
    return r'projectWorkflowProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Workflow> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Workflow> create(Ref ref) {
    final argument = this.argument as String;
    return projectWorkflow(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProjectWorkflowProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$projectWorkflowHash() => r'2f3e83c62c7ae370a5c7ce0caceda44b7fc217e1';

/// The workflow a project follows, by the project's id or key.

final class ProjectWorkflowFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Workflow>, String> {
  ProjectWorkflowFamily._()
    : super(
        retry: null,
        name: r'projectWorkflowProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The workflow a project follows, by the project's id or key.

  ProjectWorkflowProvider call(String project) =>
      ProjectWorkflowProvider._(argument: project, from: this);

  @override
  String toString() => r'projectWorkflowProvider';
}

/// Every actor in the tenant, for pickers and `@` completion.

@ProviderFor(actorDirectory)
final actorDirectoryProvider = ActorDirectoryProvider._();

/// Every actor in the tenant, for pickers and `@` completion.

final class ActorDirectoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Actor>>,
          List<Actor>,
          FutureOr<List<Actor>>
        >
    with $FutureModifier<List<Actor>>, $FutureProvider<List<Actor>> {
  /// Every actor in the tenant, for pickers and `@` completion.
  ActorDirectoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'actorDirectoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$actorDirectoryHash();

  @$internal
  @override
  $FutureProviderElement<List<Actor>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Actor>> create(Ref ref) {
    return actorDirectory(ref);
  }
}

String _$actorDirectoryHash() => r'83f116ad890fca585b9c3c9d11d12eacb906ff0d';

/// Every tag in the tenant.

@ProviderFor(tagDirectory)
final tagDirectoryProvider = TagDirectoryProvider._();

/// Every tag in the tenant.

final class TagDirectoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Tag>>,
          List<Tag>,
          FutureOr<List<Tag>>
        >
    with $FutureModifier<List<Tag>>, $FutureProvider<List<Tag>> {
  /// Every tag in the tenant.
  TagDirectoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tagDirectoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tagDirectoryHash();

  @$internal
  @override
  $FutureProviderElement<List<Tag>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Tag>> create(Ref ref) {
    return tagDirectory(ref);
  }
}

String _$tagDirectoryHash() => r'ff34c8ae93abc52f8de19ed6f8641e3e67ccc380';

/// Whether the tenant keeps a trash.

@ProviderFor(trashStatus)
final trashStatusProvider = TrashStatusProvider._();

/// Whether the tenant keeps a trash.

final class TrashStatusProvider
    extends
        $FunctionalProvider<
          AsyncValue<TrashStatus>,
          TrashStatus,
          FutureOr<TrashStatus>
        >
    with $FutureModifier<TrashStatus>, $FutureProvider<TrashStatus> {
  /// Whether the tenant keeps a trash.
  TrashStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trashStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trashStatusHash();

  @$internal
  @override
  $FutureProviderElement<TrashStatus> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TrashStatus> create(Ref ref) {
    return trashStatus(ref);
  }
}

String _$trashStatusHash() => r'ca8a9fcb3baa4730877a7a63011c4c28842f6577';

/// Every project, for choosing where a copy goes.

@ProviderFor(copyTargets)
final copyTargetsProvider = CopyTargetsProvider._();

/// Every project, for choosing where a copy goes.

final class CopyTargetsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Project>>,
          List<Project>,
          FutureOr<List<Project>>
        >
    with $FutureModifier<List<Project>>, $FutureProvider<List<Project>> {
  /// Every project, for choosing where a copy goes.
  CopyTargetsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'copyTargetsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$copyTargetsHash();

  @$internal
  @override
  $FutureProviderElement<List<Project>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Project>> create(Ref ref) {
    return copyTargets(ref);
  }
}

String _$copyTargetsHash() => r'31c1c87ee6fb248dc08df53fef30dd005ed5f23c';
