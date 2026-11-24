// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/events/events.dart';
import 'package:tix_mobile/src/core/storage/providers.dart';

import '../../helpers/container.dart';
import '../../helpers/stores.dart';

void main() {
  testWidgets('resuming reads the settings again before it fires', (
    tester,
  ) async {
    final disk = <String, String>{};
    final store = CachedKeyValueStore(disk);
    final c = makeContainer([keyValueStoreProvider.overrideWithValue(store)]);
    final seen = <String?>[];
    c.listen(appResumedProvider, (_, _) => seen.add(store.read('k')));
    disk['k'] = 'v';

    tester.binding
      ..handleAppLifecycleStateChanged(AppLifecycleState.hidden)
      ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
      ..handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(seen, ['v']);
  });
}
