// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/data/api/credential.dart';
import 'package:tix_mobile/src/data/repositories/time_prefs_repository.dart';

import '../../helpers/fake_tix.dart';
import '../../helpers/stores.dart';

void main() {
  late FakeTix server;
  late MemoryKeyValueStore store;
  late TimePrefsRepository repo;

  setUp(() {
    server = FakeTix()..keepsTime = true;
    store = MemoryKeyValueStore();
    repo = TimePrefsRepository(
      server.factory('https://tix.example', const BearerCredential('tok')),
      store,
    );
  });

  test('reads every level and what is in force', () async {
    server
      ..timeGlobal['time_format'] = 'iso'
      ..timeTenant['timezone'] = 'Europe/Sofia';
    final s = (await repo.settings())!;
    expect(s.effective?.timeFormat, 'iso');
    expect(s.formatSource, 'global');
    expect(s.effective?.timezone, 'Europe/Sofia');
    expect(s.timezoneSource, 'tenant');
    expect(s.personal, isTrue);
  });

  test('sets only the fields given, and empty inherits', () async {
    server.timeUser['timezone'] = 'UTC';
    final s = await repo.set(format: 'dotted');
    expect(server.requestsTo('/me/time').last.body, {'time_format': 'dotted'});
    expect(s.user?.timeFormat, 'dotted');
    expect(s.user?.timezone, 'UTC');
    await repo.set(timezone: '');
    expect(server.timeUser['timezone'], '');
  });

  test('an older server keeps none', () async {
    server.keepsTime = false;
    expect(await repo.settings(), isNull);
  });

  test('other failures are not swallowed', () async {
    server.failing['/api/v1/me/time'] = FakeResponse(
      500,
      envelope('internal', 'down'),
    );
    await expectLater(repo.settings(), throwsA(isA<TixException>()));
  });

  test('remembers per context', () async {
    expect(repo.remembered('c1.default'), isNull);
    server.timeUser['time_format'] = 'us';
    await repo.remember('c1.default', (await repo.settings())!);
    expect(repo.remembered('c1.default')?.effective?.timeFormat, 'us');
    expect(repo.remembered('c2.default'), isNull);
    store.values['time.c3.x'] = 'not json';
    expect(repo.remembered('c3.x'), isNull);
  });
}
