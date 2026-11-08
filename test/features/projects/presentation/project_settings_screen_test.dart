// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/features/projects/presentation/project_settings_screen.dart';

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
      const ProjectSettingsScreen(projectKey: 'infra'),
      size: size,
      settle: settle,
      overrides: fakeOverrides(
        server,
        settings: stores.settings,
        secrets: stores.secrets,
      ),
    );
  }

  Future<void> tapVisible(WidgetTester tester, Finder f) async {
    await tester.ensureVisible(f);
    await tester.pumpAndSettle();
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  Finder save() => find.byKey(const Key('project.save'));

  for (final MapEntry(key: width, value: size) in widths.entries) {
    group(width, () {
      testWidgets('loading, then the sections', (tester) async {
        final server = FakeTix()..gate = Completer<void>();
        await pump(tester, server, size: size, settle: false);
        expect(find.byType(SkeletonList), findsOneWidget);
        server.gate!.complete();
        await tester.pumpAndSettle();
        for (final title in ['Project', 'Appearance', 'Claims']) {
          expect(find.text(title), findsWidgets);
        }
        await tester.ensureVisible(find.text('Danger zone'));
        await tester.pumpAndSettle();
        expect(find.text('Danger zone'), findsOneWidget);
        expect(save(), findsNothing);
      });

      testWidgets('error', (tester) async {
        final server = FakeTix()
          ..failures['GET /api/v1/projects/infra'] = FakeResponse(
            404,
            envelope('not_found', 'project "infra"'),
          );
        await pump(tester, server, size: size);
        expect(find.byType(ErrorState), findsOneWidget);
      });

      testWidgets('a recolour sends only the colour', (tester) async {
        final server = FakeTix();
        await pump(tester, server, size: size);
        await tapVisible(tester, find.byKey(const Key('colour.violet')));
        expect(save(), findsOneWidget);
        await tester.tap(save());
        await tester.pumpAndSettle();
        final patch = server.requests.lastWhere((r) => r.method == 'PATCH');
        expect(patch.uri.path, '/api/v1/projects/infra');
        expect(patch.body, {'color': 'violet'});
        expect(find.text('Project saved.'), findsOneWidget);
      });
    });
  }

  testWidgets('a key change is explained before it is sent', (tester) async {
    final server = FakeTix();
    await pump(tester, server);
    await tester.enterText(find.byKey(const Key('project.key')), 'ops');
    await tester.pumpAndSettle();
    await tester.tap(save());
    await tester.pumpAndSettle();
    expect(find.text('infra-1  →  ops-1'), findsOneWidget);
    expect(server.requests.where((r) => r.method == 'PATCH'), isEmpty);
    await tester.tap(find.byKey(const Key('project.rekey.ok')));
    await tester.pumpAndSettle();
    final patch = server.requests.lastWhere((r) => r.method == 'PATCH');
    expect(patch.body, {'key': 'ops'});
    expect(find.text('route:/projects/ops/settings'), findsOneWidget);
  });

  testWidgets('a built-in icon replaces the text icon', (tester) async {
    final server = FakeTix();
    await pump(tester, server);
    await tapVisible(tester, find.text('Icon').last);
    await tapVisible(tester, find.byKey(const Key('icon.rocket')));
    await tester.tap(save());
    await tester.pumpAndSettle();
    final patch = server.requests.lastWhere((r) => r.method == 'PATCH');
    expect(patch.body, {'icon_name': 'rocket'});
  });

  testWidgets('a refusal stays on the screen with the server message', (
    tester,
  ) async {
    final server = FakeTix()
      ..failures['PATCH /api/v1/projects/infra'] = FakeResponse(
        409,
        envelope('conflict', 'task infra-2 is in a state "doing" lacks'),
      );
    await pump(tester, server);
    await tester.enterText(find.byKey(const Key('project.name')), 'Infra');
    await tester.pumpAndSettle();
    await tester.tap(save());
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('project.error')), findsOneWidget);
    expect(find.textContaining('lacks'), findsOneWidget);
    expect(find.text('Infra'), findsOneWidget);
  });

  testWidgets('archive is red and confirmed', (tester) async {
    final server = FakeTix();
    await pump(tester, server);
    await tapVisible(tester, find.byKey(const Key('project.archive')));
    expect(find.byKey(const Key('confirm.ok')), findsOneWidget);
    await tester.tap(find.byKey(const Key('confirm.ok')));
    await tester.pumpAndSettle();
    final del = server.requests.lastWhere((r) => r.method == 'DELETE');
    expect(del.uri.queryParameters, {'archive': 'true'});
    expect(find.byKey(const Key('project.archived')), findsOneWidget);
    expect(find.byKey(const Key('project.archive')), findsNothing);
  });

  testWidgets('without project:write nothing can be changed', (tester) async {
    final server = FakeTix()..identity = {'role': 'member'};
    await pump(tester, server);
    expect(find.byKey(const Key('project.readOnly')), findsOneWidget);
    final name = tester.widget<TextField>(
      find.byKey(const Key('project.name')),
    );
    expect(name.enabled, isFalse);
    expect(find.byKey(const Key('project.archive')), findsNothing);
    expect(find.byKey(const Key('project.delete')), findsNothing);
  });

  testWidgets('custom fields open from the settings', (tester) async {
    await pump(tester, FakeTix());
    await tapVisible(tester, find.byKey(const Key('project.fields')));
    expect(find.text('route:/projects/infra/fields'), findsOneWidget);
  });

  group('delete', () {
    testWidgets('an empty project only confirms', (tester) async {
      final server = FakeTix();
      await pump(tester, server, size: desktop);
      await tapVisible(tester, find.byKey(const Key('project.delete')));
      expect(
        find.text('The project holds no tasks. Deleting it cannot be undone.'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('project.delete.ok')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm.ok')));
      await tester.pumpAndSettle();
      final del = server.requests.lastWhere((r) => r.method == 'DELETE');
      expect(del.uri.path, '/api/v1/projects/infra');
      expect(del.uri.queryParameters, isEmpty);
      expect(find.text('route:/projects'), findsOneWidget);
    });

    testWidgets('moving the tasks shows the mapping and names the target', (
      tester,
    ) async {
      final server = FakeTix()
        ..deletionCounts['infra'] = (tasks: 2, deleted: 0);
      await pump(tester, server, size: desktop);
      await tapVisible(tester, find.byKey(const Key('project.delete')));
      final ok = find.byKey(const Key('project.delete.ok'));
      expect(tester.widget<TixButton>(ok).onPressed, isNull);
      await tester.tap(find.byKey(const Key('project.delete.target')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Web (web)').last);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('project.delete.mapping')), findsOneWidget);
      expect(find.text('in_progress'), findsOneWidget);
      await tester.tap(ok);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm.ok')));
      await tester.pumpAndSettle();
      final del = server.requests.lastWhere((r) => r.method == 'DELETE');
      expect(del.uri.queryParameters, {'move_tasks_to': 'web'});
    });

    testWidgets('deleting the tasks needs the key typed', (tester) async {
      final server = FakeTix()
        ..deletionCounts['infra'] = (tasks: 2, deleted: 1);
      await pump(tester, server, size: desktop);
      await tapVisible(tester, find.byKey(const Key('project.delete')));
      await tester.tap(find.byKey(const Key('project.delete.tasks')));
      await tester.pumpAndSettle();
      final ok = find.byKey(const Key('project.delete.ok'));
      await tester.enterText(
        find.byKey(const Key('project.delete.typed')),
        'inf',
      );
      await tester.pump();
      expect(tester.widget<TixButton>(ok).onPressed, isNull);
      await tester.enterText(
        find.byKey(const Key('project.delete.typed')),
        'infra',
      );
      await tester.pump();
      expect(tester.widget<TixButton>(ok).onPressed, isNotNull);
      await tester.tap(ok);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm.ok')));
      await tester.pumpAndSettle();
      final del = server.requests.lastWhere((r) => r.method == 'DELETE');
      expect(del.uri.queryParameters, {'delete_tasks': 'true'});
    });
  });
}
