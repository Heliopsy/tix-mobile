// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart';

/// The formatting tools of tix's web description editor, in its order.
enum MarkdownFormat {
  /// `**strong**`.
  bold,

  /// `*emphasis*`.
  italic,

  /// `~~struck~~`.
  strike,

  /// `## heading`, the one level the web writes.
  heading,

  /// `- item`.
  bullets,

  /// `1. item`.
  numbers,

  /// `- [ ] item`.
  checklist,

  /// `> quoted`.
  quote,

  /// Inline backticks inside one line, a fenced block otherwise.
  code,

  /// `[text](address)`.
  link,

  /// The web's empty two by two table.
  table,
}

/// The table the web's Table tool inserts, serialised as the web writes it.
const markdownTable = '|  |  |\n| --- | --- |\n|  |  |';

final _fence = RegExp(r'^\s*(```|~~~)');
final _line = RegExp(
  r'^(\s*(?:>[ \t]?)*)(?:([ \t]*(?:[-+*]|\d+[.)])[ \t]+)(\[[ xX]\][ \t]+)?)?'
  r'(#{1,6}[ \t]+)?',
);
final _listMarker = RegExp(r'^([ \t]*)([-+*]|\d+[.)])([ \t]+)$');
final _link = RegExp(r'\[([^\]\n]*)\]\(([^)\n]*(?:\\\)[^)\n]*)*)\)');

/// [value] with [format] toggled over its selection, in the Markdown tix's
/// web writes. [href] is the address for [MarkdownFormat.link]; without one
/// a link is left as it was. Text outside the lines acted on never changes.
TextEditingValue applyMarkdownFormat(
  TextEditingValue value,
  MarkdownFormat format, {
  String? href,
}) {
  final v = _normalised(value);
  return switch (format) {
    MarkdownFormat.bold => _inline(v, '**'),
    MarkdownFormat.italic => _inline(v, '*'),
    MarkdownFormat.strike => _inline(v, '~~'),
    MarkdownFormat.code => _code(v),
    MarkdownFormat.link => _linkTo(v, href),
    MarkdownFormat.table => _table(v),
    MarkdownFormat.heading ||
    MarkdownFormat.bullets ||
    MarkdownFormat.numbers ||
    MarkdownFormat.checklist ||
    MarkdownFormat.quote => _lines(v, format),
  };
}

/// [value] with the link around its selection reduced to its text, or null
/// when the selection is not inside one: the web's Link tool on a link.
TextEditingValue? unlinkMarkdown(TextEditingValue value) {
  final v = _normalised(value);
  final s = v.selection;
  for (final m in _link.allMatches(v.text)) {
    if (m.start <= s.start && s.end <= m.end && s.start < m.end) {
      final label = m.group(1)!;
      return TextEditingValue(
        text: v.text.replaceRange(m.start, m.end, label),
        selection: TextSelection(
          baseOffset: m.start,
          extentOffset: m.start + label.length,
        ),
      );
    }
  }
  return null;
}

/// What typing Enter in [old] should give instead of [next]: the next list
/// item or quoted line, or an empty item's marker removed. Null when [next]
/// is not one newline typed at a collapsed cursor, or the line is not a
/// list item or a quote, or it is inside fenced code.
TextEditingValue? continueMarkdownList(
  TextEditingValue old,
  TextEditingValue next,
) {
  final sel = old.selection;
  if (!sel.isValid || !sel.isCollapsed) return null;
  final c = sel.baseOffset;
  if (next.text.length != old.text.length + 1 ||
      next.text != old.text.replaceRange(c, c, '\n') ||
      !next.selection.isCollapsed ||
      next.selection.baseOffset != c + 1) {
    return null;
  }
  final text = old.text;
  final start = _lineStart(text, c);
  final end = _lineEnd(text, c);
  if (_insideFence(text, start)) return null;
  final line = text.substring(start, end);
  final m = _line.firstMatch(line)!;
  final quote = m.group(1)!;
  final list = m.group(2);
  final box = m.group(3);
  if (list == null && !quote.contains('>')) return null;
  final prefix = quote.length + (list?.length ?? 0) + (box?.length ?? 0);
  if (c < start + prefix) return null;
  if (line.substring(prefix).trim().isEmpty) {
    final kept = list != null ? quote : _dropQuote(quote);
    return TextEditingValue(
      text: text.replaceRange(start, end, kept),
      selection: TextSelection.collapsed(offset: start + kept.length),
    );
  }
  final following = StringBuffer(quote);
  if (list != null) {
    final lm = _listMarker.firstMatch(list)!;
    final marker = lm.group(2)!;
    final n = int.tryParse(marker.substring(0, marker.length - 1));
    following
      ..write(lm.group(1))
      ..write(
        n == null ? marker : '${n + 1}${marker.substring(marker.length - 1)}',
      )
      ..write(lm.group(3));
    if (box != null) following.write('[ ] ');
  }
  final inserted = '\n$following';
  return TextEditingValue(
    text: text.replaceRange(c, c, inserted),
    selection: TextSelection.collapsed(offset: c + inserted.length),
  );
}

/// Continues lists and quotes when Enter is typed; see
/// [continueMarkdownList].
class MarkdownListFormatter extends TextInputFormatter {
  /// A formatter for a Markdown text field.
  const MarkdownListFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => continueMarkdownList(oldValue, newValue) ?? newValue;
}

TextEditingValue _normalised(TextEditingValue v) {
  final s = v.selection;
  if (s.isValid && s.end <= v.text.length) {
    return v.copyWith(
      selection: TextSelection(baseOffset: s.start, extentOffset: s.end),
      composing: TextRange.empty,
    );
  }
  return v.copyWith(
    selection: TextSelection.collapsed(offset: v.text.length),
    composing: TextRange.empty,
  );
}

int _lineStart(String text, int offset) =>
    offset == 0 ? 0 : text.lastIndexOf('\n', offset - 1) + 1;

int _lineEnd(String text, int offset) {
  final i = text.indexOf('\n', offset);
  return i < 0 ? text.length : i;
}

bool _insideFence(String text, int lineStart) {
  var open = false;
  for (final l in text.substring(0, lineStart).split('\n')) {
    if (_fence.hasMatch(l)) open = !open;
  }
  return open;
}

String _dropQuote(String quote) =>
    quote.replaceFirst(RegExp(r'>[ \t]?(?=[^>]*$)'), '').trimRight();

int _run(String text, int from, int step, String char) {
  var n = 0;
  for (
    var i = step > 0 ? from : from - 1;
    i >= 0 && i < text.length && text[i] == char;
    i += step
  ) {
    n++;
  }
  return n;
}

({String text, int start, int end}) _toggleSpan(
  String text,
  int start,
  int end,
  String marker,
) {
  var s = start;
  var e = end;
  while (s < e && text[s].trim().isEmpty) {
    s++;
  }
  while (e > s && text[e - 1].trim().isEmpty) {
    e--;
  }
  final k = marker.length;
  bool present(int run) => marker == '**'
      ? run >= 2
      : marker == '*'
      ? run.isOdd
      : run >= k;
  if (marker.length <= 2 && marker[0] == '*') {
    final before = _run(text, s, -1, '*');
    final after = _run(text, e, 1, '*');
    if (before > 0 && after > 0 && present(before < after ? before : after)) {
      return (
        text: text.replaceRange(e, e + k, '').replaceRange(s - k, s, ''),
        start: s - k,
        end: e - k,
      );
    }
    final inLead = _run(text, s, 1, '*');
    final inTail = _run(text, e, -1, '*');
    final run = inLead < inTail ? inLead : inTail;
    if (e - s > inLead + inTail - 1 && run > 0 && present(run)) {
      return (
        text: text.replaceRange(e - k, e, '').replaceRange(s, s + k, ''),
        start: s,
        end: e - 2 * k,
      );
    }
  } else {
    if (s >= k &&
        text.startsWith(marker, s - k) &&
        text.startsWith(marker, e)) {
      return (
        text: text.replaceRange(e, e + k, '').replaceRange(s - k, s, ''),
        start: s - k,
        end: e - k,
      );
    }
    final inner = text.substring(s, e);
    if (inner.length >= 2 * k &&
        inner.startsWith(marker) &&
        inner.endsWith(marker)) {
      return (
        text: text.replaceRange(e - k, e, '').replaceRange(s, s + k, ''),
        start: s,
        end: e - 2 * k,
      );
    }
  }
  return (
    text: text.replaceRange(e, e, marker).replaceRange(s, s, marker),
    start: s + k,
    end: e + k,
  );
}

bool _isWrapped(String text, int start, int end, String marker) {
  final t = _toggleSpan(text, start, end, marker);
  return t.text.length < text.length;
}

TextEditingValue _inline(TextEditingValue v, String marker) {
  final text = v.text;
  final s = v.selection.start;
  final e = v.selection.end;
  if (!text.substring(s, e).contains('\n')) {
    if (s == e) {
      final k = marker.length;
      final asterisk = marker[0] == '*';
      final around = asterisk
          ? _run(text, s, -1, '*') == k && _run(text, s, 1, '*') == k
          : s >= k &&
                text.startsWith(marker, s - k) &&
                text.startsWith(marker, s);
      if (around) {
        return TextEditingValue(
          text: text.replaceRange(s - k, s + k, ''),
          selection: TextSelection.collapsed(offset: s - k),
        );
      }
      return TextEditingValue(
        text: text.replaceRange(s, s, '$marker$marker'),
        selection: TextSelection.collapsed(offset: s + k),
      );
    }
    final t = _toggleSpan(text, s, e, marker);
    return TextEditingValue(
      text: t.text,
      selection: TextSelection(baseOffset: t.start, extentOffset: t.end),
    );
  }
  final first = _lineStart(text, s);
  final last = _lineEnd(text, e);
  final spans = <(int, int)>[];
  var at = first;
  while (at <= last) {
    final lineEnd = _lineEnd(text, at);
    final prefix = at + _line.firstMatch(text.substring(at, lineEnd))!.end;
    final from = s > prefix ? s : prefix;
    final to = e < lineEnd ? e : lineEnd;
    if (text.substring(from < to ? from : to, to).trim().isNotEmpty) {
      spans.add((from, to));
    }
    at = lineEnd + 1;
  }
  if (spans.isEmpty) return v;
  final off = spans.every((p) => _isWrapped(text, p.$1, p.$2, marker));
  var out = text;
  var startOut = s;
  var endOut = e;
  for (final (from, to) in spans.reversed) {
    final wrapped = _isWrapped(out, from, to, marker);
    if (wrapped != off) continue;
    final t = _toggleSpan(out, from, to, marker);
    endOut += t.text.length - out.length;
    out = t.text;
  }
  if (startOut > out.length) startOut = out.length;
  if (endOut > out.length) endOut = out.length;
  return TextEditingValue(
    text: out,
    selection: TextSelection(baseOffset: startOut, extentOffset: endOut),
  );
}

TextEditingValue _code(TextEditingValue v) {
  final text = v.text;
  final s = v.selection.start;
  final e = v.selection.end;
  if (s != e && !text.substring(s, e).contains('\n')) return _inline(v, '`');
  final lines = text.split('\n');
  final firstLine = '\n'.allMatches(text.substring(0, s)).length;
  final lastLine = s != e && e > 0 && text[e - 1] == '\n'
      ? '\n'.allMatches(text.substring(0, e)).length - 1
      : '\n'.allMatches(text.substring(0, e)).length;
  int? open;
  for (var i = 0; i < lines.length; i++) {
    if (!_fence.hasMatch(lines[i])) continue;
    if (open == null) {
      open = i;
    } else {
      if (open <= firstLine && lastLine <= i) {
        final openAt = _offsetOf(lines, open);
        final openLen = lines[open].length + 1;
        final closeAt = _offsetOf(lines, i);
        final closeLen = lines[i].length + 1;
        final out = [
          ...lines.sublist(0, open),
          ...lines.sublist(open + 1, i),
          ...lines.sublist(i + 1),
        ].join('\n');
        int moved(int x) {
          if (x <= openAt) return x;
          if (x < openAt + openLen) return openAt;
          if (x <= closeAt) return x - openLen;
          return (x - openLen - closeLen).clamp(closeAt - openLen, out.length);
        }

        return TextEditingValue(
          text: out,
          selection: TextSelection(
            baseOffset: moved(s),
            extentOffset: moved(e),
          ),
        );
      }
      open = null;
    }
  }
  final from = _offsetOf(lines, firstLine);
  final to = _lineEnd(text, _offsetOf(lines, lastLine));
  final out = text
      .replaceRange(to, to, '\n```')
      .replaceRange(from, from, '```\n');
  int shifted(int x) => x + 4 + (x > to ? 4 : 0);
  return TextEditingValue(
    text: out,
    selection: TextSelection(baseOffset: shifted(s), extentOffset: shifted(e)),
  );
}

int _offsetOf(List<String> lines, int index) {
  var o = 0;
  for (var i = 0; i < index; i++) {
    o += lines[i].length + 1;
  }
  return o;
}

String _escapeHref(String href) => href.replaceAllMapped(
  RegExp(r'[()"\s]'),
  (m) => m[0] == ' ' ? '%20' : '\\${m[0]}',
);

TextEditingValue _linkTo(TextEditingValue v, String? href) {
  final address = href?.trim() ?? '';
  if (address.isEmpty) return v;
  final s = v.selection.start;
  final e = v.selection.end;
  final label = v.text.substring(s, e);
  final String inserted;
  if (label.isEmpty) {
    inserted = RegExp(r'^\w+:').hasMatch(address)
        ? '<$address>'
        : '[$address](${_escapeHref(address)})';
  } else {
    inserted = '[$label](${_escapeHref(address)})';
  }
  return TextEditingValue(
    text: v.text.replaceRange(s, e, inserted),
    selection: TextSelection.collapsed(offset: s + inserted.length),
  );
}

TextEditingValue _table(TextEditingValue v) {
  final text = v.text;
  final c = v.selection.end;
  final start = _lineStart(text, c);
  final end = _lineEnd(text, c);
  final blank = text.substring(start, end).trim().isEmpty;
  final before = text.substring(0, blank ? start : end);
  final after = text.substring(end);
  final lead = before.isEmpty
      ? ''
      : before.endsWith('\n\n')
      ? ''
      : before.endsWith('\n')
      ? '\n'
      : '\n\n';
  final rest = after.replaceFirst(RegExp(r'^\n*'), '');
  final tail = rest.isEmpty ? '' : '\n\n';
  final head = '$before$lead';
  return TextEditingValue(
    text: '$head$markdownTable$tail$rest',
    selection: TextSelection.collapsed(offset: head.length + 2),
  );
}

({String quote, String? list, String? box, String? heading, String rest})
_parts(String line) {
  final m = _line.firstMatch(line)!;
  return (
    quote: m.group(1)!,
    list: m.group(2),
    box: m.group(3),
    heading: m.group(4),
    rest: line.substring(m.end),
  );
}

bool _isBullet(String? list) =>
    list != null && RegExp(r'^[ \t]*[-+*]').hasMatch(list);

bool _isNumber(String? list) =>
    list != null && RegExp(r'^[ \t]*\d').hasMatch(list);

String _indentOf(String? list) =>
    list == null ? '' : RegExp(r'^[ \t]*').firstMatch(list)![0]!;

TextEditingValue _lines(TextEditingValue v, MarkdownFormat format) {
  final text = v.text;
  final s = v.selection.start;
  var e = v.selection.end;
  if (e > s && text[e - 1] == '\n') e--;
  final from = _lineStart(text, s);
  final to = _lineEnd(text, e);
  final lines = text.substring(from, to).split('\n');
  final parts = [for (final l in lines) _parts(l)];
  bool filled(int i) => lines[i].trim().isNotEmpty;
  final used = [
    for (var i = 0; i < lines.length; i++)
      if (filled(i)) i,
  ];
  final all = used.isNotEmpty;
  final out = List<String>.of(lines);
  switch (format) {
    case MarkdownFormat.heading:
      final off = all && used.every((i) => parts[i].heading != null);
      for (final i in used) {
        final p = parts[i];
        final head = off ? '' : '## ';
        out[i] = '${p.quote}${p.list ?? ''}${p.box ?? ''}$head${p.rest}';
      }
    case MarkdownFormat.quote:
      final off = all && used.every((i) => parts[i].quote.contains('>'));
      for (var i = 0; i < lines.length; i++) {
        if (off) {
          if (!filled(i)) continue;
          final p = parts[i];
          final q = p.quote.replaceFirst(RegExp(r'>[ \t]?'), '');
          out[i] = '$q${lines[i].substring(p.quote.length)}';
          if (out[i].trim().isEmpty) out[i] = '';
        } else if (filled(i)) {
          out[i] = '> ${lines[i]}';
        } else if (lines.length > 1 && i > 0 && i < lines.length - 1) {
          out[i] = '>';
        }
      }
    case MarkdownFormat.bullets:
      final off = all && used.every((i) => _isBullet(parts[i].list));
      for (final i in used) {
        final p = parts[i];
        final list = off ? '' : '${_indentOf(p.list)}- ';
        out[i] = '${p.quote}$list${p.heading ?? ''}${p.rest}';
      }
    case MarkdownFormat.numbers:
      final off = all && used.every((i) => _isNumber(parts[i].list));
      var n = 1;
      for (final i in used) {
        final p = parts[i];
        final list = off ? '' : '${_indentOf(p.list)}${n++}. ';
        final box = off ? '' : p.box ?? '';
        out[i] = '${p.quote}$list$box${p.heading ?? ''}${p.rest}';
      }
    case MarkdownFormat.checklist:
      final off =
          all &&
          used.every((i) => parts[i].list != null && parts[i].box != null);
      for (final i in used) {
        final p = parts[i];
        final list = p.list ?? '- ';
        final box = off ? '' : p.box ?? '[ ] ';
        out[i] = '${p.quote}$list$box${p.heading ?? ''}${p.rest}';
      }
    case _:
      return v;
  }
  final joined = out.join('\n');
  final result = text.replaceRange(from, to, joined);
  if (v.selection.isCollapsed) {
    final row = '\n'.allMatches(text.substring(from, s)).length;
    final lineFrom = from + _offsetOf(out, row);
    final oldLineFrom = from + _offsetOf(lines, row);
    final fromEnd = oldLineFrom + lines[row].length - s;
    final prefix = _line.firstMatch(out[row])!.end;
    var cursor = lineFrom + out[row].length - fromEnd;
    if (cursor < lineFrom + prefix) cursor = lineFrom + prefix;
    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: cursor),
    );
  }
  return TextEditingValue(
    text: result,
    selection: TextSelection(
      baseOffset: from,
      extentOffset: from + joined.length,
    ),
  );
}
