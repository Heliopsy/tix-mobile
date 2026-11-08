// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../helpers/app.dart';
import '../../../../helpers/fake_tix.dart';
import 'harness.dart';

void main() {
  late FakeTix server;

  setUp(() {
    server = FakeTix();
    server.routes.add((o, path, caller) {
      if (o.method != 'POST' || path != '/api/v1/tasks/infra-1/claim/reclaim') {
        return null;
      }
      final t = server.task('infra-1')!
        ..remove('claimed_by_actor_id')
        ..['version'] = 2;
      return FakeResponse(200, t);
    });
  });

  Future<void> openMenu(WidgetTester tester) =>
      press(tester, find.byKey(const Key('task.menu')));

  testWidgets('an unclaimed task offers no reclaim', (tester) async {
    await pumpTask(tester, server);
    await openMenu(tester);
    expect(find.byKey(const Key('menu.delete')), findsOneWidget);
    expect(find.byKey(const Key('menu.reclaim')), findsNothing);
  });

  for (final MapEntry(key: width, value: size) in {
    'compact': tallPhone,
    'expanded': tallDesktop,
  }.entries) {
    testWidgets('$width: a claimed task is released with a reason', (
      tester,
    ) async {
      server.task('infra-1')!['claimed_by_actor_id'] = 'a1';
      await pumpTask(tester, server, size: size);
      await openMenu(tester);
      await press(tester, find.byKey(const Key('menu.reclaim')));
      await tester.enterText(
        find.byKey(const Key('reclaim.reason')),
        'worker died',
      );
      await press(tester, find.byKey(const Key('form.submit')));
      expect(bodies(server, 'POST', '/tasks/infra-1/claim/reclaim'), [
        {'reason': 'worker died'},
      ]);
      expect(find.text('Released the claim on infra-1.'), findsOneWidget);
      await openMenu(tester);
      expect(find.byKey(const Key('menu.reclaim')), findsNothing);
    });
  }

  testWidgets('a refusal keeps the form open with the reason', (tester) async {
    server.task('infra-1')!['claimed_by_actor_id'] = 'a1';
    server.failures['POST /api/v1/tasks/infra-1/claim/reclaim'] = FakeResponse(
      403,
      envelope('forbidden', 'task:reclaim'),
    );
    await pumpTask(tester, server, size: phone);
    await openMenu(tester);
    await press(tester, find.byKey(const Key('menu.reclaim')));
    await press(tester, find.byKey(const Key('form.submit')));
    expect(find.byKey(const Key('form.error')), findsOneWidget);
    expect(find.byKey(const Key('reclaim.reason')), findsOneWidget);
  });
}
