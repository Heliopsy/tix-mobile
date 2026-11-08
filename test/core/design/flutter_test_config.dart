// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads real fonts for the goldens under this directory: Roboto and the
/// Material icons from the pinned Flutter SDK's own cache, so every Linux
/// host with the same Flutter renders the same pixels. Without this the
/// test font draws every glyph as a box.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final fonts = _sdkFonts();
  if (fonts != null) {
    Future<void> load(String family, List<String> files) async {
      final loader = FontLoader(family);
      for (final f in files) {
        final bytes = File('${fonts.path}/$f').readAsBytesSync();
        loader.addFont(Future.value(ByteData.sublistView(bytes)));
      }
      await loader.load();
    }

    const roboto = [
      'Roboto-Regular.ttf',
      'Roboto-Medium.ttf',
      'Roboto-Bold.ttf',
      'Roboto-Italic.ttf',
    ];
    await load('Roboto', roboto);
    await load('monospace', ['RobotoCondensed-Regular.ttf']);
    await load('MaterialIcons', ['MaterialIcons-Regular.otf']);
  }
  await testMain();
}

Directory? _sdkFonts() {
  final root =
      Platform.environment['FLUTTER_ROOT'] ??
      File(Platform.resolvedExecutable)
          .parent
          .parent
          .parent
          .parent
          .parent
          .parent
          .path;
  final dir = Directory('$root/bin/cache/artifacts/material_fonts');
  return dir.existsSync() ? dir : null;
}
