// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ProviderListenableSelect;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/quick/quick_add.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/session/templates.dart';
import 'package:tix_mobile/src/core/storage/providers.dart';
import 'package:tix_mobile/src/data/models/actor.dart';
import 'package:tix_mobile/src/data/models/project.dart';
import 'package:tix_mobile/src/data/models/quick_preview.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/data/models/template.dart';

part 'quick.g.dart';

/// The most projects, tags and people quick add offers.
const quickListCap = 500;

/// The active context as a stable key, or null when none is. Like the
/// response cache, only a switchable sign-in names its tenant, so a
/// background `whoami` filling in the tenant does not look like a switch.
@Riverpod(keepAlive: true)
String? quickContext(Ref ref) => ref.watch(
  sessionControllerProvider.select((s) {
    final c = s.value?.connection;
    if (c == null) return null;
    return '${c.id}.${c.switchable ? c.tenantKey : ''}';
  }),
);

/// Every project, for the picker and `+` completions.
@riverpod
Future<List<Project>> quickProjects(Ref ref) async {
  final repo = ref.watch(tasksRepositoryProvider);
  final all = <Project>[];
  String? cursor;
  do {
    final page = await repo.projects(cursor: cursor);
    all.addAll(page.items);
    cursor = page.nextCursor;
  } while (cursor != null && all.length < quickListCap);
  return all;
}

/// Every tag, for `#` completions.
@riverpod
Future<List<String>> quickTags(Ref ref) async => [
  for (final t in await ref.watch(tasksRepositoryProvider).tags()) t.name,
];

/// Every actor, for `@` completions.
@riverpod
Future<List<Actor>> quickActors(Ref ref) =>
    ref.watch(tasksRepositoryProvider).actors(max: quickListCap);

/// The most used templates, for one-tap use from quick add.
@riverpod
Future<List<TaskTemplate>> quickTemplates(Ref ref) async {
  final page = await ref.watch(templatesRepositoryProvider).list();
  final sorted = [...page.items]..sort((a, b) => b.uses.compareTo(a.uses));
  return sorted.take(6).toList();
}

/// Projects, tags and handles used lately in one context, newest first.
@immutable
class RecentValues {
  /// Holds the given lists.
  const RecentValues({
    this.projects = const [],
    this.tags = const [],
    this.handles = const [],
  });

  /// Reads what [toJson] wrote; anything unreadable is empty.
  factory RecentValues.fromJson(Object? json) {
    if (json is! Map<String, dynamic>) return const RecentValues();
    List<String> list(String key) => [
      for (final v in json[key] as List<dynamic>? ?? const <dynamic>[])
        if (v is String) v,
    ];
    return RecentValues(
      projects: list('projects'),
      tags: list('tags'),
      handles: list('handles'),
    );
  }

  /// Project keys.
  final List<String> projects;

  /// Tag names.
  final List<String> tags;

  /// Actor handles.
  final List<String> handles;

  /// How many of each are kept.
  static const keep = 8;

  /// These with [projects], [tags] and [handles] moved to the front.
  RecentValues adding({
    Iterable<String> projects = const [],
    Iterable<String> tags = const [],
    Iterable<String> handles = const [],
  }) {
    List<String> merge(Iterable<String> add, List<String> had) {
      final front = add.where((v) => v.isNotEmpty).toList();
      return [
        ...front,
        ...had.where((v) => !front.contains(v)),
      ].take(keep).toList();
    }

    return RecentValues(
      projects: merge(projects, this.projects),
      tags: merge(tags, this.tags),
      handles: merge(handles, this.handles),
    );
  }

  /// The stored form.
  Map<String, Object?> toJson() => {
    'projects': projects,
    'tags': tags,
    'handles': handles,
  };
}

/// The recent values of the active context, kept in preferences. Only
/// identifiers are kept: keys, tag names and handles.
@riverpod
class RecentQuickValues extends _$RecentQuickValues {
  String? get _key {
    final c = ref.read(quickContextProvider);
    return c == null ? null : 'quick.recent.$c';
  }

  @override
  RecentValues build() {
    ref.watch(quickContextProvider);
    final key = _key;
    final raw = key == null ? null : ref.watch(keyValueStoreProvider).read(key);
    if (raw == null) return const RecentValues();
    try {
      return RecentValues.fromJson(jsonDecode(raw));
    } on FormatException {
      return const RecentValues();
    }
  }

  /// Moves [project], [tags] and [handle] to the front and stores them.
  Future<void> remember({
    String project = '',
    List<String> tags = const [],
    String handle = '',
  }) async {
    state = state.adding(projects: [project], tags: tags, handles: [handle]);
    final key = _key;
    if (key != null) {
      await ref
          .read(keyValueStoreProvider)
          .write(key, jsonEncode(state.toJson()));
    }
  }
}

/// Whether quick add stays open after adding, for the next line.
@riverpod
class AddAnother extends _$AddAnother {
  static const _key = 'quick.addAnother';

  @override
  bool build() => ref.watch(keyValueStoreProvider).read(_key) == 'true';

  /// Turns it on or off and remembers it.
  Future<void> set({required bool on}) async {
    state = on;
    await ref.read(keyValueStoreProvider).write(_key, '$on');
  }
}

/// How long the preview waits after the last keystroke.
@riverpod
Duration previewDebounce(Ref ref) => const Duration(milliseconds: 300);

/// Whether the server refused the preview in this context, which it does
/// for a credential without the `import` scope.
@Riverpod(keepAlive: true)
class PreviewBlocked extends _$PreviewBlocked {
  @override
  bool build() {
    ref.watch(quickContextProvider);
    return false;
  }

  /// Stops asking for previews until the context changes.
  void block() => state = true;
}

/// What the server makes of the line typed so far: a dry run of tix's
/// import, sent once typing pauses. Only the newest answer is kept.
@riverpod
class QuickPreviewer extends _$QuickPreviewer {
  Timer? _timer;
  int _asked = 0;

  @override
  AsyncValue<QuickPreview?> build() {
    ref.onDispose(() => _timer?.cancel());
    return const AsyncData(null);
  }

  /// Asks what [line] would become in [project], after the debounce.
  void request(String project, String line) {
    _timer?.cancel();
    final asked = ++_asked;
    if (line.trim().isEmpty ||
        project.isEmpty ||
        ref.read(previewBlockedProvider)) {
      state = const AsyncData(null);
      return;
    }
    _timer = Timer(
      ref.read(previewDebounceProvider),
      () => unawaited(_fetch(asked, project, line)),
    );
  }

  Future<void> _fetch(int asked, String project, String line) async {
    try {
      final preview = await ref
          .read(tasksRepositoryProvider)
          .preview(project, line);
      if (asked == _asked && ref.mounted) state = AsyncData(preview);
    } on TixException catch (e, st) {
      if (!ref.mounted) return;
      if (e.kind == TixErrorKind.forbidden) {
        ref.read(previewBlockedProvider.notifier).block();
        state = const AsyncData(null);
      } else if (asked == _asked) {
        state = AsyncError(e, st);
      }
    }
  }
}

/// Adds tasks from quick add and from templates. The sheet and the host
/// watch it, which keeps it alive across a request.
@riverpod
class QuickAdder extends _$QuickAdder {
  @override
  void build() {}

  /// Creates a task in [project] from [line], which the server parses, and
  /// remembers what it used.
  Future<Task> add(String project, String line) async {
    final task = await ref
        .read(tasksRepositoryProvider)
        .quickAdd(project, line);
    ref.read(tasksChangedProvider.notifier).touch();
    final actors = ref.read(quickActorsProvider).value ?? const <Actor>[];
    final handle = actors
        .where((a) => a.id == task.assigneeActorId)
        .map((a) => a.handle)
        .firstOrNull;
    await ref
        .read(recentQuickValuesProvider.notifier)
        .remember(project: project, tags: task.tags, handle: handle ?? '');
    return task;
  }

  /// Creates a task from the fields of Add with details, sent as they were
  /// written, and remembers what it used.
  Future<Task> addDetailed(TaskDetails details) async {
    final task = await ref
        .read(tasksRepositoryProvider)
        .create(details.request);
    ref.read(tasksChangedProvider.notifier).touch();
    await ref
        .read(recentQuickValuesProvider.notifier)
        .remember(
          project: details.project,
          tags: task.tags,
          handle: details.assignee.trim(),
        );
    return task;
  }

  /// Creates a task from [template], in [project] when given.
  Future<Task> use(TaskTemplate template, {String? project}) async {
    final task = await ref
        .read(templatesRepositoryProvider)
        .use(template.id, project: project);
    ref
      ..invalidate(quickTemplatesProvider)
      ..read(tasksChangedProvider.notifier).touch();
    return task;
  }
}

/// What Add with details was filled in with, each field as typed.
@immutable
class TaskDetails {
  /// The fields of a new task titled [title] in [project].
  const TaskDetails({
    required this.project,
    required this.title,
    this.body = '',
    this.priority,
    this.due,
    this.assignee = '',
    this.tags = '',
    this.repeat = '',
    this.parent = '',
    this.dependsOn = '',
    this.lease = '',
  });

  /// The project's key.
  final String project;

  /// The title, stored as typed rather than read as a quick-add line.
  final String title;

  /// The Markdown description.
  final String body;

  /// The priority, or null for the server's default.
  final int? priority;

  /// When it is due, or null for never.
  final DateTime? due;

  /// The assignee's handle or identifier, empty for nobody.
  final String assignee;

  /// Tag names, comma separated.
  final String tags;

  /// A repeat rule such as `every week`.
  final String repeat;

  /// The parent task's reference.
  final String parent;

  /// References of the tasks this one waits on, comma separated.
  final String dependsOn;

  /// How long a claim holds, such as `2h`; empty inherits.
  final String lease;

  /// The create request: structured fields, never parsed, and every empty
  /// one left out so the server applies its default.
  CreateTaskRequest get request {
    String? text(String v) => v.trim().isEmpty ? null : v.trim();
    List<String>? list(String v) {
      final items = [
        for (final p in v.split(','))
          if (p.trim().isNotEmpty) p.trim(),
      ];
      return items.isEmpty ? null : items;
    }

    return CreateTaskRequest(
      projectRef: project,
      title: title.trim(),
      body: text(body),
      priority: priority,
      dueAt: due?.toUtc(),
      assigneeActorId: text(assignee),
      tags: list(tags),
      recurrence: text(repeat),
      parentRef: text(parent),
      dependsOn: list(dependsOn),
      lease: text(lease),
    );
  }
}

/// A task opened lately, for the palette.
@immutable
class RecentTask {
  /// The task [ref] in [projectKey], titled [title] once known.
  const RecentTask({
    required this.ref,
    required this.projectKey,
    this.title = '',
  });

  /// Its reference.
  final String ref;

  /// Its project's key, for its address.
  final String projectKey;

  /// Its title, empty until read.
  final String title;
}

/// Tasks opened in this session, newest first, kept in memory while the
/// quick-action host, which watches it, is mounted.
@riverpod
class RecentTasks extends _$RecentTasks {
  /// How many are kept.
  static const keep = 20;

  @override
  List<RecentTask> build() {
    ref.watch(quickContextProvider);
    return const [];
  }

  /// Notes that [taskRef] in [projectKey] was opened, and reads its title.
  Future<void> visit(String taskRef, String projectKey) async {
    final had = state.where((t) => t.ref == taskRef).firstOrNull;
    state = [
      had ?? RecentTask(ref: taskRef, projectKey: projectKey),
      ...state.where((t) => t.ref != taskRef),
    ].take(keep).toList();
    if (had != null && had.title.isNotEmpty) return;
    final Task task;
    try {
      task = await ref.read(tasksRepositoryProvider).task(taskRef);
    } on TixException {
      // The title is a courtesy: the entry still opens the task by reference.
      return;
    }
    if (!ref.mounted) return;
    state = [
      for (final t in state)
        if (t.ref == taskRef)
          RecentTask(ref: t.ref, projectKey: projectKey, title: task.title)
        else
          t,
    ];
  }
}

/// The word under the cursor when it opens with a sigil quick add completes.
@immutable
class Completion {
  /// [sigil] then [partial], spanning [start] to [end] of the line.
  const Completion({
    required this.sigil,
    required this.partial,
    required this.start,
    required this.end,
  });

  /// `#`, `@` or `+`.
  final String sigil;

  /// What follows the sigil so far.
  final String partial;

  /// Where the word starts.
  final int start;

  /// Where the word ends.
  final int end;
}

/// The completion for the word of [text] around [cursor], or null. Only the
/// sigil is looked at, to know what to offer; the line is never read for
/// meaning, which is the server's.
Completion? completionAt(String text, int cursor) {
  if (cursor < 0 || cursor > text.length) return null;
  var start = cursor;
  while (start > 0 && !_space(text[start - 1])) {
    start--;
  }
  var end = cursor;
  while (end < text.length && !_space(text[end])) {
    end++;
  }
  if (end - start < 1) return null;
  final sigil = text[start];
  if (!'#@+'.contains(sigil)) return null;
  return Completion(
    sigil: sigil,
    partial: text.substring(start + 1, end),
    start: start,
    end: end,
  );
}

bool _space(String c) => c == ' ' || c == '\t';

/// [values] matching [partial], [recent] first, then by name, at most
/// [limit].
List<T> rankCompletions<T>(
  Iterable<T> values,
  String partial, {
  required Iterable<String> Function(T) names,
  required String Function(T) id,
  List<String> recent = const [],
  int limit = 8,
}) {
  final p = partial.toLowerCase();
  final matched = [
    for (final v in values)
      if (names(v).any((n) => n.toLowerCase().contains(p))) v,
  ];
  int rank(T v) {
    final r = recent.indexOf(id(v));
    if (r >= 0) return r;
    final starts = names(v).any((n) => n.toLowerCase().startsWith(p));
    return starts ? 100 : 1000;
  }

  matched.sort((a, b) {
    final by = rank(a).compareTo(rank(b));
    return by != 0 ? by : id(a).compareTo(id(b));
  });
  return matched.take(limit).toList();
}
