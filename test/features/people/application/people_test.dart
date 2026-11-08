// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/session/people.dart';
import 'package:tix_mobile/src/data/api/gen/models.gen.dart';
import 'package:tix_mobile/src/features/people/application/people.dart';

import '../../../helpers/container.dart';
import '../../../helpers/fake_people.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  test('users page with their roles; a change patches one row', () async {
    final server = FakeTix()..pageSize = 2;
    FakePeople.on(server);
    final c = await signedInContainer(server);
    c.listen(usersProvider, (_, _) {});
    final first = await c.read(usersProvider.future);
    expect(first.people.items.map((p) => p.role), [Role.admin, Role.member]);
    expect(first.counts, (2, 0));
    await c.read(usersProvider.notifier).loadMore();
    final all = c.read(usersProvider).value!;
    expect(all.people.items, hasLength(3));
    expect(all.counts, (2, 1));
    final raj = all.people.items[1];
    final changed = await c
        .read(usersProvider.notifier)
        .change(raj, const UpdateUserInput(role: Role.viewer));
    expect(changed.role, Role.viewer);
    expect(c.read(usersProvider).value!.people.items[1].role, Role.viewer);
    await c.read(usersProvider.notifier).delete(changed);
    expect(c.read(usersProvider).value!.people.items, hasLength(2));
  });

  test('invites and actors without a membership', () async {
    final server = FakeTix();
    final people = FakePeople.on(server);
    server.actors['bot'] = {'id': 'bot', 'handle': 'ci', 'kind': 'agent'};
    final c = await signedInContainer(server);
    c.listen(invitesProvider, (_, _) {});
    expect(await c.read(invitesProvider.future), hasLength(1));
    final issued = await c
        .read(invitesProvider.notifier)
        .invite(email: 'z@example.com', role: Role.member, expiresIn: '3d');
    expect(issued.token, people.issued.single);
    expect(await c.read(invitesProvider.future), hasLength(2));
    await c.read(invitesProvider.notifier).revoke(const Invite(id: 'inv1'));
    expect(c.read(invitesProvider).value, hasLength(1));
    expect((await c.read(nonMembersProvider.future)).map((a) => a.id), ['bot']);
  });

  test('access follows whoami', () async {
    final server = FakeTix();
    FakePeople.on(server).me = {
      'id': 'me',
      'kind': 'agent',
      'token_id': 'tk',
      'scopes': ['task:read'],
    };
    final c = await signedInContainer(server);
    final access = await c.read(currentAccessProvider.future);
    expect(access.can(Scopes.taskRead), isTrue);
    expect(access.can(Scopes.userAdmin), isFalse);
  });
}
