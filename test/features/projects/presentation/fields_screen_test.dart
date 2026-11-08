// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/features/projects/presentation/fields_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  Future<void> pump(
    WidgetTester tester,
    FakeTix server, {
    Size size = phone,
    bool settle = true,
    String project = 'infra',
  }) {
    final stores = signedInStores();
    return pumpScreen(
      tester,
      ProjectFieldsScreen(projectKey: project),
      size: size,
      settle: settle,
      overrides: fakeOverrides(
        server,
        settings: stores.settings,
        secrets: stores.secrets,
      ),
    );
  }

  Future<void> pick(WidgetTester tester, Key field, String option) async {
    await tester.ensureVisible(find.byKey(field));
    await tester.tap(find.byKey(field));
    await tester.pumpAndSettle();
    await tester.tap(find.text(option).last);
    await tester.pumpAndSettle();
  }

  Future<void> save(WidgetTester tester) async {
    await tester.ensureVisible(find.byKey(const Key('field.save')));
    await tester.tap(find.byKey(const Key('field.save')));
    await tester.pumpAndSettle();
  }

  Map<String, dynamic> lastPut(FakeTix server) =>
      server.requests.lastWhere((r) => r.method == 'PUT').body;

  for (final MapEntry(key: width, value: size) in widths.entries) {
    group(width, () {
      testWidgets('loading, then the fields in order', (tester) async {
        final server = FakeTix()..gate = Completer<void>();
        await pump(tester, server, size: size, settle: false);
        expect(find.byType(SkeletonList), findsOneWidget);
        server.gate!.complete();
        await tester.pumpAndSettle();
        expect(find.text('Environment'), findsOneWidget);
        expect(find.text('production, staging'), findsOneWidget);
        expect(find.text('Change window'), findsOneWidget);
      });

      testWidgets('empty carries the create action', (tester) async {
        await pump(tester, FakeTix(), size: size, project: 'web');
        expect(find.text('No custom fields yet.'), findsOneWidget);
        expect(find.byKey(const Key('field.new')), findsWidgets);
      });

      testWidgets('error', (tester) async {
        final server = FakeTix()
          ..override = FakeResponse(500, envelope('internal', 'x'));
        await pump(tester, server, size: size);
        expect(find.byType(ErrorState), findsOneWidget);
      });

      testWidgets('an enum field sends its options', (tester) async {
        final server = FakeTix();
        await pump(tester, server, size: size, project: 'web');
        await tester.tap(find.byKey(const Key('field.new')).first);
        await tester.pumpAndSettle();
        await tester.enterText(find.byKey(const Key('field.key')), 'env');
        await pick(tester, const Key('field.type'), 'Choice');
        await tester.enterText(
          find.byKey(const Key('field.options')),
          'production, staging',
        );
        await tester.pumpAndSettle();
        await pick(tester, const Key('field.default'), 'staging');
        await save(tester);
        expect(lastPut(server), {
          'key': 'env',
          'label': '',
          'type': 'enum',
          'enum_options': ['production', 'staging'],
          'default': 'staging',
          'position': 10,
          'required': false,
        });
        expect(find.text('env'), findsWidgets);
      });
    });
  }

  testWidgets('a number default is sent as a number', (tester) async {
    final server = FakeTix();
    await pump(tester, server);
    await tester.tap(find.byKey(const Key('field.new')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('field.key')), 'points');
    await pick(tester, const Key('field.type'), 'Whole number');
    await tester.enterText(find.byKey(const Key('field.default')), '3');
    await save(tester);
    expect(lastPut(server)['default'], 3);
    expect(lastPut(server)['position'], 10);
  });

  testWidgets('a bool default is a choice of none, yes and no', (tester) async {
    final server = FakeTix();
    await pump(tester, server);
    await tester.tap(find.text('Paged'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(find.byKey(const Key('field.key'))).enabled,
      isFalse,
    );
    await pick(tester, const Key('field.default'), 'Yes');
    await save(tester);
    expect(lastPut(server)['key'], 'paged');
    expect(lastPut(server)['default'], true);
  });

  testWidgets('unreadable JSON is caught before sending', (tester) async {
    final server = FakeTix();
    await pump(tester, server);
    await tester.tap(find.byKey(const Key('field.new')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('field.key')), 'meta');
    await pick(tester, const Key('field.type'), 'JSON');
    await tester.enterText(find.byKey(const Key('field.default')), '{oops');
    await save(tester);
    expect(find.byKey(const Key('field.defaultError')), findsOneWidget);
    expect(server.requests.where((r) => r.method == 'PUT'), isEmpty);
  });

  testWidgets('a refusal stays in the form', (tester) async {
    final server = FakeTix();
    await pump(tester, server);
    await tester.tap(find.byKey(const Key('field.new')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('field.key')), 'kind');
    await pick(tester, const Key('field.type'), 'Choice');
    await save(tester);
    expect(find.byKey(const Key('field.error')), findsOneWidget);
    expect(find.textContaining('an enum field needs options'), findsOneWidget);
  });

  testWidgets('delete is red and confirmed', (tester) async {
    final server = FakeTix();
    await pump(tester, server);
    await tester.tap(find.text('Change window'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('field.delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm.ok')));
    await tester.pumpAndSettle();
    final del = server.requests.lastWhere((r) => r.method == 'DELETE');
    expect(del.uri.path, '/api/v1/projects/infra/fields/window');
    expect(find.text('Change window'), findsNothing);
  });

  testWidgets('dragging saves the new positions', (tester) async {
    final server = FakeTix();
    await pump(tester, server, size: desktop);
    final handle = find.byIcon(Icons.drag_handle);
    await tester.drag(handle.last, const Offset(0, -300));
    await tester.pumpAndSettle();
    final puts = server.requests.where((r) => r.method == 'PUT').toList();
    expect(puts, isNotEmpty);
    expect(puts.first.body['key'], 'window');
    expect(puts.first.body['position'], 10);
  });

  testWidgets('without project:write the fields are read only', (tester) async {
    final server = FakeTix()..identity = {'role': 'member'};
    await pump(tester, server);
    expect(find.byKey(const Key('field.new')), findsNothing);
    expect(find.byIcon(Icons.drag_handle), findsNothing);
    await tester.tap(find.text('Paged'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('field.save')), findsNothing);
  });

  testWidgets("the project chooser opens a project's fields", (tester) async {
    final stores = signedInStores();
    await pumpScreen(
      tester,
      const FieldProjectsScreen(),
      overrides: fakeOverrides(
        FakeTix(),
        settings: stores.settings,
        secrets: stores.secrets,
      ),
    );
    await tester.tap(find.byKey(const Key('fields.project.web')));
    await tester.pumpAndSettle();
    expect(find.text('route:/manage/fields/web'), findsOneWidget);
  });
}
