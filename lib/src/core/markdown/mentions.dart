// SPDX-License-Identifier: AGPL-3.0-or-later

/// The scheme [linkMentions] gives a handle's link, which only the app
/// reads: it never leaves for a browser.
const mentionScheme = 'tix-actor';

final _fence = RegExp(r'^\s{0,3}(```|~~~)');

final _skip = RegExp(
  r'(`+)[\s\S]*?\1'
  r'|!?\[[^\]]*\]\([^)]*\)'
  r'|<[^>\s]+>'
  r'|(?:https?://|www\.|mailto:)\S+',
);

final _handle = RegExp(
  r'(?<![\w@./-])@([A-Za-z0-9](?:[A-Za-z0-9_.-]*[A-Za-z0-9])?)\b',
);

/// [markdown] with every `@handle` made a link to [mentionScheme], as tix's
/// web links a mention. Code, links, addresses and emails are left alone.
String linkMentions(String markdown) {
  if (!markdown.contains('@')) return markdown;
  var fenced = false;
  final out = <String>[];
  for (final line in markdown.split('\n')) {
    if (_fence.hasMatch(line)) {
      fenced = !fenced;
      out.add(line);
    } else if (fenced || line.startsWith('    ') || line.startsWith('\t')) {
      out.add(line);
    } else {
      out.add(_linkLine(line));
    }
  }
  return out.join('\n');
}

String _linkLine(String line) {
  final b = StringBuffer();
  var at = 0;
  for (final m in _skip.allMatches(line)) {
    b
      ..write(_linkText(line.substring(at, m.start)))
      ..write(m[0]);
    at = m.end;
  }
  b.write(_linkText(line.substring(at)));
  return b.toString();
}

String _linkText(String text) =>
    text.replaceAllMapped(_handle, (m) => '[@${m[1]}]($mentionScheme:${m[1]})');
