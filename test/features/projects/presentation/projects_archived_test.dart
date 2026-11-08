// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/features/projects/presentation/projects_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;

  setUp(() {
    server = FakeTix();
    server.routes.add((o, path, caller) {
      if (o.method != 'GET' || path != '/api/v1/projects') return null;
      final archived = o.uri.queryParameters['include_archived'] == 'true';
      return FakeResponse(200, {
        'items': [
          ...server.projects,
          if (archived)
            {
              'id': 'p3',
              'key': 'old',
              'name': 'Old site',
              'color': 'gray',
              'workflow_id': 'wf1',
              'archived_at': '2026-10-01T00:00:00Z',
            },
        ],
        'next_cursor': '',
      });
    });
  });

  for (final MapEntry(key: width, value: size) in widths.entries) {
    testWidgets('$width: archived projects show only when asked, badged', (
      tester,
    ) async {
      final stores = signedInStores();
      await pumpScreen(
        tester,
        const ProjectsScreen(),
        size: size,
        overrides: fakeOverrides(
          server,
          settings: stores.settings,
          secrets: stores.secrets,
        ),
      );
      expect(find.text('Old site'), findsNothing);
      expect(
        server.requestsTo('/api/v1/projects').last.uri.queryParameters,
        isNot(contains('include_archived')),
      );
      await tester.tap(find.byKey(const Key('projects.archived')));
      await tester.pumpAndSettle();
      expect(
        server.requestsTo('/api/v1/projects').last.uri.queryParameters,
        containsPair('include_archived', 'true'),
      );
      expect(find.text('Old site'), findsOneWidget);
      expect(find.text('archived'), findsOneWidget);
    });
  }
}
