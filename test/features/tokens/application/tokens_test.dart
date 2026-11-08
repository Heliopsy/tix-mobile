// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/features/tokens/application/tokens.dart';

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
}
