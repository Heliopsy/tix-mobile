// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/data/models/connection.dart';
import 'package:tix_mobile/src/data/models/instance.dart';
import 'package:tix_mobile/src/data/repositories/instances_repository.dart';

import '../../helpers/stores.dart';

void main() {
  late MemoryKeyValueStore settings;
  late MemorySecretStore secrets;
  late InstancesRepository repo;
  final now = DateTime.utc(2026, 11, 8);

  setUp(() {
    settings = MemoryKeyValueStore();
    secrets = MemorySecretStore();
    repo = InstancesRepository(settings, secrets, now: () => now);
  });

  Instance remote(String id, String url) => Instance(
    id: id,
    name: id,
    kind: InstanceKind.remote,
    baseUrl: url,
    createdAt: now,
  );

  Connection token(String id, String instance, {String tenant = 'default'}) =>
      Connection(
        id: id,
        instanceId: instance,
        kind: ConnectionKind.token,
        handle: 'ana',
        tenantKey: tenant,
        createdAt: now,
      );

  group('migration from 0.1', () {
    void legacy() {
      settings.values['contexts'] = jsonEncode([
        {
          'id': 'w',
          'name': 'Work',
          'base_url': 'https://w.example',
          'handle': 'ana',
        },
        {'id': 'h', 'name': 'Home', 'base_url': 'https://h.example'},
        {
          'id': 'w2',
          'name': 'Work bot',
          'base_url': 'https://w.example',
          'handle': 'bot',
        },
      ]);
      settings.values['contexts.active'] = 'h';
      secrets.values
        ..['token.w'] = 'tw'
        ..['token.h'] = 'th'
        ..['token.w2'] = 'tw2';
    }

    test('servers become token connections on shared instances', () async {
      legacy();
      await repo.migrate();
      final instances = repo.instances();
      expect(instances.map((i) => i.baseUrl), [
        'https://w.example',
        'https://h.example',
      ]);
      expect(instances.first.name, 'Work');
      expect(instances.every((i) => i.kind == InstanceKind.remote), isTrue);
      final connections = repo.connections();
      expect(connections.map((c) => c.id), ['w', 'h', 'w2']);
      expect(connections.map((c) => c.label), ['Work', 'Home', 'Work bot']);
      expect(connections.map((c) => c.handle), ['ana', '', 'bot']);
      expect(
        connections.every((c) => c.kind == ConnectionKind.token && c.pinned),
        isTrue,
      );
      expect(repo.connectionsOf(instances.first.id).map((c) => c.id), [
        'w',
        'w2',
      ]);
      expect(repo.active(), const ContextRef(connectionId: 'h'));
      expect(repo.recents(), [const ContextRef(connectionId: 'h')]);
    });

    test('no token moves and the old keys stay for a downgrade', () async {
      legacy();
      final before = Map.of(secrets.values);
      final oldList = settings.values['contexts'];
      await repo.migrate();
      expect(secrets.values, before);
      final found = {
        for (final c in repo.connections()) c.label: await repo.secret(c),
      };
      expect(found, {'Work': 'tw', 'Home': 'th', 'Work bot': 'tw2'});
      expect(settings.values['contexts'], oldList);
      expect(settings.values['contexts.active'], 'h');
      expect(settings.values['storage.version'], '2');
    });

    test('runs once', () async {
      legacy();
      await repo.migrate();
      await repo.removeConnection('h');
      await repo.migrate();
      expect(repo.connection('h'), isNull);
    });

    test('nothing saved migrates to nothing', () async {
      await repo.migrate();
      expect(repo.instances(), isEmpty);
      expect(repo.active(), isNull);
      expect(settings.values['storage.version'], '2');
    });

    test('a stale active id is dropped', () {
      final m = migrateServers(
        jsonEncode([
          {'id': 'a', 'name': 'A', 'base_url': 'https://a'},
        ]),
        'gone',
        now,
      );
      expect(m.active, isNull);
      expect(m.connections.single.createdAt, now);
    });
  });

  test(
    'save keeps the secret out of settings and replaces the same identity',
    () async {
      final i = remote('i', 'https://a');
      final first = await repo.save(
        instance: i,
        connection: token('c1', 'i'),
        secret: 's1',
      );
      final second = await repo.save(
        instance: i,
        connection: token('c2', 'i'),
        secret: 's2',
      );
      expect(second.id, first.id);
      expect(repo.connections(), hasLength(1));
      expect(secrets.values, {'token.c1': 's2'});
      expect(settings.values.values.any((v) => v.contains('s2')), isFalse);
      await repo.save(
        instance: i,
        connection: token('c3', 'i', tenant: 'acme'),
        secret: 's3',
      );
      expect(repo.connectionsOf('i'), hasLength(2));
      expect(repo.remoteAt('https://a')?.id, 'i');
      expect(repo.remoteAt('https://b'), isNull);
      expect(repo.instances(), hasLength(1));
    },
  );

  test('sign-in secrets live under their own key', () async {
    final c = await repo.save(
      instance: remote('i', 'https://a'),
      connection: token('s', 'i').copyWith(kind: ConnectionKind.signIn),
      secret: 'sess',
    );
    expect(secrets.values, {'session.s': 'sess'});
    await repo.writeSecret(c, 'sess2');
    expect(await repo.secret(c), 'sess2');
  });

  test('activate records recents, newest first, at most eight', () async {
    for (var n = 0; n < 10; n++) {
      await repo.save(
        instance: remote('i$n', 'https://$n'),
        connection: token('c$n', 'i$n'),
        secret: 's',
      );
      await repo.activate(ContextRef(connectionId: 'c$n'));
    }
    await repo.activate(const ContextRef(connectionId: 'c5'));
    final recents = repo.recents().map((r) => r.connectionId).toList();
    expect(recents, hasLength(InstancesRepository.recentLimit));
    expect(recents.first, 'c5');
    expect(recents.where((r) => r == 'c5'), hasLength(1));
    expect(repo.instance('i5')!.lastUsedAt, now);
    expect(repo.connection('c5')!.lastUsedAt, now);
    await repo.activate(const ContextRef(connectionId: 'nope'));
    expect(repo.active()!.connectionId, 'c5');
  });

  test('removing the active connection falls back to a recent one', () async {
    final i = remote('i', 'https://a');
    await repo.save(instance: i, connection: token('a', 'i'), secret: 'x');
    await repo.save(
      instance: remote('j', 'https://b'),
      connection: token('b', 'j'),
      secret: 'y',
    );
    await repo.save(
      instance: i,
      connection: token('c', 'i', tenant: 't'),
      secret: 'z',
    );
    await repo.activate(const ContextRef(connectionId: 'b'));
    await repo.activate(const ContextRef(connectionId: 'a'));
    await repo.removeConnection('a');
    expect(repo.active()!.connectionId, 'b');
    expect(repo.instance('i'), isNotNull);
    await repo.removeConnection('b');
    expect(repo.instance('j'), isNull);
    expect(repo.active(), const ContextRef(connectionId: 'c', tenantKey: 't'));
    await repo.removeInstance('i');
    expect(repo.active(), isNull);
    expect(repo.instances(), isEmpty);
    expect(secrets.values, isEmpty);
    await repo.removeConnection('gone');
  });

  test('local instances are found by path', () async {
    final l = Instance(
      id: 'l',
      name: 'Notes',
      kind: InstanceKind.local,
      dbPath: '/n.db',
      createdAt: now,
    );
    await repo.save(instance: l, connection: token('k', 'l'), secret: 't');
    expect(repo.localAt('/n.db')?.id, 'l');
    expect(repo.localAt('/m.db'), isNull);
    expect(repo.instance('l')!.location, '/n.db');
    expect(repo.instance('l')!.host, '');
    expect(InstancesRepository.newId(), isNot(InstancesRepository.newId()));
  });
}
