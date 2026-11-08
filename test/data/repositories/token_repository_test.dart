// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/repositories/token_repository.dart';

import '../../helpers/fake_people.dart';
import '../../helpers/fake_tix.dart';

void main() {
  test('lists, issues and revokes tokens', () async {
    final server = FakeTix();
    final people = FakePeople.on(server);
    final repo = TokenRepository(
      server.factory('https://tix.example', const BearerCredential('tok')),
    );
    expect(await repo.tokens(), hasLength(2));
    expect((await repo.tokens(actorId: 'me')).single.name, 'ci');
    expect(server.requests.last.uri.queryParameters['actor_id'], 'me');
    final issued = await repo.issue(
      name: ' deploy ',
      scopes: ['task:read'],
      expiresAt: DateTime.utc(2026, 12),
    );
    expect(server.requests.last.body, {
      'name': 'deploy',
      'scopes': ['task:read'],
      'expires_at': '2026-12-01T00:00:00.000Z',
    });
    expect(issued.token, people.issued.single);
    await repo.revoke(issued.id);
    expect(server.requests.last.method, 'DELETE');
    expect(
      (await repo.tokens()).firstWhere((t) => t.id == issued.id).revokedAt,
      isNotNull,
    );
  });
}
