// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:meta/meta.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/cache/cached.dart';
import 'package:tix_mobile/src/core/clock/clock.dart';
import 'package:tix_mobile/src/core/events/invalidation.dart';
import 'package:tix_mobile/src/core/notifications/local_notifier.dart';
import 'package:tix_mobile/src/core/paging/paged.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/models/inbox.dart';
import 'package:tix_mobile/src/data/models/page.dart';

export 'package:tix_mobile/src/core/session/session.dart'
    show inboxRepositoryProvider;
export 'package:tix_mobile/src/data/models/inbox.dart';

part 'inbox.g.dart';

/// What the inbox screen shows: everything or unread only, and the kinds
/// it narrows to (none means every kind).
@immutable
class InboxFilter {
  /// A filter.
  const InboxFilter({this.unread = false, this.kinds = const {}});

  /// Unread only, asked of the server.
  final bool unread;

  /// The kinds kept, filtered here because tix has no such parameter.
  final Set<InboxKind> kinds;

  /// Whether [item] passes the kind filter.
  bool keeps(InboxItem item) => kinds.isEmpty || kinds.contains(item.kind);

  /// A copy with the given fields replaced.
  InboxFilter copyWith({bool? unread, Set<InboxKind>? kinds}) =>
      InboxFilter(unread: unread ?? this.unread, kinds: kinds ?? this.kinds);
}

/// The inbox screen's filter.
@riverpod
class InboxFilterState extends _$InboxFilterState {
  @override
  InboxFilter build() => const InboxFilter();

  /// Shows unread items only, or everything.
  void setUnread({required bool unread}) =>
      state = state.copyWith(unread: unread);

  /// Turns the filter for [kind] on or off.
  void toggleKind(InboxKind kind) => state = state.copyWith(
    kinds: state.kinds.contains(kind)
        ? ({...state.kinds}..remove(kind))
        : {...state.kinds, kind},
  );

  /// Shows every kind again.
  void clearKinds() => state = state.copyWith(kinds: const {});
}

/// Rows that arrived with the last live refresh, for a moment's highlight.
@riverpod
class FreshInboxIds extends _$FreshInboxIds {
  @override
  Set<String> build() => const {};

  /// Highlights [ids] until the next refresh.
  void highlight(Iterable<String> ids) => state = ids.toSet();
}

/// The caller's inbox, newest first, a page at a time; [unread] asks the
/// server for unread items only. Follows live events.
@riverpod
class InboxList extends _$InboxList {
  /// The most pages read in a row while a kind filter hides every row.
  static const fillPages = 5;

  @override
  Future<Paged<InboxItem>> build(bool unread) async {
    onEvents(ref, EventTopics.inbox, (_) => unawaited(refreshQuietly()));
    final repo = ref.watch(inboxRepositoryProvider);
    Paged<InboxItem> paged(Page<InboxItem> p) =>
        Paged(items: p.items, cursor: p.nextCursor);
    return paged(
      await cachedFirst(
        ref: ref,
        cached: repo.cachedItems(unread: unread),
        fresh: () => repo.items(unread: unread),
        onFresh: (p) => state = AsyncData(paged(p)),
      ),
    );
  }

  /// Fetches the next page, if there is one and none is in flight.
  Future<void> loadMore() => loadNextPage(
    current: state.value,
    fetch: (cursor) =>
        ref.read(inboxRepositoryProvider).items(unread: unread, cursor: cursor),
    emit: (next) => state = AsyncData(next),
    idOf: (item) => item.id,
  );

  /// Reads further pages until one holds a row [keep] passes, at most
  /// [fillPages]: a kind filter must not show "empty" while pages remain.
  Future<void> fill(bool Function(InboxItem) keep) async {
    for (var i = 0; i < fillPages; i++) {
      final current = state.value;
      if (current == null || !current.hasMore || current.moreError != null) {
        return;
      }
      if (current.items.any(keep)) return;
      await loadMore();
    }
  }

  /// Reads the first page again in place, keeping later pages already
  /// loaded and marking rows that were not there before.
  Future<void> refreshQuietly() async {
    final before = state.value;
    if (before == null) return;
    try {
      final page = await ref
          .read(inboxRepositoryProvider)
          .items(unread: unread);
      if (!ref.mounted) return;
      final current = state.value ?? before;
      final known = {for (final i in current.items) i.id};
      final fresh = {
        for (final i in page.items)
          if (!known.contains(i.id)) i.id,
      };
      final firstIds = {for (final i in page.items) i.id};
      final keepRest = current.items.length > page.items.length;
      state = AsyncData(
        current.copyWith(
          items: [
            ...page.items,
            if (keepRest)
              ...current.items.where((i) => !firstIds.contains(i.id)),
          ],
          cursor: keepRest ? null : () => page.nextCursor,
        ),
      );
      if (fresh.isNotEmpty && known.isNotEmpty) {
        ref.read(freshInboxIdsProvider.notifier).highlight(fresh);
      }
    } on Object {
      // A quiet refresh that fails leaves the rows as they were; the next
      // event or a pull tries again.
    }
  }

  /// Shows [id] as read or unread at once.
  void setRead(String id, {required bool read}) {
    final current = state.value;
    if (current == null) return;
    final now = ref.read(clockProvider)();
    state = AsyncData(
      current.copyWith(
        items: [
          for (final i in current.items)
            if (i.id == id) i.copyWith(readAt: read ? now : null) else i,
        ],
        cursor: () => current.cursor,
      ),
    );
  }

  /// Shows every row read at once.
  void setAllRead() {
    final current = state.value;
    if (current == null) return;
    final now = ref.read(clockProvider)();
    state = AsyncData(
      current.copyWith(
        items: [
          for (final i in current.items)
            if (i.read) i else i.copyWith(readAt: now),
        ],
        cursor: () => current.cursor,
      ),
    );
  }

  /// Puts [items] back as they were, after a refused change.
  void restore(List<InboxItem> items) {
    final current = state.value;
    if (current == null) return;
    final byId = {for (final i in items) i.id: i};
    state = AsyncData(
      current.copyWith(
        items: [for (final i in current.items) byId[i.id] ?? i],
        cursor: () => current.cursor,
      ),
    );
  }
}

/// How many of the caller's items are unread. Follows live events.
@riverpod
class InboxUnread extends _$InboxUnread {
  @override
  Future<int> build() {
    refreshOn(ref, EventTopics.inbox);
    final repo = ref.watch(inboxRepositoryProvider);
    return cachedFirst(
      ref: ref,
      cached: repo.cachedUnreadCount(),
      fresh: repo.unreadCount,
      onFresh: (n) => state = AsyncData(n),
    );
  }

  /// Moves the count by [delta] at once, never below zero.
  void adjust(int delta) {
    final n = state.value;
    if (n == null) return;
    state = AsyncData((n + delta).clamp(0, 1 << 30));
  }

  /// Sets the count at once.
  void set(int n) => state = AsyncData(n);
}

/// Marking items, for every list and the badge at once. The inbox screen
/// watches it, which keeps it alive while marks are in flight.
@riverpod
class InboxMarks extends _$InboxMarks {
  @override
  void build() {}

  // Riverpod 3.5 deprecates exists without shipping the replacement it
  // names, and reading a list that is not loaded would fetch it.
  // ignore: deprecated_member_use
  bool _loaded(bool unread) => ref.exists(inboxListProvider(unread));

  Iterable<InboxList> get _lists => [
    for (final unread in const [false, true])
      if (_loaded(unread)) ref.read(inboxListProvider(unread).notifier),
  ];

  /// Shows [item] as read or unread at once.
  void apply(InboxItem item, {required bool read}) {
    if (item.read == read) return;
    for (final l in _lists) {
      l.setRead(item.id, read: read);
    }
    ref.read(inboxUnreadProvider.notifier).adjust(read ? -1 : 1);
    if (read) {
      unawaited(ref.read(localNotesProvider).cancel(stableNoteId(item.id)));
    }
  }

  /// Puts [item] back as it was.
  void rollback(InboxItem item) {
    for (final l in _lists) {
      l.restore([item]);
    }
    ref.invalidate(inboxUnreadProvider);
  }

  /// Asks the server to mark [item] read or unread.
  Future<void> send(InboxItem item, {required bool read}) async {
    final repo = ref.read(inboxRepositoryProvider);
    await (read ? repo.markRead(item.id) : repo.markUnread(item.id));
  }

  /// Marks [item] read, at once and on the server, without a toast: what
  /// opening an item does. A refusal is rolled back.
  Future<void> openRead(InboxItem item) async {
    if (item.read) return;
    apply(item, read: true);
    try {
      await send(item, read: true);
    } on Object {
      rollback(item);
    }
  }

  /// Shows every loaded row read; answers what to restore.
  List<InboxItem> applyAll() {
    final before = [
      for (final unread in const [false, true])
        if (_loaded(unread))
          for (final i
              in ref.read(inboxListProvider(unread)).value?.items ??
                  const <InboxItem>[])
            if (!i.read) i,
    ];
    for (final l in _lists) {
      l.setAllRead();
    }
    ref.read(inboxUnreadProvider.notifier).set(0);
    unawaited(ref.read(localNotesProvider).cancelAll());
    return before;
  }

  /// Puts [items] back after a refused mark-all.
  void rollbackAll(List<InboxItem> items) {
    for (final l in _lists) {
      l.restore(items);
    }
    ref.invalidate(inboxUnreadProvider);
  }

  /// Asks the server to mark everything read; answers how many changed.
  Future<int> sendAll() => ref.read(inboxRepositoryProvider).markAllRead();
}

/// The kinds muted on the server: they create no item at all.
@riverpod
class InboxMuted extends _$InboxMuted {
  @override
  Future<Set<InboxKind>> build() => ref.watch(inboxRepositoryProvider).muted();

  /// Receives [kind] again, or mutes it.
  Future<void> setReceive(InboxKind kind, {required bool receive}) async {
    final current = state.value ?? const <InboxKind>{};
    final next = receive ? ({...current}..remove(kind)) : {...current, kind};
    state = AsyncData(next);
    try {
      state = AsyncData(await ref.read(inboxRepositoryProvider).setMuted(next));
    } on Object {
      state = AsyncData(current);
      rethrow;
    }
  }
}

/// The summary card's numbers.
@immutable
class InboxSummary {
  /// Holds the counts.
  const InboxSummary({
    required this.byCategory,
    required this.completed,
    required this.overdue,
    required this.dueToday,
  });

  /// Tasks now in each state category.
  final Map<StateCategory, int> byCategory;

  /// Tasks completed in the last seven days.
  final int completed;

  /// The caller's open tasks past due.
  final int overdue;

  /// The caller's open tasks due later today.
  final int dueToday;

  /// Tasks not in a terminal category.
  int get open => byCategory.entries
      .where(
        (e) => e.key != StateCategory.done && e.key != StateCategory.cancelled,
      )
      .fold(0, (n, e) => n + e.value);
}

/// The tenant's numbers and the caller's deadlines.
@riverpod
Future<InboxSummary> inboxSummary(Ref ref) async {
  final repo = ref.watch(inboxRepositoryProvider);
  final now = ref.watch(clockProvider)();
  final local = now.toLocal();
  final endOfDay = DateTime(local.year, local.month, local.day + 1);
  final (stats, due) = await (
    repo.stats(),
    repo.openTasksDueBefore(endOfDay),
  ).wait;
  var overdue = 0;
  var today = 0;
  for (final t in due) {
    final at = t.dueAt;
    if (at == null) continue;
    if (at.isBefore(now)) {
      overdue++;
    } else {
      today++;
    }
  }
  return InboxSummary(
    byCategory: {for (final c in stats.byCategory) ?c.category: c.count},
    completed: stats.completed,
    overdue: overdue,
    dueToday: today,
  );
}
