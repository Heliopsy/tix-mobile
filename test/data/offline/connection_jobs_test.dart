// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/data/offline/connection_jobs.dart';

void main() {
  test('stop cancels the work of that connection and waits for it', () async {
    final jobs = ConnectionJobs();
    final release = Completer<void>();
    final seen = <String>[];
    final work = jobs.run('c1', (job) async {
      await release.future;
      seen.add(job.cancelled ? 'cancelled' : 'ran');
      job.check();
      seen.add('after');
    });
    final other = jobs.run('c2', (job) async => job.cancelled);
    expect(jobs.busy('c1'), isTrue);
    var stopped = false;
    final stop = jobs.stop('c1').then((_) => stopped = true);
    await pumpEventQueue();
    expect(stopped, isFalse, reason: 'it waits for the running job');
    release.complete();
    await expectLater(work, throwsA(isA<JobCancelled>()));
    await stop;
    expect(seen, ['cancelled']);
    expect(await other, isFalse);
    expect(jobs.busy('c1'), isFalse);
  });

  test('a stopped connection refuses new work', () async {
    final jobs = ConnectionJobs();
    await jobs.stop('c1');
    var ran = false;
    await expectLater(
      jobs.run('c1', (_) async => ran = true),
      throwsA(isA<JobCancelled>()),
    );
    expect(ran, isFalse);
  });

  test('stop gives up on work that ignores it after the grace', () async {
    final jobs = ConnectionJobs(grace: const Duration(milliseconds: 10));
    final never = Completer<void>();
    unawaited(jobs.run('c1', (_) => never.future));
    await jobs.stop('c1');
    expect(jobs.busy('c1'), isTrue);
  });
}
