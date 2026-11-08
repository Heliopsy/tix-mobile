// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/cache/cached.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/events/invalidation.dart';
import 'package:tix_mobile/src/core/paging/paged.dart';
import 'package:tix_mobile/src/core/quick/quick_add.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/session/templates.dart';
import 'package:tix_mobile/src/data/models/page.dart';
import 'package:tix_mobile/src/data/models/project.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/data/models/template.dart';

part 'templates.g.dart';

/// The templates the person can read, by name, a page at a time, and what
/// can be done to them.
@riverpod
class Templates extends _$Templates {
  @override
  Future<Paged<TaskTemplate>> build() async {
    final repo = ref.watch(templatesRepositoryProvider);
    refreshOn(ref, EventTopics.templates);
    final page = await cachedFirst(
      ref: ref,
      cached: repo.cachedList(),
      fresh: repo.list,
      onFresh: (p) => state = AsyncData(_paged(p)),
    );
    return _paged(page);
  }

  static Paged<TaskTemplate> _paged(Page<TaskTemplate> p) =>
      Paged(items: p.items, cursor: p.nextCursor);

  /// Fetches the next page, if there is one and none is in flight.
  Future<void> loadMore() => loadNextPage(
    current: state.value,
    fetch: (cursor) =>
        ref.read(templatesRepositoryProvider).list(cursor: cursor),
    emit: (next) => state = AsyncData(next),
    idOf: (t) => t.id,
  );

  /// Keeps a task as a template, then reloads the list.
  Future<TaskTemplate> save(SaveTemplateInput request) async {
    final saved = await ref.read(templatesRepositoryProvider).save(request);
    ref.invalidateSelf();
    return saved;
  }

  /// Creates a task from [line] in [project] and keeps it as [name].
  Future<TaskTemplate> saveFromLine({
    required String project,
    required String line,
    required String name,
    String? dueIn,
  }) async {
    final saved = await ref
        .read(templatesRepositoryProvider)
        .saveFromLine(project: project, line: line, name: name, dueIn: dueIn);
    ref
      ..invalidateSelf()
      ..read(tasksChangedProvider.notifier).touch();
    return saved;
  }

  /// Changes what [request] names on [template].
  Future<TaskTemplate> edit(
    TaskTemplate template,
    UpdateTemplateInput request,
  ) async {
    final updated = await ref
        .read(templatesRepositoryProvider)
        .update(template.id, request);
    _replace(template.id, updated);
    return updated;
  }

  /// [template] as the server has it now, kept in the list; the listed
  /// copy when the server cannot be asked.
  Future<TaskTemplate> current(TaskTemplate template) async {
    final TaskTemplate fresh;
    try {
      fresh = await ref.read(templatesRepositoryProvider).get(template.id);
    } on TixException {
      // Editing the listed copy is better than not editing; a save still
      // reaches the server, which has the last word.
      return template;
    }
    if (ref.mounted) _replace(template.id, fresh);
    return fresh;
  }

  /// Deletes [template].
  Future<void> delete(TaskTemplate template) async {
    await ref.read(templatesRepositoryProvider).delete(template.id);
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        items: [
          for (final t in current.items)
            if (t.id != template.id) t,
        ],
      ),
    );
  }

  /// Creates a task from [template], in [project] when given.
  Future<Task> use(TaskTemplate template, {String? project}) async {
    final task = await ref
        .read(templatesRepositoryProvider)
        .use(template.id, project: project);
    ref.read(tasksChangedProvider.notifier).touch();
    _replace(template.id, template.copyWith(uses: template.uses + 1));
    return task;
  }

  void _replace(String id, TaskTemplate next) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        items: [
          for (final t in current.items)
            if (t.id == id) next else t,
        ],
      ),
    );
  }
}

/// The update holding only what differs between [before] and the form's
/// values.
UpdateTemplateInput templateChanges(
  TaskTemplate before, {
  required String name,
  required String title,
  required String body,
  required int priority,
  required List<String> tags,
  required String recurrence,
  required String dueIn,
  required String projectKey,
}) {
  final hadDue = readableDueIn(before.dueIn);
  final shape = before.shape;
  return UpdateTemplateInput(
    name: name == before.name ? null : name,
    title: title == shape.title ? null : title,
    body: body == shape.body ? null : body,
    priority: priority == shape.priority ? null : priority,
    tags: _same(tags, shape.tags) ? null : tags,
    recurrence: recurrence == shape.recurrence ? null : recurrence,
    dueIn: dueIn == hadDue ? null : (dueIn.isEmpty ? '0' : dueIn),
    projectRef: projectKey == before.projectKey ? null : projectKey,
  );
}

bool _same(List<String> a, List<String> b) =>
    a.length == b.length && a.indexed.every((e) => b[e.$1] == e.$2);

/// Tags typed as `a, b c` as a list.
List<String> splitTags(String text) => [
  for (final t in text.split(RegExp(r'[\s,]+')))
    if (t.trim().isNotEmpty) t.trim().replaceFirst(RegExp('^#'), ''),
];

/// tix's due offset as a person writes it: `72h0m0s` reads `3d`.
String readableDueIn(String? dueIn) {
  if (dueIn == null || dueIn.isEmpty) return '';
  final m = RegExp(r'^(?:(\d+)h)?(?:(\d+)m)?(?:(\d+(?:\.\d+)?)s)?$')
      .firstMatch(dueIn);
  if (m == null) return dueIn;
  final hours = int.tryParse(m.group(1) ?? '') ?? 0;
  final minutes = int.tryParse(m.group(2) ?? '') ?? 0;
  final seconds = double.tryParse(m.group(3) ?? '') ?? 0;
  if (minutes != 0 || seconds != 0) return dueIn;
  if (hours % (24 * 7) == 0 && hours > 0) return '${hours ~/ (24 * 7)}w';
  if (hours % 24 == 0 && hours > 0) return '${hours ~/ 24}d';
  return '${hours}h';
}

/// Every project, for the template forms' pickers.
@riverpod
Future<List<Project>> templateProjects(Ref ref) async {
  final repo = ref.watch(tasksRepositoryProvider);
  final all = <Project>[];
  String? cursor;
  do {
    final page = await repo.projects(cursor: cursor);
    all.addAll(page.items);
    cursor = page.nextCursor;
  } while (cursor != null && all.length < 500);
  return all;
}
