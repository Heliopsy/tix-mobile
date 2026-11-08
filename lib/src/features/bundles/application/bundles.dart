// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:typed_data';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/session/server_info.dart';
import 'package:tix_mobile/src/data/models/bundle.dart';

export 'package:tix_mobile/src/data/models/bundle.dart';

part 'bundles.g.dart';

/// The media type tix writes a bundle as.
const bundleMimeType = 'application/vnd.tix.bundle+json';

/// The kinds a bundle can carry, in the order the export lists them.
const bundleKinds = <ComponentKind>[
  ComponentKind.workflow,
  ComponentKind.fieldDef,
  ComponentKind.tag,
  ComponentKind.projectTemplate,
  ComponentKind.webhook,
];

/// Bundles out and in, and snapshots in, for the screens. It holds nothing:
/// each call is about one file.
@riverpod
class BundleTransfer extends _$BundleTransfer {
  @override
  void build() {}

  /// A bundle of [kinds], every kind when empty, labelled [name], as a file
  /// named for it.
  Future<({String name, Uint8List bytes})> export({
    Set<ComponentKind> kinds = const {},
    String name = '',
  }) async {
    final label = name.trim();
    final bytes = await ref
        .read(bundleRepositoryProvider)
        .export(
          kinds: [
            for (final k in bundleKinds)
              if (kinds.contains(k)) k,
          ],
          name: label,
        );
    final slug = label
        .toLowerCase()
        .replaceAll(RegExp('[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    return (
      name: slug.isEmpty ? 'tix-bundle.json' : 'tix-bundle-$slug.json',
      bytes: bytes,
    );
  }

  /// Applies the bundle [content], or with [preview] says what it would do.
  Future<BundleResult> import(
    String content, {
    required bool preview,
    BundleCollision? onCollision,
    String projectRef = '',
  }) => ref
      .read(bundleRepositoryProvider)
      .import(
        content,
        preview: preview,
        onCollision: onCollision,
        projectRef: projectRef.trim(),
      );

  /// Reads the snapshot [content] in, or with [dryRun] counts what it would
  /// do.
  Future<ImportResult> importSnapshot(
    String content, {
    required SnapshotImportMode mode,
    required bool dryRun,
  }) => ref
      .read(bundleRepositoryProvider)
      .importSnapshot(content, mode: mode, dryRun: dryRun);
}
