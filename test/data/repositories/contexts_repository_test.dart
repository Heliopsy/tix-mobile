// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/data/models/server_context.dart';
import 'package:tix_mobile/src/data/repositories/contexts_repository.dart';

import '../../helpers/stores.dart';

void main() {
  late MemoryKeyValueStore settings;
  late MemorySecretStore secrets;
  late ContextsRepository repo;

  const work = ServerContext(id: 'w', name: 'Work', baseUrl: 'https://w');
  const home = ServerContext(id: 'h', name: 'Home', baseUrl: 'https://h');

  setUp(() {
    settings = MemoryKeyValueStore();
    secrets = MemorySecretStore();
    repo = ContextsRepository(settings, secrets);
  });

  test('starts empty', () {
    expect(repo.contexts(), isEmpty);
    expect(repo.active(), isNull);
  });

  test(
    'save keeps the token out of settings and activates the context',
    () async {
      await repo.save(work, 'tok-w');
      expect(repo.active(), work);
      expect(await repo.token('w'), 'tok-w');
      expect(settings.values.values.join(), isNot(contains('tok-w')));
      expect(secrets.values, {'token.w': 'tok-w'});
    },
  );

  test('saving the same id replaces it in place of a duplicate', () async {
    await repo.save(work, 'a');
    await repo.save(home, 'b');
    await repo.save(work.copyWith(name: 'Office'), 'c');
    expect(repo.contexts().map((c) => c.name), ['Home', 'Office']);
    expect(await repo.token('w'), 'c');
    expect(repo.active()?.id, 'w');
  });

  test('activate switches between saved contexts', () async {
    await repo.save(work, 'a');
    await repo.save(home, 'b');
    await repo.activate('w');
    expect(repo.active(), work);
  });

  test('remove forgets the token and falls back to the next context', () async {
    await repo.save(work, 'a');
    await repo.save(home, 'b');
    await repo.remove('h');
    expect(await repo.token('h'), isNull);
    expect(repo.contexts(), [work]);
    expect(repo.active(), work);
    await repo.remove('w');
    expect(repo.contexts(), isEmpty);
    expect(repo.active(), isNull);
    expect(secrets.values, isEmpty);
  });

  test('removing an inactive context leaves the active one', () async {
    await repo.save(work, 'a');
    await repo.save(home, 'b');
    await repo.remove('w');
    expect(repo.active(), home);
  });
}
