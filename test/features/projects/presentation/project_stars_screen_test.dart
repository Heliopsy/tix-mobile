// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/features/projects/presentation/projects_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  Future<void> pump(WidgetTester tester, FakeTix server, {Size size = phone}) {
    final stores = signedInStores();
    return pumpScreen(
      tester,
      const ProjectsScreen(),
      size: size,
      overrides: fakeOverrides(
        server,
        settings: stores.settings,
        secrets: stores.secrets,
      ),
    );
  }

  Finder starred(String name) => find.descendant(
    of: find.byKey(const Key('projects.starred')),
    matching: find.text(name),
  );

  IconButton star(WidgetTester tester, String key) => tester.widget<IconButton>(
    find.descendant(
      of: find.byKey(Key('project.$key.star')),
      matching: find.byType(IconButton),
    ),
  );

  for (final MapEntry(key: width, value: size) in widths.entries) {
    testWidgets('$width: starred projects are listed first, once', (
      tester,
    ) async {
      final server = FakeTix()
        ..keepsProjectStars = true
        ..projectStars.add('web');
      await pump(tester, server, size: size);
      expect(find.text('Starred'), findsOneWidget);
      expect(find.text('Other projects'), findsOneWidget);
      expect(starred('Web'), findsOneWidget);
      expect(starred('Infrastructure'), findsNothing);
      expect(find.text('Web'), findsOneWidget, reason: 'listed once');
      expect(find.text('Infrastructure'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Web')).dy,
        lessThan(tester.getTopLeft(find.text('Infrastructure')).dy),
      );
      expect(star(tester, 'web').isSelected, isTrue);
      expect(star(tester, 'infra').isSelected, isFalse);
    });
  }

  testWidgets('starring moves a project into Starred', (tester) async {
    final server = FakeTix()..keepsProjectStars = true;
    await pump(tester, server);
    expect(find.text('Starred'), findsNothing);
    await tester.tap(find.byKey(const Key('project.infra.star')));
    await tester.pumpAndSettle();
    expect(server.projectStars, ['infra']);
    expect(starred('Infrastructure'), findsOneWidget);
    expect(find.text('Infrastructure starred'), findsOneWidget);
    expect(star(tester, 'infra').isSelected, isTrue);
  });

  testWidgets('taking a star off moves the project back', (tester) async {
    final server = FakeTix()
      ..keepsProjectStars = true
      ..projectStars.add('infra');
    await pump(tester, server);
    expect(starred('Infrastructure'), findsOneWidget);
    await tester.tap(find.byKey(const Key('project.infra.star')));
    await tester.pumpAndSettle();
    expect(server.projectStars, isEmpty);
    expect(find.byKey(const Key('projects.starred')), findsNothing);
    expect(find.text('Star removed from Infrastructure'), findsOneWidget);
  });

  testWidgets('a refused star is put back and says why', (tester) async {
    final server = FakeTix()..keepsProjectStars = true;
    server.failures['PUT /api/v1/projects/infra/star'] = FakeResponse(
      403,
      envelope('forbidden', 'project:read'),
    );
    await pump(tester, server);
    await tester.tap(find.byKey(const Key('project.infra.star')));
    await tester.pumpAndSettle();
    expect(server.projectStars, isEmpty);
    expect(find.byKey(const Key('projects.starred')), findsNothing);
    expect(star(tester, 'infra').isSelected, isFalse);
    expect(find.text('This token is not allowed to do that.'), findsOneWidget);
  });

  testWidgets('a server without project stars shows no star', (tester) async {
    await pump(tester, FakeTix());
    expect(find.text('Infrastructure'), findsOneWidget);
    expect(find.byKey(const Key('project.infra.star')), findsNothing);
    expect(find.text('Starred'), findsNothing);
  });
}
