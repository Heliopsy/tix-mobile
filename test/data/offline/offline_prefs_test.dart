// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/data/cache/cache_store.dart';
import 'package:tix_mobile/src/data/offline/offline_prefs.dart';

import '../../helpers/stores.dart';

void main() {
  const work = CacheScope('c1', 'acme');
  const home = CacheScope('c1', 'home');
  late MemoryKeyValueStore store;
  late OfflinePrefsRepository prefs;

  setUp(() {
    store = MemoryKeyValueStore();
    prefs = OfflinePrefsRepository(store);
  });

  test('My work and Starred are on until turned off', () {
    final choice = prefs.choice(work);
    expect(choice.myWork, isTrue);
    expect(choice.starred, isTrue);
    expect(choice.projects, isEmpty);
    expect(choice.isEmpty, isFalse);
    expect(prefs.syncedAt(work), isNull);
  });

  test('each context keeps its own choice and sync time', () async {
    await prefs.setChoice(
      work,
      const OfflineChoice(projects: {'web', 'infra'}, starred: false),
    );
    await prefs.setSyncedAt(work, DateTime.utc(2026, 11, 1, 12));
    expect(store.values['offline.c1.acme.projects'], '["infra","web"]');
    expect(store.values['offline.c1.acme.starred'], 'false');
    expect(
      prefs.choice(work),
      const OfflineChoice(projects: {'infra', 'web'}, starred: false),
    );
    expect(prefs.syncedAt(work), DateTime.utc(2026, 11, 1, 12));
    expect(prefs.choice(home), const OfflineChoice());
    expect(prefs.syncedAt(home), isNull);
    await prefs.clearSyncedAt(work);
    expect(prefs.syncedAt(work), isNull);
  });

  test('an unreadable project list reads as none', () {
    store.values[OfflinePrefsRepository.keyOf(work, 'projects')] = '[oops';
    expect(prefs.choice(work).projects, isEmpty);
    expect(const OfflineChoice(myWork: false, starred: false).isEmpty, isTrue);
  });
}
