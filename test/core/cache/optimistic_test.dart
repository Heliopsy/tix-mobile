// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/cache/optimistic.dart';

void main() {
  late List<String>? state;
  late List<String> sent;

  OptimisticChange<List<String>> change({bool undoable = true}) =>
      OptimisticChange(
        read: () => state,
        write: (s) => state = s,
        change: (s) => [...s, 'b'],
        send: () async => sent.add('star'),
        reverse: undoable ? () async => sent.add('unstar') : null,
      );

  setUp(() {
    state = ['a'];
    sent = [];
  });

  test('apply shows the change and rollback restores it', () async {
    final c = change()..apply();
    expect(state, ['a', 'b']);
    expect(sent, isEmpty, reason: 'nothing is sent before commit');
    await c.commit();
    expect(sent, ['star']);
    c.rollback();
    expect(state, ['a']);
    await c.undo!();
    expect(sent, ['star', 'unstar']);
  });

  test('nothing loaded means nothing to change or restore', () {
    state = null;
    final c = change()
      ..apply()
      ..rollback();
    expect(state, isNull);
    expect(c.before, isNull);
  });

  test('without a reverse there is no undo', () {
    expect(change(undoable: false).undo, isNull);
  });
}
