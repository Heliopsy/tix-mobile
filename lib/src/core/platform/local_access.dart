// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/data/local/in_place.dart';
import 'package:tix_mobile/src/data/models/instance.dart';

part 'local_access.g.dart';

/// How this platform reaches a database used in place.
enum InPlaceKind {
  /// Not at all: databases are imported.
  none,

  /// The system open and save dialogs hand over real paths (Linux, Windows).
  dialogs,

  /// Real paths in shared storage, with All files access (Android).
  sharedStorage,

  /// A picked folder, kept as a security-scoped bookmark (iOS, macOS).
  bookmark,
}

/// A folder the person picked, with the bookmark that reaches it again.
@immutable
class PickedFolder {
  /// Creates a pick.
  const PickedFolder({required this.path, this.bookmark = ''});

  /// Where the folder is now.
  final String path;

  /// The security-scoped bookmark of the folder, empty when none is needed.
  final String bookmark;
}

/// One entry of a folder listing: a folder or a database file.
@immutable
class FolderEntry {
  /// Creates an entry.
  const FolderEntry({required this.name, required this.path, this.dir = false});

  /// The entry's name.
  final String name;

  /// Its full path.
  final String path;

  /// Whether it is a folder.
  final bool dir;
}

/// Where a database used in place is, once access to it has started.
@immutable
class AccessGrant {
  /// Creates a grant.
  const AccessGrant({required this.dbPath, this.bookmark = ''});

  /// The database's path now; it moves when its folder did.
  final String dbPath;

  /// The bookmark, renewed when the old one was stale.
  final String bookmark;
}

/// Files outside the app's own storage: permissions, folder bookmarks and
/// the checks that keep SQLite safe on them. Behind an interface so tests
/// reach no channel and no file system.
abstract interface class LocalFileAccess {
  /// How this platform reaches a database in place.
  Future<InPlaceKind> kind();

  /// Whether the app may read and write shared storage (Android).
  Future<bool> hasPermission();

  /// Asks for All files access; whether it was granted.
  Future<bool> requestPermission();

  /// The root of shared storage (Android), where browsing starts.
  Future<String> sharedRoot();

  /// The folders and database files in [dir], folders first.
  Future<List<FolderEntry>> list(String dir);

  /// Asks for a folder and bookmarks it (iOS, macOS), with access to it
  /// started until [release]; null when cancelled.
  Future<PickedFolder?> pickFolder();

  /// Ends the access [pickFolder] started.
  Future<void> release(PickedFolder folder);

  /// Starts access to [instance]'s database before its engine opens it.
  Future<AccessGrant> open(Instance instance);

  /// Ends the access [open] started.
  Future<void> close(Instance instance);

  /// Throws when SQLite cannot use the database at [dbPath] in place; a
  /// missing file passes when [create].
  Future<void> checkUsable(String dbPath, {bool create = false});

  /// Conflict copies and a leftover log next to the database at [dbPath].
  Future<SyncFindings> findings(String dbPath);
}

/// [LocalFileAccess] over the platform channel `red.tix/local_access`.
class SystemLocalFileAccess implements LocalFileAccess {
  /// Creates the service.
  const SystemLocalFileAccess();

  static const _channel = MethodChannel('red.tix/local_access');

  static const _dbExtensions = ['.db', '.sqlite', '.sqlite3'];

  bool get _apple => Platform.isIOS || Platform.isMacOS;

  @override
  Future<InPlaceKind> kind() async {
    if (Platform.isLinux || Platform.isWindows) return InPlaceKind.dialogs;
    if (_apple) return InPlaceKind.bookmark;
    if (Platform.isAndroid) {
      final declared = await _channel.invokeMethod<bool>('declared') ?? false;
      return declared ? InPlaceKind.sharedStorage : InPlaceKind.none;
    }
    return InPlaceKind.none;
  }

  @override
  Future<bool> hasPermission() async =>
      !Platform.isAndroid ||
      (await _channel.invokeMethod<bool>('granted') ?? false);

  @override
  Future<bool> requestPermission() async =>
      !Platform.isAndroid ||
      (await _channel.invokeMethod<bool>('request') ?? false);

  @override
  Future<String> sharedRoot() async =>
      await _channel.invokeMethod<String>('root') ?? '/storage/emulated/0';

  @override
  Future<List<FolderEntry>> list(String dir) async {
    final entries = <FolderEntry>[];
    await for (final e in Directory(dir).list(followLinks: false)) {
      final (_, name) = splitPath(e.path);
      if (name.startsWith('.')) continue;
      final isDir = e is Directory;
      final lower = name.toLowerCase();
      if (isDir || _dbExtensions.any(lower.endsWith)) {
        entries.add(FolderEntry(name: name, path: e.path, dir: isDir));
      }
    }
    return entries..sort(
      (a, b) => a.dir != b.dir
          ? (a.dir ? -1 : 1)
          : a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
  }

  @override
  Future<PickedFolder?> pickFolder() async {
    final out = await _channel.invokeMapMethod<String, Object?>('pickFolder');
    if (out == null) return null;
    return PickedFolder(
      path: '${out['path']}',
      bookmark: '${out['bookmark'] ?? ''}',
    );
  }

  @override
  Future<void> release(PickedFolder folder) async {
    if (!_apple) return;
    await _channel.invokeMethod<void>('close', {'path': folder.path});
  }

  @override
  Future<AccessGrant> open(Instance instance) async {
    if (!instance.inPlace) return AccessGrant(dbPath: instance.dbPath);
    if (Platform.isAndroid && !await hasPermission()) {
      throw const TixException(TixErrorKind.localAccessDenied);
    }
    if (instance.bookmark.isEmpty || !_apple) {
      return AccessGrant(dbPath: instance.dbPath);
    }
    final Map<String, Object?>? out;
    try {
      out = await _channel.invokeMapMethod<String, Object?>('open', {
        'bookmark': instance.bookmark,
      });
    } on PlatformException catch (e) {
      throw TixException(
        TixErrorKind.localAccessDenied,
        message: e.message ?? e.code,
      );
    }
    final folder = '${out?['path'] ?? ''}';
    if (folder.isEmpty) {
      throw const TixException(TixErrorKind.localAccessDenied);
    }
    final (_, name) = splitPath(instance.dbPath);
    return AccessGrant(
      dbPath: '$folder/$name',
      bookmark: '${out?['bookmark'] ?? instance.bookmark}',
    );
  }

  @override
  Future<void> close(Instance instance) async {
    if (!instance.inPlace || instance.bookmark.isEmpty || !_apple) return;
    await _channel.invokeMethod<void>('close', {
      'path': splitPath(instance.dbPath).$1,
    });
  }

  @override
  Future<void> checkUsable(String dbPath, {bool create = false}) async {
    if (_apple && File(dbPath).existsSync()) {
      final downloaded =
          await _channel.invokeMethod<bool>('downloaded', {'path': dbPath}) ??
          true;
      if (!downloaded) {
        throw const TixException(
          TixErrorKind.localNotUsable,
          details: {'reason': 'notDownloaded'},
        );
      }
    }
    await probeInPlace(dbPath, create: create);
  }

  @override
  Future<SyncFindings> findings(String dbPath) => syncFindings(dbPath);
}

/// The platform's access to files outside the app.
@Riverpod(keepAlive: true)
LocalFileAccess localFileAccess(Ref ref) => const SystemLocalFileAccess();

/// How this platform reaches a database used in place.
@Riverpod(keepAlive: true)
Future<InPlaceKind> localInPlaceKind(Ref ref) =>
    ref.watch(localFileAccessProvider).kind();
