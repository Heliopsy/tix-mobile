// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/platform/adb_commands.dart';
import 'package:tix_mobile/src/core/platform/adb_snapshot.dart';

void main() {
  const snapshot = AdbSnapshot(
    version: '0.8.0',
    build: '8',
    theme: 'oled',
    locale: 'bg',
    control: true,
    contexts: [
      AdbContextLine(
        id: 's1.acme',
        instance: 'Work',
        host: 'tix.example',
        tenant: 'Acme',
        signIn: true,
        active: true,
      ),
      AdbContextLine(id: 'l1.', instance: 'Laptop', database: 'tix.db'),
    ],
    liveMode: 'polling',
    liveReport:
        'Server: https://tix.example\n'
        'Last error: refused, Authorization: Bearer sekrit-bearer-value\n'
        'GET https://tix.example/api/v1/events/poll?since_seq=4&token=abc',
    outbox: [
      AdbOutboxLine(id: 's1.acme', pending: 2, conflict: 1, openConflicts: 1),
    ],
    engines: [
      AdbEngineLine(instance: 'Laptop', state: 'resting', database: 'tix.db'),
    ],
  );

  test('all prints every section under the app line', () {
    final text = formatAdbSnapshot(snapshot, AdbSection.all);
    expect(
      text,
      startsWith('tix-mobile 0.8.0 (8), release build, app engine\n'),
    );
    expect(text, contains('Theme: oled\nLanguage: bg\nADB control: on'));
    for (final heading in [
      '[contexts]',
      '[connection]',
      '[outbox]',
      '[engine]',
    ]) {
      expect(text, contains(heading));
    }
    expect(text, contains('Active: Work (tix.example) · Acme [s1.acme]'));
    expect(text, contains('  * s1.acme  Work (tix.example) · Acme, sign-in'));
    expect(text, contains('    l1.  Laptop (local tix.db), token'));
    expect(text, contains('Live: polling'));
    expect(
      text,
      contains(
        's1.acme: 2 pending, 0 refused, 1 in conflict, 0 to check; '
        '1 open conflicts',
      ),
    );
    expect(text, contains('The active context is not a local instance.'));
    expect(text, contains('  Laptop: resting (tix.db)'));
  });

  test('a section prints only itself under the app line', () {
    final text = formatAdbSnapshot(snapshot, AdbSection.outbox);
    expect(text, contains('tix-mobile 0.8.0 (8)'));
    expect(text, contains('[outbox]'));
    expect(text, isNot(contains('[contexts]')));
    expect(text, isNot(contains('[connection]')));
    expect(text, isNot(contains('[engine]')));
  });

  test('no credential, cookie or query reaches the report', () {
    final text = formatAdbSnapshot(
      snapshot,
      AdbSection.all,
      secrets: ['sekrit-bearer-value'],
    );
    expect(text, isNot(contains('sekrit-bearer-value')));
    expect(text, isNot(contains('token=abc')));
    expect(text, isNot(contains('since_seq=4')));
    expect(text, contains('Server: https://tix.example'));
  });

  test('a secret held anywhere is redacted', () {
    const leaky = AdbSnapshot(
      version: '0.8.0',
      contexts: [
        AdbContextLine(
          id: 'c1.',
          instance: 'tok-0123456789abcdef',
          active: true,
        ),
      ],
    );
    final text = formatAdbSnapshot(
      leaky,
      AdbSection.contexts,
      secrets: ['tok-0123456789abcdef'],
    );
    expect(text, isNot(contains('tok-0123456789abcdef')));
  });

  test('a headless engine says what it cannot see', () {
    const headless = AdbSnapshot(
      version: '0.8.0',
      headless: true,
      contexts: [
        AdbContextLine(
          id: 'l1.',
          instance: 'Laptop',
          database: 'tix.db',
          active: true,
        ),
      ],
    );
    final text = formatAdbSnapshot(headless, AdbSection.all);
    expect(text, contains('background engine: the app is not open'));
    expect(text, contains('Live updates run only while the app is open.'));
    expect(text, contains('Active local instance: Laptop (tix.db)'));
    expect(text, contains('a background engine never starts one'));
    expect(text, contains('Nothing waiting.'));
  });

  test('with nothing saved it says so', () {
    final text = formatAdbSnapshot(
      const AdbSnapshot(version: '0.8.0'),
      AdbSection.all,
    );
    expect(text, contains('Active: none'));
    expect(text, contains('No saved contexts.'));
    expect(text, contains('No live connection: no context is active.'));
    expect(text, contains('No engine has run since the app started.'));
  });

  test('baseName keeps only the file name', () {
    expect(baseName('/data/user/0/red.tix/files/tix.db'), 'tix.db');
    expect(baseName(r'C:\Users\ana\tix.db'), 'tix.db');
    expect(baseName('tix.db'), 'tix.db');
  });
}
