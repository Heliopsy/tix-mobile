// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/offline/connectivity.dart';
import 'package:tix_mobile/src/core/offline/outbox.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/data/repositories/task_detail_repository.dart';

import '../../helpers/app.dart';
import '../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;
  late StreamController<NetworkState> network;
  late FakeAsync clock;
  ProviderContainer? container;

  /// Runs [future] to completion on the fake clock.
  T run<T>(Future<T> future) {
    T? value;
    Exception? error;
    var done = false;
    unawaited(
      future.then(
        (v) {
          value = v;
          done = true;
        },
        onError: (Object e) {
          error = e is Exception ? e : Exception('$e');
          done = true;
        },
      ),
    );
    for (var i = 0; i < 1000 && !done; i++) {
      clock.elapse(const Duration(milliseconds: 10));
    }
    if (error != null) throw error!;
    if (!done) fail('never completed');
    return value as T;
  }

  ProviderContainer start() {
    server = FakeTix();
    network = StreamController<NetworkState>.broadcast();
    final stores = signedInStores();
    final c = ProviderContainer(
      overrides: fakeOverrides(
        server,
        settings: stores.settings,
        secrets: stores.secrets,
        networks: network.stream,
        autoSync: true,
      ),
    );
    run(c.read(sessionControllerProvider.future));
    c.listen(outboxSyncProvider, (_, _) {});
    network.add(NetworkState.unmetered);
    clock.flushMicrotasks();
    run(c.read(syncStoreProvider).load());
    return container = c;
  }

  void inFakeTime(void Function() body) => fakeAsync((async) {
    clock = async;
    try {
      body();
    } finally {
      container?.dispose();
      container = null;
      unawaited(network.close());
      async.flushMicrotasks();
    }
  });

  List<String> patches() => [
    for (final r in server.requests)
      if (r.method == 'PATCH' && r.path.contains('/tasks/')) r.path,
  ];

  void goOffline() {
    server.offline = true;
    network.add(NetworkState.offline);
    clock.elapse(const Duration(milliseconds: 10));
  }

  void reconnect() {
    server.offline = false;
    network.add(NetworkState.unmetered);
    clock.elapse(replaySettle + const Duration(seconds: 1));
  }

  test(
    'an edit made offline waits, then replays after reconnect and '
    'merges with a change made meanwhile',
    () => inFakeTime(() {
      final c = start();
      final repo = c.read(taskDetailRepositoryProvider);
      final base = Task.fromJson(server.task('infra-1')!);
      goOffline();

      final shown = run(
        repo.update('infra-1', TaskPatch.title('Fixed offline'), base: base),
      );
      expect(shown.title, 'Fixed offline');
      expect(c.read(syncStoreProvider).now.entries, hasLength(1));

      clock.elapse(const Duration(minutes: 3));
      expect(patches(), isEmpty, reason: 'nothing is sent while offline');

      final t = server.task('infra-1')!;
      t['priority'] = 5;
      t['version'] = (t['version']! as int) + 1;

      reconnect();

      final now = server.task('infra-1')!;
      expect(now['title'], 'Fixed offline');
      expect(now['priority'], 5);
      expect(c.read(syncStoreProvider).now.entries, isEmpty);
      expect(c.read(syncStoreProvider).now.conflicts, isEmpty);
      expect(patches(), hasLength(2), reason: 'a 409, then the merged write');
    }),
  );

  test(
    'the same field changed on the server waits for the person, '
    'who keeps theirs; the history can reverse it',
    () => inFakeTime(() {
      final c = start();
      final repo = c.read(taskDetailRepositoryProvider);
      final base = Task.fromJson(server.task('infra-1')!);
      goOffline();
      run(repo.update('infra-1', TaskPatch.title('Mine'), base: base));
      final t = server.task('infra-1')!;
      t['title'] = 'Theirs';
      t['version'] = (t['version']! as int) + 1;

      reconnect();

      final store = c.read(syncStoreProvider);
      final record = store.now.conflicts.single;
      expect(record.resolution, isNull);
      expect(server.task('infra-1')!['title'], 'Theirs');

      run(
        c
            .read(outboxSyncProvider.notifier)
            .resolve(record.id, Resolution.theirs),
      );
      clock.elapse(const Duration(seconds: 1));
      expect(store.now.entries, isEmpty);
      expect(server.task('infra-1')!['title'], 'Theirs');

      run(c.read(outboxSyncProvider.notifier).reverse(record.id));
      clock.elapse(const Duration(seconds: 1));
      expect(server.task('infra-1')!['title'], 'Mine');
      expect(store.now.conflicts.single.resolution, Resolution.mine);
    }),
  );

  test(
    'the policy is kept per context and settles new conflicts',
    () => inFakeTime(() {
      final c = start();
      expect(c.read(conflictPolicySettingProvider), ConflictPolicy.ask);
      run(
        c
            .read(conflictPolicySettingProvider.notifier)
            .set(ConflictPolicy.keepMine),
      );
      final repo = c.read(taskDetailRepositoryProvider);
      final base = Task.fromJson(server.task('infra-1')!);
      goOffline();
      run(repo.update('infra-1', TaskPatch.title('Mine'), base: base));
      final t = server.task('infra-1')!;
      t['title'] = 'Theirs';
      t['version'] = (t['version']! as int) + 1;

      reconnect();

      expect(server.task('infra-1')!['title'], 'Mine');
      final record = c.read(syncStoreProvider).now.conflicts.single;
      expect((record.resolution, record.auto), (Resolution.mine, true));
    }),
  );

  test(
    'quick add offline makes a draft that replays as a real task',
    () => inFakeTime(() {
      final c = start();
      goOffline();
      final draft = run(
        c.read(tasksRepositoryProvider).quickAdd('infra', 'Spike the cache'),
      );
      expect(draft.ref, 'infra-draft1');
      run(c.read(taskDetailRepositoryProvider).addComment(draft.ref, 'note'));

      reconnect();

      final store = c.read(syncStoreProvider);
      expect(store.now.entries, isEmpty);
      final real = store.now.drafts[draft.ref]!;
      expect(server.task(real)!['title'], 'Spike the cache');
      expect(
        server.requests.where(
          (r) => r.method == 'POST' && r.path.contains('/comments'),
        ),
        hasLength(1),
      );
      expect(
        server.requests.where((r) => r.path.contains('draft')),
        isEmpty,
        reason: 'no request names the draft',
      );
    }),
  );
}
