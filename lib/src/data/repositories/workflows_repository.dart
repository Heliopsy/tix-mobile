// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/cache/response_cache.dart';
import 'package:tix_mobile/src/data/models/project_admin.dart';

/// A tenant's workflows: reading, defining and deleting them.
class WorkflowsRepository {
  /// Sends through [_api], keeping reads in [_cache].
  WorkflowsRepository(this._api, this._cache);

  final TixApi _api;
  final ResponseCache _cache;

  static List<Workflow> _list(Object? j) => [
    for (final e in j! as List<Object?>)
      Workflow.fromJson(e! as Map<String, dynamic>),
  ];

  /// Every workflow in the tenant (`workflow.list`).
  Future<List<Workflow>> list() => _cache.remember(
    'workflows',
    _api.workflow.list().then((p) => p.items),
    (l) => [for (final w in l) w.toJson()],
  );

  /// The workflows as last read.
  Future<List<Workflow>?> cachedList() => _cache.peek('workflows', _list);

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

  /// Creates the workflow [input] names, or replaces one with its key
  /// (`workflow.put`).
  Future<Workflow> create(WorkflowInput input) => _api.workflow.put(input);

  /// Replaces the workflow [key] with [input] (`workflow.put_by_key`).
  Future<Workflow> save(String key, WorkflowInput input) =>
      _api.workflow.putByKey(key, input);

  /// Deletes the workflow [key] (`workflow.delete`).
  Future<void> delete(String key) => _api.workflow.delete(key);
}
