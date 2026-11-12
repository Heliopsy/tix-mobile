// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';
import 'dart:typed_data';

import 'package:tix_mobile/src/data/api/gen/models.gen.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';

export 'package:tix_mobile/src/data/api/gen/models.gen.dart'
    show TaskImportColumn, TaskImportValue;
export 'package:tix_mobile/src/data/models/people.dart';

/// Tasks and snapshots out of tix as files, and tasks into it.
class TransferRepository {
  /// Talks through [_api].
  TransferRepository(this._api);

  final TixApi _api;

  /// Every project, each page in turn (`project.list`).
  Future<List<Project>> projects() async {
    final out = <Project>[];
    String? cursor;
    do {
      final page = await _api.project.list(cursor: cursor, limit: 200);
      out.addAll(page.items);
      cursor = page.nextCursor;
    } while (cursor != null);
    return out;
  }

  /// The custom fields of [project], which are export columns too
  /// (`field.list`).
  Future<List<FieldDef>> fields(String project) async =>
      (await _api.field.list(project)).items;

  /// [project]'s tasks as the file [request] describes, byte for byte as
  /// the server wrote it (`task.export`).
  Future<Uint8List> exportTasks(String project, TaskExportInput request) =>
      _api.task.exportFile(project, body: request);

  /// A snapshot of the whole tenant as NDJSON (`snapshot.export`).
  Future<Uint8List> exportSnapshot({
    bool comments = true,
    bool artifacts = false,
  }) async => utf8.encode(
    await _api.snapshot.export(
      body: ExportInput(includeComments: comments, includeArtifacts: artifacts),
    ),
  );

  /// Reads [content] into [project]: a dry run showing [preview] rows
  /// unless [commit] (`task.import`). [filename] and [format] say how to read
  /// it, [mapping] is a mapping file and [mode] what a matched row does; the
  /// server decides what each means.
  Future<TaskImportResult> importTasks(
    String project, {
    required String content,
    required bool commit,
    String? filename,
    String? format,
    String? mapping,
    String? mode,
    int preview = 20,
  }) => _api.task.import(
    project,
    TaskImportInput(
      content: content,
      filename: filename,
      format: format,
      mapping: mapping,
      mode: mode,
      dryRun: !commit,
      preview: commit ? null : preview,
    ),
  );

  /// The states of the workflow [key] or id, in its order, as key and label
  /// (`workflow.get`).
  Future<List<({String key, String label})>> workflowStates(String key) async {
    final states = (await _api.workflow.get(key)).definition?.states;
    if (states == null) return const [];
    return [
      for (final s in states)
        if ((s.key ?? '').isNotEmpty)
          (key: s.key!, label: (s.label ?? '').isEmpty ? s.key! : s.label!),
    ];
  }
}
