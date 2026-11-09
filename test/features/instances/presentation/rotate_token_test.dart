// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/features/instances/presentation/instances_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/container.dart';
import '../../../helpers/fake_parity.dart';
import '../../../helpers/fake_tix.dart';
import '../../../helpers/stores.dart';

/// Secure storage that refuses writes to the keys [refuses] picks, as a
/// locked keyring does.
class _LockedSecrets extends MemorySecretStore {
  bool Function(String key) refuses = (_) => false;

  @override
  Future<void> write(String key, String value) async {
    if (refuses(key)) {
      throw const TixException(TixErrorKind.secretStorageUnavailable);
    }
    await super.write(key, value);
  }
}

void main() {
  late FakeTix server;
  late FakeParity parity;
  late ({MemoryKeyValueStore settings, MemorySecretStore secrets}) stores;

  setUp(() {
    server = FakeTix();
    parity = FakeParity.on(server);
    stores = signInStores(server);
    final connections =
        jsonDecode(stores.settings.values['connections']!) as List<dynamic>
          ..add({
            'id': 't1',
            'instance_id': 'i1',
            'kind': 'token',
            'label': 'Phone',
            'handle': 'ci',
            'tenant_key': 'default',
            'created_at': '2026-11-01T00:00:00.000Z',
          });
    stores.settings.values['connections'] = jsonEncode(connections);
    stores.secrets.values['token.t1'] = 'tok-phone';
    server.tokens['tok-phone'] = 'default';
    parity.tokenIds['tok-phone'] = 'tk1';
  });

  Future<void> rotate(WidgetTester tester, Size size) async {
    await pumpScreen(
      tester,
      const InstancesScreen(),
      size: size,
      overrides: fakeOverrides(
        server,
        settings: stores.settings,
        secrets: stores.secrets,
      ),
    );
    await tester.tap(find.byKey(const Key('instances.connection.t1.menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rotate token').last);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.byKey(const Key('confirm.ok')));
    await tester.pumpAndSettle();
  }

  for (final MapEntry(key: width, value: size) in widths.entries) {
    testWidgets('$width: rotating keeps only the new token', (tester) async {
      await rotate(tester, size);
      expect(parity.rotations.single, (id: 'tk1', grace: '1m'));
      expect(stores.secrets.values['token.t1'], 'tok-rotated-1');
      expect(
        find.text('Token rotated. The old one stops in a minute.'),
        findsOneWidget,
      );
    });
  }

  testWidgets('a refusal keeps the old token and says why', (tester) async {
    server.failures['POST /api/v1/tokens/tk1/rotate'] = FakeResponse(
      403,
      envelope('forbidden', 'no'),
    );
    await rotate(tester, phone);
    expect(stores.secrets.values['token.t1'], 'tok-phone');
    expect(find.textContaining('not allowed'), findsWidgets);
  });

  Future<_LockedSecrets> locked(bool Function(String key) refuses) async {
    final secrets = _LockedSecrets()..values.addAll(stores.secrets.values);
    stores = (settings: stores.settings, secrets: secrets);
    secrets.refuses = refuses;
    return secrets;
  }

  testWidgets('a locked keyring stops the rotation before the server', (
    tester,
  ) async {
    await locked((_) => true);
    await rotate(tester, phone);
    expect(parity.rotations, isEmpty);
    expect(stores.secrets.values['token.t1'], 'tok-phone');
    expect(find.textContaining('secure storage is locked'), findsOneWidget);
  });

  for (final MapEntry(key: width, value: size) in widths.entries) {
    testWidgets('$width: a token rotated but not stored is shown once', (
      tester,
    ) async {
      await locked((key) => key == 'token.t1');
      await rotate(tester, size);
      expect(parity.rotations, hasLength(1));
      expect(stores.secrets.values['token.t1'], 'tok-phone');
      expect(find.text('Token rotated but not saved'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('secret.values')),
          matching: find.text('tok-rotated-1'),
        ),
        findsOneWidget,
      );
      expect(find.byKey(const Key('secret.copy')), findsOneWidget);
      await tester.tap(find.byKey(const Key('unsavedToken.done')));
      await tester.pumpAndSettle();
      expect(find.text('tok-rotated-1'), findsNothing);
    });
  }

  test('the active session keeps the token it could not store', () async {
    final s = signedInStores();
    parity.tokenIds['tok'] = 'tk0';
    final secrets = _LockedSecrets()..values.addAll(s.secrets.values);
    final c = makeContainer(
      fakeOverrides(server, settings: s.settings, secrets: secrets),
    );
    await c.read(sessionControllerProvider.future);
    final id = c.read(sessionControllerProvider).value!.connection.id;
    secrets.refuses = (key) => key.startsWith('token.');
    final unsaved = await c
        .read(sessionControllerProvider.notifier)
        .rotateToken(id);
    expect(unsaved, 'tok-rotated-1');
    expect(secrets.values.values, isNot(contains('tok-rotated-1')));
    server.tokens.remove('tok');
    final page = await c.read(tasksRepositoryProvider).projects();
    expect(page.items, isNotEmpty);
    expect(
      server.requests.last.headers['Authorization'],
      'Bearer tok-rotated-1',
    );
  });

  testWidgets('sign-ins are not offered a rotation', (tester) async {
    await pumpScreen(
      tester,
      const InstancesScreen(),
      overrides: fakeOverrides(
        server,
        settings: stores.settings,
        secrets: stores.secrets,
      ),
    );
    await tester.tap(find.byKey(const Key('instances.connection.s1.menu')));
    await tester.pumpAndSettle();
    expect(find.text('Rotate token'), findsNothing);
  });

  test('the active token connection keeps working after a rotation', () async {
    final s = signedInStores();
    parity.tokenIds['tok'] = 'tk0';
    final c = makeContainer(
      fakeOverrides(server, settings: s.settings, secrets: s.secrets),
    );
    await c.read(sessionControllerProvider.future);
    final id = c.read(sessionControllerProvider).value!.connection.id;
    await c.read(sessionControllerProvider.notifier).rotateToken(id);
    server.tokens.remove('tok');
    expect(s.secrets.values.values, contains('tok-rotated-1'));
    final page = await c.read(tasksRepositoryProvider).projects();
    expect(page.items, isNotEmpty);
    expect(
      server.requests.last.headers['Authorization'],
      'Bearer tok-rotated-1',
    );
  });
}
