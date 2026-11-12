// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/features/tasks/presentation/my_work_badge.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  const shell = Scaffold(body: MyWorkNavIcon(icon: Icon(Icons.person)));

  String overdue(int days) =>
      fixedNow.subtract(Duration(days: days)).toIso8601String();

  Future<void> pump(WidgetTester tester, FakeTix server) {
    final stores = signedInStores();
    return pumpScreen(
      tester,
      shell,
      overrides: fakeOverrides(
        server,
        settings: stores.settings,
        secrets: stores.secrets,
      ),
    );
  }

  Badge badge(WidgetTester tester) =>
      tester.widget<Badge>(find.byKey(const Key('myWork.badge')));

  testWidgets("counts the reader's open overdue tasks in danger red", (
    tester,
  ) async {
    final server = FakeTix(
      tasks: {
        'infra': [
          taskJson('infra-1', assignee: 'me', due: overdue(2)),
          taskJson('infra-2', assignee: 'me', due: overdue(1)),
          taskJson('infra-3', assignee: 'me', due: overdue(1), status: 'done'),
          taskJson('infra-4', due: overdue(1)),
        ],
      },
    );
    await pump(tester, server);
    expect(badge(tester).isLabelVisible, isTrue);
    expect(badge(tester).backgroundColor, TixTokens.light.danger);
    expect(
      find.descendant(
        of: find.byKey(const Key('myWork.badge')),
        matching: find.text('2'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('past 99 it reads 99+', (tester) async {
    final server = FakeTix(
      tasks: {
        'infra': [
          for (var i = 1; i <= 120; i++)
            taskJson('infra-$i', assignee: 'me', due: overdue(1)),
        ],
      },
    )..pageSize = 200;
    await pump(tester, server);
    expect(find.text('99+'), findsOneWidget);
  });

  testWidgets('nothing overdue shows no badge', (tester) async {
    final server = FakeTix(
      tasks: {
        'infra': [taskJson('infra-1', assignee: 'me')],
      },
    );
    await pump(tester, server);
    expect(badge(tester).isLabelVisible, isFalse);
  });
}
