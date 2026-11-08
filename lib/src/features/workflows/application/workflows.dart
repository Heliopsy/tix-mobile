// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/cache/cached.dart';
import 'package:tix_mobile/src/core/events/invalidation.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/models/project_admin.dart';

part 'workflows.g.dart';

/// The tenant's workflows, builtin first then by name: the cached list at
/// once, then the server's, and again whenever a workflow changes.
@riverpod
class Workflows extends _$Workflows {
  @override
  Future<List<Workflow>> build() async {
    final repo = ref.watch(workflowsRepositoryProvider);
    refreshOn(ref, EventTopics.workflows);
    final list = await cachedFirst(
      ref: ref,
      cached: repo.cachedList(),
      fresh: repo.list,
      onFresh: (w) => state = AsyncData(_sorted(w)),
    );
    return _sorted(list);
  }

  static List<Workflow> _sorted(List<Workflow> list) => [...list]
    ..sort((a, b) {
      if (a.builtin != b.builtin) return a.builtin ? -1 : 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

  /// Creates the workflow [input] names and reads the list again. A refusal
  /// is thrown to the form.
  Future<Workflow> create(WorkflowInput input) async {
    final created = await ref.read(workflowsRepositoryProvider).create(input);
    if (ref.mounted) ref.invalidateSelf();
    return created;
  }
}

/// One workflow, for its editor.
@riverpod
class WorkflowDetail extends _$WorkflowDetail {
  @override
  Future<Workflow> build(String key) async {
    final repo = ref.watch(workflowsRepositoryProvider);
    return await cachedFirst(
      ref: ref,
      cached: repo.cachedWorkflow(key),
      fresh: () => repo.workflow(key),
      onFresh: (w) => state = AsyncData(w),
    );
  }

  /// Replaces the workflow with [input] and shows the server's answer. A
  /// refusal is thrown to the editor, which keeps the draft.
  Future<Workflow> save(WorkflowInput input) async {
    final saved = await ref.read(workflowsRepositoryProvider).save(key, input);
    if (!ref.mounted) return saved;
    state = AsyncData(saved);
    ref.invalidate(workflowsProvider);
    return saved;
  }

  /// Deletes the workflow.
  Future<void> delete() async {
    await ref.read(workflowsRepositoryProvider).delete(key);
    if (ref.mounted) ref.invalidate(workflowsProvider);
  }
}
