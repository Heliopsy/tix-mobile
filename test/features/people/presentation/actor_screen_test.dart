// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/features/people/presentation/actor_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;

  setUp(() {
    server = FakeTix();
    server.routes.add((o, path, _) {
      if (o.method != 'GET') return null;
      switch (path) {
        case '/api/v1/actors/raj' || '/api/v1/actors/a1':
          return FakeResponse(200, server.actors['a1']);
        case '/api/v1/actors/me':
          return FakeResponse(200, server.actors['me']);
        case '/api/v1/tokens':
          return const FakeResponse(200, {
            'items': [
              {
                'id': 't1',
                'actor_id': 'a1',
                'name': 'ci',
                'scopes': ['task:read'],
              },
            ],
          });
        case '/api/v1/ssh-keys':
          return const FakeResponse(200, {
            'items': [
              {'id': 'k1', 'label': 'laptop', 'fingerprint': 'SHA256:abc'},
            ],
          });
        case '/api/v1/audit':
          return const FakeResponse(200, {
            'items': [
              {
                'seq': 7,
                'action': 'task.update',
                'actor_id': 'a1',
                'subject_type': 'task',
                'subject_id': 'infra-1',
              },
            ],
          });
      }
      return null;
    });
  });

  Future<void> reveal(WidgetTester tester, Finder target) =>
      tester.scrollUntilVisible(
        target,
        300,
        scrollable: find
            .descendant(
              of: find.byType(ListView).first,
              matching: find.byType(Scrollable),
            )
            .first,
      );

  Future<void> pump(
    WidgetTester tester, {
    String actor = 'raj',
    Size size = phone,
  }) {
    final stores = signedInStores();
    return pumpScreen(
      tester,
      ActorScreen(actorRef: actor),
      size: size,
      overrides: fakeOverrides(
        server,
        settings: stores.settings,
        secrets: stores.secrets,
      ),
    );
  }

  for (final MapEntry(key: width, value: size) in widths.entries) {
    testWidgets('$width: who it is, its tasks, credentials and activity', (
      tester,
    ) async {
      await pump(tester, size: size);
      expect(find.byKey(const Key('actor.handle')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('actor.id')),
          matching: find.text('a1'),
        ),
        findsOneWidget,
      );
      expect(find.byKey(const Key('actor.self')), findsNothing);
      expect(find.byKey(const Key('actor.task.infra-1')), findsOneWidget);
      await reveal(tester, find.byKey(const Key('actor.audit.7')));
      expect(find.byKey(const Key('actor.token.t1')), findsOneWidget);
      expect(find.byKey(const Key('actor.key.k1')), findsOneWidget);
      expect(
        server.requestsTo('/api/v1/audit').last.uri.queryParameters,
        containsPair('limit', '20'),
      );
      expect(server.requestsTo('/api/v1/tokens').single.uri.queryParameters, {
        'actor_id': 'a1',
      });
    });
  }

  testWidgets('without token:admin or audit:read nothing of either is asked', (
    tester,
  ) async {
    server.identity = {
      'scopes': ['task:read'],
    };
    await pump(tester);
    await reveal(tester, find.byKey(const Key('actor.recent.denied')));
    expect(find.byKey(const Key('actor.tokens')), findsNothing);
    expect(find.byKey(const Key('actor.keys')), findsNothing);
    expect(server.requestsTo('/api/v1/tokens'), isEmpty);
    expect(server.requestsTo('/api/v1/ssh-keys'), isEmpty);
    expect(server.requestsTo('/api/v1/audit'), isEmpty);
  });

  testWidgets('the reader is told it is them', (tester) async {
    await pump(tester, actor: 'me');
    expect(find.byKey(const Key('actor.self')), findsOneWidget);
    await tester.tap(find.byKey(const Key('actor.profile')));
    await tester.pumpAndSettle();
    expect(find.text('route:/settings/account'), findsOneWidget);
  });

  testWidgets('an unknown actor shows the error with Retry', (tester) async {
    server.failures['GET /api/v1/actors/raj'] = FakeResponse(
      404,
      envelope('not_found', 'actor "raj"'),
    );
    await pump(tester);
    expect(find.byType(ErrorState), findsOneWidget);
  });
}
