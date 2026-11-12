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

      testWidgets('rotating asks how long the old token lasts', (tester) async {
        final rig = PeopleRig();
        await rig.pump(tester, const TokensScreen(), size: size);
        await tapIn(tester, find.byKey(const Key('token.t2.rotate')));
        expect(find.text('Rotate raj-laptop?'), findsOneWidget);
        expect(find.textContaining("This token is Raj's"), findsOneWidget);
        final now = tester.widget<ChoiceChip>(
          find.byKey(const Key('tokens.grace.0s')),
        );
        expect(now.selected, isTrue);
        await tapIn(tester, find.byKey(const Key('tokens.grace.1h')));
        await tapIn(tester, find.byKey(const Key('tokens.rotate.submit')));
        expect(rig.sent('POST', '/api/v1/tokens/t2/rotate').single, {
          'grace': '1h',
        });
        final value = rig.people.issued.single;
        expect(find.text('Token raj-laptop rotated'), findsOneWidget);
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
        final old = find.byKey(const Key('token.t2'));
        expect(
          find.descendant(of: old, matching: find.text('retiring')),
          findsOneWidget,
        );
        expect(
          find.descendant(of: old, matching: find.textContaining('Stops ')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('token.t2.rotate')), findsNothing);
        expect(find.byKey(const Key('token.t2.revoke')), findsOneWidget);
      });

      testWidgets('a token inside its grace window reads retiring', (
        tester,
      ) async {
        final rig = PeopleRig();
        rig.people.tokens.first['revoked_at'] = '2026-11-01T13:00:00Z';
        await rig.pump(tester, const TokensScreen(), size: size);
        final row = find.byKey(const Key('token.t1'));
        expect(
          find.descendant(of: row, matching: find.text('retiring')),
          findsOneWidget,
        );
        expect(
          find.descendant(of: row, matching: find.text('active')),
          findsNothing,
        );
        expect(
          find.descendant(of: row, matching: find.textContaining('Stops ')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('token.t1.rotate')), findsNothing);
        expect(find.byKey(const Key('token.t1.revoke')), findsOneWidget);
        expect(find.byKey(const Key('token.t2.rotate')), findsOneWidget);
      });
    });
  }

  testWidgets('a refused rotation says why and shows no value', (tester) async {
    final rig = PeopleRig();
    rig.server.failures['POST /api/v1/tokens/t2/rotate'] = FakeResponse(
      403,
      envelope('forbidden', 'no'),
    );
    await rig.pump(tester, const TokensScreen());
    await tapIn(tester, find.byKey(const Key('token.t2.rotate')));
    await tapIn(tester, find.byKey(const Key('tokens.rotate.submit')));
    expect(rig.server.requestsTo('/api/v1/tokens/t2/rotate'), hasLength(1));
    expect(
      tester.widget<Text>(find.byKey(const Key('tokens.rotate.error'))).data,
      contains('not allowed'),
    );
    expect(find.text('Rotate raj-laptop?'), findsOneWidget);
    expect(find.byKey(const Key('secret.values')), findsNothing);
  });

  testWidgets('rotating now ends the old token at once', (tester) async {
    final rig = PeopleRig();
    await rig.pump(tester, const TokensScreen(personal: true));
    await tapIn(tester, find.byKey(const Key('token.t1.rotate')));
    await tapIn(tester, find.byKey(const Key('tokens.rotate.submit')));
    expect(rig.sent('POST', '/api/v1/tokens/t1/rotate').single, {
      'grace': '0s',
    });
    await tester.tap(find.byKey(const Key('secret.done')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const Key('token.t1')),
        matching: find.text('revoked'),
      ),
      findsOneWidget,
    );
  });

  testWidgets("the app's own token is swapped, not shown", (tester) async {
    final rig = PeopleRig();
    rig.people.me = {
      'id': 'me',
      'handle': 'ana',
      'kind': 'agent',
      'token_id': 't1',
      'scopes': ['*'],
    };
    await rig.pump(tester, const TokensScreen(personal: true), size: desktop);
    await tapIn(tester, find.byKey(const Key('token.t1.rotate')));
    expect(
      find.textContaining('the token this app connects with'),
      findsOneWidget,
    );
    await tapIn(tester, find.byKey(const Key('tokens.grace.10m')));
    await tapIn(tester, find.byKey(const Key('tokens.rotate.submit')));
    expect(rig.sent('POST', '/api/v1/tokens/t1/rotate').single, {
      'grace': '10m',
    });
    expect(
      find.text('ci rotated. This app now connects with the new token.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('secret.values')), findsNothing);
  });

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
