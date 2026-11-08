// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/platform/share_intake.dart';
import 'package:tix_mobile/src/core/quick/quick_add.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/features/connect/presentation/connect_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_parity.dart';
import '../../../helpers/fake_tix.dart';
import '../../../helpers/stores.dart';

void main() {
  const channel = MethodChannel('tix/share-connect-test');
  const link = 'https://tix.example/invite/tix_inv_abc';
  late FakeTix server;
  late FakeParity parity;
  late MemorySecretStore secrets;
  Map<String, String>? pending;

  setUp(() {
    server = FakeTix();
    parity = FakeParity.on(server);
    secrets = MemorySecretStore();
    pending = null;
    parity.invites['tix_inv_abc'] = FakeInvite(
      email: 'lee@example.com',
      displayName: 'Lee',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          final p = pending;
          pending = null;
          return p;
        });
  });

  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null),
  );

  Future<ProviderContainer> pump(
    WidgetTester tester,
    ConnectScreen screen, {
    Size size = phone,
  }) => pumpScreen(
    tester,
    screen,
    size: size,
    overrides: [
      ...fakeOverrides(server, secrets: secrets),
      shareIntakeProvider.overrideWithValue(ShareIntake(channel)),
    ],
  );

  Future<void> press(WidgetTester tester, String key) async {
    await tester.ensureVisible(find.byKey(Key(key)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  for (final MapEntry(key: width, value: size) in widths.entries) {
    testWidgets('$width: an invite link is previewed and accepted', (
      tester,
    ) async {
      final c = await pump(
        tester,
        const ConnectScreen(invite: link),
        size: size,
      );
      expect(find.byKey(const Key('connect.url')), findsNothing);
      expect(find.text('Join Default'), findsOneWidget);
      expect(find.text('as lee@example.com'), findsOneWidget);
      expect(
        tester
            .widget<TextField>(
              find.byKey(const Key('connect.inviteDisplayName')),
            )
            .controller!
            .text,
        'Lee',
      );
      await tester.enterText(
        find.byKey(const Key('connect.invitePassword')),
        'short',
      );
      await press(tester, 'connect.inviteAccept');
      expect(find.byKey(const Key('connect.error')), findsOneWidget);
      expect(find.textContaining('password too short'), findsOneWidget);
      await tester.enterText(
        find.byKey(const Key('connect.invitePassword')),
        'correct horse battery',
      );
      await press(tester, 'connect.inviteAccept');
      final session = c.read(sessionControllerProvider).value;
      expect(session?.connection.email, 'lee@example.com');
      expect(session?.instance.baseUrl, 'https://tix.example');
    });
  }

  testWidgets('a pasted link that is not an invite is explained', (
    tester,
  ) async {
    await pump(tester, const ConnectScreen());
    await tester.tap(find.text('Invite'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('connect.inviteLink')),
      'https://tix.example/tasks/infra-1',
    );
    await press(tester, 'connect.invitePreview');
    expect(find.textContaining('not an invite link'), findsOneWidget);
    expect(server.requests, isEmpty);
  });

  testWidgets('an existing account confirms its password and keeps its name', (
    tester,
  ) async {
    parity.invites['tix_inv_abc'] = FakeInvite(
      email: 'ana@example.com',
      existing: true,
      codeRequired: true,
    );
    await pump(tester, const ConnectScreen(invite: link));
    expect(find.byKey(const Key('connect.inviteExisting')), findsOneWidget);
    expect(find.byKey(const Key('connect.inviteDisplayName')), findsNothing);
    expect(find.byKey(const Key('connect.inviteCode')), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('connect.invitePassword')),
      'pw',
    );
    await tester.enterText(
      find.byKey(const Key('connect.inviteCode')),
      FakeTix.goodCode,
    );
    await press(tester, 'connect.inviteAccept');
    expect(server.requestsTo('/auth/invites/tix_inv_abc').last.body, {
      'password': 'pw',
      'code': FakeTix.goodCode,
      'surface': 'cli',
    });
  });

  testWidgets('a shared invite link opens the invite, other text waits', (
    tester,
  ) async {
    pending = {'text': 'Join us: $link', 'subject': ''};
    final c = await pump(tester, const ConnectScreen());
    expect(find.text('Join Default'), findsOneWidget);
    expect(c.read(quickAddDraftsProvider), isNull);
    pending = {'text': 'Buy milk', 'subject': ''};
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(
          channel.name,
          channel.codec.encodeMethodCall(const MethodCall('shared')),
          (_) {},
        );
    await tester.pumpAndSettle();
    expect(c.read(quickAddDraftsProvider)?.text, 'Buy milk');
  });
}
