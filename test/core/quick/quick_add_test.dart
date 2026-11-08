// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/quick/quick_add.dart';

void main() {
  test('a draft waits until taken, once', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    final drafts = c.read(quickAddDraftsProvider.notifier)
      ..open(text: 'Renew cert', project: 'ops');
    final draft = drafts.take()!;
    expect(draft.text, 'Renew cert');
    expect(draft.project, 'ops');
    expect(drafts.take(), isNull);
    expect(c.read(quickAddDraftsProvider), isNull);
  });

  test('a draft is one line', () {
    expect(
      oneLine('  Login fails\n\nhttps://x.test/1 \r\n'),
      'Login fails https://x.test/1',
    );
    expect(oneLine(''), '');
  });

  test('tasks changed ticks', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(tasksChangedProvider.notifier).touch();
    expect(c.read(tasksChangedProvider), 1);
  });
}
