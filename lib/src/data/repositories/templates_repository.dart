// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/cache/response_cache.dart';
import 'package:tix_mobile/src/data/models/page.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/data/models/template.dart';

/// Task templates on the active server. The first page is kept in [_cache]
/// so the screen draws before the server answers.
class TemplatesRepository {
  /// Reads and writes through [_api], keeping copies in [_cache].
  TemplatesRepository(this._api, this._cache);

  final TixApi _api;
  final ResponseCache _cache;

  static const _key = 'templates';

  static Page<TaskTemplate> _page(Object? json) => Page.fromJson(
    json! as Map<String, dynamic>,
    (e) => TaskTemplate.fromJson(e! as Map<String, dynamic>),
  );

  /// One page of templates, by name.
  Future<Page<TaskTemplate>> list({String? cursor}) {
    final fresh = _api.template.list(cursor: cursor);
    if (cursor != null) return fresh;
    return _cache.remember(
      _key,
      fresh,
      (p) => p.toJson((e) => e.toJson()),
      decode: _page,
    );
  }

  /// The first page as last read, null when never read.
  Future<Page<TaskTemplate>?> cachedList() => _cache.peek(_key, _page);

  /// The template [ref], by name or id.
  Future<TaskTemplate> get(String ref) => _api.template.show(ref);

  /// Keeps a task as a template, as [request] says.
  Future<TaskTemplate> save(SaveTemplateInput request) =>
      _api.template.save(request);

  /// Creates a task from the quick-add [line] in [project], then keeps it as
  /// a template; tix saves templates only from tasks.
  Future<TaskTemplate> saveFromLine({
    required String project,
    required String line,
    required String name,
    String? dueIn,
  }) async {
    final task = await _api.task.create(
      CreateTaskRequest(title: line, projectRef: project, parse: true),
    );
    return await _api.template.save(
      SaveTemplateInput(taskRef: task.ref, name: name, dueIn: dueIn),
    );
  }

  /// Changes what [request] names on [ref].
  Future<TaskTemplate> update(String ref, UpdateTemplateInput request) =>
      _api.template.update(ref, request);

  /// Removes [ref]; tasks made from it stay.
  Future<void> delete(String ref) => _api.template.delete(ref);

  /// Creates a task from [ref], in [project] when given.
  Future<Task> use(String ref, {String? project}) => _api.template.use(
    ref,
    body: UseTemplateInput(
      projectRef: project == null || project.isEmpty ? null : project,
    ),
  );
}
