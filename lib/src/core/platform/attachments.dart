// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:file_selector/file_selector.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

part 'attachments.g.dart';

/// A file the person picked, in memory.
@immutable
class PickedFile {
  /// The file [name] holding [bytes] of type [mimeType].
  const PickedFile({
    required this.name,
    required this.bytes,
    required this.mimeType,
  });

  /// The file's name.
  final String name;

  /// Its content.
  final Uint8List bytes;

  /// Its media type, `application/octet-stream` when unknown.
  final String mimeType;
}

/// Files in and out of the app, and links out to the browser, behind an
/// interface so tests reach no platform channel.
abstract interface class Attachments {
  /// Whether this device has a camera the app can ask for.
  bool get hasCamera;

  /// Asks for any file; null when cancelled.
  Future<PickedFile?> pickFile();

  /// Takes a photo, scaled to keep it small; null when cancelled.
  Future<PickedFile?> takePhoto();

  /// Hands [bytes] to the person as a file called [name]: the share sheet
  /// on phones, a save dialog on desktops. Whether it went anywhere.
  Future<bool> saveBytes(
    String name,
    Uint8List bytes,
    String mimeType, {
    Rect? origin,
  });

  /// Opens [uri] outside the app.
  Future<bool> openLink(Uri uri);
}

/// [Attachments] with the platform's pickers, share sheet and browser.
class SystemAttachments implements Attachments {
  /// Creates the service.
  const SystemAttachments();

  // Platform service, not layout: image_picker's camera exists only on
  // phones.
  @override
  bool get hasCamera => Platform.isAndroid || Platform.isIOS;

  @override
  Future<PickedFile?> pickFile() async {
    final file = await openFile();
    if (file == null) return null;
    return PickedFile(
      name: file.name,
      bytes: await file.readAsBytes(),
      mimeType: file.mimeType ?? mimeTypeOf(file.name),
    );
  }

  @override
  Future<PickedFile?> takePhoto() async {
    final photo = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 70,
    );
    if (photo == null) return null;
    return PickedFile(
      name: photo.name,
      bytes: await photo.readAsBytes(),
      mimeType: photo.mimeType ?? 'image/jpeg',
    );
  }

  @override
  Future<bool> saveBytes(
    String name,
    Uint8List bytes,
    String mimeType, {
    Rect? origin,
  }) async {
    if (Platform.isAndroid || Platform.isIOS) {
      final result = await SharePlus.instance.share(
        ShareParams(
          files: [XFile.fromData(bytes, mimeType: mimeType, name: name)],
          fileNameOverrides: [name],
          sharePositionOrigin: origin,
        ),
      );
      return result.status == ShareResultStatus.success;
    }
    final location = await getSaveLocation(suggestedName: name);
    if (location == null) return false;
    await File(location.path).writeAsBytes(bytes);
    return true;
  }

  @override
  Future<bool> openLink(Uri uri) =>
      launchUrl(uri, mode: LaunchMode.externalApplication);
}

/// A media type for [name] by its extension.
String mimeTypeOf(String name) {
  final ext = name.contains('.') ? name.split('.').last.toLowerCase() : '';
  return switch (ext) {
    'txt' || 'log' || 'md' => 'text/plain',
    'json' => 'application/json',
    'csv' => 'text/csv',
    'pdf' => 'application/pdf',
    'png' => 'image/png',
    'jpg' || 'jpeg' => 'image/jpeg',
    'gif' => 'image/gif',
    'webp' => 'image/webp',
    'zip' => 'application/zip',
    _ => 'application/octet-stream',
  };
}

/// The platform's attachments service.
@Riverpod(keepAlive: true)
Attachments attachments(Ref ref) => const SystemAttachments();
