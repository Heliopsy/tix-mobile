// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:tix_mobile/src/core/errors/tix_exception.dart';

/// The query parameters of `GET /api/v1/tasks`, each possibly repeated.
typedef TaskParams = Map<String, List<String>>;

/// The keys tix's filter language accepts, as `internal/query` lists them.
const filterKeys = [
  'project',
  'status',
  'tag',
  'assignee',
  'creator',
  'claimed-by',
  'priority',
  'due',
  'due-before',
  'due-after',
  'parent',
  'is',
  'sort',
  'limit',
  'text',
  'title',
  'body',
  'claimed',
  'blocked',
  'deleted',
  'starred',
  'has',
  'checklist',
  'snoozed',
];

/// The `due:` windows tix names.
const dueWindows = ['overdue', 'today', 'week', 'month'];

/// Turns tix's filter expression into `GET /tasks` parameters, the way the
/// CLI does (`internal/query` then `internal/client/tasks.go`): terms map to
/// parameters and values are left for the server to judge. [now] answers the
/// relative `due:` windows. A term the language does not have throws a
/// [TixException] of kind invalid with tix's wording.
TaskParams parseFilterExpression(String expression, {required DateTime now}) {
  final out = <String, List<String>>{};
  void add(String key, String value) => (out[key] ??= []).add(value);
  final words = <String>[];
  for (final token in tokenizeFilter(expression)) {
    if (token.quoted) {
      words.add(token.text);
      continue;
    }
    final negate = token.text.startsWith('-');
    final text = negate ? token.text.substring(1) : token.text;
    if (atHandle(text) case final String handle) {
      _applyTerm('assignee', handle, false, negate, now, add);
      continue;
    }
    final cut = text.indexOf(RegExp('[:~]'));
    if (cut < 0) {
      if (text.isEmpty) continue;
      if (negate) {
        add('text', '-any~$text');
      } else {
        words.add(text);
      }
      continue;
    }
    final rawKey = text.substring(0, cut).trim();
    final op = text[cut];
    final value = _trimQuotes(text.substring(cut + 1)).trim();
    if (rawKey.startsWith('field.')) {
      final name = rawKey.substring(6);
      if (negate) {
        throw _invalid('custom field term "field.$name" cannot be negated yet');
      }
      if (value.isEmpty) {
        throw _invalid('filter term "field.$name" has no value');
      }
      add('field.$name', value);
      continue;
    }
    _applyTerm(rawKey.toLowerCase(), value, op == '~', negate, now, add);
  }
  if (words.isNotEmpty) {
    final q = [...?out.remove('q'), ...words].join(' ');
    out['q'] = [q];
  }
  return out;
}

void _applyTerm(
  String key,
  String value,
  bool weak,
  bool negate,
  DateTime now,
  void Function(String, String) add,
) {
  if (value.isEmpty) throw _invalid('filter term "$key" has no value');
  const textKeys = {'title', 'body', 'text', 'q'};
  if (weak && !textKeys.contains(key)) {
    throw _invalid(
      '"$key" takes an exact value; the weak operator "~" only applies to '
      'title, body or text',
    );
  }
  const fixed = {'sort', 'limit', 'due', 'due-before', 'due-after', 'parent'};
  if (negate && fixed.contains(key)) {
    throw _invalid('filter term "$key" cannot be negated');
  }
  void pair(String name) => add(negate ? 'not_$name' : name, value);
  switch (key) {
    case 'project' || 'p':
      add(negate ? 'not_project' : 'project', value.toLowerCase());
    case 'status' || 's':
      pair('status');
    case 'tag':
      pair('tag');
    case 'assignee' || 'a':
      pair('assignee');
    case 'creator':
      pair('creator');
    case 'claimed-by':
      pair('claimed_by');
    case 'priority' || 'prio':
      add(negate ? 'not_priority' : 'priority', '${_priority(value)}');
    case 'due':
      _applyDue(value, now, add);
    case 'due-before':
      add('due_before', _time(value));
    case 'due-after':
      add('due_after', _time(value));
    case 'parent':
      if (value.toLowerCase() == 'none') {
        add('root_only', 'true');
      } else {
        add('parent_id', value);
      }
    case 'is':
      _applyIs(value.toLowerCase(), negate, add);
    case 'has':
      if (value.toLowerCase() != 'checklist') {
        throw _invalid('unknown has: value "$value"; try has:checklist');
      }
      add('checklist', negate ? 'false' : 'true');
    case 'checklist':
      switch (value.toLowerCase()) {
        case 'open':
          add('checklist_open', negate ? 'false' : 'true');
        case 'done':
          if (negate) {
            throw _invalid(
              'checklist:done cannot be negated; use checklist:open',
            );
          }
          add('checklist', 'true');
          add('checklist_open', 'false');
        default:
          throw _invalid(
            'unknown checklist: value "$value"; try checklist:open or '
            'checklist:done',
          );
      }
    case 'sort':
      add('sort', value);
    case 'limit':
      final n = int.tryParse(value);
      if (n == null || n < 0) {
        throw _invalid('limit "$value" must be a non-negative number');
      }
      add('limit', '$n');
    case 'title' || 'body':
      add('text', '${negate ? '-' : ''}$key${weak ? '~' : ':'}$value');
    case 'text' || 'q':
      if (!weak && !negate) {
        add('q', value);
      } else {
        add('text', '${negate ? '-' : ''}any~$value');
      }
    case 'snoozed':
      switch (value.toLowerCase()) {
        case 'any' || 'all':
          if (negate) {
            throw _invalid(
              'snoozed:any cannot be negated; use -is:snoozed for tasks that '
              'are not snoozed',
            );
          }
          add('snoozed', 'any');
        case 'true' || 'yes' || '1':
          _applyIs('snoozed', negate, add);
        case 'false' || 'no' || '0':
          _applyIs('awake', negate, add);
        default:
          throw _invalid(
            'filter term "snoozed" takes true, false or any, not "$value"',
          );
      }
    case 'claimed' || 'blocked' || 'deleted' || 'starred':
      _applyIs(_boolTerm(key, value), negate, add);
    default:
      throw _invalid(
        'unknown filter key "$key"; try one of ${filterKeys.join(', ')}',
      );
  }
}

String _boolTerm(String key, String value) {
  switch (value.toLowerCase()) {
    case 'true' || 'yes' || '1':
      return key;
    case 'false' || 'no' || '0':
      return switch (key) {
        'claimed' => 'unclaimed',
        'blocked' => 'unblocked',
        'starred' => 'unstarred',
        _ => throw _invalid(
          'filter term "$key" cannot be negated with a value; use -$key',
        ),
      };
    default:
      throw _invalid('filter term "$key" takes true or false, not "$value"');
  }
}

void _applyIs(String value, bool negate, void Function(String, String) add) {
  final yes = negate ? 'false' : 'true';
  final no = negate ? 'true' : 'false';
  switch (value) {
    case 'claimed':
      add('claimed', yes);
    case 'unclaimed' || 'free':
      add('claimed', no);
    case 'blocked' || 'waiting-on':
      add('blocked', yes);
    case 'unblocked' || 'ready':
      add('blocked', no);
    case 'starred':
      add('starred', yes);
    case 'unstarred':
      add('starred', no);
    case 'deleted':
      if (!negate) add('include_deleted', 'true');
    case 'trashed':
      add('trashed', yes);
    case 'snoozed':
      add('snoozed', yes);
    case 'awake':
      add('snoozed', no);
    case 'recurring':
      add('recurring', yes);
    case 'root':
      if (negate) {
        throw _invalid('is:root cannot be negated; name a parent instead');
      }
      add('root_only', 'true');
    default:
      throw _invalid(
        'unknown is: value "$value"; try claimed, unclaimed, waiting-on (or '
        'blocked), unblocked, recurring, starred, unstarred, snoozed, awake, '
        'deleted, trashed or root',
      );
  }
}

void _applyDue(String value, DateTime now, void Function(String, String) add) {
  if (value.startsWith('<')) {
    add('due_before', _time(value.substring(1)));
    return;
  }
  if (value.startsWith('>')) {
    add('due_after', _time(value.substring(1)));
    return;
  }
  final utc = now.toUtc();
  final DateTime end;
  switch (value.toLowerCase()) {
    case 'overdue' || 'late':
      end = utc;
    case 'today':
      end = DateTime.utc(utc.year, utc.month, utc.day + 1);
    case 'week':
      end = utc.add(const Duration(days: 7));
    case 'month':
      end = DateTime.utc(
        utc.year,
        utc.month + 1,
        utc.day,
        utc.hour,
        utc.minute,
        utc.second,
      );
    default:
      throw _invalid(
        'unknown due: value "$value"; try one of ${dueWindows.join(', ')}, '
        'or a bound such as due:<2026-02-01',
      );
  }
  add('due_before', _rfc3339(end));
}

int _priority(String value) {
  final v = value.trim().toLowerCase();
  final named = const {
    'highest': 1,
    'high': 2,
    'normal': 3,
    'medium': 3,
    'low': 4,
    'lowest': 5,
  }[v];
  if (named != null) return named;
  final n = int.tryParse(v);
  if (n == null) {
    throw _invalid('priority "$value" must be a name or a number from 1 to 5');
  }
  if (n < 1 || n > 5) throw _invalid('priority $n is out of range');
  return n;
}

String _time(String value) {
  final v = value.trim();
  final date = RegExp(r'^\d{4}-\d{2}-\d{2}$');
  final local = RegExp(r'^\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2}(:\d{2})?$');
  DateTime? parsed;
  if (date.hasMatch(v)) {
    parsed = DateTime.tryParse('${v}T00:00:00Z');
  } else if (local.hasMatch(v)) {
    parsed = DateTime.tryParse('${v.replaceFirst(' ', 'T')}Z');
  } else if (RegExp(r'(Z|[+-]\d{2}:\d{2})$').hasMatch(v)) {
    parsed = DateTime.tryParse(v);
  }
  if (parsed == null) {
    throw _invalid('time "$value" must be RFC3339 or YYYY-MM-DD');
  }
  return _rfc3339(parsed.toUtc());
}

String _rfc3339(DateTime t) =>
    '${t.toUtc().toIso8601String().split('.').first}Z';

String _trimQuotes(String s) {
  var out = s;
  while (out.startsWith('"')) {
    out = out.substring(1);
  }
  while (out.endsWith('"')) {
    out = out.substring(0, out.length - 1);
  }
  return out;
}

TixException _invalid(String message) =>
    TixException(TixErrorKind.invalid, message: message);

/// One word of a filter expression; `quoted` when a quote opened it, which
/// makes it free text however many colons it holds.
typedef FilterToken = ({String text, bool quoted});

/// The handle of a word written `@handle`, as tix reads it for `assignee:`;
/// null for a lone `@` and for a word that carries an operator.
String? atHandle(String word) {
  if (!word.startsWith('@')) return null;
  final handle = word.substring(1);
  if (handle.isEmpty || handle.contains(RegExp('[:~]'))) return null;
  return handle;
}

/// Splits [expression] on spaces, honouring double quotes, as tix does.
List<FilterToken> tokenizeFilter(String expression) {
  final out = <FilterToken>[];
  final cur = StringBuffer();
  var seen = false;
  var quoted = false;
  var open = false;
  for (final r in expression.runes) {
    final c = String.fromCharCode(r);
    if (c == '"') {
      if (!open && cur.isEmpty) quoted = true;
      seen = true;
      open = !open;
    } else if (c == ' ' && !open) {
      if (cur.isNotEmpty || seen) {
        out.add((text: cur.toString(), quoted: quoted));
        cur.clear();
        seen = false;
        quoted = false;
      }
    } else {
      cur.write(c);
    }
  }
  if (open) throw _invalid('filter has an unterminated quote');
  if (cur.isNotEmpty || seen) out.add((text: cur.toString(), quoted: quoted));
  return out;
}

/// Whether [expression] holds [term] as a whole word, ignoring case.
bool hasFilterTerm(String expression, String term) =>
    expression.split(' ').any((w) => w.toLowerCase() == term.toLowerCase());

/// [expression] with [term] added at the end, or taken out when present.
String toggleFilterTerm(String expression, String term) {
  final words = expression.split(' ').where((w) => w.isNotEmpty).toList();
  final before = words.length;
  words.removeWhere((w) => w.toLowerCase() == term.toLowerCase());
  if (words.length == before) words.add(term);
  return words.join(' ');
}

/// [expression] without any word that starts with [prefix], ignoring case.
String dropFilterTerms(String expression, String prefix) => expression
    .split(' ')
    .where((w) => w.isNotEmpty && !w.toLowerCase().startsWith(prefix))
    .join(' ');

/// The values of every `key:` term in [expression] that selects rather than
/// excludes.
List<String> filterTermValues(String expression, String key) {
  final out = <String>[];
  for (final w in expression.split(' ')) {
    final lower = w.toLowerCase();
    if (lower.startsWith('$key:')) out.add(w.substring(key.length + 1));
  }
  return out;
}
