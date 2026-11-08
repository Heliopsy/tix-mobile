// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/platform/app_shortcuts.dart';
import 'package:tix_mobile/src/core/platform/share_intake.dart';
import 'package:tix_mobile/src/features/quick/presentation/quick_actions_host.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_tix.dart';

class _NoShortcuts implements AppShortcuts {
  @override
  Future<void> install(
    List<AppShortcut> items,
    void Function(String type) onPick,
  ) async {}
}

void main() {
  const channel = MethodChannel('tix/share-invite-test');

  testWidgets('a shared invite link goes to the invite, not quick add', (
    tester,
  ) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          channel,
          (call) async => {
            'text': 'https://tix.example/invite/tix_inv_abc',
            'subject': 'You are invited',
          },
        );
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );
    final stores = signedInStores();
    await pumpScreen(
      tester,
      const QuickActionsHost(
        child: TixShortcuts(child: Scaffold(body: Text('home'))),
      ),
      overrides: [
        ...fakeOverrides(
          FakeTix(),
          settings: stores.settings,
          secrets: stores.secrets,
        ),
        appShortcutsProvider.overrideWithValue(_NoShortcuts()),
        shareIntakeProvider.overrideWithValue(ShareIntake(channel)),
      ],
      settle: false,
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('quickAdd.line')), findsNothing);
    expect(find.textContaining('route:/connect?invite='), findsOneWidget);
  });
}
