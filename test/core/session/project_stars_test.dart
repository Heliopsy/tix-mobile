// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/events/events.dart';
import 'package:tix_mobile/src/core/session/project_stars.dart';
import 'package:tix_mobile/src/core/session/session.dart';

import '../../helpers/app.dart';
import '../../helpers/container.dart';
import '../../helpers/eventually.dart';
import '../../helpers/fake_events.dart';
import '../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;
  late FakeEventSockets sockets;

  const web = Project(id: 'p2', key: 'web', name: 'Web');

  int starReads() => server.requestsTo('/api/v1/me/starred-projects').length;

  setUp(() {
    server = FakeTix()..keepsProjectStars = true;
    sockets = FakeEventSockets();
  });

  Future<ProviderContainer> container() async {
    final stores = signedInStores();
    final c = makeContainer(
      fakeOverrides(
        server,
        settings: stores.settings,
        secrets: stores.secrets,
        events: sockets.connect,
      ),
    );
    await c.read(sessionControllerProvider.future);
    final sub = c.listen(projectStarsProvider, (_, _) {});
    addTearDown(sub.close);
    return c;
  }

  List<String>? keys(ProviderContainer c) =>
      c.read(projectStarsProvider).value?.projects.map((p) => p.key).toList();

  test("reads the reader's starred projects", () async {
    server.projectStars.add('infra');
    final c = await container();
    final stars = await c.read(projectStarsProvider.future);
    expect(stars!.keys, {'infra'});
  });

  test('a server without project stars hides them', () async {
    server.keepsProjectStars = false;
    final c = await container();
    expect(await c.read(projectStarsProvider.future), isNull);
  });

  test('a star shows at once and reaches the server', () async {
    final c = await container();
    await c.read(projectStarsProvider.future);
    final change =
        c.read(projectStarsProvider.notifier).star(web, starred: true)..apply();
    expect(keys(c), ['web']);
    await change.commit();
    expect(server.projectStars, ['web']);
  });

  test('a refused star is put back', () async {
    server.failures['PUT /api/v1/projects/web/star'] = FakeResponse(
      403,
      envelope('forbidden', 'project:read'),
    );
    final c = await container();
    await c.read(projectStarsProvider.future);
    final change =
        c.read(projectStarsProvider.notifier).star(web, starred: true)..apply();
    expect(keys(c), ['web']);
    await expectLater(change.commit(), throwsA(isA<TixException>()));
    change.rollback();
    expect(keys(c), isEmpty);
    expect(server.projectStars, isEmpty);
  });

  test('a lane star elsewhere is read again; another view is not', () async {
    final c = await container();
    await c.read(projectStarsProvider.future);
    await eventually(
      () =>
          sockets.sockets.isNotEmpty &&
          sockets.last.sent.any((m) => m['type'] == 'subscribe'),
      reason: 'a subscription',
    );
    final s = sockets.last..ack();
    await eventually(
      () => c.read(tixEventStreamProvider)?.status.mode == LiveMode.websocket,
      reason: 'a live WebSocket',
    );
    expect(starReads(), 1);

    void arranged(int seq, String view) => s.push({
      'type': 'event',
      'id': 's1',
      'event': {
        'seq': seq,
        'type': 'view.arranged',
        'subject_type': 'view',
        'subject_id': view,
        'payload': {
          'view': view,
          'groups': ['infra'],
        },
        'occurred_at': '2026-11-08T10:00:00Z',
      },
    });

    arranged(1, 'board');
    await eventually(() => c.read(tixEventStreamProvider)?.cursor == 1);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    expect(starReads(), 1);

    server.projectStars.add('infra');
    arranged(2, 'lanes');
    await eventually(
      () => keys(c)?.contains('infra') ?? false,
      reason: 'the star read again',
    );
    expect(starReads(), 2);
  });
}
