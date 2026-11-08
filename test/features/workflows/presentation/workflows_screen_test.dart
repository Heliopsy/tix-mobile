// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/features/workflows/presentation/workflows_screen.dart';

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
      const WorkflowsScreen(),
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
      testWidgets('loading, then the workflows', (tester) async {
        final server = FakeTix()..gate = Completer<void>();
        await pump(tester, server, size: size, settle: false);
        expect(find.byType(SkeletonList), findsOneWidget);
        server.gate!.complete();
        await tester.pumpAndSettle();
        expect(find.text('Default'), findsOneWidget);
        expect(find.text('builtin'), findsOneWidget);
        expect(find.text('5 states'), findsOneWidget);
      });

      testWidgets('error', (tester) async {
        final server = FakeTix()
          ..override = FakeResponse(500, envelope('internal', 'x'));
        await pump(tester, server, size: size);
        expect(find.byType(ErrorState), findsOneWidget);
      });

      testWidgets('a copy starts from the chosen workflow', (tester) async {
        final server = FakeTix();
        await pump(tester, server, size: size);
        await tester.tap(find.byKey(const Key('workflow.new')));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const Key('workflow.key')),
          'support',
        );
        await tester.enterText(
          find.byKey(const Key('workflow.name')),
          'Support',
        );
        await tester.tap(find.byKey(const Key('workflow.from')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('A copy of Default').last);
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('workflow.create')));
        await tester.pumpAndSettle();
        final put = server.requests.lastWhere((r) => r.method == 'PUT');
        expect(put.uri.path, '/api/v1/workflows');
        expect(put.body['key'], 'support');
        expect(put.body['name'], 'Support');
        final def = put.body['definition'] as Map<String, dynamic>;
        expect((def['states'] as List).length, 5);
        expect(find.text('route:/manage/workflows/support'), findsOneWidget);
      });
    });
  }

  testWidgets('a key in use cannot be created over', (tester) async {
    final server = FakeTix();
    await pump(tester, server);
    await tester.tap(find.byKey(const Key('workflow.new')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('workflow.key')), 'default');
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TixButton>(find.byKey(const Key('workflow.create')))
          .onPressed,
      isNull,
    );
  });

  testWidgets('a member reads but cannot create', (tester) async {
    final server = FakeTix()..identity = {'role': 'member'};
    await pump(tester, server);
    expect(find.text('Default'), findsOneWidget);
    expect(find.byKey(const Key('workflow.new')), findsNothing);
  });

  testWidgets('a workflow opens in its editor', (tester) async {
    await pump(tester, FakeTix());
    await tester.tap(find.byKey(const Key('workflow.default')));
    await tester.pumpAndSettle();
    expect(find.text('route:/manage/workflows/default'), findsOneWidget);
  });
}
