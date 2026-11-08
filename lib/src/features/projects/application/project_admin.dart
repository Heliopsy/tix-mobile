// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/cache/cached.dart';
import 'package:tix_mobile/src/core/events/invalidation.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/models/project_admin.dart';
import 'package:tix_mobile/src/features/projects/application/projects.dart';

part 'project_admin.g.dart';

/// One project's settings: the cached copy at once, then the server's, and
/// again whenever a project changes.
@riverpod
class ProjectSettings extends _$ProjectSettings {
  @override
  Future<Project> build(String key) async {
    final repo = ref.watch(projectsRepositoryProvider);
    refreshOn(ref, EventTopics.projects);
    return await cachedFirst(
      ref: ref,
      cached: repo.cachedProject(key),
      fresh: () => repo.project(key),
      onFresh: (p) => state = AsyncData(p),
    );
  }

  /// Sends [input], shows the server's answer and refreshes the project
  /// list. A refusal is thrown to the form, which keeps what was typed.
  Future<Project> save(UpdateProjectInput input) async {
    final saved = await ref.read(projectsRepositoryProvider).update(key, input);
    state = AsyncData(saved);
    ref.invalidate(projectsProvider);
    return saved;
  }

  /// Archives the project, keeping its tasks.
  Future<void> archive() async {
    await ref.read(projectsRepositoryProvider).archive(key);
    if (!ref.mounted) return;
    ref
      ..invalidate(projectsProvider)
      ..invalidateSelf();
  }

  /// Deletes the project, moving its tasks to [moveTasksTo] or deleting
  /// them with it.
  Future<void> delete({String? moveTasksTo, bool deleteTasks = false}) async {
    await ref
        .read(projectsRepositoryProvider)
        .delete(key, moveTasksTo: moveTasksTo, deleteTasks: deleteTasks);
    if (ref.mounted) ref.invalidate(projectsProvider);
  }
}

/// What deleting project [key] would do: with [moveTo] the tasks move
/// there, otherwise the plan only counts them.
@riverpod
Future<ProjectDeletion> deletionPlan(Ref ref, String key, String? moveTo) => ref
    .watch(projectsRepositoryProvider)
    .deletionPlan(key, moveTasksTo: moveTo);

/// The uploaded icon of project [key], whose digest is [digest]; a new
/// digest reads the new image.
@riverpod
Future<Uint8List> projectIcon(Ref ref, String key, String digest) =>
    ref.watch(projectsRepositoryProvider).icon(key);

/// The workflows a project can follow.
@riverpod
class WorkflowChoices extends _$WorkflowChoices {
  @override
  Future<List<Workflow>> build() async {
    final repo = ref.watch(workflowsRepositoryProvider);
    refreshOn(ref, EventTopics.workflows);
    return await cachedFirst(
      ref: ref,
      cached: repo.cachedList(),
      fresh: repo.list,
      onFresh: (w) => state = AsyncData(w),
    );
  }
}

/// The custom fields of project [key], in display order.
@riverpod
class ProjectFields extends _$ProjectFields {
  @override
  Future<List<FieldDef>> build(String key) async {
    final repo = ref.watch(projectsRepositoryProvider);
    refreshOn(ref, EventTopics.fields);
    final fields = await cachedFirst(
      ref: ref,
      cached: repo.cachedFields(key),
      fresh: () => repo.fields(key),
      onFresh: (f) => state = AsyncData(_ordered(f)),
    );
    return _ordered(fields);
  }

  static List<FieldDef> _ordered(List<FieldDef> fields) =>
      [...fields]..sort((a, b) {
        final p = a.position.compareTo(b.position);
        return p != 0 ? p : a.key.compareTo(b.key);
      });

  /// Defines or redefines a field. A refusal is thrown to the form.
  Future<FieldDef> put(FieldDefInput input) async {
    final saved = await ref
        .read(projectsRepositoryProvider)
        .putField(key, input);
    if (!ref.mounted) return saved;
    final current = state.value ?? const <FieldDef>[];
    state = AsyncData(
      _ordered([
        for (final f in current)
          if (f.key != saved.key) f,
        saved,
      ]),
    );
    return saved;
  }

  /// Removes the field [fieldKey].
  Future<void> delete(String fieldKey) async {
    await ref.read(projectsRepositoryProvider).deleteField(key, fieldKey);
    if (!ref.mounted) return;
    state = AsyncData([
      for (final f in state.value ?? const <FieldDef>[])
        if (f.key != fieldKey) f,
    ]);
  }

  /// Moves the field at [from] to the index [to] it has afterwards, and
  /// saves the positions that changed, ten apart so a later insert fits
  /// between two.
  Future<void> move(int from, int to) async {
    final list = [...state.value ?? const <FieldDef>[]];
    final f = list.removeAt(from);
    list.insert(to, f);
    final placed = [
      for (final (i, f) in list.indexed) f.copyWith(position: (i + 1) * 10),
    ];
    final before = state.value;
    state = AsyncData(placed);
    final repo = ref.read(projectsRepositoryProvider);
    try {
      for (final (i, f) in placed.indexed) {
        if (list[i].position == f.position) continue;
        await repo.putField(key, inputOf(f));
      }
    } on Object {
      if (ref.mounted) {
        if (before != null) state = AsyncData(before);
        ref.invalidateSelf();
      }
      rethrow;
    }
  }

  /// The input that redefines [f] exactly as it is.
  static FieldDefInput inputOf(FieldDef f) => FieldDefInput(
    key: f.key,
    label: f.label,
    type: f.type,
    enumOptions: f.type == FieldType.enumValue ? f.enumOptions : null,
    defaultValue: f.defaultValue,
    position: f.position,
    required: f.required,
  );
}
