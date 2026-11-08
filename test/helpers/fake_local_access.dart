// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/platform/local_access.dart';
import 'package:tix_mobile/src/data/local/in_place.dart';
import 'package:tix_mobile/src/data/models/instance.dart';

/// Files outside the app, answered from fields and recorded.
class FakeLocalFileAccess implements LocalFileAccess {
  FakeLocalFileAccess({
    this.inPlace = InPlaceKind.dialogs,
    this.granted = true,
    this.grants = true,
    this.root = '/storage/emulated/0',
    this.folder,
    Map<String, List<FolderEntry>>? folders,
  }) : folders = folders ?? {};

  InPlaceKind inPlace;
  bool granted;

  /// Whether asking for the permission grants it.
  bool grants;
  String root;
  PickedFolder? folder;
  final Map<String, List<FolderEntry>> folders;

  /// Thrown by [checkUsable] when set.
  TixException? unusable;

  /// Thrown by [open] when set.
  TixException? denied;

  /// What [findings] answers.
  SyncFindings found = SyncFindings.none;

  /// Answered by [open] in place of the instance's own path and bookmark.
  AccessGrant? grant;

  int requests = 0;
  final opened = <Instance>[];
  final closed = <Instance>[];
  final released = <PickedFolder>[];
  final checked = <String>[];

  @override
  Future<InPlaceKind> kind() async => inPlace;

  @override
  Future<bool> hasPermission() async => granted;

  @override
  Future<bool> requestPermission() async {
    requests++;
    return granted = grants;
  }

  @override
  Future<String> sharedRoot() async => root;

  @override
  Future<List<FolderEntry>> list(String dir) async => folders[dir] ?? const [];

  @override
  Future<PickedFolder?> pickFolder() async => folder;

  @override
  Future<void> release(PickedFolder folder) async => released.add(folder);

  @override
  Future<AccessGrant> open(Instance instance) async {
    final d = denied;
    if (d != null) throw d;
    opened.add(instance);
    return grant ??
        AccessGrant(dbPath: instance.dbPath, bookmark: instance.bookmark);
  }

  @override
  Future<void> close(Instance instance) async => closed.add(instance);

  @override
  Future<void> checkUsable(String dbPath, {bool create = false}) async {
    checked.add(dbPath);
    final u = unusable;
    if (u != null) throw u;
  }

  @override
  Future<SyncFindings> findings(String dbPath) async => found;
}
