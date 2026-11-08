// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/data/models/actor.dart';
import 'package:tix_mobile/src/features/tasks/application/tasks.dart';

import '../../../helpers/container.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;

  setUp(() => server = FakeTix());

  Future<ProviderContainer> signedIn() => signedInContainer(server);

  test('project tasks page with the project key and cursor', () async {
    server.pageSize = 1;
    final c = await signedIn();
    final provider = projectTasksProvider('infra');
    final sub = c.listen(provider, (_, _) {});
    addTearDown(sub.close);
    expect((await c.read(provider.future)).items.single.ref, 'infra-1');
    await c.read(provider.notifier).loadMore();
    expect(c.read(provider).value!.items.map((t) => t.ref), [
      'infra-1',
      'infra-2',
    ]);
    expect(server.requests.last.uri.queryParameters, {
      'project': 'infra',
      'limit': '50',
      'cursor': '1',
    });
  });

  test('a failed next page keeps the rows and can be retried', () async {
    server.pageSize = 1;
    final c = await signedIn();
    final provider = projectTasksProvider('infra');
    final sub = c.listen(provider, (_, _) {});
    addTearDown(sub.close);
    await c.read(provider.future);
    server.override = FakeResponse(500, envelope('internal', 'boom'));
    await c.read(provider.notifier).loadMore();
    final failed = c.read(provider).value!;
    expect(failed.items, hasLength(1));
    expect(failed.moreError, isA<TixException>());
    server.override = null;
    await c.read(provider.notifier).loadMore();
    expect(c.read(provider).value!.items, hasLength(2));
    expect(c.read(provider).value!.moreError, isNull);
  });

  test('quickAdd creates in the project and reloads the list', () async {
    final c = await signedIn();
    final provider = projectTasksProvider('infra');
    final sub = c.listen(provider, (_, _) {});
    addTearDown(sub.close);
    await c.read(provider.future);
    final task = await c.read(provider.notifier).quickAdd('Ship !high');
    expect(task.ref, 'infra-3');
    expect((await c.read(provider.future)).items.first.ref, 'infra-3');
  });

  test('taskDetail and actor read one record each', () async {
    final c = await signedIn();
    expect(
      (await c.read(taskDetailProvider('infra-1').future)).title,
      'Fix login',
    );
    expect((await c.read(actorProvider('a1').future)).label, 'Raj');
  });
}
