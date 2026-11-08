// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/data/api/gen/models.gen.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/cache/response_cache.dart';
import 'package:tix_mobile/src/data/models/page.dart';

export 'package:tix_mobile/src/data/models/people.dart';

/// The caller's own account: its history and its calendar feed.
///
/// A feed's address is in the answer to create or rotate and nowhere else;
/// only the feed's metadata, which carries no secret, may be cached.
class AccountRepository {
  /// Reads and writes through [_api], keeping copies in [_cache].
  AccountRepository(this._api, this._cache);

  final TixApi _api;
  final ResponseCache _cache;

  static const _logKey = 'account/log';

  /// One page of the account's history, newest first (`account.log`); the
  /// first is cached.
  Future<Page<AccountLogEntry>> log({String? cursor}) {
    final fresh = _api.account.log(cursor: cursor, direction: 'desc');
    if (cursor != null) return fresh;
    return _cache.remember(_logKey, fresh, (p) => p.toJson((e) => e.toJson()));
  }

  /// The first page of the history as last read.
  Future<Page<AccountLogEntry>?> cachedLog() => _cache.peek(
    _logKey,
    (j) => Page.fromJson(
      j! as Map<String, dynamic>,
      (e) => AccountLogEntry.fromJson(e! as Map<String, dynamic>),
    ),
  );

  /// The live feed, without its address, or null when there is none
  /// (`calendar.show`).
  Future<CalendarFeed?> feed() async {
    try {
      return await _api.calendar.show();
    } on TixException catch (e) {
      if (e.kind == TixErrorKind.notFound) return null;
      rethrow;
    }
  }

  /// Issues a feed listing [filter], or the caller's open tasks when empty
  /// (`calendar.create`).
  Future<IssuedCalendarFeed> createFeed(String filter) => _api.calendar.create(
    body: CalendarFeedInput(filter: filter.trim().isEmpty ? null : filter),
  );

  /// Replaces the feed's address, keeping its filter (`calendar.rotate`).
  Future<IssuedCalendarFeed> rotateFeed() => _api.calendar.rotate();

  /// Changes the feed's filter, keeping its address (`calendar.filter`).
  Future<CalendarFeed> filterFeed(String filter) =>
      _api.calendar.filter(CalendarFeedInput(filter: filter.trim()));

  /// Stops the feed (`calendar.revoke`).
  Future<void> revokeFeed() => _api.calendar.revoke();
}
