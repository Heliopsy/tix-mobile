// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/session/admin.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/features/security/application/security.dart';

import '../../../helpers/app.dart';
import '../../../helpers/container.dart';
import '../../../helpers/fake_admin.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  test('enrolment hands out the secret and codes without keeping them '
      'in state', () async {
    final server = FakeTix();
    FakeAdmin.on(server);
    final c = await signedInContainer(server);
    final sub = c.listen(secondFactorProvider, (_, _) {});
    addTearDown(sub.close);
    expect((await c.read(secondFactorProvider.future)).enrolled, isFalse);
    final notifier = c.read(secondFactorProvider.notifier);
    expect((await notifier.enrol()).secret, FakeAdmin.secret);
    expect(await notifier.confirm(FakeAdmin.goodCode), FakeAdmin.codes);
    final status = await c.read(secondFactorProvider.future);
    expect(status.enrolled, isTrue);
    expect(status.toString(), isNot(contains(FakeAdmin.secret)));
    expect(await notifier.newRecoveryCodes(), FakeAdmin.codes);
    await notifier.remove();
    expect((await c.read(secondFactorProvider.future)).enrolled, isFalse);
  });

  test('SSH keys add and revoke, then read the list again', () async {
    final server = FakeTix();
    FakeAdmin.on(server);
    final c = await signedInContainer(server);
    final sub = c.listen(sshKeysProvider, (_, _) {});
    addTearDown(sub.close);
    await c.read(sshKeysProvider.future);
    await c
        .read(sshKeysProvider.notifier)
        .add(const EnrolSSHKeyInput(publicKey: 'ssh-ed25519 AAAA d'));
    expect(await c.read(sshKeysProvider.future), hasLength(2));
    await c.read(sshKeysProvider.notifier).revoke('k1');
    final keys = await c.read(sshKeysProvider.future);
    expect(keys.first.revokedAt, isNotNull);
  });

  group('active sessions', () {
    late FakeTix server;
    late FakeAdmin admin;

    setUp(() {
      server = FakeTix();
      admin = FakeAdmin.on(server);
    });

    Future<ProviderContainer> signedIn() async {
      final stores = signInStores(server);
      final c = makeContainer(
        fakeOverrides(
          server,
          settings: stores.settings,
          secrets: stores.secrets,
        ),
      );
      await c.read(sessionControllerProvider.future);
      final sub = c.listen(activeSessionsProvider, (_, _) {});
      addTearDown(sub.close);
      return c;
    }

    test('page with the cursor', () async {
      server.pageSize = 1;
      final c = await signedIn();
      final first = await c.read(activeSessionsProvider.future);
      expect(first.items.single.id, 'sess-here');
      await c.read(activeSessionsProvider.notifier).loadMore();
      final paged = c.read(activeSessionsProvider).value!;
      expect(paged.items.map((s) => s.id), ['sess-here', 'sess-laptop']);
      expect(paged.hasMore, isFalse);
      expect(server.requests.last.uri.queryParameters['cursor'], '1');
    });

    test('revoking another session keeps this one signed in', () async {
      final c = await signedIn();
      final paged = await c.read(activeSessionsProvider.future);
      await c
          .read(activeSessionsProvider.notifier)
          .revoke(paged.items.firstWhere((s) => !s.current));
      expect(admin.accountSessions.map((s) => s['id']), ['sess-here']);
      expect(c.read(activeSessionsProvider).value!.items.map((s) => s.id), [
        'sess-here',
      ]);
      expect(c.read(sessionControllerProvider).value, isNotNull);
    });

    test('revoking the current session signs out', () async {
      final c = await signedIn();
      final paged = await c.read(activeSessionsProvider.future);
      await c
          .read(activeSessionsProvider.notifier)
          .revoke(paged.items.firstWhere((s) => s.current));
      expect(admin.accountSessions.map((s) => s['id']), ['sess-laptop']);
      expect(c.read(sessionControllerProvider).value, isNull);
    });
  });
}
