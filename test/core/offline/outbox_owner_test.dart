// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/offline/outbox_owner.dart';

void main() {
  test('owned from the start', () {
    expect(OutboxOwnership.owned().isOwned, isTrue);
  });

  test('pending until taken, and taking twice is harmless', () {
    final o = OutboxOwnership.pending();
    expect(o.isOwned, isFalse);
    o
      ..take()
      ..take();
    expect(o.isOwned, isTrue);
  });

  test('taken after the timeout when nobody answers', () {
    fakeAsync((async) {
      final o = OutboxOwnership.pending();
      async.elapse(const Duration(seconds: 29));
      expect(o.isOwned, isFalse);
      async.elapse(const Duration(seconds: 2));
      expect(o.isOwned, isTrue);
    });
  });
}
