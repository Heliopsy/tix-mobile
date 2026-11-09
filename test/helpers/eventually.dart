// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';

/// Waits until [done] holds, checking every 10 ms, and fails the test when
/// it still does not after [timeout]. Use it instead of a fixed delay, which
/// passes or fails with the load on the machine.
Future<void> eventually(
  bool Function() done, {
  Duration timeout = const Duration(seconds: 5),
  String reason = 'condition',
}) async {
  final deadline = DateTime.now().add(timeout);
  while (!done()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('$reason not met within ${timeout.inMilliseconds} ms');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}
