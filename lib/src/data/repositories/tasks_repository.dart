// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:tix_mobile/src/core/config/config.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/data/api/gen/models.gen.dart'
    show TaskImportInput;
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/cache/response_cache.dart';
import 'package:tix_mobile/src/data/models/actor.dart';
import 'package:tix_mobile/src/data/models/bulk.dart';
import 'package:tix_mobile/src/data/models/page.dart';
import 'package:tix_mobile/src/data/models/project.dart';
import 'package:tix_mobile/src/data/models/quick_preview.dart';
import 'package:tix_mobile/src/data/models/tag.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/data/repositories/task_detail_repository.dart'
    show TaskDetailRepository;

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

  /// One page of projects, archived ones too when [archived]
  /// (`project.list`, `include_archived`).
  Future<Page<Project>> projects({String? cursor, bool archived = false}) {
    final fresh = _api.project.list(
      cursor: cursor,
      limit: pageSize,
      includeArchived: archived ? true : null,
    );
    if (cursor != null) return fresh;
    return _cache.remember(
      archived ? 'projects/archived' : 'projects',
      fresh,
      (p) => p.toJson((e) => e.toJson()),
      decode: _projects,
    );
  }

  /// Every project, kept under the first page's key as one page with no
  /// cursor, so the project list opened offline holds all of them.
  Future<List<Project>> allProjects() async {
    final all = <Project>[];
    String? cursor;
    do {
      final page = await _api.project.list(cursor: cursor, limit: pageSize);
      all.addAll(page.items);
      cursor = page.nextCursor;
    } while (cursor != null);
    await _cache.keep(
      'projects',
      Page(items: all),
      (p) => p.toJson((e) => e.toJson()),
    );
    return all;
  }

  /// The first page of projects as last read, null when never read.
  Future<Page<Project>?> cachedProjects({bool archived = false}) =>
      _cache.peek(archived ? 'projects/archived' : 'projects', _projects);

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
      decode: _tasks,
    );
  }

  /// The first page of [project]'s tasks as last read, null when never read.
  Future<Page<Task>?> cachedTasks(String project) =>
      _cache.peek('tasks/$project', _tasks);

  /// How many of project [key]'s tasks are in an unfinished category.
  Future<int> projectOpenCount(String key) async =>
      (await _api.stats.read(project: key)).open;

  /// The task [ref].
  Future<Task> task(String ref) => _cache.remember(
    'task/$ref',
    _api.task.show(ref),
    (t) => t.toJson(),
    decode: _task,
  );

  /// The task [ref] as last read, null when never read.
  Future<Task?> cachedTask(String ref) => _cache.peek('task/$ref', _task);

  static Task _task(Object? json) =>
      Task.fromJson(json! as Map<String, dynamic>);

  /// The actor [id], fetched once per repository. While the server cannot
  /// be reached it comes from the kept actor list, when that names it.
  Future<Actor> actor(String id) => _actors[id] ??= _fetchActor(id);

  Future<Actor> _fetchActor(String id) async {
    try {
      return await _api.actor.show(id);
    } on TixException catch (e) {
      _actors.removeWhere((key, _) => key == id);
      if (!ResponseCache.isUnreachable(e)) rethrow;
      final kept = await _cache.stored(
        TaskDetailRepository.actorsKey,
        TaskDetailRepository.decodeActors,
      );
      final actor = kept?.value.where((a) => a.id == id).firstOrNull;
      if (actor == null) rethrow;
      return actor;
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

  /// Every tag in the tenant.
  Future<List<Tag>> tags() async => (await _api.tag.list()).items;

  /// The tenant's actors, at most [max] of them.
  Future<List<Actor>> actors({int max = 2000}) async {
    final all = <Actor>[];
    String? cursor;
    do {
      final page = await _api.actor.list(cursor: cursor, limit: 500);
      all.addAll(page.items);
      cursor = page.nextCursor;
    } while (cursor != null && all.length < max);
    return all;
  }

  /// What the server would make of the quick-add [line] in [project], from
  /// a dry run of tix's import of a bare title and the line, which writes
  /// nothing.
  Future<QuickPreview> preview(String project, String line) async {
    final result = await _api.task.import(
      project,
      TaskImportInput(
        content: '$_plainTitle\n$line',
        format: 'lines',
        dryRun: true,
        preview: 2,
      ),
    );
    final rows = result.preview;
    if (rows.length < 2) throw StateError('dry run returned ${rows.length}');
    return QuickPreview(line: rows[1], plain: rows[0]);
  }

  static const _plainTitle = 'x';
}
