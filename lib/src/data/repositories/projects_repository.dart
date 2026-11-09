// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:typed_data';

import 'package:tix_mobile/src/core/config/config.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/cache/response_cache.dart';
import 'package:tix_mobile/src/data/models/page.dart';
import 'package:tix_mobile/src/data/models/project_admin.dart';
import 'package:tix_mobile/src/data/offline/outbox.dart';

/// Creating, changing, archiving, deleting and starring projects, and their
/// custom field definitions.
class ProjectsRepository {
  /// Sends through [_api], keeping reads in [_cache] and queueing stars in
  /// [_outbox] while the server is out of reach.
  ProjectsRepository(this._api, this._cache, {this._outbox});

  final TixApi _api;
  final ResponseCache _cache;
  final Outbox? _outbox;

  static const _starredKey = 'projects/starred';

  static Page<Project> _page(Object? json) => Page.fromJson(
    json! as Map<String, dynamic>,
    (e) => Project.fromJson(e! as Map<String, dynamic>),
  );

  static List<FieldDef> _fields(Object? j) => [
    for (final e in j! as List<Object?>)
      FieldDef.fromJson(e! as Map<String, dynamic>),
  ];

  /// One page of projects, archived ones included (`project.list`).
  Future<Page<Project>> all({String? cursor}) =>
      _api.project.list(cursor: cursor, limit: pageSize, includeArchived: true);

  /// The projects the reader starred, in the order their lanes are drawn,
  /// with the stars still waiting in the outbox drawn on top
  /// (`project.starred`). Null when the server keeps no project stars.
  Future<List<Project>?> starred() async {
    final Page<Project> page;
    try {
      page = await _cache.remember(
        _starredKey,
        _api.project.starred(),
        (p) => p.toJson((e) => e.toJson()),
        decode: _page,
      );
    } on TixException catch (e) {
      if (e.status == 404 || e.status == 405) return null;
      rethrow;
    }
    return await _withQueued(page.items);
  }

  /// The starred projects as last read, null when never read.
  Future<List<Project>?> cachedStarred() async {
    final page = await _cache.peek(_starredKey, _page);
    return page == null ? null : await _withQueued(page.items);
  }

  Future<List<Project>> _withQueued(List<Project> read) async {
    final outbox = _outbox;
    if (outbox == null) return read;
    await outbox.store.load();
    final out = [...read];
    for (final e in outbox.projectStarWrites()) {
      final listed = out.any((p) => p.key == e.target);
      final json = e.values['project'];
      if (e.op == OutboxOp.projectUnstar) {
        out.removeWhere((p) => p.key == e.target);
      } else if (!listed && json is Map<String, Object?>) {
        out.add(Project.fromJson(json).copyWith(starred: true));
      }
    }
    return out;
  }

  /// Stars [project] for the reader alone (`project.star`), queued while
  /// the server is out of reach.
  Future<void> star(Project project) => _star(project, starred: true);

  /// Takes the reader's star off [project] (`project.unstar`), queued while
  /// the server is out of reach.
  Future<void> unstar(Project project) => _star(project, starred: false);

  Future<void> _star(Project project, {required bool starred}) {
    final key = project.key;
    Future<void> send(String? idempotencyKey) => starred
        ? _api.project.star(key, idempotencyKey: idempotencyKey)
        : _api.project.unstar(key, idempotencyKey: idempotencyKey);
    final outbox = _outbox;
    if (outbox == null) return send(null);
    return outbox.write(
      op: starred ? OutboxOp.projectStar : OutboxOp.projectUnstar,
      target: key,
      values: {'project': project.copyWith(starred: starred).toJson()},
      online: send,
      local: (_) {},
    );
  }

  /// The project [ref] (`project.show`).
  Future<Project> project(String ref) => _cache.remember(
    'project/$ref',
    _api.project.show(ref),
    (p) => p.toJson(),
  );

  /// The project [ref] as last read.
  Future<Project?> cachedProject(String ref) => _cache.peek(
    'project/$ref',
    (j) => Project.fromJson(j! as Map<String, dynamic>),
  );

  /// Creates a project (`project.create`).
  Future<Project> create(CreateProjectInput input) =>
      _api.project.create(input);

  /// Changes the fields [input] names on [ref] (`project.update`).
  Future<Project> update(String ref, UpdateProjectInput input) =>
      _api.project.update(ref, input);

  /// Archives [ref], keeping its tasks (`project.delete` with `archive`).
  Future<void> archive(String ref) async {
    await _api.project.delete(ref, archive: true);
  }

  /// What deleting [ref] would do to its tasks (`project.delete-plan`).
  Future<ProjectDeletion> deletionPlan(
    String ref, {
    String? moveTasksTo,
    bool deleteTasks = false,
  }) => _api.project.deletePlan(
    ref,
    moveTasksTo: moveTasksTo,
    deleteTasks: deleteTasks ? true : null,
  );

  /// Deletes [ref], moving its tasks to [moveTasksTo] or deleting them with
  /// it (`project.delete`).
  Future<ProjectDeletion?> delete(
    String ref, {
    String? moveTasksTo,
    bool deleteTasks = false,
  }) => _api.project.delete(
    ref,
    moveTasksTo: moveTasksTo,
    deleteTasks: deleteTasks ? true : null,
  );

  /// The uploaded icon image of [ref] (`project.icon`).
  Future<Uint8List> icon(String ref) => _api.project.icon(ref);

  /// The custom fields of [ref], in display order (`field.list`).
  Future<List<FieldDef>> fields(String ref) => _cache.remember(
    'project/$ref/fields',
    _api.field.list(ref).then((p) => p.items),
    (l) => [for (final f in l) f.toJson()],
  );

  /// The custom fields of [ref] as last read.
  Future<List<FieldDef>?> cachedFields(String ref) =>
      _cache.peek('project/$ref/fields', _fields);

  /// Defines or redefines a custom field on [ref] (`field.put`).
  Future<FieldDef> putField(String ref, FieldDefInput input) =>
      _api.field.put(ref, input);

  /// Removes the custom field [key] from [ref] (`field.delete`).
  Future<void> deleteField(String ref, String key) =>
      _api.field.delete(ref, key);
}
