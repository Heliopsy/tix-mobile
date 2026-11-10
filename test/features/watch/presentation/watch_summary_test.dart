// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/data/events/tix_event.dart';
import 'package:tix_mobile/src/features/watch/presentation/watch_summary.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  TixEvent event(
    String type, [
    Map<String, Object?> payload = const {},
    String subjectType = 'task',
  ]) => TixEvent(
    seq: 1,
    type: type,
    subjectType: subjectType,
    subjectId: '01SUBJECT',
    actorId: '01ACTOR',
    payload: payload,
    occurredAt: DateTime.utc(2026, 11, 8, 10),
  );

  test('a transition names both states', () {
    expect(
      watchDetail(
        l10n,
        event('task.transitioned', {'from': 'todo', 'to': 'doing'}),
      ),
      'todo → doing',
    );
  });

  test('a claim names the lease, and the holder only when not the actor', () {
    final mine = event('task.claimed', {
      'actor_handle': 'pax',
      'claimed_by_handle': 'pax',
      'lease_expires_at': '2026-11-08T10:30:00Z',
    });
    expect(watchDetail(l10n, mine), 'lease 30m');
    final forOther = event('task.claimed', {
      'actor_handle': 'ana',
      'claimed_by_handle': 'pax',
      'lease_expires_at': '2026-11-08T11:30:00Z',
    });
    expect(watchDetail(l10n, forOther), 'for pax, lease 1h30m');
  });

  test('releases, expiries and updates read as tix writes them', () {
    expect(
      watchDetail(l10n, event('task.released', {'final_status': 'done'})),
      '→ done',
    );
    expect(
      watchDetail(
        l10n,
        event('task.lease_expired', {
          'previous_holder_handle': 'pax',
          'reverted_to': 'todo',
        }),
      ),
      'held by pax, reverted to todo',
    );
    expect(
      watchDetail(
        l10n,
        event('task.updated', {
          'fields': ['title', 'due_at'],
        }),
      ),
      'changed title, due at',
    );
    expect(
      watchDetail(l10n, event('task.updated', {'restored': true})),
      'restored',
    );
    expect(
      watchDetail(
        l10n,
        event('task.updated', {'removed': true, 'tag': 'auth'}),
      ),
      'tag removed: auth',
    );
  });

  test('otherwise the title, tag or name the payload carries', () {
    expect(
      watchDetail(l10n, event('task.created', {'title': 'Fix login'})),
      'Fix login',
    );
    expect(watchDetail(l10n, event('task.starred')), '');
  });

  test('the subject is the ref, the key, or the id', () {
    expect(watchSubject(event('task.created', {'ref': 'infra-1'})), 'infra-1');
    expect(
      watchSubject(event('project.created', {'key': 'web'}, 'project')),
      'web',
    );
    expect(watchSubject(event('filter.saved')), '01SUBJECT');
  });

  test('the actor is the handle, else the id', () {
    expect(watchActor(event('task.created', {'actor_handle': 'pax'})), '@pax');
    expect(watchActor(event('task.created')), '01ACTOR');
  });

  test('tasks and projects have a route, the rest none', () {
    expect(
      watchRoute(event('comment.added', {'ref': 'infra-12'})),
      '/projects/infra/tasks/infra-12',
    );
    expect(
      watchRoute(event('project.updated', {'key': 'web'}, 'project')),
      '/projects/web',
    );
    expect(watchRoute(event('filter.saved', {'name': 'Mine'})), isNull);
  });
}
