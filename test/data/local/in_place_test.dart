// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/data/local/in_place.dart';

void main() {
  late Directory dir;
  setUp(() async {
    dir = await Directory.systemTemp.createTemp('tix-mobile-in-place-');
  });
  tearDown(() => dir.delete(recursive: true));

  String path(String name) => '${dir.path}${Platform.pathSeparator}$name';

  Matcher refused(InPlaceRefusal why) => throwsA(
    isA<TixException>()
        .having((e) => e.kind, 'kind', TixErrorKind.localNotUsable)
        .having((e) => e.details['reason'], 'reason', why.name),
  );

  test('conflict copies of each sync client are found, nothing else', () {
    expect(
      conflictCopies('team.db', [
        'team.db',
        'team.db-wal',
        'team.db-shm',
        'team (conflicted copy 2026-11-08 101010).db',
        'team.sync-conflict-20261108-101010-ABCDEFG.db',
        'team (1).db',
        'team 2.db',
        'Team-Conflict.db',
        'teamwork.db',
        'other (1).db',
        'notes.txt',
      ]),
      [
        'Team-Conflict.db',
        'team (1).db',
        'team (conflicted copy 2026-11-08 101010).db',
        'team 2.db',
        'team.sync-conflict-20261108-101010-ABCDEFG.db',
      ],
    );
    expect(conflictCopies('team.db', ['team.db', 'teamwork.db']), isEmpty);
    expect(splitPath('/a/b/c.db'), ('/a/b', 'c.db'));
    expect(splitPath('c.db'), ('.', 'c.db'));
  });

  test('findings read the folder: conflicts and a leftover log', () async {
    File(path('team.db')).writeAsStringSync('');
    expect(await syncFindings(path('team.db')), SyncFindings.none);
    File(path('team (1).db')).writeAsStringSync('');
    File(path('team.db-wal')).writeAsStringSync('');
    final found = await syncFindings(path('team.db'));
    expect(found.conflicts, ['team (1).db']);
    expect(found.walLeftOver, isTrue);
    expect(found.isEmpty, isFalse);
    expect(
      found,
      const SyncFindings(conflicts: ['team (1).db'], walLeftOver: true),
    );
    expect(found.hashCode, isNot(SyncFindings.none.hashCode));
    expect(
      await syncFindings('${path('missing')}${Platform.pathSeparator}x.db'),
      SyncFindings.none,
    );
  });

  test('an SQLite file in a writable folder is usable in place', () async {
    final db = File(path('team.db'))
      ..writeAsBytesSync([...'SQLite format 3\u0000'.codeUnits, 1, 2, 3]);
    await probeInPlace(db.path);
    expect(dir.listSync().map((e) => e.path), [db.path]);
  });

  test('an empty file and a new file to create are usable', () async {
    File(path('empty.db')).writeAsStringSync('');
    await probeInPlace(path('empty.db'));
    await probeInPlace(path('new.db'), create: true);
    await expectLater(
      probeInPlace(path('new.db')),
      throwsA(
        isA<TixException>().having(
          (e) => e.kind,
          'kind',
          TixErrorKind.notFound,
        ),
      ),
    );
  });

  test('a placeholder that is not SQLite is refused', () async {
    File(path('team.db')).writeAsStringSync('{"cloud":"placeholder"}');
    await expectLater(
      probeInPlace(path('team.db')),
      refused(InPlaceRefusal.notDatabase),
    );
  });

  test('a folder that takes no new files is refused', () async {
    await expectLater(
      probeInPlace(
        '${path('missing')}${Platform.pathSeparator}team.db',
        create: true,
      ),
      refused(InPlaceRefusal.folderNotWritable),
    );
  });
}
