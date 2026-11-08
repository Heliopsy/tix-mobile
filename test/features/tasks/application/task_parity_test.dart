// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/data/models/saved_filter.dart';
import 'package:tix_mobile/src/features/tasks/application/screen.dart';
import 'package:tix_mobile/src/features/tasks/application/task_detail.dart';

import '../../../helpers/container.dart';
import '../../../helpers/fake_parity.dart';
import '../../../helpers/fake_tix.dart';

P keep<P extends ProviderListenable<Object?>>(ProviderContainer c, P provider) {
  final sub = c.listen(provider, (_, _) {});
  addTearDown(sub.close);
  return provider;
}

void main() {
  late FakeTix server;

  setUp(() {
    server = FakeTix();
    FakeParity.on(server);
  });

  group('moves', () {
    Future<(ProviderContainer, TaskDetailController)> open() async {
      final c = await signedInContainer(server);
      await c.read(keep(c, taskDetailControllerProvider('infra-1')).future);
      return (c, c.read(taskDetailControllerProvider('infra-1').notifier));
    }

    test('a direct move is one transition', () async {
      final (c, ctl) = await open();
      final result = await ctl.move('doing', comment: 'go', direct: true);
      expect(server.requestsTo('/tasks/infra-1/transition'), hasLength(1));
      expect(server.requestsTo('/tasks/infra-1/route'), isEmpty);
      expect(server.requests.last.body, {'to': 'doing', 'comment': 'go'});
      expect(result.task?.status, 'doing');
      expect(result.stopped, isEmpty);
      expect(
        c.read(taskDetailControllerProvider('infra-1')).value?.status,
        'doing',
      );
    });

    test('a move through other states keeps the route', () async {
      final (_, ctl) = await open();
      await ctl.move('done');
      expect(server.requestsTo('/tasks/infra-1/transition'), isEmpty);
      expect(server.requestsTo('/tasks/infra-1/route'), hasLength(1));
    });

    test('a refused transition puts the status back', () async {
      final (c, ctl) = await open();
      server.failures['POST /api/v1/tasks/infra-1/transition'] = FakeResponse(
        422,
        envelope('precondition_failed', 'needs a comment'),
      );
      await expectLater(
        ctl.move('doing', direct: true),
        throwsA(isA<TixException>()),
      );
      expect(
        c.read(taskDetailControllerProvider('infra-1')).value?.status,
        'todo',
      );
    });
  });

  test('the lease and the fresh tags are read for a task', () async {
    final c = await signedInContainer(server);
    final lease = await c.read(keep(c, taskLeaseProvider('infra-1')).future);
    expect(lease.ttl, '2h0m0s');
    server.task('infra-1')!['tags'] = ['auth', 'ops'];
    expect(await c.read(keep(c, taskTagsProvider('infra-1')).future), [
      'auth',
      'ops',
    ]);
  });

  group('saved filters', () {
    const scope = AllScope();

    test(
      'the server copy replaces a drawn filter only when it changed',
      () async {
        server.filters.add({'id': 'f1', 'name': 'Ops', 'query': 'tag:ops'});
        final c = await signedInContainer(server);
        final p = keep(c, taskScreenProvider(scope));
        keep(c, savedFiltersProvider);
        final stale = SavedFilter.fromJson({
          'id': 'f1',
          'name': 'Ops',
          'query': 'tag:old',
        });
        c.read(p.notifier).applySaved(stale);
        final fresh = await c.read(savedFiltersProvider.notifier).fetch('f1');
        expect(server.requestsTo('/filters/f1'), hasLength(1));
        c.read(p.notifier).refreshSaved(stale, fresh);
        expect(c.read(p).expression, 'tag:ops');
        c.read(p.notifier).clear();
        c.read(p.notifier).refreshSaved(stale, fresh);
        expect(c.read(p).expression, isEmpty);
      },
    );

    test('one gone from the server is refused and dropped', () async {
      final c = await signedInContainer(server);
      final p = keep(c, taskScreenProvider(scope));
      keep(c, savedFiltersProvider);
      await c.read(savedFiltersProvider.future);
      await expectLater(
        c.read(savedFiltersProvider.notifier).fetch('f9'),
        throwsA(
          isA<TixException>().having(
            (e) => e.kind,
            'kind',
            TixErrorKind.notFound,
          ),
        ),
      );
      c
          .read(p.notifier)
          .applySaved(
            SavedFilter.fromJson({
              'id': 'f9',
              'name': 'Gone',
              'query': 'tag:x',
            }),
          );
      c.read(p.notifier).dropSaved('f9');
      expect(c.read(p).savedFilterId, isNull);
      expect(c.read(p).expression, isEmpty);
    });

    test('a filter is fetched by name', () async {
      server.filters.add({
        'id': 'f2',
        'name': 'Due soon',
        'query': 'due:week',
        'view': 'board',
      });
      final c = await signedInContainer(server);
      keep(c, savedFiltersProvider);
      final f = await c.read(savedFiltersProvider.notifier).fetch('due soon');
      expect(f.id, 'f2');
      expect(server.requestsTo('/filters/due%20soon'), hasLength(1));
    });
  });
}
