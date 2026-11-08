// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/cache/cached.dart';
import 'package:tix_mobile/src/core/events/invalidation.dart';
import 'package:tix_mobile/src/core/paging/paged.dart';
import 'package:tix_mobile/src/core/session/people.dart';
import 'package:tix_mobile/src/data/models/page.dart';
import 'package:tix_mobile/src/data/repositories/account_repository.dart';

part 'account.g.dart';

/// The caller's account history, newest first, a page at a time.
@riverpod
class AccountLog extends _$AccountLog {
  @override
  Future<Paged<AccountLogEntry>> build() async {
    final repo = ref.watch(accountRepositoryProvider);
    refreshOn(ref, EventTopics.people);
    final page = await cachedFirst(
      ref: ref,
      cached: repo.cachedLog(),
      fresh: repo.log,
      onFresh: (p) => state = AsyncData(_paged(p)),
    );
    return _paged(page);
  }

  static Paged<AccountLogEntry> _paged(Page<AccountLogEntry> p) =>
      Paged(items: p.items, cursor: p.nextCursor);

  /// Fetches the next page, if there is one and none is in flight.
  Future<void> loadMore() => loadNextPage(
    current: state.value,
    fetch: (cursor) => ref.read(accountRepositoryProvider).log(cursor: cursor),
    emit: (next) => state = AsyncData(next),
    idOf: (e) => e.seq,
  );
}

/// The caller's calendar feed, null when there is none.
///
/// The feed's address is never held here: create and rotate return it to
/// the screen that shows it once.
@riverpod
class Calendar extends _$Calendar {
  @override
  Future<CalendarFeed?> build() async {
    final repo = ref.watch(accountRepositoryProvider);
    refreshOn(ref, EventTopics.calendar);
    return await repo.feed();
  }

  /// Issues a feed listing [filter].
  Future<IssuedCalendarFeed> create(String filter) async {
    final issued = await ref.read(accountRepositoryProvider).createFeed(filter);
    if (ref.mounted) state = AsyncData(_metadata(issued));
    return issued;
  }

  /// Replaces the feed's address.
  Future<IssuedCalendarFeed> rotate() async {
    final issued = await ref.read(accountRepositoryProvider).rotateFeed();
    if (ref.mounted) state = AsyncData(_metadata(issued));
    return issued;
  }

  /// Changes the feed's filter, keeping its address.
  Future<void> setFilter(String filter) async {
    final feed = await ref.read(accountRepositoryProvider).filterFeed(filter);
    if (ref.mounted) state = AsyncData(feed);
  }

  /// Stops the feed.
  Future<void> revoke() async {
    await ref.read(accountRepositoryProvider).revokeFeed();
    if (ref.mounted) state = const AsyncData(null);
  }

  static CalendarFeed _metadata(IssuedCalendarFeed f) => CalendarFeed(
    id: f.id,
    actorId: f.actorId,
    tenantId: f.tenantId,
    filter: f.filter,
    createdAt: f.createdAt,
  );
}
