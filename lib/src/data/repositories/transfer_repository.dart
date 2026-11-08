// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';
import 'dart:typed_data';

import 'package:tix_mobile/src/data/api/gen/models.gen.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';

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

  /// Reads [content], a file called [filename], into [project]: a dry run
  /// unless [commit] (`task.import`).
  Future<TaskImportResult> importTasks(
    String project, {
    required String content,
    required String filename,
    required bool commit,
  }) => _api.task.import(
    project,
    TaskImportInput(
      content: content,
      filename: filename,
      dryRun: !commit,
      preview: commit ? null : 20,
    ),
  );
}
