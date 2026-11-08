// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:tix_mobile/src/core/config/config.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/cache/response_cache.dart';
import 'package:tix_mobile/src/data/models/inbox.dart';
import 'package:tix_mobile/src/data/models/page.dart';
import 'package:tix_mobile/src/data/models/task.dart';

/// The caller's inbox, their channels and the summary numbers.
///
/// The first page of the inbox and the unread count are kept in [_cache],
/// with `cached…` twins a screen draws before the server answers.
class InboxRepository {
  /// Reads through [_api], keeping copies in [_cache].
  InboxRepository(this._api, this._cache);

  final TixApi _api;
  final ResponseCache _cache;

  static Page<InboxItem> _items(Object? json) => Page.fromJson(
    json! as Map<String, dynamic>,
    (e) => InboxItem.fromJson(e! as Map<String, dynamic>),
  );

  static String _key(bool unread) => unread ? 'inbox/unread' : 'inbox';

  /// One page of items, newest first; only unread ones when [unread].
  Future<Page<InboxItem>> items({bool unread = false, String? cursor}) {
    final fresh = _api.inbox.list(
      unread: unread ? true : null,
      cursor: cursor,
      limit: pageSize,
    );
    if (cursor != null) return fresh;
    return _cache.remember(
      _key(unread),
      fresh,
      (p) => p.toJson((e) => e.toJson()),
    );
  }

  /// The first page as last read, null when never read.
  Future<Page<InboxItem>?> cachedItems({bool unread = false}) =>
      _cache.peek(_key(unread), _items);

  /// How many items are unread.
  Future<int> unreadCount() => _cache.remember(
    'inbox/count',
    _api.inbox.count().then((c) => c.unread),
    (n) => n,
  );

  /// The unread count as last read, null when never read.
  Future<int?> cachedUnreadCount() =>
      _cache.peek('inbox/count', (json) => json! as int);

  /// Marks [id] read.
  Future<InboxItem> markRead(String id) => _api.inbox.read(id);

  /// Marks [id] unread.
  Future<InboxItem> markUnread(String id) => _api.inbox.unread(id);

  /// Marks everything read; answers how many changed.
  Future<int> markAllRead() async => (await _api.inbox.readAll()).marked;

  /// The kinds muted on the server.
  Future<Set<InboxKind>> muted() async =>
      _kinds((await _api.inbox.prefs()).muted);

  /// Replaces the muted kinds.
  Future<Set<InboxKind>> setMuted(Set<InboxKind> kinds) async => _kinds(
    (await _api.inbox.prefsSet(
      InboxPrefsInput(
        muted: [
          for (final k in inboxKinds)
            if (kinds.contains(k)) k.value,
        ],
      ),
    )).muted,
  );

  /// Every channel.
  Future<List<InboxChannel>> channels() async => [
    ...(await _api.inbox.channelList()).items,
  ];

  /// Adds a channel; the answer carries its secret.
  Future<IssuedInboxChannel> addChannel(InboxChannelInput input) =>
      _api.inbox.channelAdd(input);

  /// Changes a channel.
  Future<InboxChannel> editChannel(String id, InboxChannelUpdate input) =>
      _api.inbox.channelEdit(id, input);

  /// Deletes a channel and its deliveries.
  Future<void> deleteChannel(String id) => _api.inbox.channelRm(id);

  /// Queues a test message.
  Future<ChannelDelivery> testChannel(String id) => _api.inbox.channelTest(id);

  /// One page of a channel's deliveries.
  Future<Page<ChannelDelivery>> deliveries(String channel, {String? cursor}) =>
      _api.inbox.channelDeliveries(channel, cursor: cursor, limit: pageSize);

  /// Queues another attempt of delivery [id].
  Future<void> redeliver(String id) => _api.inbox.channelRedeliver(id);

  /// The tenant's numbers over the last seven days.
  Future<Stats> stats() => _api.stats.read(window: '7d');

  /// The caller's open tasks due before [before], at most one page.
  Future<List<Task>> openTasksDueBefore(DateTime before) async => [
    for (final t in (await _api.task.list(
      assignee: ['me'],
      dueBefore: before.toUtc(),
      sort: 'due_at',
      limit: 100,
    )).items)
      if (t.completedAt == null) t,
  ];

  static Set<InboxKind> _kinds(List<String> names) => {
    for (final n in names) ?inboxKindNamed(n),
  };
}
