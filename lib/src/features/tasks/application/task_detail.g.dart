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
    r'e50ae27ef636e59ba509c69a1f5cd1d91912be03';

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

String _$taskCommentsHash() => r'b4be638ebe0e5420c633d881a16c7de14548c836';

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

/// Whether the server takes comment reactions: true until a reaction meets
/// a missing route, as on a tix older than reactions.

@ProviderFor(ReactionSupport)
final reactionSupportProvider = ReactionSupportProvider._();

/// Whether the server takes comment reactions: true until a reaction meets
/// a missing route, as on a tix older than reactions.
final class ReactionSupportProvider
    extends $NotifierProvider<ReactionSupport, bool> {
  /// Whether the server takes comment reactions: true until a reaction meets
  /// a missing route, as on a tix older than reactions.
  ReactionSupportProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reactionSupportProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reactionSupportHash();

  @$internal
  @override
  ReactionSupport create() => ReactionSupport();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$reactionSupportHash() => r'be6ce02349fa72cdb2329379b32e2afa541895ab';

/// Whether the server takes comment reactions: true until a reaction meets
/// a missing route, as on a tix older than reactions.

abstract class _$ReactionSupport extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The channel each comment on a task came through, by comment id, from
/// the task's `comment.add` audit entries. Empty when the audit log is out
/// of reach, so comments still show without it.

@ProviderFor(TaskCommentChannels)
final taskCommentChannelsProvider = TaskCommentChannelsFamily._();

/// The channel each comment on a task came through, by comment id, from
/// the task's `comment.add` audit entries. Empty when the audit log is out
/// of reach, so comments still show without it.
final class TaskCommentChannelsProvider
    extends $AsyncNotifierProvider<TaskCommentChannels, Map<String, Via>> {
  /// The channel each comment on a task came through, by comment id, from
  /// the task's `comment.add` audit entries. Empty when the audit log is out
  /// of reach, so comments still show without it.
  TaskCommentChannelsProvider._({
    required TaskCommentChannelsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'taskCommentChannelsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$taskCommentChannelsHash();

  @override
  String toString() {
    return r'taskCommentChannelsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TaskCommentChannels create() => TaskCommentChannels();

  @override
  bool operator ==(Object other) {
    return other is TaskCommentChannelsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$taskCommentChannelsHash() =>
    r'2cb62133503d002437383e79722b307885a0b206';

/// The channel each comment on a task came through, by comment id, from
/// the task's `comment.add` audit entries. Empty when the audit log is out
/// of reach, so comments still show without it.

final class TaskCommentChannelsFamily extends $Family
    with
        $ClassFamilyOverride<
          TaskCommentChannels,
          AsyncValue<Map<String, Via>>,
          Map<String, Via>,
          FutureOr<Map<String, Via>>,
          String
        > {
  TaskCommentChannelsFamily._()
    : super(
        retry: null,
        name: r'taskCommentChannelsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The channel each comment on a task came through, by comment id, from
  /// the task's `comment.add` audit entries. Empty when the audit log is out
  /// of reach, so comments still show without it.

  TaskCommentChannelsProvider call(String taskRef) =>
      TaskCommentChannelsProvider._(argument: taskRef, from: this);

  @override
  String toString() => r'taskCommentChannelsProvider';
}

/// The channel each comment on a task came through, by comment id, from
/// the task's `comment.add` audit entries. Empty when the audit log is out
/// of reach, so comments still show without it.

abstract class _$TaskCommentChannels extends $AsyncNotifier<Map<String, Via>> {
  late final _$args = ref.$arg as String;
  String get taskRef => _$args;

  FutureOr<Map<String, Via>> build(String taskRef);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<Map<String, Via>>, Map<String, Via>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Map<String, Via>>, Map<String, Via>>,
              AsyncValue<Map<String, Via>>,
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

String _$taskDependenciesHash() => r'66e73eb0e529c05abc2b65a8b59d85ed386b2bdb';

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

String _$taskSubtasksHash() => r'e7f9dd7bf38b12676cf6319cbefe6c019e614ccc';

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

String _$taskArtifactsHash() => r'9f69c9f4f354fafea3306026b87911b62cca5365';

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

String _$taskHistoryHash() => r'69f9992e0d2ec88ffd297f6dc4abd308bebd3ddb';

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

/// The lease a claim on [taskRef] that names no length would get now, and
/// the levels that decide it. Read again whenever the task's claim begins
/// or ends.

@ProviderFor(taskLease)
final taskLeaseProvider = TaskLeaseFamily._();

/// The lease a claim on [taskRef] that names no length would get now, and
/// the levels that decide it. Read again whenever the task's claim begins
/// or ends.

final class TaskLeaseProvider
    extends
        $FunctionalProvider<
          AsyncValue<LeaseGrant>,
          LeaseGrant,
          FutureOr<LeaseGrant>
        >
    with $FutureModifier<LeaseGrant>, $FutureProvider<LeaseGrant> {
  /// The lease a claim on [taskRef] that names no length would get now, and
  /// the levels that decide it. Read again whenever the task's claim begins
  /// or ends.
  TaskLeaseProvider._({
    required TaskLeaseFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'taskLeaseProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$taskLeaseHash();

  @override
  String toString() {
    return r'taskLeaseProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<LeaseGrant> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<LeaseGrant> create(Ref ref) {
    final argument = this.argument as String;
    return taskLease(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TaskLeaseProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$taskLeaseHash() => r'91a8775a7c5a299d765977e1bb6a94f853136846';

/// The lease a claim on [taskRef] that names no length would get now, and
/// the levels that decide it. Read again whenever the task's claim begins
/// or ends.

final class TaskLeaseFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<LeaseGrant>, String> {
  TaskLeaseFamily._()
    : super(
        retry: null,
        name: r'taskLeaseProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The lease a claim on [taskRef] that names no length would get now, and
  /// the levels that decide it. Read again whenever the task's claim begins
  /// or ends.

  TaskLeaseProvider call(String taskRef) =>
      TaskLeaseProvider._(argument: taskRef, from: this);

  @override
  String toString() => r'taskLeaseProvider';
}

/// The tags on [taskRef] as the server has them now, so a picker never
/// offers one somebody else has just added.

@ProviderFor(taskTags)
final taskTagsProvider = TaskTagsFamily._();

/// The tags on [taskRef] as the server has them now, so a picker never
/// offers one somebody else has just added.

final class TaskTagsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  /// The tags on [taskRef] as the server has them now, so a picker never
  /// offers one somebody else has just added.
  TaskTagsProvider._({
    required TaskTagsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'taskTagsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$taskTagsHash();

  @override
  String toString() {
    return r'taskTagsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    final argument = this.argument as String;
    return taskTags(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TaskTagsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$taskTagsHash() => r'7c78743d036a776b94fe67c3cb3346c6f44bca94';

/// The tags on [taskRef] as the server has them now, so a picker never
/// offers one somebody else has just added.

final class TaskTagsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<String>>, String> {
  TaskTagsFamily._()
    : super(
        retry: null,
        name: r'taskTagsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The tags on [taskRef] as the server has them now, so a picker never
  /// offers one somebody else has just added.

  TaskTagsProvider call(String taskRef) =>
      TaskTagsProvider._(argument: taskRef, from: this);

  @override
  String toString() => r'taskTagsProvider';
}

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
