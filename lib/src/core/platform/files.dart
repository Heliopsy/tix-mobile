// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'files.g.dart';

/// Choosing database files, behind an interface so tests reach no channel.
abstract interface class FilePicking {
  /// Whether the platform has a save dialog; phones do not.
  bool get canChooseNewFile;

  /// Asks for an existing database file; null when cancelled.
  Future<String?> openDatabase();

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

  // Platform service, not layout: only desktops have a save dialog.
  @override
  bool get canChooseNewFile =>
      Platform.isLinux || Platform.isMacOS || Platform.isWindows;

  @override
  Future<String?> openDatabase() async {
    final file = await openFile(
      acceptedTypeGroups: canChooseNewFile ? const [_databases] : const [],
    );
    return file?.path;
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

/// [name] trimmed, with `.db` added unless it ends so already.
String withDbExtension(String name) {
  final n = name.trim().isEmpty ? 'tix' : name.trim();
  return n.toLowerCase().endsWith('.db') ? n : '$n.db';
}

/// The platform's file dialogs.
@Riverpod(keepAlive: true)
FilePicking filePicking(Ref ref) => const SystemFilePicking();
