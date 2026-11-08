// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/features/account/application/account.dart';

import '../../../helpers/container.dart';
import '../../../helpers/fake_people.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  test('the history pages; the feed keeps no address', () async {
    final server = FakeTix()..pageSize = 1;
    final people = FakePeople.on(server);
    people.log.add({'seq': 2, 'action': 'user.totp.confirmed'});
    final c = await signedInContainer(server);
    c
      ..listen(accountLogProvider, (_, _) {})
      ..listen(calendarProvider, (_, _) {});
    expect((await c.read(accountLogProvider.future)).items.single.seq, 2);
    await c.read(accountLogProvider.notifier).loadMore();
    expect(c.read(accountLogProvider).value!.items.map((e) => e.seq), [2, 1]);

    expect(await c.read(calendarProvider.future), isNull);
    final issued = await c.read(calendarProvider.notifier).create('tag:ops');
    expect(c.read(calendarProvider).value!.filter, 'tag:ops');
    expect(
      c.read(calendarProvider).value.toString(),
      isNot(contains(issued.token)),
    );
    await c.read(calendarProvider.notifier).setFilter('tag:x');
    expect(c.read(calendarProvider).value!.filter, 'tag:x');
    await c.read(calendarProvider.notifier).rotate();
    await c.read(calendarProvider.notifier).revoke();
    expect(c.read(calendarProvider).value, isNull);
  });
}
