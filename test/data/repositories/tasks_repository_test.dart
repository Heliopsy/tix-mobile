// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/models/actor.dart';
import 'package:tix_mobile/src/data/models/page.dart';
import 'package:tix_mobile/src/data/models/project.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/data/repositories/tasks_repository.dart';

class MockTixApi extends Mock implements TixApi;

void main() {
  late MockTixApi api;
  late TasksRepository repo;

  setUpAll(() => registerFallbackValue(const CreateTaskRequest(title: '')));

  setUp(() {
    api = MockTixApi();
    repo = TasksRepository(api);
  });

  test('lists pass the cursor through', () async {
    when(() => api.projects(cursor: 'c')).thenAnswer(
      (_) async => const Page(
        items: [Project(id: 'p', key: 'k')],
      ),
    );
    when(() => api.tasks(project: 'k', cursor: 'd'))
        .thenAnswer((_) async => const Page(items: []));
    when(() => api.task('k-1'))
        .thenAnswer((_) async => const Task(id: 'i', ref: 'k-1', title: 't'));
    expect((await repo.projects(cursor: 'c')).items.single.key, 'k');
    expect((await repo.tasks('k', cursor: 'd')).items, isEmpty);
    expect((await repo.task('k-1')).title, 't');
  });

  test('an actor is fetched once', () async {
    when(() => api.actor('a'))
        .thenAnswer((_) async => const Actor(id: 'a', handle: 'raj'));
    await repo.actor('a');
    await repo.actor('a');
    verify(() => api.actor('a')).called(1);
  });

  test('a failed actor lookup is tried again next time', () async {
    var calls = 0;
    when(() => api.actor('a')).thenAnswer((_) async {
      if (calls++ == 0) throw const TixException(TixErrorKind.network);
      return const Actor(id: 'a');
    });
    await expectLater(repo.actor('a'), throwsA(isA<TixException>()));
    expect((await repo.actor('a')).id, 'a');
  });

  test('quickAdd asks the server to parse the line in the project', () async {
    when(() => api.createTask(any())).thenAnswer(
      (_) async => const Task(id: 'i', ref: 'web-3', title: 'Fix login'),
    );
    await repo.quickAdd('web', 'Fix login !high');
    final sent =
        verify(() => api.createTask(captureAny())).captured.single
            as CreateTaskRequest;
    expect(sent.title, 'Fix login !high');
    expect(sent.projectRef, 'web');
    expect(sent.parse, isTrue);
  });
}
