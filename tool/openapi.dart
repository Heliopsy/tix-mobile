// SPDX-License-Identifier: AGPL-3.0-or-later

// The tix API description, pinned by tix.lock, and the Dart generated from it.
//
//   dart run tool/openapi.dart sync    fetch api/openapi.yaml at the pinned commit
//   dart run tool/openapi.dart check   fail if api/tix-openapi.yaml differs from it
//   dart run tool/openapi.dart gen     regenerate lib/src/data/api/gen/*.gen.dart
//
// The source is GitHub's raw file for the pinned commit, or a local tix
// checkout when TIX_SOURCE names one (read with `git show`, offline).

import 'dart:convert';
import 'dart:io';

import '../hook/src/libtix.dart' show TixLock;
import 'openapi/generator.dart';

/// The vendored copy of tix's OpenAPI document.
const vendored = 'api/tix-openapi.yaml';

/// Where the generated Dart goes.
const outDir = 'lib/src/data/api/gen';

Future<void> main(List<String> args) async {
  final lock = TixLock.parse(File('tix.lock').readAsStringSync());
  switch (args.firstOrNull) {
    case 'sync':
      File(vendored).writeAsStringSync(await _fetch(lock.commit));
      stdout.writeln('$vendored is tix ${lock.version} (${lock.commit})');
    case 'check':
      final want = await _fetch(lock.commit);
      if (File(vendored).readAsStringSync() != want) {
        stderr.writeln(
          '$vendored is not api/openapi.yaml at the commit tix.lock pins '
          '(${lock.commit}); run `just openapi-sync` and `just gen`',
        );
        exitCode = 1;
        return;
      }
      stdout.writeln('$vendored matches tix ${lock.version}');
    case 'gen':
      final files = generate(File(vendored).readAsStringSync());
      Directory(outDir).createSync(recursive: true);
      for (final MapEntry(:key, :value) in files.entries) {
        File('$outDir/$key').writeAsStringSync(value);
      }
      final paths = [for (final k in files.keys) '$outDir/$k'];
      final r = await Process.run('dart', ['format', ...paths]);
      if (r.exitCode != 0) {
        stderr.write(r.stderr);
        exitCode = r.exitCode;
        return;
      }
      stdout.writeln('generated ${paths.join(', ')}');
    default:
      stderr.writeln('usage: dart run tool/openapi.dart sync|check|gen');
      exitCode = 64;
  }
}

Future<String> _fetch(String commit) async {
  final source = Platform.environment['TIX_SOURCE'];
  if (source != null && source.isNotEmpty) {
    final r = await Process.run('git', [
      '-C',
      source,
      'show',
      '$commit:api/openapi.yaml',
    ], stdoutEncoding: utf8);
    if (r.exitCode != 0) {
      throw ProcessException('git', ['show'], '${r.stderr}', r.exitCode);
    }
    return r.stdout as String;
  }
  final url = Uri.parse(
    'https://raw.githubusercontent.com/heliopsy/tix/$commit/api/openapi.yaml',
  );
  final client = HttpClient();
  try {
    final response = await (await client.getUrl(url)).close();
    final body = await response.transform(utf8.decoder).join();
    if (response.statusCode != 200) {
      throw HttpException('${response.statusCode} from $url', uri: url);
    }
    return body;
  } finally {
    client.close();
  }
}
