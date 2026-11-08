// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/models/actor.dart';
import 'package:tix_mobile/src/data/models/page.dart';
import 'package:tix_mobile/src/data/models/project.dart';
import 'package:tix_mobile/src/data/models/task.dart';

/// Projects, tasks and the actors they name, for the active server.
class TasksRepository {
  /// Reads through [_api].
  TasksRepository(this._api);

  final TixApi _api;
  final _actors = <String, Future<Actor>>{};

  /// One page of projects.
  Future<Page<Project>> projects({String? cursor}) =>
      _api.projects(cursor: cursor);

  /// One page of the tasks in [project].
  Future<Page<Task>> tasks(String project, {String? cursor}) =>
      _api.tasks(project: project, cursor: cursor);

  /// The task [ref].
  Future<Task> task(String ref) => _api.task(ref);

  /// The actor [id], fetched once per repository.
  Future<Actor> actor(String id) => _actors[id] ??= _fetchActor(id);

  Future<Actor> _fetchActor(String id) async {
    try {
      return await _api.actor(id);
    } catch (_) {
      _actors.removeWhere((key, _) => key == id);
      rethrow;
    }
  }

  /// Creates a task in [project] from a quick-add [line], which the server
  /// parses: `Fix login !high #auth @raj due:fri`.
  Future<Task> quickAdd(String project, String line) => _api.createTask(
    CreateTaskRequest(title: line, projectRef: project, parse: true),
  );
}
