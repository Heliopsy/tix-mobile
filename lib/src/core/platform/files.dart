// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:io';
import 'dart:ui' show Rect;

import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';

part 'files.g.dart';

/// Choosing database files, behind an interface so tests reach no channel.
abstract interface class FilePicking {
  /// Whether the engine works on the file the person picks, where it is.
  /// Elsewhere (phones, and the sandboxed macOS app) it works on a copy in
  /// the app's documents folder: imported in, exported out.
  bool get opensInPlace;

  /// Asks for an existing database file to use in place; null when
  /// cancelled.
  Future<String?> openDatabase();

  /// Asks for a database file and copies it into the app's documents
  /// folder, returning the copy; null when cancelled.
  Future<String?> importDatabase();

  /// Hands a copy of the database at [path] to the person: the share sheet
  /// on phones, a save dialog on macOS. [origin] anchors the sheet on
  /// tablets. Whether it went anywhere.
  Future<bool> exportDatabase(String path, {Rect? origin});

  /// Asks where to create a database, suggesting [name]; null when cancelled.
  Future<String?> newDatabase(String name);

  /// The path of a database called [name] in the app's documents folder.
  Future<String> documentsDatabase(String name);
}

/// [FilePicking] with file_selector and path_provider.
class SystemFilePicking implements FilePicking {
  /// Creates the picker.
  const SystemFilePicking();

  static const _databases = XTypeGroup(
    label: 'tix',
    extensions: ['db', 'sqlite', 'sqlite3'],
    uniformTypeIdentifiers: ['public.database', 'public.data'],
  );

  // Platform service, not layout. SQLite writes -wal and -shm files beside
  // the database, which the macOS sandbox does not let the app create next
  // to a file the person picked, and phones hand over a copy anyway.
  @override
  bool get opensInPlace => Platform.isLinux || Platform.isWindows;

  // Android and iOS pickers filter by MIME type, and no system knows a
  // .db file's, so they show every file.
  List<XTypeGroup> get _filter =>
      Platform.isAndroid || Platform.isIOS ? const [] : const [_databases];

  @override
  Future<String?> openDatabase() async {
    final file = await openFile(acceptedTypeGroups: _filter);
    return file?.path;
  }

  @override
  Future<String?> importDatabase() async {
    final file = await openFile(acceptedTypeGroups: _filter);
    if (file == null) return null;
    final dir = await getApplicationDocumentsDirectory();
    final target = uniqueDatabasePath(
      dir.path,
      withDbExtension(file.name),
      (p) => File(p).existsSync(),
    );
    await file.saveTo(target);
    return target;
  }

  @override
  Future<bool> exportDatabase(String path, {Rect? origin}) async {
    final name = path.split(RegExp(r'[/\\]')).last;
    if (Platform.isMacOS) {
      final location = await getSaveLocation(
        suggestedName: name,
        acceptedTypeGroups: const [_databases],
      );
      if (location == null) return false;
      await File(path).copy(location.path);
      return true;
    }
    final result = await SharePlus.instance.share(
      ShareParams(
        files: [XFile(path, mimeType: 'application/vnd.sqlite3')],
        fileNameOverrides: [name],
        sharePositionOrigin: origin,
      ),
    );
    return result.status == ShareResultStatus.success;
  }

  @override
  Future<String?> newDatabase(String name) async {
    final location = await getSaveLocation(
      suggestedName: withDbExtension(name),
      acceptedTypeGroups: const [_databases],
    );
    return location?.path;
  }

  @override
  Future<String> documentsDatabase(String name) async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}${Platform.pathSeparator}${withDbExtension(name)}';
  }
}

/// [name] in [dir], numbered (`notes-2.db`) when [exists] says it is taken.
String uniqueDatabasePath(
  String dir,
  String name,
  bool Function(String path) exists,
) {
  final sep = Platform.pathSeparator;
  final stem = name.substring(0, name.length - 3);
  var path = '$dir$sep$name';
  for (var n = 2; exists(path); n++) {
    path = '$dir$sep$stem-$n.db';
  }
  return path;
}

/// [name] trimmed, with `.db` added unless it ends so already.
String withDbExtension(String name) {
  final n = name.trim().isEmpty ? 'tix' : name.trim();
  return n.toLowerCase().endsWith('.db') ? n : '$n.db';
}

/// The platform's file dialogs.
@Riverpod(keepAlive: true)
FilePicking filePicking(Ref ref) => const SystemFilePicking();
