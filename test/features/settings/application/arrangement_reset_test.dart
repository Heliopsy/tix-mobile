// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/features/settings/application/settings.dart';
import 'package:tix_mobile/src/features/tasks/application/screen.dart';

import '../../../helpers/container.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;

  setUp(() => server = FakeTix());

  test('resetting from Settings redraws open views', () async {
    server.views['board'] = {
      'todo': {'hidden': true},
    };
    final c = await signedInContainer(server);
    final sub = c.listen(viewArrangementProvider('board'), (_, _) {});
    addTearDown(sub.close);
    final before = await c.read(viewArrangementProvider('board').future);
    expect(before['todo']?.hidden, isTrue);

    await c.read(arrangementSettingsProvider.notifier).reset();

    final after = await c.read(viewArrangementProvider('board').future);
    expect(after, isEmpty);
  });

  test('a reset that fails still reads the views again', () async {
    final c = await signedInContainer(server);
    final sub = c.listen(viewArrangementProvider('mine'), (_, _) {});
    addTearDown(sub.close);
    await c.read(viewArrangementProvider('mine').future);
    int reads() => server
        .requestsTo('/views/mine/groups')
        .where((r) => r.method == 'GET')
        .length;
    final before = reads();
    server.failures['DELETE /api/v1/views/lanes/groups'] = FakeResponse(
      500,
      envelope('internal', 'down'),
    );
    await expectLater(
      c.read(arrangementSettingsProvider.notifier).reset(),
      throwsA(anything),
    );
    await c.read(viewArrangementProvider('mine').future);
    expect(reads(), before + 1);
  });
}
