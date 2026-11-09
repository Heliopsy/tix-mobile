// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ProviderListenableSelect;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/offline/sync.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/storage/providers.dart';
import 'package:tix_mobile/src/data/models/instance.dart';
import 'package:tix_mobile/src/data/models/project.dart';

export 'package:tix_mobile/src/core/offline/sync.dart';

part 'offline.g.dart';

/// Whether the active context is a local instance, which offline mode
/// leaves alone.
@riverpod
bool offlineIsLocal(Ref ref) => ref.watch(
  sessionControllerProvider.select(
    (s) => s.value?.instance.kind == InstanceKind.local,
  ),
);

/// What the active context keeps available offline.
@riverpod
class OfflineChoices extends _$OfflineChoices {
  @override
  OfflineChoice build() {
    final scope = ref.watch(activeCacheScopeProvider);
    if (scope == null) return const OfflineChoice();
    return ref.watch(offlinePrefsRepositoryProvider).choice(scope);
  }

  Future<void> _save(OfflineChoice next) async {
    final scope = ref.read(activeCacheScopeProvider);
    if (scope == null) return;
    state = next;
    await ref.read(offlinePrefsRepositoryProvider).setChoice(scope, next);
  }

  /// Keeps My work offline, or stops.
  Future<void> setMyWork({required bool on}) =>
      _save(state.copyWith(myWork: on));

  /// Keeps Starred offline, or stops.
  Future<void> setStarred({required bool on}) =>
      _save(state.copyWith(starred: on));

  /// Keeps the project [key] offline, or stops.
  Future<void> setProject(String key, {required bool on}) => _save(
    state.copyWith(
      projects: on
          ? {...state.projects, key}
          : ({...state.projects}..remove(key)),
    ),
  );
}

/// Every unarchived project the reader can keep offline, in the server's
/// order. The first page is read through the cache, so the list still shows
/// offline once it has been synced.
@riverpod
Future<List<Project>> offlineProjects(Ref ref) async {
  final repo = ref.watch(tasksRepositoryProvider);
  final all = <Project>[];
  String? cursor;
  do {
    final page = await repo.projects(cursor: cursor);
    all.addAll(page.items.where((p) => p.archivedAt == null));
    cursor = page.nextCursor;
  } while (cursor != null);
  return all;
}

/// How many bytes the active context's offline copies take, entries
/// waiting to be sent included.
@riverpod
Future<int> offlineStorage(Ref ref) async {
  ref.watch(offlineSyncProvider.select((s) => s.lastSyncedAt));
  final scope = ref.watch(activeCacheScopeProvider);
  if (scope == null) return 0;
  return await ref.watch(cacheStoreProvider).sizeOf(scope);
}
