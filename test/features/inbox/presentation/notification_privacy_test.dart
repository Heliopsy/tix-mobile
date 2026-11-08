// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/features/inbox/presentation/notification_settings_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_notes.dart';
import '../../../helpers/fake_tix.dart';
import '../../../helpers/stores.dart';

void main() {
  late MemoryKeyValueStore settings;

  Future<void> pump(WidgetTester tester, {Size size = phone}) {
    final stores = signedInStores();
    settings = stores.settings;
    return pumpScreen(
      tester,
      const NotificationSettingsScreen(),
      size: size,
      overrides: fakeOverrides(
        FakeTix(),
        settings: stores.settings,
        secrets: stores.secrets,
        notes: FakeNotes(),
      ),
    );
  }

  TixSwitchRow row(WidgetTester tester) =>
      tester.widget<TixSwitchRow>(find.byKey(const Key('notif.hideContent')));

  for (final MapEntry(key: width, value: size) in widths.entries) {
    testWidgets('$width: hiding content is off and waits for notifications', (
      tester,
    ) async {
      await pump(tester, size: size);
      expect(row(tester).value, isFalse);
      expect(row(tester).onChanged, isNull);
      await tester.tap(find.byKey(const Key('notif.enabled')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('notif.hideContent')));
      await tester.pumpAndSettle();
      expect(row(tester).value, isTrue);
      expect(
        settings.values.entries
            .where((e) => e.key.startsWith('notif.private.'))
            .map((e) => e.value),
        ['true'],
      );
    });
  }
}
