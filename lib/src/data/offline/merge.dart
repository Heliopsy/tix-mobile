// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:tix_mobile/src/data/offline/outbox_entry.dart';

/// What a three-way merge of one queued update made of the server's task.
@immutable
class MergeResult {
  /// Creates a result.
  const MergeResult({required this.send, required this.conflicts});

  /// The person's changes nobody else touched, as a PATCH body.
  final Map<String, Object?> send;

  /// The attributes both sides changed to different values.
  final List<FieldConflict> conflicts;

  /// Whether nothing is left to send or decide.
  bool get empty => send.isEmpty && conflicts.isEmpty;
}

const _customPrefix = 'custom_fields.';

/// The key in tix's task JSON that holds what [field] of a PATCH changes.
String _taskKey(String field) => switch (field) {
  'parent_ref' => 'parent_id',
  _ => field,
};

/// Merges the person's [mine] (a PATCH body) made against [base] with the
/// server's [theirs], attribute by attribute.
///
/// An attribute only the person changed is sent; one both changed to the
/// same value is dropped; one both changed differently is a conflict. Tags
/// merge as sets, so adding and removing different tags never conflicts.
/// [base] and [theirs] are tix's task JSON.
MergeResult merge3({
  required Map<String, Object?> base,
  required Map<String, Object?> mine,
  required Map<String, Object?> theirs,
}) {
  final send = <String, Object?>{};
  final conflicts = <FieldConflict>[];
  for (final MapEntry(:key, :value) in flatten(mine).entries) {
    if (key == 'tags') {
      final merged = mergeTags(
        base: _strings(base['tags']),
        mine: _strings(value),
        theirs: _strings(theirs['tags']),
      );
      if (!same(merged, _strings(theirs['tags']))) send['tags'] = merged;
      continue;
    }
    final b = read(base, key);
    final t = read(theirs, key);
    if (same(t, value)) continue;
    if (same(t, b)) {
      send[key] = value;
    } else {
      conflicts.add(FieldConflict(field: key, base: b, mine: value, theirs: t));
    }
  }
  return MergeResult(send: unflatten(send), conflicts: conflicts);
}

/// The PATCH body that settles [result] by [policy]: the merged changes,
/// plus the person's side of every conflict when keeping theirs is not
/// asked for. Null for [ConflictPolicy.ask] while conflicts remain.
Map<String, Object?>? settle(MergeResult result, ConflictPolicy policy) {
  if (result.conflicts.isEmpty) return result.send;
  return switch (policy) {
    ConflictPolicy.ask => null,
    ConflictPolicy.keepTheirs => result.send,
    ConflictPolicy.keepMine => unflatten({
      ...flatten(result.send),
      for (final c in result.conflicts) c.field: c.mine,
    }),
  };
}

/// Tags as they should be: the server's, plus what the person added, less
/// what the person took off.
List<String> mergeTags({
  required List<String> base,
  required List<String> mine,
  required List<String> theirs,
}) {
  final added = mine.where((t) => !base.contains(t));
  final removed = base.where((t) => !mine.contains(t)).toSet();
  return [
    for (final t in theirs)
      if (!removed.contains(t)) t,
    for (final t in added)
      if (!theirs.contains(t)) t,
  ];
}

/// [body] with each custom field as its own `custom_fields.<key>` entry.
Map<String, Object?> flatten(Map<String, Object?> body) => {
  for (final MapEntry(:key, :value) in body.entries)
    if (key == 'custom_fields' && value is Map)
      for (final f in value.entries) '$_customPrefix${f.key}': f.value
    else if (key != 'version')
      key: value,
};

/// The inverse of [flatten].
Map<String, Object?> unflatten(Map<String, Object?> flat) {
  final out = <String, Object?>{};
  final custom = <String, Object?>{};
  for (final MapEntry(:key, :value) in flat.entries) {
    if (key.startsWith(_customPrefix)) {
      custom[key.substring(_customPrefix.length)] = value;
    } else {
      out[key] = value;
    }
  }
  if (custom.isNotEmpty) out['custom_fields'] = custom;
  return out;
}

/// The value of the PATCH attribute [field] in tix's task JSON [task].
Object? read(Map<String, Object?> task, String field) {
  if (field.startsWith(_customPrefix)) {
    final custom = task['custom_fields'];
    return custom is Map ? custom[field.substring(_customPrefix.length)] : null;
  }
  return task[_taskKey(field)];
}

/// Whether two JSON values mean the same: instants compared as instants,
/// an absent value as an empty one, maps whatever their key order.
bool same(Object? a, Object? b) => _canon(a) == _canon(b);

String _canon(Object? v) => jsonEncode(_norm(v));

Object? _norm(Object? v) {
  if (v == null || v == '') return null;
  if (v is String) {
    final t = _instant.hasMatch(v) ? DateTime.tryParse(v) : null;
    return t == null ? v : t.toUtc().toIso8601String();
  }
  if (v is List) return [for (final e in v) _norm(e)];
  if (v is Map) {
    final keys = [for (final k in v.keys) k.toString()]..sort();
    return {for (final k in keys) k: _norm(v[k])};
  }
  return v;
}

final _instant = RegExp(r'^\d{4}-\d{2}-\d{2}T');

List<String> _strings(Object? v) => [
  if (v is List)
    for (final e in v) e.toString(),
];
