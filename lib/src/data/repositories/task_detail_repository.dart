// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:tix_mobile/src/core/config/config.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/markdown/checklist.dart';
import 'package:tix_mobile/src/data/api/gen/models.gen.dart'
    show ForceReclaimInput, MoveTaskInput, TaskMove;
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/cache/response_cache.dart';
import 'package:tix_mobile/src/data/models/actor.dart';
import 'package:tix_mobile/src/data/models/page.dart';
import 'package:tix_mobile/src/data/models/project.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/data/models/task_detail.dart';
import 'package:tix_mobile/src/data/models/task_patch.dart';
import 'package:tix_mobile/src/data/offline/outbox.dart';

export 'package:tix_mobile/src/data/api/gen/models.gen.dart' show TaskMove;
export 'package:tix_mobile/src/data/models/task_detail.dart';
export 'package:tix_mobile/src/data/models/task_patch.dart';

/// The server cannot move a task to another project: it predates that.
final class TaskMoveUnsupported implements Exception {
  /// Reports a server that answered [cause] to a move.
  const TaskMoveUnsupported(this.cause);

  /// The server's answer.
  final TixException cause;

  @override
  String toString() => 'the server cannot move tasks between projects ($cause)';
}

/// Everything the task screen reads and changes about one task.
///
/// The reads that open a section are kept in the response cache and have a
/// `cached…` twin, so the section draws at once from the last answer.
class TaskDetailRepository {
  /// Reads and writes through [_api], keeping copies in [_cache]. With
  /// `outbox`, writes the server cannot take now wait there and answer with
  /// how they will look.
  TaskDetailRepository(this._api, this._cache, {this._outbox});

  final TixApi _api;
  final ResponseCache _cache;
  final Outbox? _outbox;

  Future<T> _write<T>(
    OutboxOp op,
    String ref, {
    required Future<T> Function(String? key) send,
    required T Function(OutboxEntry entry) local,
    Task? base,
    Map<String, Object?> values = const {},
  }) {
    final outbox = _outbox;
    if (outbox == null) return send(null);
    return outbox.write(
      op: op,
      target: ref,
      base: base,
      values: values,
      online: send,
      local: local,
    );
  }

  Task _shown(String ref, Task? base) =>
      base ?? _outbox?.draft(ref) ?? Task(id: ref, ref: ref);

  static List<T> _list<T>(
    Object? json,
    T Function(Map<String, dynamic>) item,
  ) => [
    for (final e in json! as List<Object?>) item(e! as Map<String, dynamic>),
  ];

  static List<Map<String, Object?>> _encode<T>(
    List<T> items,
    Map<String, Object?> Function(T) toJson,
  ) => [for (final e in items) toJson(e)];

  /// The task [ref], by reference or id (`task.show`). A draft made offline
  /// answers from the outbox, and one already sent from its real task.
  Future<Task> task(String ref) {
    final real = _outbox?.realRef(ref) ?? ref;
    if (isDraftRef(real)) {
      final draft = _outbox?.draft(real);
      if (draft == null) throw const TixException(TixErrorKind.notFound);
      return Future.value(draft);
    }
    return _api.task.show(real).then((t) => _outbox?.overlay(t) ?? t);
  }

  /// Applies [patch] to [ref] (`task.update`). [base] is the task the
  /// person changed: an update the outbox keeps is merged against it.
  Future<Task> update(
    String ref,
    TaskPatch patch, {
    int? version,
    Task? base,
  }) => _write(
    OutboxOp.update,
    ref,
    base: base,
    values: patch.toJson(),
    send: (key) => _api.task.update(
      ref,
      patch.toInput(version: version),
      idempotencyKey: key,
    ),
    local: (_) => patch.applyTo(_shown(ref, base)),
  );

  /// Ticks or clears checklist item [item] (`task.check`).
  Future<Task> check(
    String ref,
    int item, {
    required bool done,
    int? version,
    Task? base,
  }) => _write(
    OutboxOp.check,
    ref,
    base: base,
    values: {'item': item, 'done': done},
    send: (key) => _api.task.check(
      ref,
      CheckItemInput(item: item, done: done, version: version),
      idempotencyKey: key,
    ),
    local: (_) {
      final t = _shown(ref, base);
      return t.copyWith(body: setChecklistItem(t.body, item, done: done));
    },
  );

  /// Moves [ref] to the state [to] by the workflow's route (`task.route`).
  Future<RouteResult> move(
    String ref,
    String to, {
    String? comment,
    Task? base,
  }) => _write(
    OutboxOp.move,
    ref,
    base: base,
    values: {'to': to, 'comment': ?comment},
    send: (key) => _api.task.route(
      ref,
      RouteInput(to: to, comment: comment),
      idempotencyKey: key,
    ),
    local: (_) => RouteResult(task: _shown(ref, base).copyWith(status: to)),
  );

  /// Moves [ref] one transition to [to] (`task.transition`). With
  /// [version], a task changed since that version is refused as a conflict.
  Future<Task> transition(
    String ref,
    String to, {
    String? comment,
    int? version,
  }) => _api.task.transition(
    ref,
    TransitionInput(
      to: to,
      comment: (comment ?? '').isEmpty ? null : comment,
      version: version,
    ),
  );

  /// The lease a claim on [ref] would get now, and the levels that decide
  /// it (`task.lease`).
  Future<LeaseGrant> lease(String ref) => _api.task.lease(ref);

  /// The tags on [ref] as the server has them now (`task.tags`).
  Future<List<String>> taskTags(String ref) async =>
      (await _api.task.tags(ref)).items;

  /// Stars or unstars [ref] for the reader (`task.star`, `task.unstar`).
  Future<void> setStar(String ref, {required bool starred}) => _write(
    starred ? OutboxOp.star : OutboxOp.unstar,
    ref,
    send: (key) => starred
        ? _api.task.star(ref, idempotencyKey: key)
        : _api.task.unstar(ref, idempotencyKey: key),
    local: (_) {},
  );

  /// Snoozes [ref] until [until] (`task.snooze`), or wakes it when null
  /// (`task.unsnooze`).
  Future<Task> snooze(String ref, DateTime? until, {Task? base}) => _write(
    OutboxOp.snooze,
    ref,
    base: base,
    values: {'until': ?until?.toUtc().toIso8601String()},
    send: (key) => until == null
        ? _api.task.unsnooze(ref, idempotencyKey: key)
        : _api.task.snooze(ref, SnoozeInput(until: until), idempotencyKey: key),
    local: (_) => _shown(ref, base).copyWith(snoozedUntil: until),
  );

  /// Copies [ref] (`task.copy`).
  Future<Task> copy(String ref, CopyTaskInput request) =>
      _api.task.copy(ref, body: request);

  /// Moves [ref] into the project [projectRef], by key or id, and answers
  /// what the move did (`task.move`). Throws [TaskMoveUnsupported] on a
  /// server without the route.
  Future<TaskMove> moveToProject(String ref, String projectRef) async {
    try {
      return await _api.task.move(ref, MoveTaskInput(projectRef: projectRef));
    } on TixException catch (e) {
      if (e.missingRoute) throw TaskMoveUnsupported(e);
      rethrow;
    }
  }

  /// Deletes [ref] (`task.delete`).
  Future<void> delete(String ref, {bool hard = false, bool cascade = false}) =>
      _api.task.delete(
        ref,
        hard: hard ? true : null,
        cascade: cascade ? true : null,
      );

  /// Ends the lease another actor holds on [ref] (`claim.reclaim`).
  Future<Task> reclaim(String ref, {String reason = ''}) => _api.claim.reclaim(
    ref,
    body: ForceReclaimInput(reason: reason.isEmpty ? null : reason),
  );

  /// Brings [ref] back from the trash (`task.restore`).
  Future<Task> restore(String ref) => _api.task.restore(ref);

  /// The direct subtasks of [ref] (`task.tree`, depth 1).
  Future<List<Task>> subtasks(String ref) => _cache.remember(
    'task/$ref/subtasks',
    _api.task.tree(ref, depth: 1).then((p) => p.items.skip(1).toList()),
    (v) => _encode(v, (t) => t.toJson()),
    decode: (j) => _list(j, Task.fromJson),
  );

  /// The subtasks of [ref] as last read.
  Future<List<Task>?> cachedSubtasks(String ref) =>
      _cache.peek('task/$ref/subtasks', (j) => _list(j, Task.fromJson));

  /// Creates a subtask of [parent] in [project] titled [title]
  /// (`task.create`).
  Future<Task> addSubtask(String project, String parent, String title) {
    final request = CreateTaskRequest(
      title: title,
      projectRef: project,
      parentRef: parent,
    );
    final outbox = _outbox;
    if (outbox == null) return _api.task.create(request);
    return outbox.create(
      request.toJson(),
      online: (key) => _api.task.create(request, idempotencyKey: key),
    );
  }

  /// One page of [ref]'s history, newest first (`task.audit`).
  Future<Page<AuditEntry>> history(String ref, {String? cursor}) =>
      _api.task.audit(ref, cursor: cursor, limit: pageSize, direction: 'desc');

  /// Puts the tag [name] on [ref] (`tag.add`).
  Future<void> addTag(String ref, String name) => _write(
    OutboxOp.tagAdd,
    ref,
    values: {'name': name},
    send: (key) =>
        _api.tag.add(ref, TagRequest(name: name), idempotencyKey: key),
    local: (_) {},
  );

  /// Takes the tag [name] off [ref] (`tag.remove`).
  Future<void> removeTag(String ref, String name) => _write(
    OutboxOp.tagRemove,
    ref,
    values: {'name': name},
    send: (key) => _api.tag.remove(ref, name, idempotencyKey: key),
    local: (_) {},
  );

  /// Every tag in the tenant (`tag.list`).
  Future<List<Tag>> tags() => _cache.remember(
    tagsKey,
    _api.tag.list().then((p) => p.items),
    (v) => _encode(v, (t) => t.toJson()),
    decode: (j) => _list(j, Tag.fromJson),
  );

  /// Where [tags] keeps its answer.
  static const tagsKey = 'tags';

  /// [ref]'s comments, oldest first (`comment.list`).
  Future<List<Comment>> comments(String ref) => _cache.remember(
    'task/$ref/comments',
    _api.comment.list(ref).then((p) => p.items),
    (v) => _encode(v, (c) => c.toJson()),
    decode: (j) => _list(j, Comment.fromJson),
  );

  /// [ref]'s comments as last read.
  Future<List<Comment>?> cachedComments(String ref) =>
      _cache.peek('task/$ref/comments', (j) => _list(j, Comment.fromJson));

  /// Adds a comment to [ref] (`comment.add`).
  Future<Comment> addComment(String ref, String body) => _write(
    OutboxOp.comment,
    ref,
    values: {'body': body},
    send: (key) =>
        _api.comment.add(ref, CommentRequest(body: body), idempotencyKey: key),
    local: (e) => Comment(id: e.id, body: body, createdAt: e.createdAt),
  );

  /// The comments on [ref] still waiting in the outbox, oldest first.
  List<Comment> queuedComments(String ref) => [
    for (final c in _outbox?.comments(ref) ?? const <QueuedComment>[])
      Comment(id: c.id, body: c.body, createdAt: c.at),
  ];

  /// The subtasks of [ref] created offline and not yet sent.
  List<Task> draftSubtasks(String ref) =>
      _outbox?.drafts(parent: _outbox.realRef(ref)) ?? const [];

  /// Rewrites the comment [id] (`comment.edit`).
  Future<Comment> editComment(String id, String body) =>
      _api.comment.edit(id, CommentRequest(body: body));

  /// Deletes the comment [id] (`comment.delete`).
  Future<void> deleteComment(String id) => _api.comment.delete(id);

  /// Adds the caller's [emoji] reaction to the comment [id], or takes it off
  /// when [add] is false, and answers the comment as the server now has it
  /// (`comment.react`, `comment.unreact`). Throws [ReactionsUnsupported] on
  /// a server without the routes.
  Future<Comment> react(String id, String emoji, {required bool add}) async {
    try {
      return add
          ? await _api.comment.react(id, emoji)
          : await _api.comment.unreact(id, emoji);
    } on TixException catch (e) {
      if (e.missingRoute) throw ReactionsUnsupported(e);
      rethrow;
    }
  }

  /// The channel each comment on [ref] was added through, by comment id,
  /// read from its `comment.add` audit entries (`task.audit`).
  Future<Map<String, Via>> commentChannels(String ref) async {
    final channels = <String, Via>{};
    String? cursor;
    do {
      final page = await _api.task.audit(
        ref,
        action: const ['comment.add'],
        cursor: cursor,
        limit: pageSize,
      );
      for (final e in page.items) {
        final via = e.via;
        if (via != null && e.subjectId.isNotEmpty) channels[e.subjectId] = via;
      }
      cursor = page.nextCursor;
    } while (cursor != null);
    return channels;
  }

  /// The edges from [ref] to the tasks it waits for (`dependency.list`).
  Future<List<Dependency>> dependencies(String ref) async =>
      (await _api.dependency.list(ref)).items;

  /// Records that [ref] waits for [dependsOn] (`dependency.add`).
  Future<void> addDependency(String ref, String dependsOn) => _write(
    OutboxOp.dependencyAdd,
    ref,
    values: {'depends_on': dependsOn},
    send: (key) => _api.dependency.add(
      ref,
      DependencyRequest(dependsOn: dependsOn),
      idempotencyKey: key,
    ),
    local: (_) {},
  );

  /// Removes the edge from [ref] to [dependsOn] (`dependency.remove`).
  Future<void> removeDependency(String ref, String dependsOn) =>
      _api.dependency.remove(ref, dependsOn);

  /// [ref]'s artifacts, oldest first (`artifact.list`).
  Future<List<Artifact>> artifacts(String ref) async =>
      (await _api.artifact.list(ref)).items;

  /// Attaches an artifact to [ref] (`artifact.put`).
  Future<Artifact> attach(String ref, ArtifactInput input) => _write(
    OutboxOp.artifactAdd,
    ref,
    values: input.toJson(),
    send: (key) => _api.artifact.put(ref, input, idempotencyKey: key),
    local: (e) => Artifact(
      id: e.id,
      name: input.name ?? '',
      contentType: input.contentType ?? '',
      createdAt: e.createdAt,
    ),
  );

  /// The custom fields of [project], in display order (`field.list`).
  Future<List<FieldDef>> fields(String project) => _cache.remember(
    'project/$project/fields',
    _api.field.list(project).then((p) => p.items),
    (v) => _encode(v, (f) => f.toJson()),
    decode: (j) => _list(j, FieldDef.fromJson),
  );

  /// The custom fields of [project] as last read.
  Future<List<FieldDef>?> cachedFields(String project) => _cache.peek(
    'project/$project/fields',
    (j) => _list(j, FieldDef.fromJson),
  );

  /// The project [ref] (`project.show`).
  Future<Project> project(String ref) => _cache.remember(
    'project/$ref',
    _api.project.show(ref),
    (p) => p.toJson(),
    decode: (j) => Project.fromJson(j! as Map<String, dynamic>),
  );

  /// The workflow [key] or id (`workflow.get`).
  Future<Workflow> workflow(String key) => _cache.remember(
    'workflow/$key',
    _api.workflow.get(key),
    (w) => w.toJson(),
    decode: _workflow,
  );

  /// The workflow [key] as last read.
  Future<Workflow?> cachedWorkflow(String key) =>
      _cache.peek('workflow/$key', _workflow);

  static Workflow _workflow(Object? j) =>
      Workflow.fromJson(j! as Map<String, dynamic>);

  /// Every actor in the tenant (`actor.list`, every page).
  Future<List<Actor>> actors() => _cache.remember(
    actorsKey,
    _allActors(),
    (v) => _encode(v, (a) => a.toJson()),
    decode: decodeActors,
  );

  Future<List<Actor>> _allActors() async {
    final all = <Actor>[];
    String? cursor;
    do {
      final page = await _api.actor.list(cursor: cursor, limit: 500);
      all.addAll(page.items);
      cursor = page.nextCursor;
    } while (cursor != null);
    return all;
  }

  /// Where [actors] keeps its answer.
  static const actorsKey = 'actors';

  /// Reads what [actors] keeps.
  static List<Actor> decodeActors(Object? json) => _list(json, Actor.fromJson);

  /// Whether the tenant keeps a trash (`trash.status`).
  Future<TrashStatus> trash() => _api.trash.status();
}

/// The server has no reaction routes: it predates them.
final class ReactionsUnsupported implements Exception {
  /// Reports a server that answered [cause] to a reaction.
  const ReactionsUnsupported(this.cause);

  /// The server's answer.
  final TixException cause;

  @override
  String toString() => 'the server does not support reactions ($cause)';
}
