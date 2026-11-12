// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/session/people.dart';
import 'package:tix_mobile/src/data/repositories/transfer_repository.dart';
import 'package:tix_mobile/src/features/transfer/application/transfer.dart';

part 'import_wizard.g.dart';

/// The steps of an import, in order, as the web names them.
enum ImportStep {
  /// A file or a pasted list.
  source,

  /// Which field each column fills.
  columns,

  /// What each status, priority and assignee becomes.
  valueMap,

  /// The counts, the rows in error and the first rows.
  preview,

  /// What the import did.
  result,
}

/// What an import does with a row that matches a task imported before.
enum ImportMode {
  /// Update matched tasks, create the rest.
  upsert,

  /// Create every row as a new task.
  create,

  /// Leave matched tasks alone, create the rest.
  skip,
}

/// The fields a column can fill, in tix's order (`taskio.Targets`). Custom
/// fields follow as `custom:KEY`.
const importTargets = [
  'title',
  'body',
  'status',
  'priority',
  'assignee',
  'tags',
  'due',
  'parent',
  'depends_on',
  'recurrence',
  'external_id',
  'alias',
  'ref',
  'append_body',
  'ignore',
];

/// The fields whose values are mapped, in the order the values step shows.
const importValueFields = ['status', 'priority', 'assignee'];

/// The priorities a value can become, highest first.
const importPriorities = ['highest', 'high', 'normal', 'low', 'lowest'];

/// What may happen to a value with no mapping, per field, as the web offers.
const importPolicies = {
  'status': ['default', 'skip_row', 'error'],
  'priority': ['default', 'skip_row', 'error'],
  'assignee': ['ignore', 'skip_row', 'error'],
};

/// The policy tix applies to a field that names none.
const importDefaultPolicies = {
  'status': 'default',
  'priority': 'default',
  'assignee': 'ignore',
};

/// The rows a dry run shows, tix's most.
const importPreviewRows = 200;

/// An import in progress: what was chosen so far and what the server said.
@immutable
class ImportDraft {
  /// A draft on [project], at [step].
  const ImportDraft({
    required this.project,
    this.step = ImportStep.source,
    this.filename = '',
    this.content = '',
    this.lines = '',
    this.columns = const {},
    this.columnsSeen = false,
    this.values = const {},
    this.valuesSeen = false,
    this.unknown = const {},
    this.mode = ImportMode.upsert,
    this.result,
    this.committed,
    this.busy = false,
    this.error,
  });

  /// The project the tasks go into.
  final String project;

  /// The step shown.
  final ImportStep step;

  /// The chosen file's name, empty when none is.
  final String filename;

  /// The chosen file's text.
  final String content;

  /// A pasted list of tasks, one per line in quick-add syntax.
  final String lines;

  /// The targets the person chose, by column header.
  final Map<String, String> columns;

  /// Whether the columns step was left, so every column is written down.
  final bool columnsSeen;

  /// The values the person chose, by field and then by the file's value;
  /// empty is "no mapping".
  final Map<String, Map<String, String>> values;

  /// Whether the values step was left, so the suggestions are written down.
  final bool valuesSeen;

  /// The unknown-value policy chosen per field.
  final Map<String, String> unknown;

  /// What a matched row does.
  final ImportMode mode;

  /// The last dry run.
  final TaskImportResult? result;

  /// The import itself, once run.
  final TaskImportResult? committed;

  /// Whether a request is in flight.
  final bool busy;

  /// The last refusal, cleared by the next request.
  final TixException? error;

  /// Whether the pasted list is what gets imported: no file is chosen.
  bool get pasted => filename.isEmpty;

  /// Whether there is anything to read.
  bool get ready => pasted ? lines.trim().isNotEmpty : content.isNotEmpty;

  /// The target column [c] fills: the person's choice, else the server's.
  String target(TaskImportColumn c) => columns[c.header] ?? c.target;

  /// What [v], a value of [field], becomes: the person's choice, else the
  /// server's.
  String valueOf(String field, TaskImportValue v) =>
      values[field]?[v.value] ?? v.mapped;

  /// The policy for [field]'s values with no mapping.
  String policy(String field) =>
      unknown[field] ?? importDefaultPolicies[field] ?? 'default';

  /// The choices as a JSON mapping file, which tix's reader takes as YAML;
  /// null when there is nothing to say and the server's suggestion stands.
  String? get mapping {
    if (pasted) return null;
    final r = result;
    final cols = <String, String>{
      if (r != null && columnsSeen)
        for (final c in r.columns) c.header: target(c),
    };
    final vals = <String, Map<String, String>>{};
    for (final field in importValueFields) {
      final out = <String, String>{
        if (r != null && valuesSeen)
          for (final v in r.values[field] ?? const <TaskImportValue>[])
            if (valueOf(field, v).trim().isNotEmpty)
              v.value: valueOf(field, v).trim(),
        for (final MapEntry(:key, :value) in (values[field] ?? {}).entries)
          if (value.trim().isNotEmpty) key: value.trim(),
      };
      if (out.isNotEmpty) vals[field] = out;
    }
    if (cols.isEmpty && vals.isEmpty && unknown.isEmpty) return null;
    return jsonEncode({
      'version': 1,
      if (cols.isNotEmpty) 'columns': cols,
      if (vals.isNotEmpty) 'values': vals,
      if (unknown.isNotEmpty) 'unknown': unknown,
    });
  }

  /// A copy with the given fields changed; [error] is cleared unless given.
  ImportDraft copyWith({
    String? project,
    ImportStep? step,
    String? filename,
    String? content,
    String? lines,
    Map<String, String>? columns,
    bool? columnsSeen,
    Map<String, Map<String, String>>? values,
    bool? valuesSeen,
    Map<String, String>? unknown,
    ImportMode? mode,
    TaskImportResult? result,
    TaskImportResult? committed,
    bool? busy,
    TixException? error,
  }) => ImportDraft(
    project: project ?? this.project,
    step: step ?? this.step,
    filename: filename ?? this.filename,
    content: content ?? this.content,
    lines: lines ?? this.lines,
    columns: columns ?? this.columns,
    columnsSeen: columnsSeen ?? this.columnsSeen,
    values: values ?? this.values,
    valuesSeen: valuesSeen ?? this.valuesSeen,
    unknown: unknown ?? this.unknown,
    mode: mode ?? this.mode,
    result: result ?? this.result,
    committed: committed ?? this.committed,
    busy: busy ?? this.busy,
    error: error,
  );

  /// The same source on [project] with every choice and answer dropped.
  ImportDraft fresh({String? project}) => ImportDraft(
    project: project ?? this.project,
    filename: filename,
    content: content,
    lines: lines,
    mode: mode,
  );
}

/// The states of [project]'s workflow, for the values step.
@riverpod
Future<List<({String key, String label})>> importStates(
  Ref ref,
  String project,
) async {
  final repo = ref.watch(transferRepositoryProvider);
  final projects = await ref.watch(transferProjectsProvider.future);
  final workflow = projects
      .where((p) => p.key == project)
      .map((p) => p.workflowId)
      .firstOrNull;
  if (workflow == null || workflow.isEmpty) return const [];
  return await repo.workflowStates(workflow);
}

/// The import wizard's state, opened on [project].
@riverpod
class ImportWizard extends _$ImportWizard {
  @override
  ImportDraft build(String project) => ImportDraft(project: project);

  /// Imports into [project] instead, starting the mapping over.
  void setProject(String project) {
    if (project == state.project) return;
    state = state.fresh(project: project);
  }

  /// Reads the file [name] holding [content], starting the mapping over.
  void chooseFile(String name, String content) => state = ImportDraft(
    project: state.project,
    filename: name,
    content: content,
    lines: state.lines,
    mode: state.mode,
  );

  /// Drops the chosen file, so the pasted list is read.
  void clearFile() => state = ImportDraft(
    project: state.project,
    lines: state.lines,
    mode: state.mode,
  );

  /// Keeps [text] as the pasted list.
  void setLines(String text) {
    if (text == state.lines) return;
    state = state.pasted
        ? state.fresh().copyWith(lines: text)
        : state.copyWith(lines: text);
  }

  /// Sets the target of the column [header].
  void setColumn(String header, String target) =>
      state = state.copyWith(columns: {...state.columns, header: target});

  /// Sets what the value [raw] of [field] becomes; empty is no mapping.
  void setValue(String field, String raw, String to) => state = state.copyWith(
    values: {
      ...state.values,
      field: {...?state.values[field], raw: to},
    },
  );

  /// Sets what happens to [field]'s values with no mapping.
  void setPolicy(String field, String policy) =>
      state = state.copyWith(unknown: {...state.unknown, field: policy});

  /// Sets the mode and runs the dry run again when one was shown.
  Future<void> setMode(ImportMode mode) async {
    state = state.copyWith(mode: mode);
    if (state.result != null) await _dryRun(state.step);
  }

  /// Leaves the step shown for the next one, after a dry run.
  Future<void> next() => switch (state.step) {
    ImportStep.source => _dryRun(
      state.pasted ? ImportStep.preview : ImportStep.columns,
    ),
    ImportStep.columns => _dryRunAfterLeaving(ImportStep.valueMap),
    ImportStep.valueMap => _dryRunAfterLeaving(ImportStep.preview),
    ImportStep.preview || ImportStep.result => Future.value(),
  };

  /// Goes straight to the preview from the source or the columns.
  Future<void> skipToPreview() => _dryRunAfterLeaving(ImportStep.preview);

  /// Goes to the step before, keeping every choice.
  void back() {
    _leave();
    final to = switch (state.step) {
      ImportStep.source || ImportStep.columns => ImportStep.source,
      ImportStep.valueMap => ImportStep.columns,
      ImportStep.preview =>
        state.pasted ? ImportStep.source : ImportStep.valueMap,
      ImportStep.result => ImportStep.preview,
    };
    state = state.copyWith(step: to);
  }

  /// Imports for real and shows the result.
  Future<void> commit() async {
    state = state.copyWith(busy: true);
    try {
      final done = await _send(commit: true);
      state = state.copyWith(
        busy: false,
        committed: done,
        step: ImportStep.result,
      );
    } on TixException catch (e) {
      state = state.copyWith(busy: false, error: e);
    }
  }

  /// Starts again on the same project with nothing chosen.
  void restart() => state = ImportDraft(project: state.project);

  void _leave() {
    switch (state.step) {
      case ImportStep.columns:
        state = state.copyWith(columnsSeen: true);
      case ImportStep.valueMap:
        state = state.copyWith(valuesSeen: true);
      case ImportStep.source || ImportStep.preview || ImportStep.result:
    }
  }

  Future<void> _dryRunAfterLeaving(ImportStep to) {
    _leave();
    return _dryRun(to);
  }

  Future<void> _dryRun(ImportStep to) async {
    state = state.copyWith(busy: true);
    try {
      final result = await _send(commit: false);
      state = state.copyWith(busy: false, result: result, step: to);
    } on TixException catch (e) {
      state = state.copyWith(busy: false, error: e);
    }
  }

  Future<TaskImportResult> _send({required bool commit}) {
    final d = state;
    return ref
        .read(transferRepositoryProvider)
        .importTasks(
          d.project,
          content: d.pasted ? d.lines : d.content,
          filename: d.pasted ? null : d.filename,
          format: d.pasted ? 'lines' : null,
          mapping: d.mapping,
          mode: d.mode.name,
          commit: commit,
          preview: importPreviewRows,
        );
  }
}

/// The rows of [result] in error as a CSV report: the line, the error, and
/// the row's fields when the preview holds it.
String importErrorsCsv(TaskImportResult result) {
  final rows = {for (final r in result.preview) r.line: r};
  final errors = [
    for (final e in result.errors) (line: e.line, message: e.message),
    for (final r in result.preview)
      if (r.action == 'error' && !result.errors.any((e) => e.line == r.line))
        for (final m in r.errors.isEmpty ? [r.reason] : r.errors)
          (line: r.line, message: m),
  ];
  final out = StringBuffer()
    ..write(
      'line,error,ref,title,status,priority,assignee,tags,due,parent,'
      'external_id\n',
    );
  for (final e in errors) {
    final r = rows[e.line];
    final cells = [
      '${e.line}',
      e.message,
      r?.ref ?? '',
      r?.title ?? '',
      r?.status ?? '',
      if (r != null && r.priority >= 1 && r.priority <= 5)
        importPriorities[r.priority - 1]
      else
        '',
      r?.assignee ?? '',
      r?.tags.join(', ') ?? '',
      r?.due?.toUtc().toIso8601String() ?? '',
      r?.parent ?? '',
      r?.externalId ?? '',
    ];
    out
      ..write(cells.map(_csvCell).join(','))
      ..write('\n');
  }
  return out.toString();
}

String _csvCell(String raw) {
  final guarded = raw.isNotEmpty && '=+-@\t\r'.contains(raw[0]) ? "'$raw" : raw;
  if (!guarded.contains(RegExp('[",\r\n]'))) return guarded;
  return '"${guarded.replaceAll('"', '""')}"';
}
