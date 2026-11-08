// SPDX-License-Identifier: AGPL-3.0-or-later

// Maintenance for the embedded engine pinned in tix.lock.
//
//   dart run tool/engine.dart notices   regenerate assets/licenses/libtix.json
//   dart run tool/engine.dart version   print the pinned version and commit

import 'dart:convert';
import 'dart:io';

import '../hook/src/libtix.dart';

/// Every target the app ships libtix for, as GOOS/GOARCH.
const targets = [
  'android/arm64',
  'android/arm',
  'android/amd64',
  'ios/arm64',
  'ios/amd64',
  'darwin/arm64',
  'darwin/amd64',
  'linux/amd64',
  'linux/arm64',
  'windows/amd64',
];

/// Where the merged notices live, bundled as a Flutter asset.
const noticesAsset = 'assets/licenses/libtix.json';

Future<void> main(List<String> args) async {
  final lock = TixLock.parse(File('tix.lock').readAsStringSync());
  switch (args.firstOrNull) {
    case 'version':
      stdout.writeln('${lock.version} ${lock.commit}');
    case 'notices':
      await _notices(lock);
    default:
      stderr.writeln('usage: dart run tool/engine.dart notices|version');
      exitCode = 64;
  }
}

Future<void> _notices(TixLock lock) async {
  final builder = LibtixBuilder(
    lock: lock,
    cacheRoot: LibtixBuilder.defaultCacheRoot(Platform.environment),
    log: stderr.writeln,
  );
  final tmp = await Directory.systemTemp.createTemp('libtix-notices-');
  final merged = <String, Map<String, Object?>>{};
  try {
    for (final target in targets) {
      final [goos, goarch] = target.split('/');
      final out = File('${tmp.path}/${target.replaceAll('/', '-')}.json');
      await builder.notices(goos, goarch, out);
      final doc = jsonDecode(out.readAsStringSync()) as Map<String, Object?>;
      for (final m in (doc['modules']! as List).cast<Map<String, Object?>>()) {
        final key = '${m['module']}@${m['version'] ?? ''}';
        final entry = merged.putIfAbsent(
          key,
          () => {...m, 'targets': <String>[]},
        );
        (entry['targets']! as List<String>).add(target);
      }
    }
  } finally {
    await tmp.delete(recursive: true);
  }
  final keys = merged.keys.toList()..sort();
  final doc = {
    'tix': {'version': lock.version, 'commit': lock.commit},
    'modules': [for (final k in keys) merged[k]],
  };
  final file = File(noticesAsset);
  await file.parent.create(recursive: true);
  await file.writeAsString(
    '${const JsonEncoder.withIndent(' ').convert(doc)}\n',
  );
  stderr.writeln('wrote $noticesAsset: ${keys.length} modules');
}
