// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/cache/response_cache.dart';
import 'package:tix_mobile/src/data/repositories/people_repository.dart';

import '../../helpers/fake_people.dart';
import '../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;
  late FakePeople people;
  late MemoryCacheStore store;
  late PeopleRepository repo;

  setUp(() {
    server = FakeTix();
    people = FakePeople.on(server);
    store = MemoryCacheStore();
    repo = PeopleRepository(
      server.factory('https://tix.example', const BearerCredential('tok')),
      ResponseCache(store, const CacheScope('c1', '')),
    );
  });

  test('the first page of users is cached', () async {
    server.pageSize = 2;
    final first = await repo.users();
    expect(first.items.map((u) => u.email), [
      'ana@example.com',
      'raj@example.com',
    ]);
    final next = await repo.users(cursor: first.nextCursor);
    expect(next.items.single.email, 'bo@example.com');
    expect((await repo.cachedUsers())!.items, hasLength(2));
  });

  test('roles come from the memberships, null when refused', () async {
    expect(await repo.roles(), {
      'me': Role.admin,
      'a1': Role.member,
      'u3': Role.viewer,
    });
    people.membersForbidden = true;
    expect(await repo.roles(), isNull);
    server.failures['GET /api/v1/members'] = FakeResponse(
      500,
      envelope('internal', 'x'),
    );
    await expectLater(repo.roles(), throwsA(isA<TixException>()));
  });

  test('creates, changes and deletes an account', () async {
    final u = await repo.createUser(
      email: ' zoe@example.com ',
      password: 'pw',
      role: Role.viewer,
    );
    expect(server.requests.last.body, {
      'email': 'zoe@example.com',
      'password': 'pw',
      'role': 'viewer',
      'require_password_change': true,
    });
    await repo.updateUser(u.id, const UpdateUserInput(role: Role.member));
    expect(server.requests.last.body, {'role': 'member'});
    expect(people.roles[u.id], 'member');
    await repo.deleteUser(u.id);
    expect(people.users.any((x) => x['id'] == u.id), isFalse);
  });

  test('invites, re-issues and revokes', () async {
    final issued = await repo.invite(
      email: 'kim2@example.com',
      role: Role.member,
      expiresIn: '7d',
    );
    expect(server.requests.last.body['expires_in'], '7d');
    expect(issued.token, people.issued.last);
    expect(await repo.invites(), hasLength(2));
    final again = await repo.reissueInvite(issued.id);
    expect(again.url, contains(people.issued.last));
    await repo.revokeInvite(issued.id);
    expect(await repo.invites(), hasLength(1));
  });

  test('adds and removes a membership, and lists actors', () async {
    await repo.addMember('bot', Role.member);
    expect(server.requests.last.body, {'actor_id': 'bot', 'role': 'member'});
    await repo.removeMember('bot');
    expect(people.roles.containsKey('bot'), isFalse);
    expect((await repo.actors()).map((a) => a.handle), ['ana', 'raj']);
  });

  test('nothing about invites reaches the cache', () async {
    await repo.invites();
    await repo.invite(
      email: 'x@example.com',
      role: Role.member,
      expiresIn: '1d',
    );
    expect(
      store.entries.values.expand((m) => m.keys),
      isNot(contains(anything)),
    );
  });
}
