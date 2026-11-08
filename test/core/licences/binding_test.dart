// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/licences/binding.dart';

class _Bundle extends CachingAssetBundle {
  _Bundle(this.assets);

  final Map<String, List<int>> assets;

  @override
  Future<ByteData> load(String key) async {
    final bytes = assets[key];
    if (bytes == null) throw FlutterError('no asset $key');
    return ByteData.sublistView(Uint8List.fromList(bytes));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final notices = gzip.encode(
    utf8.encode(
      [
        'dio\n\nMIT licence text',
        'build_runner\n\nBSD licence text',
        'skia\n\nSkia licence text',
      ].join('\n${'-' * 80}\n'),
    ),
  );
  final bundle = _Bundle({
    'NOTICES.Z': notices,
    engineNoticesAsset: File('assets/licenses/libtix.json').readAsBytesSync(),
  });

  Future<List<String>> packages({required bool engine}) async => [
    await for (final e in shippedLicences(bundle, engineBundled: engine))
      ...e.packages,
  ];

  test('lists runtime packages and the engine, not dev tools', () async {
    final names = await packages(engine: true);
    expect(names, containsAll(['dio', 'skia', 'github.com/heliopsy/tix']));
    expect(names, contains('modernc.org/sqlite'));
    expect(names, isNot(contains('build_runner')));
  });

  test('a build without the engine lists no Go modules', () async {
    final names = await packages(engine: false);
    expect(names, containsAll(['dio', 'skia']));
    expect(names, isNot(contains('github.com/heliopsy/tix')));
  });
}
