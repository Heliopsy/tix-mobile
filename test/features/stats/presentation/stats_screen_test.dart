// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/features/stats/presentation/stats_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_tix.dart';

/// What `GET /stats` answers in these tests.
Map<String, Object?> statsJson() => {
  'completed': 4,
  'created': 6,
  'median_lead_time': '36h0m0s',
  'slowest_lead_time': '240h0m0s',
  'leaderboard_measure': 'tasks moved to a terminal state',
  'per_day': [
    {'date': '2026-10-30', 'completed': 1},
    {'date': '2026-10-31', 'completed': 0},
    {'date': '2026-11-01', 'completed': 3},
  ],
  'by_category': [
    {'category': 'todo', 'count': 5},
    {'category': 'in_progress', 'count': 2},
    {'category': 'done', 'count': 9},
  ],
  'top_actors': [
    {'actor_id': 'a1', 'handle': 'raj', 'moved': 3},
    {'actor_id': 'me', 'handle': 'ana', 'moved': 1},
  ],
  'oldest': [
    {
      'ref': 'infra-2',
      'title': 'Rotate keys',
      'status': 'todo',
      'age': '480h0m0s',
    },
  ],
};

Map<String, Object?> emptyStatsJson() => {
  'completed': 0,
  'created': 0,
  'per_day': [
    {'date': '2026-11-01', 'completed': 0},
  ],
  'by_category': <Object>[],
  'top_actors': <Object>[],
  'oldest': <Object>[],
};

void main() {
  late FakeTix server;
  late Map<String, Object?> answer;

  setUp(() {
    server = FakeTix();
    answer = statsJson();
    server.routes.add((o, path, _) {
      if (o.method == 'GET' && path == '/api/v1/stats') {
        return FakeResponse(200, answer);
      }
      return null;
    });
  });

  Future<void> pump(
    WidgetTester tester, {
    Size size = phone,
    bool settle = true,
  }) {
    final stores = signedInStores();
    return pumpScreen(
      tester,
      const StatsScreen(),
      size: size,
      settle: settle,
      overrides: fakeOverrides(
        server,
        settings: stores.settings,
        secrets: stores.secrets,
      ),
    );
  }

  for (final MapEntry(key: width, value: size) in widths.entries) {
    testWidgets('$width: loading, then every part of the report', (
      tester,
    ) async {
      server.gate = Completer<void>();
      await pump(tester, size: size, settle: false);
      await tester.pump();
      expect(find.byType(SkeletonList), findsOneWidget);
      server.gate!.complete();
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byKey(const Key('stats.figure.completed')),
          matching: find.text('4'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('stats.figure.median')),
          matching: find.text('1 d 12 h'),
        ),
        findsOneWidget,
      );
      expect(find.byKey(const Key('stats.day.2026-11-01')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('stats.category.in_progress')),
          matching: find.text('2'),
        ),
        findsOneWidget,
      );
      await tester.ensureVisible(
        find.byKey(const Key('stats.waiting.infra-2')),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('stats.actor.a1')), findsOneWidget);
      expect(
        find.text('Counting tasks moved to a terminal state.'),
        findsOneWidget,
      );
    });

    testWidgets('$width: empty parts say so', (tester) async {
      answer = emptyStatsJson();
      await pump(tester, size: size);
      expect(find.byKey(const Key('stats.perDay.empty')), findsOneWidget);
      expect(find.byKey(const Key('stats.where.empty')), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('stats.waiting.empty')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('stats.active.empty')), findsOneWidget);
    });

    testWidgets('$width: a failure is shown and can be retried', (
      tester,
    ) async {
      server.failures['GET /api/v1/stats'] = FakeResponse(
        403,
        envelope('forbidden', 'needs task:read'),
      );
      await pump(tester, size: size);
      expect(find.byType(ErrorState), findsOneWidget);
      server.failures.clear();
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('stats.figure.completed')), findsOneWidget);
    });
  }

  testWidgets('the window and project are sent', (tester) async {
    await pump(tester);
    expect(server.requestsTo('/api/v1/stats').last.uri.queryParameters, {
      'window': '336h',
    });
    await tester.tap(find.text('30 days'));
    await tester.pumpAndSettle();
    expect(
      server.requestsTo('/api/v1/stats').last.uri.queryParameters['window'],
      '720h',
    );
    await tester.tap(find.byKey(const Key('stats.project')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Infrastructure').last);
    await tester.pumpAndSettle();
    expect(server.requestsTo('/api/v1/stats').last.uri.queryParameters, {
      'window': '720h',
      'project': 'infra',
    });
  });

  testWidgets('a waiting task opens', (tester) async {
    await pump(tester);
    await tester.ensureVisible(find.byKey(const Key('stats.waiting.infra-2')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('stats.waiting.infra-2')));
    await tester.pumpAndSettle();
    expect(find.text('route:/projects/infra/tasks/infra-2'), findsOneWidget);
  });

  testWidgets('a leaderboard row opens the actor', (tester) async {
    await pump(tester);
    await tester.ensureVisible(find.byKey(const Key('stats.actor.a1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('stats.actor.a1')));
    await tester.pumpAndSettle();
    expect(find.text('route:/actors/a1'), findsOneWidget);
  });
}
