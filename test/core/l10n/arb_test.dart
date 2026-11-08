// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// One argument of an ICU message: `{name}`, or `{name, plural|select, ...}`
/// with its cases.
typedef _Arg = ({String name, String kind, Map<String, String> cases});

/// The top-level arguments of [message], in order.
List<_Arg> _args(String message) {
  final out = <_Arg>[];
  var i = 0;
  while (i < message.length) {
    if (message[i] != '{') {
      i++;
      continue;
    }
    final end = _close(message, i);
    final inner = message.substring(i + 1, end);
    final parts = inner.split(',');
    final name = parts.first.trim();
    if (parts.length < 3) {
      out.add((name: name, kind: '', cases: const {}));
    } else {
      final kind = parts[1].trim();
      final body = parts.sublist(2).join(',');
      out.add((name: name, kind: kind, cases: _cases(body)));
    }
    i = end + 1;
  }
  return out;
}

int _close(String s, int open) {
  var depth = 0;
  for (var i = open; i < s.length; i++) {
    if (s[i] == '{') depth++;
    if (s[i] == '}' && --depth == 0) return i;
  }
  throw FormatException('unbalanced braces', s, open);
}

Map<String, String> _cases(String body) {
  final cases = <String, String>{};
  var i = 0;
  while (i < body.length) {
    final open = body.indexOf('{', i);
    if (open < 0) break;
    final key = body.substring(i, open).trim();
    final end = _close(body, open);
    cases[key] = body.substring(open + 1, end);
    i = end + 1;
  }
  return cases;
}

/// Every placeholder name in [message], case bodies included.
Set<String> _names(String message) => {
  for (final a in _args(message)) ...{
    a.name,
    for (final c in a.cases.values) ..._names(c),
  },
};

/// What is wrong with [translated] as a translation of [english].
List<String> _problems(String english, String translated) {
  final problems = <String>[];
  try {
    final want = _names(english);
    final got = _names(translated);
    if (!_same(want, got)) problems.add('placeholders $got, want $want');
    final en = {for (final a in _args(english)) a.name: a};
    for (final a in _args(translated)) {
      final e = en[a.name];
      if (e == null || e.kind == a.kind) {
        if (e != null &&
            a.kind == 'select' &&
            !_same(e.cases.keys, a.cases.keys)) {
          problems.add(
            'select ${a.name} cases ${a.cases.keys}, want ${e.cases.keys}',
          );
        }
        if (e != null && a.kind == 'plural') {
          final need = e.cases.keys.where(
            (k) => k.startsWith('=') || k == 'other',
          );
          final missing = need.where((k) => !a.cases.containsKey(k));
          if (missing.isNotEmpty)
            problems.add('plural ${a.name} lacks $missing');
        }
        continue;
      }
      problems.add('${a.name} is ${a.kind}, want ${e.kind}');
    }
  } on FormatException catch (e) {
    problems.add(e.message);
  }
  return problems;
}

bool _same(Iterable<String> a, Iterable<String> b) =>
    a.toSet().length == b.toSet().length && a.toSet().containsAll(b);

Map<String, String> _messages(File f) => {
  for (final MapEntry(:key, :value)
      in (jsonDecode(f.readAsStringSync()) as Map<String, Object?>).entries)
    if (!key.startsWith('@')) key: value! as String,
};

void main() {
  final dir = Directory('lib/l10n');
  final english = _messages(File('${dir.path}/app_en.arb'));
  final others =
      dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.arb'))
          .where((f) => !f.path.endsWith('app_en.arb'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  test('every language besides English is checked', () {
    expect(
      others.map((f) => f.uri.pathSegments.last),
      containsAll(['app_bg.arb', 'app_de.arb', 'app_fr.arb']),
    );
  });

  for (final file in others) {
    final name = file.uri.pathSegments.last;
    final messages = _messages(file);

    test('$name has every key of app_en.arb and no other', () {
      final missing = english.keys.where((k) => !messages.containsKey(k));
      final extra = messages.keys.where((k) => !english.containsKey(k));
      expect(missing, isEmpty, reason: 'missing from $name');
      expect(extra, isEmpty, reason: 'in $name but not in app_en.arb');
    });

    test('$name keeps every placeholder, plural and select', () {
      final problems = [
        for (final MapEntry(:key, :value) in english.entries)
          if (messages[key] case final t?)
            for (final p in _problems(value, t)) '$key: $p',
      ];
      expect(problems, isEmpty);
    });

    test('$name translates every message that has words', () {
      final empty = [
        for (final MapEntry(:key, :value) in english.entries)
          if (value.trim().isNotEmpty && (messages[key] ?? 'x').trim().isEmpty)
            key,
      ];
      expect(empty, isEmpty);
    });
  }

  test('the checker sees a renamed placeholder and a dropped case', () {
    expect(_problems('Hi {name}', 'Salut {nom}'), isNotEmpty);
    expect(
      _problems(
        '{n, plural, =1{one} other{{n} many}}',
        '{n, plural, other{{n}}}',
      ),
      isNotEmpty,
    );
    expect(
      _problems(
        '{p, select, 1{a} other{b}}',
        '{p, select, 1{x} 2{y} other{z}}',
      ),
      isNotEmpty,
    );
    expect(
      _problems(
        '{n, plural, =1{one} other{{n} many}}',
        '{n, plural, =1{un} one{un} other{{n} plusieurs}}',
      ),
      isEmpty,
    );
  });
}
