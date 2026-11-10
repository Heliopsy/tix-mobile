// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/features/shell/presentation/watch_shortcut.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  Future<void> pump(WidgetTester tester, List<String> scopes) {
    final server = FakeTix()..identity = {'scopes': scopes};
    final stores = signedInStores();
    return pumpScreen(
      tester,
      const Scaffold(body: Center(child: WatchShortcutButton())),
      overrides: fakeOverrides(
        server,
        settings: stores.settings,
        secrets: stores.secrets,
      ),
    );
  }

  testWidgets('with event:subscribe it opens Watch', (tester) async {
    await pump(tester, ['event:subscribe']);
    await tester.tap(find.byKey(const Key('shell.watch')));
    await tester.pumpAndSettle();
    expect(find.text('route:/manage/watch'), findsOneWidget);
  });

  testWidgets('it says what it opens', (tester) async {
    await pump(tester, ['*']);
    expect(find.byTooltip('Watch live events'), findsOneWidget);
  });

  testWidgets('without event:subscribe there is no button', (tester) async {
    await pump(tester, ['task:read', 'audit:read']);
    expect(find.byKey(const Key('shell.watch')), findsNothing);
  });
}
