// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/features/projects/application/projects.dart';

import '../../../helpers/container.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  test('projects load a page at a time until the cursor runs out', () async {
    final server = FakeTix()..pageSize = 1;
    final c = await signedInContainer(server);
    final sub = c.listen(projectsProvider, (_, _) {});
    addTearDown(sub.close);
    final first = await c.read(projectsProvider.future);
    expect(first.items.map((p) => p.key), ['infra']);
    expect(first.hasMore, isTrue);
    await c.read(projectsProvider.notifier).loadMore();
    final second = c.read(projectsProvider).value!;
    expect(second.items.map((p) => p.key), ['infra', 'web']);
    expect(second.hasMore, isFalse);
    await c.read(projectsProvider.notifier).loadMore();
    expect(
      server.requests.where((r) => r.uri.path.endsWith('/projects')),
      hasLength(2),
    );
  });
}
