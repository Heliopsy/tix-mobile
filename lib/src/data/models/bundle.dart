// SPDX-License-Identifier: AGPL-3.0-or-later

/// Bundles of workflows, tags and webhooks, and tenant snapshots coming
/// back in, as the generated client reads them.
library;

export 'package:tix_mobile/src/data/api/gen/models.gen.dart'
    show
        BundleExportInput,
        BundleResult,
        ComponentAction,
        ComponentKind,
        ComponentOutcome,
        ImportResult;

/// What a bundle import does with a component whose key is taken.
enum BundleCollision {
  /// Keeps the existing one.
  skip,

  /// Imports under a new key.
  rename,

  /// Overwrites the existing one.
  replace,
}

/// How a snapshot import treats what is already there.
enum SnapshotImportMode {
  /// Adds and updates.
  merge,

  /// Also removes the tasks and fields of an imported project the snapshot
  /// does not carry.
  replace,
}
