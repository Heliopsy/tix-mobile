// SPDX-License-Identifier: AGPL-3.0-or-later

// The headings of tix's docs at the commit tix.lock pins, which the screens'
// help links land on.
//
//   dart run tool/doc_anchors.dart sync    write api/tix-doc-anchors.json
//
// The source is GitHub's raw files for the pinned commit, or a local tix
// checkout when TIX_SOURCE names one (read with `git show`, offline).
// test/core/help/screen_help_test.dart fails when the file is for another
// commit than tix.lock's, or a help link names a heading it does not list.

import 'dart:convert';
import 'dart:io';

import '../hook/src/libtix.dart' show TixLock;

/// The vendored anchors.
const vendored = 'api/tix-doc-anchors.json';

/// The pages tix's `/docs/{page}` redirect serves (docPages in
/// internal/web/connect.go).
const pages = [
  'README.md',
  'agents.md',
  'api.md',
  'audit-log.md',
  'calendar.md',
  'commands.md',
  'configuration.md',
  'deployment.md',
  'development.md',
  'embedding.md',
  'features.md',
  'filtering.md',
  'import-export.md',
  'mcp.md',
  'migrating.md',
  'scaling.md',
  'scripting.md',
  'second-factor.md',
  'shell-completion.md',
  'specifications.md',
  'statistics.md',
  'tenancy.md',
  'testing.md',
  'theming.md',
  'tui.md',
  'upgrading.md',
  'web-ui.md',
  'workflows.md',
];

Future<void> main(List<String> args) async {
  if (args.firstOrNull != 'sync') {
    stderr.writeln('usage: dart run tool/doc_anchors.dart sync');
    exitCode = 64;
    return;
  }
  final lock = TixLock.parse(File('tix.lock').readAsStringSync());
  final out = <String, Object>{'commit': lock.commit};
  final anchors = <String, List<String>>{};
  for (final page in pages) {
    anchors[page] = headingAnchors(await _fetch(lock.commit, 'docs/$page'));
  }
  out['pages'] = anchors;
  File(
    vendored,
  ).writeAsStringSync('${const JsonEncoder.withIndent('  ').convert(out)}\n');
  stdout.writeln('$vendored is tix ${lock.version} (${lock.commit})');
}

/// The anchor GitHub gives every heading of [markdown], numbered for a
/// repeated heading; lines in fenced code are not headings.
List<String> headingAnchors(String markdown) {
  final out = <String>[];
  final seen = <String, int>{};
  var fenced = false;
  for (final line in const LineSplitter().convert(markdown)) {
    if (line.trim().startsWith('```')) {
      fenced = !fenced;
      continue;
    }
    final text = line.replaceFirst(RegExp('^#+'), '');
    if (fenced ||
        text == line ||
        !text.startsWith(' ') ||
        line.length - text.length > 6) {
      continue;
    }
    final anchor = githubAnchor(text.trim());
    final n = seen[anchor] ?? 0;
    out.add(n > 0 ? '$anchor-$n' : anchor);
    seen[anchor] = n + 1;
  }
  return out;
}

/// GitHub's anchor for [heading]: lower case, punctuation other than hyphens
/// and underscores dropped, spaces turned into hyphens.
String githubAnchor(String heading) {
  final b = StringBuffer();
  for (final rune in heading.toLowerCase().runes) {
    final c = String.fromCharCode(rune);
    if (c == ' ') {
      b.write('-');
    } else if (c == '-' || c == '_' || _word.hasMatch(c)) {
      b.write(c);
    }
  }
  return b.toString();
}

final _word = RegExp(r'[\p{L}\p{N}]', unicode: true);

Future<String> _fetch(String commit, String path) async {
  final source = Platform.environment['TIX_SOURCE'];
  if (source != null && source.isNotEmpty) {
    final r = await Process.run('git', [
      '-C',
      source,
      'show',
      '$commit:$path',
    ], stdoutEncoding: utf8);
    if (r.exitCode != 0) {
      throw ProcessException('git', ['show'], '${r.stderr}', r.exitCode);
    }
    return r.stdout as String;
  }
  final url = Uri.parse(
    'https://raw.githubusercontent.com/heliopsy/tix/$commit/$path',
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
