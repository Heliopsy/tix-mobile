// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:tix_mobile/src/core/config/config.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/cache/response_cache.dart';
import 'package:tix_mobile/src/data/models/actor.dart';
import 'package:tix_mobile/src/data/models/page.dart';
import 'package:tix_mobile/src/data/models/project.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/data/models/task_detail.dart';
import 'package:tix_mobile/src/data/models/task_patch.dart';

export 'package:tix_mobile/src/data/models/task_detail.dart';
export 'package:tix_mobile/src/data/models/task_patch.dart';

/// Everything the task screen reads and changes about one task.
///
/// The reads that open a section are kept in the response cache and have a
/// `cached…` twin, so the section draws at once from the last answer.
class TaskDetailRepository {
  /// Reads and writes through [_api], keeping copies in [_cache].
  TaskDetailRepository(this._api, this._cache);

  final TixApi _api;
  final ResponseCache _cache;

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

  /// The task [ref], by reference or id (`task.show`).
  Future<Task> task(String ref) => _api.task.show(ref);

  /// Applies [patch] to [ref] (`task.update`).
  Future<Task> update(String ref, TaskPatch patch, {int? version}) async {
    if (!patch.clearsDue) {
      return await _api.task.update(ref, patch.toInput(version: version));
    }
    // The generated input drops a null, and a null is how tix clears a due
    // date, so this one body goes through the same operation with it kept.
    return Task.fromJson(
      await _api.transport.json(
        'PATCH',
        '/api/v1/tasks/${_api.transport.segment(ref)}',
        body: {
          ...patch.toInput(version: version).toJson(),
          'due_at': null,
        },
      ),
    );
  }

  /// Ticks or clears checklist item [item] (`task.check`).
  Future<Task> check(
    String ref,
    int item, {
    required bool done,
    int? version,
  }) => _api.task.check(
    ref,
    CheckItemInput(item: item, done: done, version: version),
  );

  /// Moves [ref] to the state [to] by the workflow's route (`task.route`).
  Future<RouteResult> move(String ref, String to, {String? comment}) =>
      _api.task.route(ref, RouteInput(to: to, comment: comment));

  /// Stars or unstars [ref] for the reader (`task.star`, `task.unstar`).
  Future<void> setStar(String ref, {required bool starred}) =>
      starred ? _api.task.star(ref) : _api.task.unstar(ref);

  /// Snoozes [ref] until [until] (`task.snooze`), or wakes it when null
  /// (`task.unsnooze`).
  Future<Task> snooze(String ref, DateTime? until) => until == null
      ? _api.task.unsnooze(ref)
      : _api.task.snooze(ref, SnoozeInput(until: until));

  /// Copies [ref] (`task.copy`).
  Future<Task> copy(String ref, CopyTaskInput request) =>
      _api.task.copy(ref, body: request);

  /// Deletes [ref] (`task.delete`).
  Future<void> delete(String ref, {bool hard = false, bool cascade = false}) =>
      _api.task.delete(
        ref,
        hard: hard ? true : null,
        cascade: cascade ? true : null,
      );

  /// Brings [ref] back from the trash (`task.restore`).
  Future<Task> restore(String ref) => _api.task.restore(ref);

  /// The direct subtasks of [ref] (`task.tree`, depth 1).
  Future<List<Task>> subtasks(String ref) => _cache.remember(
    'task/$ref/subtasks',
    _api.task.tree(ref, depth: 1).then((p) => p.items.skip(1).toList()),
    (v) => _encode(v, (t) => t.toJson()),
  );

  /// The subtasks of [ref] as last read.
  Future<List<Task>?> cachedSubtasks(String ref) =>
      _cache.peek('task/$ref/subtasks', (j) => _list(j, Task.fromJson));

  /// Creates a subtask of [parent] in [project] titled [title]
  /// (`task.create`).
  Future<Task> addSubtask(String project, String parent, String title) =>
      _api.task.create(
        CreateTaskRequest(title: title, projectRef: project, parentRef: parent),
      );

  /// One page of [ref]'s history, newest first (`task.audit`).
  Future<Page<AuditEntry>> history(String ref, {String? cursor}) =>
      _api.task.audit(ref, cursor: cursor, limit: pageSize, direction: 'desc');

  /// Puts the tag [name] on [ref] (`tag.add`).
  Future<void> addTag(String ref, String name) =>
      _api.tag.add(ref, TagRequest(name: name));

  /// Takes the tag [name] off [ref] (`tag.remove`).
  Future<void> removeTag(String ref, String name) => _api.tag.remove(ref, name);

  /// Every tag in the tenant (`tag.list`).
  Future<List<Tag>> tags() async => (await _api.tag.list()).items;

  /// [ref]'s comments, oldest first (`comment.list`).
  Future<List<Comment>> comments(String ref) => _cache.remember(
    'task/$ref/comments',
    _api.comment.list(ref).then((p) => p.items),
    (v) => _encode(v, (c) => c.toJson()),
  );

  /// [ref]'s comments as last read.
  Future<List<Comment>?> cachedComments(String ref) =>
      _cache.peek('task/$ref/comments', (j) => _list(j, Comment.fromJson));

  /// Adds a comment to [ref] (`comment.add`).
  Future<Comment> addComment(String ref, String body) =>
      _api.comment.add(ref, CommentRequest(body: body));

  /// Rewrites the comment [id] (`comment.edit`).
  Future<Comment> editComment(String id, String body) =>
      _api.comment.edit(id, CommentRequest(body: body));

  /// Deletes the comment [id] (`comment.delete`).
  Future<void> deleteComment(String id) => _api.comment.delete(id);

  /// The edges from [ref] to the tasks it waits for (`dependency.list`).
  Future<List<Dependency>> dependencies(String ref) async =>
      (await _api.dependency.list(ref)).items;

  /// Records that [ref] waits for [dependsOn] (`dependency.add`).
  Future<void> addDependency(String ref, String dependsOn) =>
      _api.dependency.add(ref, DependencyRequest(dependsOn: dependsOn));

  /// Removes the edge from [ref] to [dependsOn] (`dependency.remove`).
  Future<void> removeDependency(String ref, String dependsOn) =>
      _api.dependency.remove(ref, dependsOn);

  /// [ref]'s artifacts, oldest first (`artifact.list`).
  Future<List<Artifact>> artifacts(String ref) async =>
      (await _api.artifact.list(ref)).items;

  /// Attaches an artifact to [ref] (`artifact.put`).
  Future<Artifact> attach(String ref, ArtifactInput input) =>
      _api.artifact.put(ref, input);

  /// The custom fields of [project], in display order (`field.list`).
  Future<List<FieldDef>> fields(String project) => _cache.remember(
    'project/$project/fields',
    _api.field.list(project).then((p) => p.items),
    (v) => _encode(v, (f) => f.toJson()),
  );

  /// The custom fields of [project] as last read.
  Future<List<FieldDef>?> cachedFields(String project) => _cache.peek(
    'project/$project/fields',
    (j) => _list(j, FieldDef.fromJson),
  );

  /// The project [ref] (`project.show`).
  Future<Project> project(String ref) => _api.project.show(ref);

  /// The workflow [key] or id (`workflow.get`).
  Future<Workflow> workflow(String key) => _cache.remember(
    'workflow/$key',
    _api.workflow.get(key),
    (w) => w.toJson(),
  );

  /// The workflow [key] as last read.
  Future<Workflow?> cachedWorkflow(String key) => _cache.peek(
    'workflow/$key',
    (j) => Workflow.fromJson(j! as Map<String, dynamic>),
  );

  /// Every actor in the tenant (`actor.list`, every page).
  Future<List<Actor>> actors() async {
    final all = <Actor>[];
    String? cursor;
    do {
      final page = await _api.actor.list(cursor: cursor, limit: 500);
      all.addAll(page.items);
      cursor = page.nextCursor;
    } while (cursor != null);
    return all;
  }

  /// Whether the tenant keeps a trash (`trash.status`).
  Future<TrashStatus> trash() => _api.trash.status();
}
