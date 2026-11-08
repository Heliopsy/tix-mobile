// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/features/shell/presentation/home_shell.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  List<ShellDestination> make(int n) => [
    for (var i = 0; i < n; i++)
      ShellDestination(
        id: 'd$i',
        icon: Icons.circle_outlined,
        selectedIcon: Icons.circle,
        label: 'Place $i',
      ),
  ];

  Future<List<int>> pump(WidgetTester tester, int n) async {
    final picked = <int>[];
    var current = 0;
    await pumpScreen(
      tester,
      Scaffold(
        bottomNavigationBar: StatefulBuilder(
          builder: (context, setState) => ShellBottomBar(
            destinations: make(n),
            currentIndex: current,
            onSelect: (i) => setState(() {
              picked.add(i);
              current = i;
            }),
          ),
        ),
      ),
      overrides: fakeOverrides(FakeTix()),
    );
    return picked;
  }

  testWidgets('five destinations all fit', (tester) async {
    await pump(tester, 5);
    expect(find.byType(NavigationDestination), findsNWidgets(5));
    expect(find.byKey(const Key('nav.more')), findsNothing);
  });

  testWidgets('six show four and More, which lists the other two', (
    tester,
  ) async {
    final picked = await pump(tester, 6);
    expect(find.byType(NavigationDestination), findsNWidgets(5));
    expect(find.byKey(const Key('nav.d4')), findsNothing);
    await tester.tap(find.byKey(const Key('nav.more')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('nav.more.d4')), findsOneWidget);
    expect(find.byKey(const Key('nav.more.d5')), findsOneWidget);
    expect(find.byKey(const Key('nav.more.d3')), findsNothing);
    await tester.tap(find.byKey(const Key('nav.more.d5')));
    await tester.pumpAndSettle();
    expect(picked, [5]);
    final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(bar.selectedIndex, 4);
  });

  testWidgets('the shell lists Manage before Settings', (tester) async {
    final stores = signedInStores();
    await pumpScreen(
      tester,
      Builder(
        builder: (context) => Text(
          [
            for (final d in HomeShell.destinations(
              AppLocalizations.of(context),
            ))
              d.id,
          ].join(','),
        ),
      ),
      overrides: fakeOverrides(
        FakeTix(),
        settings: stores.settings,
        secrets: stores.secrets,
      ),
    );
    expect(find.text('projects,tasks,myWork,manage,settings'), findsOneWidget);
  });
}
