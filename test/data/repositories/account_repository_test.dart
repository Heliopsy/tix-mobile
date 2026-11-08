// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/cache/response_cache.dart';
import 'package:tix_mobile/src/data/repositories/account_repository.dart';

import '../../helpers/fake_people.dart';
import '../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;
  late FakePeople people;
  late MemoryCacheStore store;
  late AccountRepository repo;

  setUp(() {
    server = FakeTix();
    people = FakePeople.on(server);
    store = MemoryCacheStore();
    repo = AccountRepository(
      server.factory('https://tix.example', const BearerCredential('tok')),
      ResponseCache(store, const CacheScope('c1', '')),
    );
  });

  test('the history is read newest first and its first page cached', () async {
    people.log.add({'seq': 2, 'action': 'user.totp.confirmed'});
    final page = await repo.log();
    expect(page.items.map((e) => e.seq), [2, 1]);
    expect(server.requests.last.uri.queryParameters['direction'], 'desc');
    expect((await repo.cachedLog())!.items, hasLength(2));
  });

  test('the feed is created, filtered, rotated and revoked', () async {
    expect(await repo.feed(), isNull);
    final issued = await repo.createFeed('');
    expect(server.requests.last.body, <String, dynamic>{});
    expect(issued.token, people.issued.last);
    expect((await repo.feed())!.id, issued.id);
    expect((await repo.filterFeed('tag:ops')).filter, 'tag:ops');
    final rotated = await repo.rotateFeed();
    expect(rotated.token, isNot(issued.token));
    await repo.revokeFeed();
    expect(await repo.feed(), isNull);
    expect(store.entries, isEmpty);
  });
}
