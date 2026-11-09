// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:tix_mobile/src/core/storage/stores.dart';
import 'package:tix_mobile/src/data/cache/cache_store.dart';

/// What one context keeps available offline.
@immutable
class OfflineChoice {
  /// A choice of [projects], My work when [myWork], Starred when [starred].
  const OfflineChoice({
    this.projects = const {},
    this.myWork = true,
    this.starred = true,
  });

  /// The keys of the projects kept.
  final Set<String> projects;

  /// Whether the reader's own open work is kept.
  final bool myWork;

  /// Whether the reader's starred tasks are kept.
  final bool starred;

  /// Whether anything at all is kept.
  bool get isEmpty => projects.isEmpty && !myWork && !starred;

  /// A copy with the given fields replaced.
  OfflineChoice copyWith({
    Set<String>? projects,
    bool? myWork,
    bool? starred,
  }) => OfflineChoice(
    projects: projects ?? this.projects,
    myWork: myWork ?? this.myWork,
    starred: starred ?? this.starred,
  );

  @override
  bool operator ==(Object other) =>
      other is OfflineChoice &&
      other.myWork == myWork &&
      other.starred == starred &&
      other.projects.length == projects.length &&
      other.projects.containsAll(projects);

  @override
  int get hashCode =>
      Object.hash(myWork, starred, Object.hashAllUnordered(projects));
}

/// The offline choices and the last sync of each context, in preferences
/// under `offline.<connection>.<tenant>.*`.
class OfflinePrefsRepository {
  /// Keeps the choices in [_store].
  OfflinePrefsRepository(this._store);

  final KeyValueStore _store;

  /// The preference key of [field] for [scope].
  @visibleForTesting
  static String keyOf(CacheScope scope, String field) =>
      'offline.${scope.connectionId}.${scope.tenantKey}.$field';

  /// What [scope] keeps offline; My work and Starred are on until turned
  /// off.
  OfflineChoice choice(CacheScope scope) {
    final projects = _store.read(keyOf(scope, 'projects'));
    var keys = const <String>{};
    if (projects != null) {
      try {
        keys = {for (final k in jsonDecode(projects) as List) k as String};
      } on FormatException {
        keys = const {};
      }
    }
    return OfflineChoice(
      projects: keys,
      myWork: _store.read(keyOf(scope, 'mywork')) != 'false',
      starred: _store.read(keyOf(scope, 'starred')) != 'false',
    );
  }

  /// Saves [choice] for [scope].
  Future<void> setChoice(CacheScope scope, OfflineChoice choice) async {
    await _store.write(
      keyOf(scope, 'projects'),
      jsonEncode(choice.projects.toList()..sort()),
    );
    await _store.write(keyOf(scope, 'mywork'), '${choice.myWork}');
    await _store.write(keyOf(scope, 'starred'), '${choice.starred}');
  }

  /// When [scope] last finished a sync, null when never.
  DateTime? syncedAt(CacheScope scope) {
    final text = _store.read(keyOf(scope, 'synced'));
    return text == null ? null : DateTime.tryParse(text);
  }

  /// Records that [scope] finished a sync [at].
  Future<void> setSyncedAt(CacheScope scope, DateTime at) =>
      _store.write(keyOf(scope, 'synced'), at.toUtc().toIso8601String());

  /// Forgets when [scope] last synced.
  Future<void> clearSyncedAt(CacheScope scope) =>
      _store.delete(keyOf(scope, 'synced'));
}
