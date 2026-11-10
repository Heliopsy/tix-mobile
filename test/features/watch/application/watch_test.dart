// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/data/events/tix_event.dart';
import 'package:tix_mobile/src/features/watch/application/watch.dart';

void main() {
  TixEvent by(String actorId, [String handle = '']) => TixEvent(
    seq: 1,
    type: 'task.created',
    actorId: actorId,
    payload: {if (handle.isNotEmpty) 'actor_handle': handle},
  );

  test('the actor filter matches the id or the handle', () {
    const q = WatchQuery(actors: ['@Pax', '01ANA']);
    expect(q.keeps(by('01PAX', 'pax')), isTrue);
    expect(q.keeps(by('01ANA')), isTrue);
    expect(q.keeps(by('01BOB', 'bob')), isFalse);
    expect(const WatchQuery().keeps(by('01BOB')), isTrue);
  });

  test('the subscription leaves the actor out', () {
    const a = WatchQuery(types: ['task.*'], actors: ['pax'], since: 3);
    const b = WatchQuery(types: ['task.*'], actors: ['ana'], since: 3);
    expect(a.subscription, b.subscription);
    expect(a, isNot(b));
    expect(
      a.subscription,
      isNot(const WatchQuery(types: ['task.*']).subscription),
    );
  });

  test('copyWith clears the replay point', () {
    const q = WatchQuery(since: 9);
    expect(q.copyWith(since: () => null).since, isNull);
    expect(q.copyWith(types: const ['task.*']).since, 9);
  });
}
