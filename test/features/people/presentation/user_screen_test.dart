// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/features/people/presentation/user_screen.dart';

import '../../../helpers/fake_tix.dart';
import '../../../helpers/people_app.dart';

void main() {
  const tall = {'compact': Size(400, 2000), 'expanded': Size(1280, 2000)};
  for (final MapEntry(key: width, value: size) in tall.entries) {
    testWidgets('shows the account, $width', (tester) async {
      final rig = PeopleRig();
      await rig.pump(tester, const UserScreen(userId: 'a1'), size: size);
      expect(find.text('raj@example.com'), findsWidgets);
      expect(find.text('member'), findsOneWidget);
      expect(find.byKey(const Key('user.delete')), findsOneWidget);
      expect(find.byKey(const Key('user.disabled')), findsOneWidget);
    });
  }

  testWidgets('an account gone from the list says so', (tester) async {
    final rig = PeopleRig();
    await rig.pump(tester, const UserScreen(userId: 'nobody'));
    expect(find.textContaining('Not found.'), findsOneWidget);
  });

  testWidgets('my own account offers neither delete nor disable', (
    tester,
  ) async {
    final rig = PeopleRig();
    await rig.pump(
      tester,
      const UserScreen(userId: 'me'),
      size: const Size(400, 2000),
    );
    expect(find.byKey(const Key('user.delete')), findsNothing);
    expect(find.byKey(const Key('user.disabled')), findsNothing);
    expect(find.byKey(const Key('user.requireChange')), findsOneWidget);
  });

  testWidgets('the role changes, sending only the role', (tester) async {
    final rig = PeopleRig();
    await rig.pump(
      tester,
      const UserScreen(userId: 'a1'),
      size: const Size(400, 2000),
    );
    await tapIn(tester, find.byKey(const Key('user.role')));
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('people.role')),
        matching: find.text('viewer'),
      ),
    );
    await tester.pumpAndSettle();
    await tapIn(tester, find.byKey(const Key('role.save')));
    expect(rig.sent('PATCH', '/api/v1/users/a1').single, {'role': 'viewer'});
    expect(find.text('Raj is now viewer'), findsOneWidget);
  });

  testWidgets('rename, disable and ask for a password change', (tester) async {
    final rig = PeopleRig();
    await rig.pump(
      tester,
      const UserScreen(userId: 'a1'),
      size: const Size(400, 2000),
    );
    await tapIn(tester, find.byKey(const Key('user.name')));
    await tester.enterText(find.byKey(const Key('rename.field')), 'Raj K');
    await tapIn(tester, find.byKey(const Key('rename.save')));
    await tapIn(
      tester,
      find.descendant(
        of: find.byKey(const Key('user.disabled')),
        matching: find.byType(Switch),
      ),
    );
    await tapIn(
      tester,
      find.descendant(
        of: find.byKey(const Key('user.requireChange')),
        matching: find.byType(Switch),
      ),
    );
    expect(rig.sent('PATCH', '/api/v1/users/a1'), [
      {'display_name': 'Raj K'},
      {'disabled': true},
      {'require_password_change': true},
    ]);
    expect(
      tester
          .widget<Switch>(
            find.descendant(
              of: find.byKey(const Key('user.disabled')),
              matching: find.byType(Switch),
            ),
          )
          .value,
      isTrue,
    );
  });

  testWidgets('a refused change says why and changes nothing', (tester) async {
    final rig = PeopleRig();
    rig.server.failures['PATCH /api/v1/users/a1'] = FakeResponse(
      403,
      envelope('forbidden', 'no'),
    );
    await rig.pump(
      tester,
      const UserScreen(userId: 'a1'),
      size: const Size(400, 2000),
    );
    await tapIn(
      tester,
      find.descendant(
        of: find.byKey(const Key('user.disabled')),
        matching: find.byType(Switch),
      ),
    );
    expect(find.text('This token is not allowed to do that.'), findsOneWidget);
    expect(rig.people.users[1]['disabled_at'], isNull);
  });

  testWidgets('delete and remove membership confirm first', (tester) async {
    final rig = PeopleRig();
    await rig.pump(
      tester,
      const UserScreen(userId: 'a1'),
      size: const Size(400, 2000),
    );
    await tapIn(tester, find.byKey(const Key('user.removeMember')));
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(rig.server.requestsTo('/api/v1/members/a1'), isEmpty);
    await tapIn(tester, find.byKey(const Key('user.removeMember')));
    await tapIn(tester, find.byKey(const Key('confirm.ok')));
    expect(rig.server.requestsTo('/api/v1/members/a1').single.method, 'DELETE');
    await tapIn(tester, find.byKey(const Key('user.delete')));
    await tapIn(tester, find.byKey(const Key('confirm.ok')));
    expect(rig.server.requestsTo('/api/v1/users/a1').last.method, 'DELETE');
    expect(rig.people.users.any((u) => u['id'] == 'a1'), isFalse);
  });
}
