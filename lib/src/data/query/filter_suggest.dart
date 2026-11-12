// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:tix_mobile/src/data/query/filter_expression.dart';

/// The keys the filter field offers for a bare word, most typed first, as
/// tix web's filter box lists them.
const suggestKeys = [
  'project',
  'tag',
  'assignee',
  'status',
  'priority',
  'due',
  'is',
  'title',
  'creator',
  'has',
];

/// The `is:` states the filter field offers.
const suggestIs = [
  'starred',
  'blocked',
  'claimed',
  'unclaimed',
  'recurring',
  'snoozed',
  'root',
];

/// The priority names tix's filter language reads, highest first.
const suggestPriorities = ['highest', 'high', 'normal', 'low', 'lowest'];

const _aliases = {
  'p': 'project',
  's': 'status',
  'a': 'assignee',
  'prio': 'priority',
};

/// One project the filter field can complete.
typedef SuggestProject = ({String key, String name});

/// What the filter field suggests from: the tenant's projects, tags, people
/// and states, loaded once so typing costs no request.
class FilterSuggestData {
  /// Suggestions from these lists; [scoped] drops `project:` from the keys.
  const FilterSuggestData({
    this.projects = const [],
    this.tags = const [],
    this.people = const [],
    this.statuses = const [],
    this.scoped = false,
  });

  /// The projects, by key and name.
  final List<SuggestProject> projects;

  /// The tag names.
  final List<String> tags;

  /// The people's handles.
  final List<String> people;

  /// The workflow state keys.
  final List<String> statuses;

  /// Whether the screen is one project's, so `project:` is not offered.
  final bool scoped;

  /// The keys offered for a bare word.
  List<String> get keys => scoped
      ? [
          for (final k in suggestKeys)
            if (k != 'project') k,
        ]
      : suggestKeys;
}

/// The word of a filter expression the caret is in: its span, a leading
/// minus, the key it names (empty for a bare word, `@` for a handle, `#` for
/// a tag) and what was typed after the key.
typedef FilterWord = ({
  int start,
  int end,
  bool negated,
  String key,
  String typed,
});

/// One suggestion: what the list shows, the text that replaces the word, and
/// a note such as a project's name.
typedef FilterSuggestion = ({String label, String insert, String note});

/// The word of [text] the [caret] is in, or null inside an open quote,
/// where everything is free text.
FilterWord? filterWordAt(String text, int caret) {
  final at = caret.clamp(0, text.length);
  if ('"'.allMatches(text.substring(0, at)).length.isOdd) return null;
  final start = at == 0 ? 0 : text.lastIndexOf(' ', at - 1) + 1;
  var end = text.indexOf(' ', at);
  if (end < 0) end = text.length;
  var word = text.substring(start, end);
  final negated = word.startsWith('-');
  if (negated) word = word.substring(1);
  FilterWord out(String key, String typed) =>
      (start: start, end: end, negated: negated, key: key, typed: typed);
  if (word.startsWith('@') || word.startsWith('#')) {
    return out(word[0], word.substring(1));
  }
  final colon = word.indexOf(':');
  if (colon < 0) return out('', word);
  final key = word.substring(0, colon).toLowerCase();
  return out(_aliases[key] ?? key, word.substring(colon + 1));
}

/// What [word] completes to from [data], at most [limit]: values starting
/// with what was typed first, then those holding it. A word that already is
/// its only suggestion gets nothing, so Enter applies it.
List<FilterSuggestion> filterSuggest(
  FilterSuggestData data,
  FilterWord word, {
  int limit = 8,
}) {
  List<_Value> plain(Iterable<String> values) => [
    for (final v in values) (value: v, note: '', match: v),
  ];
  FilterSuggestion Function(_Value) keyed(String key) =>
      (v) => (
        label: '$key:${v.value}',
        insert: '$key:${_quoted(v.value)}',
        note: v.note,
      );
  final List<FilterSuggestion> out;
  switch (word.key) {
    case '':
      if (word.typed.isEmpty) return const [];
      out = _rank(
        plain(data.keys),
        word.typed,
        (v) => (label: '${v.value}:', insert: '${v.value}:', note: ''),
      );
    case '@':
      out = _rank(
        plain(data.people),
        word.typed,
        (v) => (label: '@${v.value}', insert: '@${v.value}', note: ''),
      );
    case '#':
      out = _rank(plain(data.tags), word.typed, keyed('tag'));
    case 'project':
      out = _rank(
        [
          for (final p in data.projects)
            (value: p.key, note: p.name, match: '${p.key} ${p.name}'),
        ],
        word.typed,
        keyed('project'),
      );
    case 'assignee' || 'creator' || 'claimed-by':
      out = _rank(plain([...data.people, 'me']), word.typed, keyed(word.key));
    case final key:
      final values = switch (key) {
        'tag' => data.tags,
        'status' => data.statuses,
        'priority' => suggestPriorities,
        'due' => dueWindows,
        'is' => suggestIs,
        'has' => const ['checklist'],
        _ => null,
      };
      if (values == null) return const [];
      out = _rank(plain(values), word.typed, keyed(key));
  }
  final shown = out.take(limit).toList();
  final typed = switch (word.key) {
    '' => word.typed,
    '@' || '#' => '${word.key}${word.typed}',
    _ => '${word.key}:${word.typed}',
  };
  if (shown.length == 1 &&
      shown.single.insert.toLowerCase() == typed.toLowerCase()) {
    return const [];
  }
  return shown;
}

typedef _Value = ({String value, String note, String match});

List<FilterSuggestion> _rank(
  List<_Value> values,
  String typed,
  FilterSuggestion Function(_Value) show,
) {
  final q = typed.toLowerCase();
  final starts = <FilterSuggestion>[];
  final inside = <FilterSuggestion>[];
  final seen = <String>{};
  for (final v in values) {
    if (!seen.add(v.value.toLowerCase())) continue;
    final hay = v.match.toLowerCase();
    final at = hay.indexOf(q);
    if (at == 0 || (q.isNotEmpty && hay.contains(' $q'))) {
      starts.add(show(v));
    } else if (q.isNotEmpty && at > 0) {
      inside.add(show(v));
    }
  }
  return [...starts, ...inside];
}

String _quoted(String v) =>
    v.contains(RegExp(r'[\s"]')) ? '"${v.replaceAll('"', '')}"' : v;

/// [text] once [insert] replaces [word]: its minus kept, a space after a
/// whole term but none after a bare key, and where the caret goes.
({String text, int caret}) filterInsert(
  String text,
  FilterWord word,
  String insert,
) {
  final term = '${word.negated ? '-' : ''}$insert';
  final tail = text.substring(word.end).replaceFirst(RegExp(r'^\s'), '');
  final gap = insert.endsWith(':') ? '' : ' ';
  final head = '${text.substring(0, word.start)}$term$gap';
  return (text: '$head$tail', caret: head.length);
}

/// One term of an expression and where it sits.
typedef FilterTerm = ({int start, int end, String text});

/// The terms of [expression] in order, a quoted phrase kept whole. An
/// unterminated quote runs to the end.
List<FilterTerm> filterTerms(String expression) {
  final out = <FilterTerm>[];
  var start = -1;
  var open = false;
  for (var i = 0; i < expression.length; i++) {
    final c = expression[i];
    if (c == ' ' && !open) {
      if (start >= 0) {
        out.add((start: start, end: i, text: expression.substring(start, i)));
        start = -1;
      }
      continue;
    }
    if (start < 0) start = i;
    if (c == '"') open = !open;
  }
  if (start >= 0) {
    out.add((
      start: start,
      end: expression.length,
      text: expression.substring(start),
    ));
  }
  return out;
}

/// [expression] without [term], the spaces around it closed up.
String removeFilterTerm(String expression, FilterTerm term) => [
  for (final t in filterTerms(expression))
    if (t.start != term.start) t.text,
].join(' ');

/// The values of the terms of [expression] that select by [key], its short
/// form and, for `assignee`, `@handle` words included.
List<String> selectingValues(String expression, String key) => [
  for (final t in filterTerms(expression))
    if (_selects(t.text, key) case final String v) v,
];

/// [expression] with every term selecting by [key] replaced by one for
/// [value], or taken out when [value] is null.
String setFilterKey(String expression, String key, String? value) {
  final kept = [
    for (final t in filterTerms(expression))
      if (_selects(t.text, key) == null) t.text,
  ];
  return [...kept, if (value != null) '$key:${_quoted(value)}'].join(' ');
}

String? _selects(String term, String key) {
  final handle = key == 'assignee' ? atHandle(term) : null;
  if (handle != null) return handle;
  final colon = term.indexOf(':');
  if (colon <= 0) return null;
  final named = term.substring(0, colon).toLowerCase();
  if ((_aliases[named] ?? named) != key) return null;
  final value = term.substring(colon + 1);
  return value.replaceAll('"', '');
}
