// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/platform/attachments.dart';
import 'package:tix_mobile/src/features/security/presentation/security_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/attachments.dart';
import '../../../helpers/fake_admin.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;
  late FakeAdmin admin;
  late FakeAttachments attachments;

  setUp(() {
    server = FakeTix();
    admin = FakeAdmin.on(server);
    attachments = FakeAttachments();
  });

  Future<void> pump(
    WidgetTester tester, {
    Size size = phone,
    bool settle = true,
    bool signIn = false,
  }) {
    final stores = signIn ? signInStores(server) : signedInStores();
    return pumpScreen(
      tester,
      const SecurityScreen(),
      size: size,
      settle: settle,
      overrides: [
        ...fakeOverrides(
          server,
          settings: stores.settings,
          secrets: stores.secrets,
        ),
        attachmentsProvider.overrideWithValue(attachments),
      ],
    );
  }

  Future<void> reveal(WidgetTester tester, Finder target) =>
      tester.scrollUntilVisible(
        target,
        200,
        scrollable: find.byType(Scrollable).first,
      );

  Finder inSection(String title, Finder matching) => find.descendant(
    of: find.widgetWithText(TixSection, title),
    matching: matching,
  );

  for (final MapEntry(key: width, value: size) in widths.entries) {
    group(width, () {
      testWidgets('loading, then both sections', (tester) async {
        server.gate = Completer<void>();
        await pump(tester, size: size, settle: false);
        expect(find.byType(SkeletonList), findsNWidgets(3));
        server.gate!.complete();
        await tester.pumpAndSettle();
        expect(find.byType(SkeletonList), findsNothing);
        expect(
          inSection('Second factor', find.byKey(const Key('totp.state'))),
          findsOneWidget,
        );
        expect(inSection('SSH keys', find.text('laptop')), findsOneWidget);
      });

      testWidgets('a password sign-in lists its sessions, this one marked', (
        tester,
      ) async {
        await pump(tester, size: size, signIn: true);
        await reveal(tester, find.byKey(const Key('session.sess-laptop')));
        expect(
          inSection('Active sessions', find.text('tix-cli/1.4 (linux)')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('session.sess-here.current')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('session.sess-laptop.current')),
          findsNothing,
        );
      });

      testWidgets('a token without account:read is told why', (tester) async {
        await pump(tester, size: size);
        final notReadable = find.byKey(const Key('sessions.notReadable'));
        await reveal(tester, notReadable);
        expect(notReadable, findsOneWidget);
        expect(
          server.requests.where((r) => r.uri.path.endsWith('/sessions')),
          isEmpty,
        );
      });

      testWidgets('no keys says so', (tester) async {
        admin.sshKeys.clear();
        await pump(tester, size: size);
        expect(find.byKey(const Key('sshKeys.empty')), findsOneWidget);
      });

      testWidgets('a failure explains itself in each section', (tester) async {
        server.override = FakeResponse(500, envelope('internal', 'x'));
        await pump(tester, size: size);
        expect(find.byType(ErrorState), findsNWidgets(3));
        expect(find.byKey(const Key('totp.setup')), findsNothing);
      });
    });
  }

  testWidgets('setting up shows the secret, confirms the code and shows '
      'the recovery codes once', (tester) async {
    admin.requiredWeb = true;
    await pump(tester);
    expect(find.byKey(const Key('totp.required')), findsOneWidget);
    await tester.tap(find.byKey(const Key('totp.setup')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const Key('totp.secret')),
        matching: find.text(FakeAdmin.secret),
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('totp.openApp')));
    expect(attachments.links.single.scheme, 'otpauth');
    await tester.enterText(find.byKey(const Key('totp.code')), '000000');
    await tester.tap(find.byKey(const Key('form.submit')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const Key('form.error')),
        matching: find.text(
          'That code is not right. Check the time on this device and try '
          'the next one.',
        ),
        matchRoot: true,
      ),
      findsOneWidget,
    );
    await tester.enterText(
      find.byKey(const Key('totp.code')),
      FakeAdmin.goodCode,
    );
    await tester.tap(find.byKey(const Key('form.submit')));
    await tester.pumpAndSettle();
    final codes = find.byKey(const Key('totp.codes'));
    expect(
      find.descendant(
        of: codes,
        matching: find.text(FakeAdmin.codes.join('\n')),
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('totp.codesDone')));
    await tester.pumpAndSettle();
    expect(codes, findsNothing);
    expect(find.text(FakeAdmin.codes.first, findRichText: true), findsNothing);
    expect(admin.totp, 'on');
    expect(find.text('3 recovery codes left'), findsOneWidget);
  });

  testWidgets('removing the second factor asks first', (tester) async {
    admin
      ..totp = 'on'
      ..codesLeft = 1;
    await pump(tester);
    expect(find.text('1 recovery code left'), findsOneWidget);
    await tester.tap(find.byKey(const Key('totp.remove')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(admin.totp, 'on');
    await tester.tap(find.byKey(const Key('totp.remove')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm.ok')));
    await tester.pumpAndSettle();
    expect(admin.totp, 'off');
    expect(find.byKey(const Key('totp.setup')), findsOneWidget);
  });

  testWidgets('new recovery codes replace the old ones after a confirm', (
    tester,
  ) async {
    admin
      ..totp = 'on'
      ..codesLeft = 1;
    await pump(tester);
    await tester.tap(find.byKey(const Key('totp.newCodes')));
    await tester.pumpAndSettle();
    expect(
      server.requests.where((r) => r.uri.path.endsWith('recovery-codes')),
      isEmpty,
    );
    await tester.tap(find.byKey(const Key('confirm.ok')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('totp.codes')), findsOneWidget);
  });

  testWidgets('adding an SSH key sends it and lists it', (tester) async {
    await pump(tester, size: desktop);
    await tester.tap(find.byKey(const Key('security.addKey')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('sshKey.publicKey')), 'nope');
    await tester.tap(find.byKey(const Key('form.submit')));
    await tester.pumpAndSettle();
    expect(find.textContaining('not an authorized_keys line'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('sshKey.publicKey')),
      'ssh-ed25519 AAAA desk',
    );
    await tester.enterText(find.byKey(const Key('sshKey.label')), 'desk');
    await tester.tap(find.byKey(const Key('sshKey.allTenants')));
    await tester.tap(find.byKey(const Key('form.submit')));
    await tester.pumpAndSettle();
    expect(
      server.requests
          .lastWhere(
            (r) => r.method == 'POST' && r.uri.path.endsWith('ssh-keys'),
          )
          .body['all_tenants'],
      isTrue,
    );
    expect(find.text('desk'), findsOneWidget);
  });

  testWidgets('revoking a key asks first and marks it revoked', (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(const Key('sshKey.revoke.k1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm.ok')));
    await tester.pumpAndSettle();
    expect(admin.sshKeys.single['revoked_at'], isNotNull);
    expect(find.byKey(const Key('sshKey.revoke.k1')), findsNothing);
    expect(
      find.descendant(
        of: find.byKey(const Key('sshKey.k1')),
        matching: find.text('Revoked'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('a 403 on the sessions shows the explanation, not an error', (
    tester,
  ) async {
    server
      ..identity = {
        'scopes': ['*', 'account:read'],
      }
      ..failures['GET /api/v1/account/sessions'] = FakeResponse(
        403,
        envelope('forbidden', 'needs account:read'),
      );
    await pump(tester);
    expect(
      server.requests.where((r) => r.uri.path.endsWith('/account/sessions')),
      isNotEmpty,
    );
    final notReadable = find.byKey(const Key('sessions.notReadable'));
    await reveal(tester, notReadable);
    expect(notReadable, findsOneWidget);
    expect(inSection('Active sessions', find.byType(ErrorState)), findsNothing);
  });

  testWidgets('revoking a session asks first and drops it', (tester) async {
    await pump(tester, size: desktop, signIn: true);
    final revoke = find.byKey(const Key('session.revoke.sess-laptop'));
    await reveal(tester, revoke);
    await tester.tap(revoke);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(admin.accountSessions, hasLength(2));
    await tester.tap(revoke);
    await tester.pumpAndSettle();
    expect(
      find.textContaining('tix-cli/1.4 (linux) is signed out'),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('confirm.ok')));
    await tester.pumpAndSettle();
    expect(admin.accountSessions.map((s) => s['id']), ['sess-here']);
    expect(find.byKey(const Key('session.sess-laptop')), findsNothing);
    expect(find.text('Session revoked.'), findsOneWidget);
  });

  testWidgets('revoking this session warns that it signs out', (tester) async {
    await pump(tester, size: desktop, signIn: true);
    final revoke = find.byKey(const Key('session.revoke.sess-here'));
    await reveal(tester, revoke);
    await tester.tap(revoke);
    await tester.pumpAndSettle();
    expect(find.textContaining('signs you out here'), findsOneWidget);
    await tester.tap(find.byKey(const Key('confirm.ok')));
    await tester.pumpAndSettle();
    expect(admin.accountSessions.map((s) => s['id']), ['sess-laptop']);
    expect(
      server.requests.where((r) => r.uri.path.endsWith('/auth/logout')),
      isNotEmpty,
    );
  });
}
