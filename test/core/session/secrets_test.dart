// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/logging/log.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/api/gen/models.gen.dart';
import 'package:tix_mobile/src/data/cache/cache_store.dart';
import 'package:tix_mobile/src/features/account/application/account.dart';
import 'package:tix_mobile/src/features/people/application/people.dart';
import 'package:tix_mobile/src/features/tokens/application/tokens.dart';

import '../../helpers/app.dart';
import '../../helpers/container.dart';
import '../../helpers/fake_people.dart';
import '../../helpers/fake_tix.dart';

/// A token value, an invite link and a calendar address are shown once and
/// must never reach the response cache or the log.
void main() {
  test('issued secrets never reach the cache or the log', () async {
    final lines = <String>[];
    final saved = logSink;
    logSink = (m, error, stackTrace) => lines.add('$m $error $stackTrace');
    addTearDown(() => logSink = saved);

    final server = FakeTix();
    final people = FakePeople.on(server);
    final cache = MemoryCacheStore();
    final stores = signedInStores();
    final c = makeContainer(
      fakeOverrides(
        server,
        settings: stores.settings,
        secrets: stores.secrets,
        cache: cache,
      ),
    );
    await c.read(sessionControllerProvider.future);
    c
      ..listen(usersProvider, (_, _) {})
      ..listen(invitesProvider, (_, _) {})
      ..listen(tokensProvider(null), (_, _) {})
      ..listen(calendarProvider, (_, _) {})
      ..listen(accountLogProvider, (_, _) {});
    await c.read(usersProvider.future);
    await c.read(invitesProvider.future);
    await c.read(tokensProvider(null).future);
    await c.read(calendarProvider.future);
    await c.read(accountLogProvider.future);

    await c
        .read(invitesProvider.notifier)
        .invite(email: 'kim@example.com', role: Role.member, expiresIn: '7d');
    await c.read(invitesProvider.notifier).reissue(const Invite(id: 'inv1'));
    await c
        .read(tokensProvider(null).notifier)
        .issue(name: 'deploy', scopes: ['task:read']);
    await c.read(calendarProvider.notifier).create('');
    await c.read(calendarProvider.notifier).rotate();
    await c.read(usersProvider.future);
    await c.read(tokensProvider(null).future);
    await c.read(invitesProvider.future);

    expect(people.issued, hasLength(5));
    expect(cache.entries, isNotEmpty);
    final cached = cache.entries.values.expand((m) => m.values).join('\n');
    expect(lines, isNotEmpty);
    final logged = lines.join('\n');
    for (final secret in people.issued) {
      expect(cached, isNot(contains(secret)), reason: 'cached $secret');
      expect(logged, isNot(contains(secret)), reason: 'logged $secret');
    }
    for (final state in [
      c.read(tokensProvider(null)).value.toString(),
      c.read(invitesProvider).value.toString(),
      c.read(calendarProvider).value.toString(),
    ]) {
      for (final secret in people.issued) {
        expect(state, isNot(contains(secret)));
      }
    }
  });
}
