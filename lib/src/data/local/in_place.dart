// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:io';
import 'dart:math';

import 'package:meta/meta.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';

/// Why a file cannot be opened in place.
enum InPlaceRefusal {
  /// Nothing can be created in the file's folder, so SQLite cannot write
  /// its `-wal` and `-shm` files there.
  folderNotWritable,

  /// The file is not an SQLite database, or not one this device holds yet:
  /// a cloud provider's placeholder reads as something else.
  notDatabase,

  /// The file cannot be locked, which SQLite needs to keep it whole.
  notLockable,

  /// A cloud file that has not been downloaded to this device.
  notDownloaded,
}

/// What sits next to a database that a person should know about before
/// trusting it: sync-conflict copies and a write-ahead log left behind.
@immutable
class SyncFindings {
  /// Creates findings.
  const SyncFindings({this.conflicts = const [], this.walLeftOver = false});

  /// No findings.
  static const none = SyncFindings();

  /// File names of sync-conflict copies of the database, in its folder.
  final List<String> conflicts;

  /// Whether a `-wal` file was beside the database before the engine
  /// opened it: another program has it open, or a sync client copied one.
  final bool walLeftOver;

  /// Whether there is anything to say.
  bool get isEmpty => conflicts.isEmpty && !walLeftOver;

  @override
  bool operator ==(Object other) =>
      other is SyncFindings &&
      other.walLeftOver == walLeftOver &&
      _sameList(other.conflicts, conflicts);

  @override
  int get hashCode => Object.hash(walLeftOver, Object.hashAll(conflicts));

  static bool _sameList(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

const _sqliteHeader = 'SQLite format 3\u0000';

final _separator = RegExp(r'[/\\]');

/// The folder and file name of [path].
(String dir, String name) splitPath(String path) {
  final i = path.lastIndexOf(_separator);
  return i < 0 ? ('.', path) : (path.substring(0, i), path.substring(i + 1));
}

/// The names among [siblings] that sync clients give conflict copies of
/// the database [name]: Nextcloud's `name (conflicted copy ...).db`,
/// Syncthing's `name.sync-conflict-....db`, Dropbox's and others'
/// `name (1).db`, iCloud's `name 2.db`, and anything else naming a conflict.
List<String> conflictCopies(String name, Iterable<String> siblings) {
  final lower = name.toLowerCase();
  final dot = lower.lastIndexOf('.');
  final stem = dot <= 0 ? lower : lower.substring(0, dot);
  final ext = dot <= 0 ? '' : lower.substring(dot);
  final numbered = RegExp(
    '^${RegExp.escape(stem)}(?: \\(\\d+\\)| \\d+)${RegExp.escape(ext)}\$',
  );
  return [
    for (final s in siblings)
      if (s.toLowerCase() != lower &&
          s.toLowerCase().startsWith(stem) &&
          !_isSqliteSibling(s.toLowerCase(), lower) &&
          (s.toLowerCase().contains('conflict') ||
              numbered.hasMatch(s.toLowerCase())))
        s,
  ]..sort();
}

bool _isSqliteSibling(String s, String db) =>
    s == '$db-wal' || s == '$db-shm' || s == '$db-journal';

/// Looks next to the database at [path] for conflict copies and a
/// leftover write-ahead log. A folder that cannot be listed finds nothing.
Future<SyncFindings> syncFindings(String path) async {
  final (dir, name) = splitPath(path);
  final names = <String>[];
  try {
    await for (final e in Directory(dir).list()) {
      names.add(splitPath(e.path).$2);
    }
  } on FileSystemException {
    return SyncFindings.none;
  }
  return SyncFindings(
    conflicts: conflictCopies(name, names),
    walLeftOver: names.contains('$name-wal'),
  );
}

/// Checks that SQLite can use the database at [path] where it is: its
/// folder takes new files, and an existing file is an SQLite database it
/// can lock. A file that does not exist yet passes when [create]. Throws a
/// [TixException] of kind [TixErrorKind.localNotUsable] naming the
/// [InPlaceRefusal] otherwise.
Future<void> probeInPlace(String path, {bool create = false}) async {
  final (dir, _) = splitPath(path);
  final probe = File(
    '$dir${Platform.pathSeparator}.tix-probe-'
    '${Random().nextInt(1 << 32).toRadixString(16)}',
  );
  try {
    await probe.writeAsString('');
    await probe.delete();
  } on FileSystemException catch (e) {
    throw _refused(InPlaceRefusal.folderNotWritable, e.message);
  }
  final file = File(path);
  if (!file.existsSync()) {
    if (create) return;
    throw TixException(TixErrorKind.notFound, message: path);
  }
  RandomAccessFile? raf;
  try {
    raf = await file.open(mode: FileMode.append);
    final length = await raf.length();
    if (length > 0) {
      await raf.setPosition(0);
      final head = await raf.read(_sqliteHeader.length);
      if (String.fromCharCodes(head) != _sqliteHeader) {
        throw _refused(InPlaceRefusal.notDatabase, path);
      }
    }
    try {
      await raf.lock();
      await raf.unlock();
    } on FileSystemException catch (e) {
      throw _refused(InPlaceRefusal.notLockable, e.message);
    }
  } on FileSystemException catch (e) {
    throw _refused(InPlaceRefusal.notDatabase, e.message);
  } finally {
    await raf?.close();
  }
}

TixException _refused(InPlaceRefusal why, String detail) => TixException(
  TixErrorKind.localNotUsable,
  message: detail,
  details: {'reason': why.name},
);
