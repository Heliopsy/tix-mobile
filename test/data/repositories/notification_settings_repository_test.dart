// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/data/models/inbox.dart';
import 'package:tix_mobile/src/data/repositories/notification_settings_repository.dart';

import '../../helpers/stores.dart';

void main() {
  test('off until turned on, per context', () async {
    final store = MemoryKeyValueStore();
    final repo = NotificationSettingsRepository(store);
    expect(repo.enabled('a.x'), isFalse);
    await repo.setEnabled('a.x', on: true);
    expect(repo.enabled('a.x'), isTrue);
    expect(repo.enabled('b.x'), isFalse);
    await repo.setEnabled('a.x', on: false);
    expect(store.values, isEmpty);
  });

  test(
    'every kind until some is turned off; unknown names are dropped',
    () async {
      final store = MemoryKeyValueStore();
      final repo = NotificationSettingsRepository(store);
      expect(repo.kinds(), inboxKinds.toSet());
      await repo.setKinds({InboxKind.status, InboxKind.mention});
      expect(store.values['notif.kinds'], 'mention,status');
      store.values['notif.kinds'] = 'mention,reaction';
      expect(repo.kinds(), {InboxKind.mention});
      store.values['notif.kinds'] = '';
      expect(repo.kinds(), isEmpty);
    },
  );

  test('remembers the newest item seen, in UTC', () async {
    final repo = NotificationSettingsRepository(MemoryKeyValueStore());
    expect(repo.seen('a.x'), isNull);
    await repo.setSeen('a.x', DateTime.utc(2026, 11, 1, 9));
    expect(repo.seen('a.x'), DateTime.utc(2026, 11, 1, 9));
    expect(repo.nudgeDismissed(), isFalse);
    await repo.dismissNudge();
    expect(repo.nudgeDismissed(), isTrue);
  });
}
