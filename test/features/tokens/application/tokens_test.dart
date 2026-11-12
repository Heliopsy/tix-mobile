// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/session/access.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/features/tokens/application/tokens.dart';

import '../../../helpers/app.dart';

import '../../../helpers/container.dart';
import '../../../helpers/fake_people.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  test('tokens list newest first, issue and revoke', () async {
    final server = FakeTix();
    final people = FakePeople.on(server);
    final c = await signedInContainer(server);
    c.listen(tokensProvider(null), (_, _) {});
    expect((await c.read(tokensProvider(null).future)).map((t) => t.name), [
      'raj-laptop',
      'ci',
    ]);
    final issued = await c
        .read(tokensProvider(null).notifier)
        .issue(name: 'x', scopes: ['task:read']);
    expect(issued.token, people.issued.single);
    final list = await c.read(tokensProvider(null).future);
    expect(list.first.name, 'x');
    expect(list.toString(), isNot(contains(issued.token)));
    await c.read(tokensProvider(null).notifier).revoke(list.first);
    expect(
      (await c.read(tokensProvider(null).future)).first.revokedAt,
      isNotNull,
    );
    expect((await c.read(tokenOwnersProvider.future)).keys, contains('a1'));
  });

  test("somebody else's token is rotated and its value handed back", () async {
    final server = FakeTix();
    final people = FakePeople.on(server);
    final c = await signedInContainer(server);
    c.listen(tokensProvider(null), (_, _) {});
    final list = await c.read(tokensProvider(null).future);
    final rotated = await c
        .read(tokensProvider(null).notifier)
        .rotate(list.firstWhere((t) => t.id == 't2'), grace: '10m');
    expect(rotated.value, people.issued.single);
    expect(rotated.connection, isFalse);
    expect(server.requestsTo('/api/v1/tokens/t2/rotate').single.body, {
      'grace': '10m',
    });
    final after = await c.read(tokensProvider(null).future);
    expect(after, hasLength(3));
    expect(after.toString(), isNot(contains(rotated.value)));
  });

  test("the app's own token is swapped in the connection", () async {
    final server = FakeTix();
    final people = FakePeople.on(server)
      ..me = {
        'id': 'me',
        'handle': 'ana',
        'kind': 'agent',
        'token_id': 't1',
        'scopes': ['*'],
      };
    final stores = signedInStores();
    final c = makeContainer(
      fakeOverrides(server, settings: stores.settings, secrets: stores.secrets),
    );
    await c.read(sessionControllerProvider.future);
    c.listen(tokensProvider(null), (_, _) {});
    final list = await c.read(tokensProvider(null).future);
    c.listen(currentAccessProvider, (_, _) {});
    await c.read(currentAccessProvider.future);
    final rotated = await c
        .read(tokensProvider(null).notifier)
        .rotate(list.firstWhere((t) => t.id == 't1'), grace: '1h');
    expect(rotated.value, isNull);
    expect(rotated.connection, isTrue);
    expect(server.requestsTo('/api/v1/tokens/t1/rotate').single.body, {
      'grace': '1h',
    });
    expect(stores.secrets.values['token.c1'], people.issued.single);
  });
}
