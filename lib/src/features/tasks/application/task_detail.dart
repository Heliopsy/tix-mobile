// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/cache/cached.dart';
import 'package:tix_mobile/src/core/events/invalidation.dart';
import 'package:tix_mobile/src/core/markdown/checklist.dart';
import 'package:tix_mobile/src/core/paging/paged.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/events/tix_event.dart';
import 'package:tix_mobile/src/data/models/actor.dart';
import 'package:tix_mobile/src/data/models/project.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/data/repositories/task_detail_repository.dart';

export 'package:tix_mobile/src/data/repositories/task_detail_repository.dart';

part 'task_detail.g.dart';

/// Whether [e] is about the task [task]: the task itself or something on it.
bool _about(TixEvent e, Task task) =>
    e.subjectId == task.id ||
    e.subjectId == task.ref ||
    e.payload['task_id'] == task.id;

/// One change to a task: how it looks locally at once, and how it is sent.
class TaskChange {
  /// A change drawn with [apply] and sent with [send].
  TaskChange({required this.apply, required this.send});

  /// A change of the attributes [patch] names.
  factory TaskChange.patch(TaskPatch patch, {bool checkVersion = false}) =>
      TaskChange(
        apply: patch.applyTo,
        send: (repo, server) => repo.update(
          server.ref,
          patch,
          version: checkVersion ? server.version : null,
        ),
      );

  /// Ticks or clears checklist item [item] of the description.
  factory TaskChange.check(int item, {required bool done}) => TaskChange(
    apply: (t) => t.copyWith(body: setChecklistItem(t.body, item, done: done)),
    send: (repo, server) =>
        repo.check(server.ref, item, done: done, version: server.version),
  );

  /// Stars or unstars the task for the reader.
  factory TaskChange.star({required bool starred}) => TaskChange(
    apply: (t) => t.copyWith(starred: starred),
    send: (repo, server) async {
      await repo.setStar(server.ref, starred: starred);
      return null;
    },
  );

  /// Snoozes the task until [until], or wakes it when null.
  factory TaskChange.snooze(DateTime? until) => TaskChange(
    apply: (t) => t.copyWith(snoozedUntil: until),
    send: (repo, server) => repo.snooze(server.ref, until),
  );

  /// Draws the change on a task.
  final Task Function(Task) apply;

  /// Sends the change against the server's last answer; the task as the
  /// server now has it, or null when [apply] to the last answer is it.
  final Future<Task?> Function(TaskDetailRepository repo, Task server) send;
}

/// One task, as the task screen edits it.
///
/// Changes show at once ([begin]) and are sent one after another
/// ([commit]), each against the server's last answer, so a version-checked
/// write never races the change before it. A refused change disappears and
/// the task is drawn as the server last had it, with the changes still in
/// flight on top.
@riverpod
class TaskDetailController extends _$TaskDetailController {
  final _pending = <TaskChange>[];
  Future<void> _queue = Future.value();
  Task? _server;

  @override
  Future<Task> build(String taskRef) async {
    _pending.clear();
    final tasks = ref.watch(tasksRepositoryProvider);
    final task = await cachedFirst(
      ref: ref,
      cached: tasks.cachedTask(taskRef),
      fresh: () => tasks.task(taskRef),
      onFresh: accept,
    );
    if (ref.mounted) {
      refreshOn(ref, EventTopics.tasks, where: (e) => _about(e, task));
    }
    _server = task;
    return task;
  }

  TaskDetailRepository get _repo => ref.read(taskDetailRepositoryProvider);

  void _show() {
    final server = _server;
    if (server == null) return;
    state = AsyncData(_pending.fold(server, (t, c) => c.apply(t)));
  }

  /// Takes [task] as the server's latest answer.
  void accept(Task task) {
    _server = task;
    _show();
  }

  /// Draws [change] at once, before it is sent.
  void begin(TaskChange change) {
    _pending.add(change);
    _show();
  }

  /// Takes back [change] before it is sent.
  void drop(TaskChange change) {
    _pending.remove(change);
    _show();
  }

  /// Sends [change] once the changes before it are done. On failure the
  /// change is dropped and the error rethrown.
  Future<void> commit(TaskChange change) => _serial(() async {
    try {
      final server = _server!;
      final answer = await change.send(_repo, server);
      _server = answer ?? change.apply(server);
    } finally {
      _pending.remove(change);
      _show();
    }
  });

  /// Draws and sends [change] in one step.
  Future<void> change(TaskChange change) {
    begin(change);
    return commit(change);
  }

  /// Moves the task to [to] by the workflow's route, drawing the new status
  /// at once; the answer says where it stopped if it did not arrive.
  Future<RouteResult> move(String to, {String? comment}) {
    final local = TaskChange(
      apply: (t) => t.copyWith(status: to),
      send: (_, _) async => null,
    );
    begin(local);
    return _serial(() async {
      try {
        final result = await _repo.move(taskRef, to, comment: comment);
        _server = result.task ?? _server;
        return result;
      } finally {
        _pending.remove(local);
        _show();
      }
    });
  }

  /// Deletes the task: to the trash, or for good when [hard].
  Future<void> delete({bool hard = false, bool cascade = false}) =>
      _serial(() => _repo.delete(taskRef, hard: hard, cascade: cascade));

  /// Brings the task back from the trash.
  Future<void> restore() => _serial(() async {
    accept(await _repo.restore(taskRef));
  });

  /// Copies the task as [request] says and returns the copy.
  Future<Task> copy(CopyTaskInput request) => _repo.copy(taskRef, request);

  /// Reloads the task from the server, dropping nothing in flight.
  Future<void> reload() async {
    accept(await _repo.task(taskRef));
  }

  Future<T> _serial<T>(Future<T> Function() run) {
    final next = _queue.then((_) => run());
    _queue = next.then<void>((_) {}, onError: (Object _) {});
    return next;
  }
}

/// A task's comments, oldest first.
@riverpod
class TaskComments extends _$TaskComments {
  @override
  Future<List<Comment>> build(String taskRef) async {
    final repo = ref.watch(taskDetailRepositoryProvider);
    final comments = await cachedFirst(
      ref: ref,
      cached: repo.cachedComments(taskRef),
      fresh: () => repo.comments(taskRef),
      onFresh: (v) => state = AsyncData(v),
    );
    final task = ref.read(taskDetailControllerProvider(taskRef)).value;
    if (ref.mounted && task != null) {
      refreshOn(ref, EventTopics.comments, where: (e) => _about(e, task));
    }
    return comments;
  }

  TaskDetailRepository get _repo => ref.read(taskDetailRepositoryProvider);

  List<Comment> get _now => state.value ?? const [];

  /// Adds a comment saying [body].
  Future<Comment> add(String body) async {
    final c = await _repo.addComment(taskRef, body);
    state = AsyncData([..._now, c]);
    return c;
  }

  /// Rewrites the comment [id] to [body].
  Future<void> edit(String id, String body) async {
    final c = await _repo.editComment(id, body);
    state = AsyncData([
      for (final x in _now)
        if (x.id == id) c else x,
    ]);
  }

  /// Deletes the comment [id].
  Future<void> delete(String id) async {
    await _repo.deleteComment(id);
    state = AsyncData([
      for (final x in _now)
        if (x.id != id) x,
    ]);
  }
}

/// The tasks a task waits for, each read in full.
@riverpod
class TaskDependencies extends _$TaskDependencies {
  @override
  Future<List<Task>> build(String taskRef) async {
    final repo = ref.watch(taskDetailRepositoryProvider);
    final task = ref.read(taskDetailControllerProvider(taskRef)).value;
    if (task != null) {
      refreshOn(ref, EventTopics.dependencies, where: (e) => _about(e, task));
    }
    final edges = await repo.dependencies(taskRef);
    return await Future.wait([
      for (final e in edges)
        repo
            .task(e.dependsOn)
            .catchError((Object _) => Task(id: e.dependsOn, ref: e.dependsOn)),
    ]);
  }

  TaskDetailRepository get _repo => ref.read(taskDetailRepositoryProvider);

  /// Records that the task waits for [dependsOn], a reference.
  Future<void> add(String dependsOn) async {
    await _repo.addDependency(taskRef, dependsOn);
    final task = await _repo.task(dependsOn);
    state = AsyncData([...?state.value, task]);
    ref.invalidate(taskDetailControllerProvider(taskRef));
  }

  /// Removes the dependency on [task].
  Future<void> remove(Task task) async {
    await _repo.removeDependency(taskRef, task.id);
    state = AsyncData([
      for (final t in state.value ?? const <Task>[])
        if (t.id != task.id) t,
    ]);
    ref.invalidate(taskDetailControllerProvider(taskRef));
  }
}

/// A task's direct subtasks.
@riverpod
class TaskSubtasks extends _$TaskSubtasks {
  @override
  Future<List<Task>> build(String taskRef) async {
    final repo = ref.watch(taskDetailRepositoryProvider);
    final subtasks = await cachedFirst(
      ref: ref,
      cached: repo.cachedSubtasks(taskRef),
      fresh: () => repo.subtasks(taskRef),
      onFresh: (v) => state = AsyncData(v),
    );
    if (ref.mounted) refreshOn(ref, EventTopics.tasks);
    return subtasks;
  }

  /// Creates a subtask titled [title] in [project].
  Future<Task> add(String project, String title) async {
    final task = await ref
        .read(taskDetailRepositoryProvider)
        .addSubtask(project, taskRef, title);
    state = AsyncData([...?state.value, task]);
    return task;
  }
}

/// A task's artifacts, oldest first.
@riverpod
class TaskArtifacts extends _$TaskArtifacts {
  @override
  Future<List<Artifact>> build(String taskRef) {
    final task = ref.read(taskDetailControllerProvider(taskRef)).value;
    if (task != null) {
      refreshOn(ref, EventTopics.artifacts, where: (e) => _about(e, task));
    }
    return ref.watch(taskDetailRepositoryProvider).artifacts(taskRef);
  }

  /// Attaches [input] to the task.
  Future<Artifact> attach(ArtifactInput input) async {
    final a = await ref
        .read(taskDetailRepositoryProvider)
        .attach(taskRef, input);
    state = AsyncData([...?state.value, a]);
    return a;
  }
}

/// A task's history, newest first, a page at a time.
@riverpod
class TaskHistory extends _$TaskHistory {
  @override
  Future<Paged<AuditEntry>> build(String taskRef) async {
    final page = await ref.watch(taskDetailRepositoryProvider).history(taskRef);
    return Paged(items: page.items, cursor: page.nextCursor);
  }

  /// Fetches the next page.
  Future<void> loadMore() => loadNextPage(
    current: state.value,
    fetch: (cursor) =>
        ref.read(taskDetailRepositoryProvider).history(taskRef, cursor: cursor),
    emit: (next) => state = AsyncData(next),
    idOf: (e) => e.seq,
  );
}

/// One task by id or reference, read once: a parent, a copy's original.
@riverpod
Future<Task> relatedTask(Ref ref, String id) =>
    ref.watch(taskDetailRepositoryProvider).task(id);

/// One project by id or key.
@riverpod
Future<Project> projectById(Ref ref, String id) =>
    ref.watch(taskDetailRepositoryProvider).project(id);

/// The custom fields of a project, by id or key.
@riverpod
class ProjectFields extends _$ProjectFields {
  @override
  Future<List<FieldDef>> build(String project) async {
    final repo = ref.watch(taskDetailRepositoryProvider);
    final fields = await cachedFirst(
      ref: ref,
      cached: repo.cachedFields(project),
      fresh: () => repo.fields(project),
      onFresh: (v) => state = AsyncData(v),
    );
    if (ref.mounted) refreshOn(ref, EventTopics.fields);
    return fields;
  }
}

/// The workflow a project follows, by the project's id or key.
@riverpod
Future<Workflow> projectWorkflow(Ref ref, String project) async {
  refreshOn(ref, EventTopics.workflows);
  final p = await ref.watch(projectByIdProvider(project).future);
  final repo = ref.watch(taskDetailRepositoryProvider);
  return await repo.cachedWorkflow(p.workflowId) ??
      await repo.workflow(p.workflowId);
}

/// Every actor in the tenant, for pickers and `@` completion.
@riverpod
Future<List<Actor>> actorDirectory(Ref ref) =>
    ref.watch(taskDetailRepositoryProvider).actors();

/// Every tag in the tenant.
@riverpod
Future<List<Tag>> tagDirectory(Ref ref) =>
    ref.watch(taskDetailRepositoryProvider).tags();

/// Whether the tenant keeps a trash.
@riverpod
Future<TrashStatus> trashStatus(Ref ref) =>
    ref.watch(taskDetailRepositoryProvider).trash();

/// Every project, for choosing where a copy goes.
@riverpod
Future<List<Project>> copyTargets(Ref ref) async {
  final repo = ref.watch(tasksRepositoryProvider);
  final all = <Project>[];
  String? cursor;
  do {
    final page = await repo.projects(cursor: cursor);
    all.addAll(page.items.where((p) => p.archivedAt == null));
    cursor = page.nextCursor;
  } while (cursor != null);
  return all;
}

/// A named moment a snooze can run to.
enum SnoozePreset {
  /// Three hours on, rounded up to the hour.
  laterToday,

  /// Nine tomorrow morning.
  tomorrow,

  /// Nine on the coming Monday.
  nextWeek;

  /// The moment this preset names, seen from [now] in local time, as tix's
  /// own presets count it.
  DateTime from(DateTime now) {
    final local = now.toLocal();
    DateTime morning(int days) =>
        DateTime(local.year, local.month, local.day + days, 9);
    switch (this) {
      case laterToday:
        final t = local.add(const Duration(hours: 3));
        if (t.minute == 0 && t.second == 0 && t.millisecond == 0) return t;
        return DateTime(t.year, t.month, t.day, t.hour + 1);
      case tomorrow:
        return morning(1);
      case nextWeek:
        final days = (DateTime.monday - local.weekday + 7) % 7;
        return morning(days == 0 ? 7 : days);
    }
  }
}

/// The project key of a task reference such as `infra-8`.
String projectKeyOf(String taskRef) {
  final at = taskRef.lastIndexOf('-');
  return at <= 0 ? taskRef : taskRef.substring(0, at);
}
