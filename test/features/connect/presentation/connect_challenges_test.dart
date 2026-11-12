// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/features/connect/presentation/connect_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/attachments.dart';
import '../../../helpers/fake_tix.dart';
import '../../../helpers/stores.dart';

void main() {
  late FakeTix server;
  late MemorySecretStore secrets;
  late FakeAttachments attachments;
  const email = 'ana@example.com';
  const replacement = 'a much longer one';

  setUp(() {
    server = FakeTix();
    secrets = MemorySecretStore();
    attachments = FakeAttachments();
  });

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> enter(WidgetTester tester, String key, String text) async {
    final field = find.byKey(Key(key));
    await tester.ensureVisible(field);
    await tester.enterText(field, text);
  }

  Future<void> signIn(WidgetTester tester, Size size) async {
    await pumpScreen(
      tester,
      const ConnectScreen(adding: true),
      size: size,
      overrides: [
        ...fakeOverrides(server, secrets: secrets),
        attachments.asOverride,
      ],
    );
    await tester.tap(find.text('Sign in').first);
    await tester.pump();
    await enter(tester, 'connect.url', 'tix.example');
    await enter(tester, 'connect.email', email);
    await enter(tester, 'connect.password', 'pw');
    await tap(tester, find.byKey(const Key('connect.submit')));
  }

  Future<void> changePassword(
    WidgetTester tester, {
    String confirm = replacement,
  }) async {
    await enter(tester, 'connect.newPassword', replacement);
    await enter(tester, 'connect.confirmPassword', confirm);
    await tap(tester, find.byKey(const Key('connect.changePassword')));
  }

  String? error(WidgetTester tester) {
    final found = find.byKey(const Key('connect.error'));
    return found.evaluate().isEmpty ? null : tester.widget<Text>(found).data;
  }

  Future<void> openHelp(WidgetTester tester, String key) async {
    await tap(tester, find.byKey(Key(key)));
    expect(find.byKey(const Key('help.body')), findsOneWidget);
    await tap(tester, find.byKey(const Key('help.close')));
  }

  for (final MapEntry(key: width, value: size) in widths.entries) {
    group(width, () {
      testWidgets('a required password change is made here and signs in', (
        tester,
      ) async {
        server.mustChangePassword.add(email);
        await signIn(tester, size);
        expect(find.text('Choose a new password'), findsOneWidget);
        expect(
          tester.widget<Text>(find.byKey(const Key('connect.changeAs'))).data,
          'Signing in as $email',
        );
        expect(error(tester), isNull);
        await openHelp(tester, 'connect.help.newPassword');

        await changePassword(tester, confirm: 'something else entirely');
        expect(error(tester), 'The two passwords do not match.');
        expect(server.requestsTo('/auth/login'), hasLength(1));

        await changePassword(tester);
        expect(find.text('route:/projects'), findsOneWidget);
        expect(server.requestsTo('/auth/login').last.body, {
          'email': email,
          'password': 'pw',
          'new_password': replacement,
          'surface': 'cli',
        });
        expect(secrets.values.values, isNot(contains(replacement)));
      });

      testWidgets('a second factor is set up here, and the recovery codes '
          'are shown before going on', (tester) async {
        server.mustEnrol.add(email);
        await signIn(tester, size);
        final secret = find.byKey(const Key('connect.enrolSecret'));
        expect(
          find.descendant(of: secret, matching: find.text(FakeTix.enrolSecret)),
          findsOneWidget,
        );
        await openHelp(tester, 'connect.help.secondFactor');

        await tap(tester, find.byKey(const Key('connect.enrolOpenApp')));
        expect(attachments.links.single.scheme, 'otpauth');

        await enter(tester, 'connect.enrolCode', '000000');
        await tap(tester, find.byKey(const Key('connect.enrolConfirm')));
        expect(error(tester), startsWith('That code is not right.'));

        await enter(tester, 'connect.enrolCode', FakeTix.goodCode);
        await tap(tester, find.byKey(const Key('connect.enrolConfirm')));
        final codes = find.byKey(const Key('connect.recoveryCodes'));
        expect(
          find.descendant(
            of: codes,
            matching: find.text(FakeTix.recoveryCodes.join('\n')),
          ),
          findsOneWidget,
        );
        expect(find.byType(BackButton), findsNothing);
        expect(secrets.values, isEmpty);
        await openHelp(tester, 'connect.help.recoveryCodes');

        await tap(tester, find.byKey(const Key('connect.codesSaved')));
        expect(find.text('route:/projects'), findsOneWidget);
        expect(secrets.values.keys.single, startsWith('session.'));
      });
    });
  }

  testWidgets('a password change then enrolment, and the old password is '
      'gone from the form', (tester) async {
    server
      ..mustChangePassword.add(email)
      ..mustEnrol.add(email);
    await signIn(tester, phone);
    await changePassword(tester);
    expect(find.byKey(const Key('connect.enrolSecret')), findsOneWidget);
    await tap(tester, find.byType(BackButton));
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('connect.password')))
          .controller
          ?.text,
      isEmpty,
    );
  });

  testWidgets('the server refusing the new password says why', (tester) async {
    server.mustChangePassword.add(email);
    await signIn(tester, phone);
    await enter(tester, 'connect.newPassword', 'short');
    await enter(tester, 'connect.confirmPassword', 'short');
    await tap(tester, find.byKey(const Key('connect.changePassword')));
    expect(error(tester), contains('at least 12 characters'));
    expect(find.byKey(const Key('connect.newPassword')), findsOneWidget);
  });

  testWidgets('copying the recovery codes puts them on the clipboard', (
    tester,
  ) async {
    final copied = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied.add((call.arguments as Map)['text'] as String);
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    server.mustEnrol.add(email);
    await signIn(tester, phone);
    await enter(tester, 'connect.enrolCode', FakeTix.goodCode);
    await tap(tester, find.byKey(const Key('connect.enrolConfirm')));
    await tap(
      tester,
      find.descendant(
        of: find.byKey(const Key('connect.recoveryCodes')),
        matching: find.byKey(const Key('secret.copy')),
      ),
    );
    expect(copied.single, FakeTix.recoveryCodes.join('\n'));
  });
}
