// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/events/invalidation.dart';
import 'package:tix_mobile/src/core/session/people.dart';
import 'package:tix_mobile/src/data/models/project.dart';
import 'package:tix_mobile/src/data/repositories/transfer_repository.dart';

part 'transfer.g.dart';

/// The formats a task export can be written in, as tix names them.
enum ExportFormat {
  /// Comma-separated, for spreadsheets.
  csv('csv', 'text/csv'),

  /// One JSON array.
  json('json', 'application/json'),

  /// One task per line.
  ndjson('ndjson', 'application/x-ndjson'),

  /// A Markdown table.
  markdown('md', 'text/markdown');

  ExportFormat(this.extension, this.mimeType);

  /// The file extension, which tix also takes as the format's name.
  final String extension;

  /// The media type the file is handed out as.
  final String mimeType;

  /// The value of `format` in the request.
  String get wire => this == markdown ? 'markdown' : name;
}

/// The columns an export may carry, in tix's order (`core.TaskColumns`).
const exportColumns = [
  'ref',
  'title',
  'status',
  'priority',
  'assignee',
  'tags',
  'due',
  'parent',
  'depends_on',
  'recurrence',
  'body',
  'created_at',
  'updated_at',
  'started_at',
  'completed_at',
  'deleted_at',
  'creator',
  'project',
  'id',
  'comments',
  'history',
];

/// The columns an export carries when it names none
/// (`core.DefaultTaskColumns`).
const defaultExportColumns = [
  'ref',
  'title',
  'status',
  'priority',
  'assignee',
  'tags',
  'due',
  'parent',
  'depends_on',
  'recurrence',
  'body',
  'created_at',
  'updated_at',
  'completed_at',
];

/// The CSV delimiters tix accepts.
const exportDelimiters = [',', ';', 'tab', '|'];

/// The date styles tix writes.
const exportDateStyles = ['iso', 'date'];

/// Every project, for the export and import pickers.
@riverpod
Future<List<Project>> transferProjects(Ref ref) async {
  refreshOn(ref, EventTopics.projects);
  return await ref.watch(transferRepositoryProvider).projects();
}

/// The custom fields of [project], offered as export columns.
@riverpod
Future<List<FieldDef>> transferFields(Ref ref, String project) =>
    ref.watch(transferRepositoryProvider).fields(project);

/// Writes exports and runs imports for the screens.
@riverpod
class Transfer extends _$Transfer {
  @override
  void build() {}

  /// [project]'s tasks as a file named for it.
  Future<({String name, Uint8List bytes, String mimeType})> exportTasks({
    required String project,
    required ExportFormat format,
    required List<String> columns,
    String query = '',
    bool finished = true,
    bool subtasks = true,
    bool trashed = false,
    String dates = 'iso',
    String delimiter = ',',
  }) async {
    final bytes = await ref
        .read(transferRepositoryProvider)
        .exportTasks(
          project,
          TaskExportInput(
            format: format.wire,
            columns: columns,
            query: query.trim().isEmpty ? null : query.trim(),
            excludeFinished: !finished,
            excludeSubtasks: !subtasks,
            includeTrashed: trashed,
            dates: dates,
            delimiter: format == ExportFormat.csv ? delimiter : null,
          ),
        );
    return (
      name: '$project-tasks.${format.extension}',
      bytes: bytes,
      mimeType: format.mimeType,
    );
  }

  /// A snapshot of the tenant.
  Future<({String name, Uint8List bytes, String mimeType})> exportSnapshot({
    bool comments = true,
  }) async => (
    name: 'tix-snapshot.ndjson',
    bytes: await ref
        .read(transferRepositoryProvider)
        .exportSnapshot(comments: comments),
    mimeType: 'application/x-ndjson',
  );
}
