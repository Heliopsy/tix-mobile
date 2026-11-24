// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/platform/sso_pending.dart';
import 'package:tix_mobile/src/core/storage/stores.dart';
import 'package:tix_mobile/src/data/models/sso.dart';

import '../../helpers/stores.dart';

class _LockedSecrets implements SecretStore {
  @override
  Future<String?> read(String key) =>
      throw const TixException(TixErrorKind.secretStorageUnavailable);

  @override
  Future<void> write(String key, String value) =>
      throw const TixException(TixErrorKind.secretStorageUnavailable);

  @override
  Future<void> delete(String key) =>
      throw const TixException(TixErrorKind.secretStorageUnavailable);
}

void main() {
  final start = DateTime.utc(2026, 11, 1, 12);
  late DateTime now;
  late MemorySecretStore secrets;

  setUp(() {
    now = start;
    secrets = MemorySecretStore();
  });

  PendingSsoStore store([SecretStore? s]) =>
      PendingSsoStore(s ?? secrets, now: () => now);

  PendingSso pending(String state) => PendingSso(
    attempt: SsoAttempt(
      baseUrl: 'https://tix.example',
      provider: 'acme',
      verifier: 'verifier-$state',
      state: state,
    ),
    startedAt: start,
    name: 'Work',
    replacing: 'c1',
  );

  test('an attempt is kept with everything needed to finish it', () async {
    await store().save(pending('s1'));
    final kept = jsonDecode(secrets.values[PendingSsoStore.key]!);
    expect(kept, {
      'base_url': 'https://tix.example',
      'provider': 'acme',
      'verifier': 'verifier-s1',
      'state': 's1',
      'started_at': '2026-11-01T12:00:00.000Z',
      'name': 'Work',
      'replacing': 'c1',
    });
  });

  test('the next run takes it once', () async {
    await store().save(pending('s1'));
    final next = store();
    final taken = await next.take();
    expect(taken?.attempt.state, 's1');
    expect(taken?.attempt.verifier, 'verifier-s1');
    expect(taken?.replacing, 'c1');
    expect(taken?.name, 'Work');
    expect(secrets.values, isEmpty);
    expect(await next.take(), isNull);
  });

  test('peek leaves it in place', () async {
    await store().save(pending('s1'));
    final next = store();
    expect((await next.peek())?.replacing, 'c1');
    expect(secrets.values, isNotEmpty);
  });

  test('the run that kept it cannot take it', () async {
    final s = store();
    await s.save(pending('s1'));
    expect(s.live, isTrue);
    expect(await s.take(), isNull);
    expect(await s.peek(), isNull);
    expect(secrets.values, isNotEmpty);
  });

  test('clear forgets only the attempt it names', () async {
    final s = store();
    await s.save(pending('s1'));
    await s.save(pending('s2'));
    await s.clear('s1');
    expect(s.live, isTrue);
    final kept = jsonDecode(secrets.values[PendingSsoStore.key]!) as Map;
    expect(kept['state'], 's2');
    await s.clear('s2');
    expect(s.live, isFalse);
    expect(secrets.values, isEmpty);
  });

  test('one past its lifetime is dropped', () async {
    await store().save(pending('s1'));
    now = start.add(const Duration(minutes: 11));
    expect(await store().take(), isNull);
    expect(secrets.values, isEmpty);
  });

  test('something unreadable is dropped', () async {
    secrets.values[PendingSsoStore.key] = '{not json';
    expect(await store().take(), isNull);
    secrets.values[PendingSsoStore.key] = '{"state": 1}';
    expect(await store().take(), isNull);
    expect(secrets.values, isEmpty);
  });

  test('a locked keychain costs the recovery, not the sign-in', () async {
    final s = store(_LockedSecrets());
    await s.save(pending('s1'));
    expect(s.live, isTrue);
    await s.clear('s1');
    expect(await store(_LockedSecrets()).take(), isNull);
  });
}
