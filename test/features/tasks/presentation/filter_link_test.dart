// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/features/tasks/application/screen.dart';
import 'package:tix_mobile/src/features/tasks/presentation/task_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_parity.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;

  setUp(() {
    server = FakeTix();
    FakeParity.on(server);
    server.filters.add({
      'id': 'f1',
      'name': 'Ops',
      'query': 'tag:ops',
      'mine': true,
      'editable': true,
    });
  });

  Future<ProviderContainer> pump(
    WidgetTester tester,
    TasksScreen screen,
    Size size,
  ) {
    final stores = signedInStores();
    return pumpScreen(
      tester,
      screen,
      size: size,
      overrides: fakeOverrides(
        server,
        settings: stores.settings,
        secrets: stores.secrets,
      ),
    );
  }

  for (final MapEntry(key: width, value: size) in widths.entries) {
    testWidgets('$width: a link naming a saved filter opens it', (
      tester,
    ) async {
      final c = await pump(tester, const TasksScreen(filter: 'ops'), size);
      final state = c.read(taskScreenProvider(const AllScope()));
      expect(state.expression, 'tag:ops');
      expect(state.savedFilterId, 'f1');
      expect(server.requestsTo('/api/v1/filters/ops'), hasLength(1));
    });
  }

  testWidgets('a link to a filter that is gone says so', (tester) async {
    await pump(tester, const TasksScreen(filter: 'nope'), phone);
    expect(find.textContaining('Not found.'), findsOneWidget);
  });

  testWidgets('a saved chip is checked against the server', (tester) async {
    final c = await pump(tester, const TasksScreen(), desktop);
    server.filters.first['query'] = 'tag:ops is:open';
    await tester.tap(find.byKey(const Key('saved.f1')));
    await tester.pumpAndSettle();
    expect(server.requestsTo('/api/v1/filters/f1'), hasLength(1));
    expect(
      c.read(taskScreenProvider(const AllScope())).expression,
      'tag:ops is:open',
    );
  });
}
