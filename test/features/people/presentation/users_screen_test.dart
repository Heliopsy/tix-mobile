// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/features/people/presentation/users_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_tix.dart';
import '../../../helpers/people_app.dart';

void main() {
  Finder inRow(String id, String text) => find.descendant(
    of: find.byKey(Key('person.$id')),
    matching: find.text(text),
  );

  for (final MapEntry(key: width, value: size) in widths.entries) {
    group(width, () {
      testWidgets('loading, then users with roles and state', (tester) async {
        final rig = PeopleRig();
        rig.server.gate = Completer<void>();
        await rig.pump(tester, const UsersScreen(), size: size, settle: false);
        expect(find.byType(SkeletonList), findsOneWidget);
        rig.server.gate!.complete();
        await tester.pumpAndSettle();
        expect(find.text('2 active · 1 disabled'), findsOneWidget);
        expect(inRow('me', 'you'), findsOneWidget);
        expect(inRow('me', 'admin'), findsOneWidget);
        expect(inRow('a1', 'member'), findsOneWidget);
        expect(inRow('u3', 'disabled'), findsOneWidget);
        expect(find.byKey(const Key('invite.inv1')), findsOneWidget);
      });

      testWidgets('empty', (tester) async {
        final rig = PeopleRig();
        rig.people.users.clear();
        rig.people.invites.clear();
        await rig.pump(tester, const UsersScreen(), size: size);
        expect(find.text('No users yet.'), findsOneWidget);
        expect(find.byType(EmptyState), findsOneWidget);
      });

      testWidgets('error', (tester) async {
        final rig = PeopleRig();
        rig.server.failures['GET /api/v1/users'] = FakeResponse(
          500,
          envelope('internal', 'x'),
        );
        await rig.pump(tester, const UsersScreen(), size: size);
        expect(
          find.textContaining('The server had a problem.'),
          findsOneWidget,
        );
      });
    });
  }

  testWidgets('without tenant:admin the roles are left out', (tester) async {
    final rig = PeopleRig()..people.membersForbidden = true;
    await rig.pump(tester, const UsersScreen());
    expect(inRow('a1', 'member'), findsNothing);
    expect(inRow('a1', 'no role'), findsNothing);
    expect(inRow('a1', 'Raj'), findsOneWidget);
  });

  testWidgets('a row opens the account', (tester) async {
    final rig = PeopleRig();
    await rig.pump(tester, const UsersScreen());
    await tester.tap(find.byKey(const Key('person.a1')));
    await tester.pumpAndSettle();
    expect(find.text('route:/manage/users/a1'), findsOneWidget);
  });

  testWidgets('an invite link is created and shown once', (tester) async {
    final rig = PeopleRig();
    await rig.pump(tester, const UsersScreen(), size: desktop);
    await tester.tap(find.byKey(const Key('people.add')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('people.email')),
      'zoe@example.com',
    );
    await tester.tap(find.byKey(const Key('people.expiry.14d')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('people.create')));
    await tester.pumpAndSettle();
    expect(rig.sent('POST', '/api/v1/invites').single, {
      'email': 'zoe@example.com',
      'role': 'member',
      'expires_in': '14d',
    });
    final secret = rig.people.issued.single;
    expect(
      find.descendant(
        of: find.byKey(const Key('secret.values')),
        matching: find.textContaining('https://tix.example/invite/$secret'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('secret.share')));
    await tester.pumpAndSettle();
    expect(rig.sharing.shared.single, 'https://tix.example/invite/$secret');
    await tester.tap(find.byKey(const Key('secret.done')));
    await tester.pumpAndSettle();
    expect(find.textContaining(secret), findsNothing);
    expect(find.byKey(const Key('invite.inv1')), findsOneWidget);
  });

  testWidgets('a password account is created', (tester) async {
    final rig = PeopleRig();
    await rig.pump(tester, const UsersScreen());
    await tester.tap(find.byKey(const Key('people.add')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Set a password'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('people.email')),
      'zoe@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('people.password')),
      'hunter22',
    );
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('people.role')),
        matching: find.text('viewer'),
      ),
    );
    await tester.pumpAndSettle();
    await tapIn(tester, find.byKey(const Key('people.create')));
    expect(rig.sent('POST', '/api/v1/users').single, {
      'email': 'zoe@example.com',
      'password': 'hunter22',
      'role': 'viewer',
      'require_password_change': true,
    });
    expect(find.text('Created zoe@example.com'), findsOneWidget);
  });

  testWidgets('a refused account keeps the form and says why', (tester) async {
    final rig = PeopleRig();
    rig.server.failures['POST /api/v1/invites'] = FakeResponse(
      400,
      envelope('invalid', 'email is taken'),
    );
    await rig.pump(tester, const UsersScreen());
    await tester.tap(find.byKey(const Key('people.add')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('people.email')),
      'ana@example.com',
    );
    await tapIn(tester, find.byKey(const Key('people.create')));
    expect(find.textContaining('email is taken'), findsOneWidget);
    expect(find.byKey(const Key('people.email')), findsOneWidget);
  });

  testWidgets('re-issue shows the new link; revoke asks first', (tester) async {
    final rig = PeopleRig();
    await rig.pump(tester, const UsersScreen());
    await tapIn(tester, find.byKey(const Key('invite.inv1.reissue')));
    expect(find.textContaining(rig.people.issued.single), findsOneWidget);
    await tester.tap(find.byKey(const Key('secret.done')));
    await tester.pumpAndSettle();
    await tapIn(tester, find.byKey(const Key('invite.inv1.revoke')));
    expect(rig.server.requestsTo('/api/v1/invites/inv1'), isEmpty);
    await tester.tap(find.byKey(const Key('confirm.ok')));
    await tester.pumpAndSettle();
    expect(
      rig.server.requestsTo('/api/v1/invites/inv1').single.method,
      'DELETE',
    );
    expect(find.byKey(const Key('invite.inv1')), findsNothing);
  });

  testWidgets('a member is added from the actors without one', (tester) async {
    final rig = PeopleRig();
    rig.server.actors['bot'] = {
      'id': 'bot',
      'handle': 'ci-bot',
      'kind': 'agent',
    };
    await rig.pump(tester, const UsersScreen());
    await tester.tap(find.byKey(const Key('people.addMember')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('member.actor.a1')), findsNothing);
    await tester.tap(find.byKey(const Key('member.actor.bot')));
    await tester.pumpAndSettle();
    await tapIn(tester, find.byKey(const Key('member.add')));
    expect(rig.sent('POST', '/api/v1/members').single, {
      'actor_id': 'bot',
      'role': 'member',
    });
  });

  testWidgets('nothing overflows at twice the text size', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final rig = PeopleRig();
    await rig.pump(tester, const UsersScreen());
    expect(tester.takeException(), isNull);
  });
}
