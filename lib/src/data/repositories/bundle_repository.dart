// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';
import 'dart:typed_data';

import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/models/bundle.dart';

export 'package:tix_mobile/src/data/models/bundle.dart';

/// Configuration bundles out and in, and tenant snapshots in. Nothing here
/// is cached: each answer is about one file.
class BundleRepository {
  /// Talks through [_api].
  BundleRepository(this._api);

  final TixApi _api;

  /// A bundle of [kinds] (every kind when empty), labelled [name], as the
  /// server wrote it (`bundle.export`).
  Future<Uint8List> export({
    List<ComponentKind> kinds = const [],
    String name = '',
  }) async => utf8.encode(
    await _api.bundle.export(
      body: BundleExportInput(
        kinds: [for (final k in kinds) k.value],
        name: name.isEmpty ? null : name,
      ),
    ),
  );

  /// Applies the bundle [content], or with [preview] reports what it would
  /// do and writes nothing (`bundle.import`).
  Future<BundleResult> import(
    String content, {
    required bool preview,
    BundleCollision? onCollision,
    String projectRef = '',
  }) => _api.bundle.import(
    content,
    preview: preview,
    onCollision: onCollision?.name,
    projectRef: projectRef.isEmpty ? null : projectRef,
  );

  /// Reads the snapshot [content] into the tenant, or with [dryRun] counts
  /// what it would do and writes nothing (`snapshot.import`).
  Future<ImportResult> importSnapshot(
    String content, {
    required SnapshotImportMode mode,
    required bool dryRun,
  }) => _api.snapshot.import(content, mode: mode.name, dryRun: dryRun);
}
