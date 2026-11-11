// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/quick/quick_add.dart';
import 'package:tix_mobile/src/features/tasks/application/task_detail.dart';

import '../../../helpers/container.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;
  late ProviderContainer c;
  final detail = taskDetailControllerProvider('infra-1');

  setUp(() async {
    server = FakeTix();
    c = await signedInContainer(server);
    final sub = c.listen(detail, (_, _) {});
    addTearDown(sub.close);
    await c.read(detail.future);
  });

  test('sends the project and answers where the task landed', () async {
    final changed = c.read(tasksChangedProvider);
    final moved = await c.read(detail.notifier).moveToProject('web');
    final post = server.requests.last;
    expect(post.method, 'POST');
    expect(post.uri.path, '/api/v1/tasks/infra-1/move');
    expect(post.data, {'project_ref': 'web'});
    expect(moved.task?.ref, 'web-50');
    expect(moved.fromRef, 'infra-1');
    expect(moved.project, 'web');
    expect(c.read(tasksChangedProvider), changed + 1);
    expect(c.read(taskMoveSupportProvider), isTrue);
  });

  test('the old reference keeps leading to the task', () async {
    await c.read(detail.notifier).moveToProject('web');
    expect(server.task('infra-1'), isNull);
    expect(server.movedRefs['infra-1'], 'web-50');
  });

  test('a refusal is rethrown and changes nothing', () async {
    server.failures['POST /api/v1/tasks/infra-1/move'] = FakeResponse(
      422,
      envelope('precondition_failed', 'project "web" is archived'),
    );
    final changed = c.read(tasksChangedProvider);
    await expectLater(
      c.read(detail.notifier).moveToProject('web'),
      throwsA(
        isA<TixException>().having(
          (e) => e.kind,
          'kind',
          TixErrorKind.preconditionFailed,
        ),
      ),
    );
    expect(c.read(tasksChangedProvider), changed);
    expect(c.read(taskMoveSupportProvider), isTrue);
  });

  test('a missing project is an ordinary not found', () async {
    await expectLater(
      c.read(detail.notifier).moveToProject('nope'),
      throwsA(isA<TixException>().having((e) => e.status, 'status', 404)),
    );
    expect(c.read(taskMoveSupportProvider), isTrue);
  });

  test('a server without the route is remembered for the session', () async {
    server.moveSupported = false;
    await expectLater(
      c.read(detail.notifier).moveToProject('web'),
      throwsA(isA<TaskMoveUnsupported>()),
    );
    expect(c.read(taskMoveSupportProvider), isFalse);
  });
}
