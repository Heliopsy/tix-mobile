// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/data/offline/merge.dart';
import 'package:tix_mobile/src/data/offline/outbox_entry.dart';

void main() {
  const base = <String, Object?>{
    'title': 'Fix login',
    'priority': 3,
    'body': 'old',
    'tags': ['auth', 'web'],
    'custom_fields': {'team': 'core', 'size': 'S'},
    'due_at': '2026-11-10T09:00:00.000Z',
  };

  group('merge3', () {
    test('sends a change nobody else made', () {
      final r = merge3(
        base: base,
        mine: {'title': 'Fix sign-in'},
        theirs: {...base, 'priority': 1},
      );
      expect(r.send, {'title': 'Fix sign-in'});
      expect(r.conflicts, isEmpty);
    });

    test('drops a change the server already has', () {
      final r = merge3(
        base: base,
        mine: {'priority': 1},
        theirs: {...base, 'priority': 1},
      );
      expect(r.empty, isTrue);
    });

    test('a different value on both sides is a conflict', () {
      final r = merge3(
        base: base,
        mine: {'title': 'Mine', 'priority': 2},
        theirs: {...base, 'title': 'Theirs'},
      );
      expect(r.send, {'priority': 2});
      expect(r.conflicts.single.field, 'title');
      expect(r.conflicts.single.base, 'Fix login');
      expect(r.conflicts.single.mine, 'Mine');
      expect(r.conflicts.single.theirs, 'Theirs');
    });

    test('each custom field merges on its own', () {
      final r = merge3(
        base: base,
        mine: {
          'custom_fields': {'team': 'web', 'size': 'L'},
        },
        theirs: {
          ...base,
          'custom_fields': {'team': 'core', 'size': 'M'},
        },
      );
      expect(r.send, {
        'custom_fields': {'team': 'web'},
      });
      expect(r.conflicts.single.field, 'custom_fields.size');
    });

    test('tags merge as sets and never conflict', () {
      final r = merge3(
        base: base,
        mine: {
          'tags': ['auth', 'urgent'],
        },
        theirs: {
          ...base,
          'tags': ['auth', 'web', 'ops'],
        },
      );
      expect(r.conflicts, isEmpty);
      expect(r.send, {
        'tags': ['auth', 'ops', 'urgent'],
      });
    });

    test('instants compare as instants', () {
      final r = merge3(
        base: base,
        mine: {'due_at': '2026-11-10T10:00:00+01:00'},
        theirs: base,
      );
      expect(r.empty, isTrue);
    });
  });

  group('settle', () {
    final r = merge3(
      base: base,
      mine: {'title': 'Mine', 'priority': 2},
      theirs: {...base, 'title': 'Theirs'},
    );

    test('asking keeps the write waiting', () {
      expect(settle(r, ConflictPolicy.ask), isNull);
    });

    test('keep mine sends my side of the conflict', () {
      expect(settle(r, ConflictPolicy.keepMine), {
        'priority': 2,
        'title': 'Mine',
      });
    });

    test('keep theirs sends only what did not conflict', () {
      expect(settle(r, ConflictPolicy.keepTheirs), {'priority': 2});
    });
  });
}
