// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/features/account/presentation/account_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_tix.dart';
import '../../../helpers/people_app.dart';

void main() {
  for (final MapEntry(key: width, value: size) in widths.entries) {
    group(width, () {
      testWidgets('loading, then profile, tenants and history', (tester) async {
        final rig = PeopleRig();
        rig.people.me = {
          ...rig.people.me,
          'scopes': ['account:read'],
          'token_id': 'tk',
        };
        rig.server.gate = Completer<void>();
        await rig.pump(
          tester,
          const AccountScreen(),
          size: size,
          settle: false,
        );
        expect(find.byType(SkeletonList), findsOneWidget);
        rig.server.gate!.complete();
        await tester.pumpAndSettle();
        expect(find.text('Ana'), findsOneWidget);
        expect(find.byKey(const Key('membership.acme')), findsOneWidget);
        expect(
          find.descendant(
            of: find.byKey(const Key('membership.default')),
            matching: find.text('current'),
          ),
          findsOneWidget,
        );
        await tester.scrollUntilVisible(
          find.byKey(const Key('log.1')),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('user.password_changed'), findsOneWidget);
      });

      testWidgets('empty history', (tester) async {
        final rig = PeopleRig();
        rig.people.me = {
          ...rig.people.me,
          'scopes': ['account:read'],
          'token_id': 'tk',
        };
        rig.people.log.clear();
        await rig.pump(
          tester,
          const AccountScreen(),
          size: const Size(1280, 2000),
        );
        expect(find.text('Nothing has changed yet.'), findsOneWidget);
      });

      testWidgets('error', (tester) async {
        final rig = PeopleRig();
        rig.server.override = FakeResponse(500, envelope('internal', 'x'));
        await rig.pump(tester, const AccountScreen(), size: size);
        expect(
          find.textContaining('The server had a problem.'),
          findsOneWidget,
        );
      });
    });
  }

  testWidgets('a token without account:read asks nothing about history', (
    tester,
  ) async {
    final rig = PeopleRig();
    rig.people.me = {
      ...rig.people.me,
      'token_id': 'tk',
      'scopes': ['*'],
    };
    await rig.pump(tester, const AccountScreen(), size: const Size(400, 2000));
    expect(find.byKey(const Key('account.noHistory')), findsOneWidget);
    expect(rig.server.requestsTo('/api/v1/account/log'), isEmpty);
  });
}
