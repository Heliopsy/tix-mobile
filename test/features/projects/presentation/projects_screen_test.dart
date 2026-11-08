// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/features/projects/presentation/projects_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  Future<void> pump(
    WidgetTester tester,
    FakeTix server, {
    Size size = phone,
    bool settle = true,
  }) {
    final stores = signedInStores();
    return pumpScreen(
      tester,
      const ProjectsScreen(),
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
    group(width, () {
      testWidgets('loading, then data', (tester) async {
        final server = FakeTix()..gate = Completer<void>();
        await pump(tester, server, size: size, settle: false);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Infrastructure'), findsNothing);
        server.gate!.complete();
        await tester.pumpAndSettle();
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text('Infrastructure'), findsOneWidget);
      });

      testWidgets('empty', (tester) async {
        await pump(tester, FakeTix(projects: []), size: size);
        expect(find.text('No projects yet.'), findsOneWidget);
      });

      testWidgets('error', (tester) async {
        final server = FakeTix()
          ..override = FakeResponse(500, envelope('internal', 'x'));
        await pump(tester, server, size: size);
        expect(
          find.textContaining('The server had a problem.'),
          findsOneWidget,
        );
        expect(find.textContaining('Request req-1.'), findsOneWidget);
      });
    });
  }

  testWidgets('lists projects and opens one', (tester) async {
    await pump(tester, FakeTix());
    expect(find.text('Infrastructure'), findsOneWidget);
    expect(find.text('Web'), findsOneWidget);
    await tester.tap(find.text('Infrastructure'));
    await tester.pumpAndSettle();
    expect(find.text('route:/projects/infra'), findsOneWidget);
  });

  testWidgets('a long list fetches the next page as it scrolls', (
    tester,
  ) async {
    final server = FakeTix(
      projects: [
        for (var i = 0; i < 30; i++) {'id': 'p$i', 'key': 'k$i', 'name': 'P$i'},
      ],
    )..pageSize = 10;
    await pump(tester, server);
    await tester.drag(find.byType(ListView), const Offset(0, -3000));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -3000));
    await tester.pumpAndSettle();
    expect(find.text('P29'), findsOneWidget);
    expect(server.requests.map((r) => r.uri.queryParameters['cursor']), [
      null,
      '10',
      '20',
    ]);
  });

  testWidgets('an empty server says so', (tester) async {
    await pump(tester, FakeTix(projects: []));
    expect(find.text('No projects yet.'), findsOneWidget);
  });

  testWidgets('a failure explains itself and retries', (tester) async {
    final server = FakeTix()
      ..override = FakeResponse(403, envelope('forbidden', 'no'));
    await pump(tester, server);
    expect(find.text('This token is not allowed to do that.'), findsOneWidget);
    server.override = null;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Infrastructure'), findsOneWidget);
  });

  testWidgets('pull to refresh reloads', (tester) async {
    final server = FakeTix();
    await pump(tester, server);
    server.projects.add({'id': 'p3', 'key': 'ops', 'name': 'Ops'});
    await tester.fling(find.text('Infrastructure'), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();
    expect(find.text('Ops'), findsOneWidget);
  });

  testWidgets('a failed next page offers a retry in the footer', (
    tester,
  ) async {
    final server = FakeTix(
      projects: [
        for (var i = 0; i < 32; i++) {'id': 'p$i', 'key': 'k$i', 'name': 'P$i'},
      ],
    )..pageSize = 30;
    await pump(tester, server);
    server.override = FakeResponse(500, envelope('internal', 'x'));
    await tester.drag(find.byType(ListView), const Offset(0, -3000));
    await tester.pumpAndSettle();
    expect(find.text("Couldn't load more."), findsOneWidget);
    server.override = null;
    final retry = find.widgetWithText(TextButton, 'Retry');
    await tester.ensureVisible(retry);
    await tester.pumpAndSettle();
    await tester.tap(retry);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -3000));
    await tester.pumpAndSettle();
    expect(find.text('P31'), findsOneWidget);
  });
}
