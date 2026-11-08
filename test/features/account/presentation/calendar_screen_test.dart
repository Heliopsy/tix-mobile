// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/features/account/presentation/calendar_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_tix.dart';
import '../../../helpers/people_app.dart';

void main() {
  for (final MapEntry(key: width, value: size) in widths.entries) {
    group(width, () {
      testWidgets('no feed offers Create', (tester) async {
        final rig = PeopleRig();
        await rig.pump(tester, const CalendarScreen(), size: size);
        expect(find.byKey(const Key('calendar.none')), findsOneWidget);
        expect(find.byType(EmptyState), findsOneWidget);
      });

      testWidgets('an active feed', (tester) async {
        final rig = PeopleRig()
          ..people.feed = {
            'id': 'c1',
            'filter': 'tag:ops',
            'created_at': '2026-10-01T00:00:00Z',
          };
        await rig.pump(tester, const CalendarScreen(), size: size);
        expect(find.byKey(const Key('calendar.active')), findsOneWidget);
        expect(find.text('tag:ops'), findsOneWidget);
      });

      testWidgets('error', (tester) async {
        final rig = PeopleRig();
        rig.server.failures['GET /api/v1/calendar'] = FakeResponse(
          500,
          envelope('internal', 'x'),
        );
        await rig.pump(tester, const CalendarScreen(), size: size);
        expect(
          find.textContaining('The server had a problem.'),
          findsOneWidget,
        );
      });
    });
  }

  testWidgets('create shows the address once with how to subscribe', (
    tester,
  ) async {
    final rig = PeopleRig();
    await rig.pump(tester, const CalendarScreen(), size: desktop);
    await tester.tap(find.byKey(const Key('calendar.create')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('calendar.filterField')),
      'tag:ops',
    );
    await tapIn(tester, find.byKey(const Key('calendar.save')));
    expect(rig.sent('POST', '/api/v1/calendar').single, {'filter': 'tag:ops'});
    final secret = rig.people.issued.single;
    final address = 'https://tix.example/api/v1/calendar/feeds/$secret.ics';
    expect(find.text(address), findsOneWidget);
    expect(find.textContaining('Google Calendar'), findsOneWidget);
    await tapIn(tester, find.byKey(const Key('calendar.subscribe')));
    expect(
      rig.files.links.single.toString(),
      'webcal://tix.example/api/v1/calendar/feeds/$secret.ics',
    );
    await tapIn(tester, find.byKey(const Key('secret.share')));
    expect(rig.sharing.shared.single, address);
    await tapIn(tester, find.byKey(const Key('secret.done')));
    expect(find.text(address), findsNothing);
    expect(find.byKey(const Key('calendar.active')), findsOneWidget);
  });

  testWidgets('filter, rotate and revoke', (tester) async {
    final rig = PeopleRig()..people.feed = {'id': 'c1', 'filter': ''};
    await rig.pump(tester, const CalendarScreen(), size: desktop);
    await tapIn(tester, find.byKey(const Key('calendar.editFilter')));
    await tester.enterText(
      find.byKey(const Key('calendar.filterField')),
      'bogus:',
    );
    await tapIn(tester, find.byKey(const Key('calendar.save')));
    expect(find.textContaining('cannot read filter'), findsOneWidget);
    await tapIn(tester, find.byKey(const Key('calendar.rotate')));
    expect(find.textContaining('replaces the old one'), findsOneWidget);
    await tapIn(tester, find.byKey(const Key('secret.done')));
    await tapIn(tester, find.byKey(const Key('calendar.revoke')));
    expect(rig.people.feed, isNotNull);
    await tapIn(tester, find.byKey(const Key('confirm.ok')));
    expect(rig.people.feed, isNull);
    expect(find.byKey(const Key('calendar.none')), findsOneWidget);
  });

  testWidgets('a credential that cannot read tasks is told so', (tester) async {
    final rig = PeopleRig();
    rig.people.me = {
      'id': 'me',
      'kind': 'agent',
      'token_id': 'tk',
      'scopes': ['token:admin'],
    };
    await rig.pump(tester, const CalendarScreen());
    expect(find.byKey(const Key('calendar.unavailable')), findsOneWidget);
  });
}
