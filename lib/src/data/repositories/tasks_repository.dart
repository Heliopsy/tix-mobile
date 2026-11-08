// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:tix_mobile/src/core/config/config.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/cache/response_cache.dart';
import 'package:tix_mobile/src/data/models/actor.dart';
import 'package:tix_mobile/src/data/models/bulk.dart';
import 'package:tix_mobile/src/data/models/page.dart';
import 'package:tix_mobile/src/data/models/project.dart';
import 'package:tix_mobile/src/data/models/task.dart';

/// Projects, tasks and the actors they name, for the active server.
///
/// Every read of a first page or a single record is kept in [_cache], and
/// each has a `cached…` twin that returns the last kept copy, for a screen
/// to draw before the server answers.
class TasksRepository {
  /// Reads through [_api], keeping copies in [_cache].
  TasksRepository(this._api, this._cache);

  final TixApi _api;
  final ResponseCache _cache;
  final _actors = <String, Future<Actor>>{};

  static Page<Project> _projects(Object? json) => Page.fromJson(
    json! as Map<String, dynamic>,
    (e) => Project.fromJson(e! as Map<String, dynamic>),
  );

  static Page<Task> _tasks(Object? json) => Page.fromJson(
    json! as Map<String, dynamic>,
    (e) => Task.fromJson(e! as Map<String, dynamic>),
  );

  /// One page of projects.
  Future<Page<Project>> projects({String? cursor}) {
    final fresh = _api.project.list(cursor: cursor, limit: pageSize);
    if (cursor != null) return fresh;
    return _cache.remember(
      'projects',
      fresh,
      (p) => p.toJson((e) => e.toJson()),
    );
  }

  /// The first page of projects as last read, null when never read.
  Future<Page<Project>?> cachedProjects() => _cache.peek('projects', _projects);

  /// One page of the tasks in [project].
  Future<Page<Task>> tasks(String project, {String? cursor}) {
    final fresh = _api.task.list(
      project: [project],
      cursor: cursor,
      limit: pageSize,
    );
    if (cursor != null) return fresh;
    return _cache.remember(
      'tasks/$project',
      fresh,
      (p) => p.toJson((e) => e.toJson()),
    );
  }

  /// The first page of [project]'s tasks as last read, null when never read.
  Future<Page<Task>?> cachedTasks(String project) =>
      _cache.peek('tasks/$project', _tasks);

  /// How many of project [key]'s tasks are in an unfinished category.
  Future<int> projectOpenCount(String key) async =>
      (await _api.stats.read(project: key)).open;

  /// The task [ref].
  Future<Task> task(String ref) =>
      _cache.remember('task/$ref', _api.task.show(ref), (t) => t.toJson());

  /// The task [ref] as last read, null when never read.
  Future<Task?> cachedTask(String ref) => _cache.peek(
    'task/$ref',
    (json) => Task.fromJson(json! as Map<String, dynamic>),
  );

  /// The actor [id], fetched once per repository.
  Future<Actor> actor(String id) => _actors[id] ??= _fetchActor(id);

  Future<Actor> _fetchActor(String id) async {
    try {
      return await _api.actor.show(id);
    } catch (_) {
      _actors.removeWhere((key, _) => key == id);
      rethrow;
    }
  }

  /// Creates a task in [project] from a quick-add [line], which the server
  /// parses: `Fix login !high #auth @raj due:fri`.
  Future<Task> quickAdd(String project, String line) => _api.task.create(
    CreateTaskRequest(title: line, projectRef: project, parse: true),
  );
}
