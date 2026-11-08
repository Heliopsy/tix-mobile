// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/features/tokens/presentation/tokens_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_tix.dart';
import '../../../helpers/people_app.dart';

void main() {
  for (final MapEntry(key: width, value: size) in widths.entries) {
    group(width, () {
      testWidgets('loading, then every token with its owner', (tester) async {
        final rig = PeopleRig();
        rig.server.gate = Completer<void>();
        await rig.pump(tester, const TokensScreen(), size: size, settle: false);
        expect(find.byType(SkeletonList), findsOneWidget);
        rig.server.gate!.complete();
        await tester.pumpAndSettle();
        expect(find.text('ci'), findsOneWidget);
        expect(find.text('raj-laptop'), findsOneWidget);
        expect(find.text('Owner: Raj'), findsOneWidget);
        expect(find.text('Owner: ana (you)'), findsOneWidget);
        expect(find.textContaining('Never expires'), findsOneWidget);
        expect(find.textContaining('Not used yet'), findsOneWidget);
        expect(
          rig.server.requestsTo('/api/v1/tokens').single.uri.queryParameters,
          isEmpty,
        );
      });

      testWidgets('empty', (tester) async {
        final rig = PeopleRig()..people.tokens.clear();
        await rig.pump(tester, const TokensScreen(), size: size);
        expect(find.text('No tokens.'), findsOneWidget);
      });

      testWidgets('error', (tester) async {
        final rig = PeopleRig();
        rig.server.failures['GET /api/v1/tokens'] = FakeResponse(
          500,
          envelope('internal', 'x'),
        );
        await rig.pump(tester, const TokensScreen(), size: size);
        expect(
          find.textContaining('The server had a problem.'),
          findsOneWidget,
        );
      });
    });
  }

  testWidgets('personal tokens ask for mine only', (tester) async {
    final rig = PeopleRig();
    await rig.pump(tester, const TokensScreen(personal: true));
    expect(rig.server.requestsTo('/api/v1/tokens').single.uri.queryParameters, {
      'actor_id': 'me',
    });
    expect(find.text('raj-laptop'), findsNothing);
    expect(find.textContaining('Owner:'), findsNothing);
  });

  testWidgets('a token is issued and its value shown once', (tester) async {
    final rig = PeopleRig();
    await rig.pump(tester, const TokensScreen(personal: true), size: desktop);
    await tester.tap(find.byKey(const Key('tokens.issue')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('tokens.name')), 'deploy');
    await tapIn(tester, find.byKey(const Key('tokens.preset.read')));
    await tapIn(tester, find.byKey(const Key('tokens.expiry.30d')));
    await tapIn(tester, find.byKey(const Key('tokens.submit')));
    final body = rig.sent('POST', '/api/v1/tokens').single;
    expect(body['name'], 'deploy');
    expect(body['actor_id'], 'me');
    expect(body['scopes'], [
      'task:read',
      'project:read',
      'workflow:read',
      'event:subscribe',
    ]);
    expect(body['expires_at'], '2026-12-01T12:00:00.000Z');
    final value = rig.people.issued.single;
    expect(
      find.descendant(
        of: find.byKey(const Key('secret.values')),
        matching: find.text(value),
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('secret.done')));
    await tester.pumpAndSettle();
    expect(find.text(value), findsNothing);
    expect(find.text('deploy'), findsOneWidget);
  });

  testWidgets('a scope the caller lacks cannot be ticked', (tester) async {
    final rig = PeopleRig();
    rig.people.me = {
      'id': 'me',
      'handle': 'ana',
      'kind': 'agent',
      'token_id': 'tk',
      'scopes': ['token:admin', 'task:read'],
    };
    await rig.pump(tester, const TokensScreen());
    await tester.tap(find.byKey(const Key('tokens.issue')));
    await tester.pumpAndSettle();
    final write = tester.widget<CheckboxListTile>(
      find.byKey(const Key('tokens.scope.task:write')),
    );
    expect(write.onChanged, isNull);
    expect(find.byKey(const Key('tokens.scope.*')), findsNothing);
    expect(find.byKey(const Key('tokens.preset.agent')), findsNothing);
  });

  testWidgets("revoking somebody else's token says so first", (tester) async {
    final rig = PeopleRig();
    await rig.pump(tester, const TokensScreen());
    await tapIn(tester, find.byKey(const Key('token.t2.revoke')));
    expect(find.textContaining("This token is Raj's"), findsOneWidget);
    expect(rig.server.requestsTo('/api/v1/tokens/t2'), isEmpty);
    await tapIn(tester, find.byKey(const Key('confirm.ok')));
    expect(rig.server.requestsTo('/api/v1/tokens/t2').single.method, 'DELETE');
    expect(
      find.descendant(
        of: find.byKey(const Key('token.t2')),
        matching: find.text('revoked'),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('token.t2.revoke')), findsNothing);
  });
}
