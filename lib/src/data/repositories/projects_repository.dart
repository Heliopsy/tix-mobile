// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:typed_data';

import 'package:tix_mobile/src/core/config/config.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/cache/response_cache.dart';
import 'package:tix_mobile/src/data/models/page.dart';
import 'package:tix_mobile/src/data/models/project_admin.dart';

/// Creating, changing, archiving and deleting projects, and their custom
/// field definitions.
class ProjectsRepository {
  /// Sends through [_api], keeping reads in [_cache].
  ProjectsRepository(this._api, this._cache);

  final TixApi _api;
  final ResponseCache _cache;

  static List<FieldDef> _fields(Object? j) => [
    for (final e in j! as List<Object?>)
      FieldDef.fromJson(e! as Map<String, dynamic>),
  ];

  /// One page of projects, archived ones included (`project.list`).
  Future<Page<Project>> all({String? cursor}) =>
      _api.project.list(cursor: cursor, limit: pageSize, includeArchived: true);

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
