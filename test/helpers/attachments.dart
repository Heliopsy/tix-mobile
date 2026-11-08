// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:flutter_riverpod/misc.dart';
import 'package:tix_mobile/src/core/platform/attachments.dart';

/// Attachments that answer from fields and record what they were asked.
class FakeAttachments implements Attachments {
  FakeAttachments({this.hasCamera = false, this.picked, this.photo});

  @override
  final bool hasCamera;

  /// What [pickFile] answers; null is a cancelled picker.
  PickedFile? picked;

  /// What [takePhoto] answers.
  PickedFile? photo;

  /// How many times each picker opened.
  int picks = 0;
  int photos = 0;

  /// Files handed out by [saveBytes].
  final saved = <({String name, Uint8List bytes, String mimeType})>[];

  /// Links opened.
  final links = <Uri>[];

  @override
  Future<PickedFile?> pickFile() async {
    picks++;
    return picked;
  }

  @override
  Future<PickedFile?> takePhoto() async {
    photos++;
    return photo;
  }

  @override
  Future<bool> saveBytes(
    String name,
    Uint8List bytes,
    String mimeType, {
    Rect? origin,
  }) async {
    saved.add((name: name, bytes: bytes, mimeType: mimeType));
    return true;
  }

  @override
  Future<bool> openLink(Uri uri) async {
    links.add(uri);
    return true;
  }

  /// The override that puts this fake in place.
  Override get asOverride => attachmentsProvider.overrideWithValue(this);
}
