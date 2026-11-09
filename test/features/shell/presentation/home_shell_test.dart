// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/router/router.dart';
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

  Future<List<int>> pump(
    WidgetTester tester,
    int n, {
    bool about = false,
  }) async {
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
            onAbout: about ? () => context.go(Routes.about) : null,
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

  testWidgets('More ends with About, which opens the About screen', (
    tester,
  ) async {
    final picked = await pump(tester, 6, about: true);
    await tester.tap(find.byKey(const Key('nav.more')));
    await tester.pumpAndSettle();
    final about = find.byKey(const Key('nav.more.about'));
    expect(
      find.descendant(of: about, matching: find.text('About')),
      findsOneWidget,
    );
    expect(
      tester.getTopLeft(about).dy,
      greaterThan(tester.getTopLeft(find.byKey(const Key('nav.more.d5'))).dy),
    );
    await tester.tap(about);
    await tester.pumpAndSettle();
    expect(find.text('route:/settings/about'), findsOneWidget);
    expect(picked, isEmpty);
  });

  testWidgets('with About, More is there even when the rest fit', (
    tester,
  ) async {
    await pump(tester, 5, about: true);
    expect(find.byType(NavigationDestination), findsNWidgets(5));
    await tester.tap(find.byKey(const Key('nav.more')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('nav.more.d4')), findsOneWidget);
    expect(find.byKey(const Key('nav.more.about')), findsOneWidget);
  });

  testWidgets('three destinations and About: all three, then More', (
    tester,
  ) async {
    await pump(tester, 3, about: true);
    expect(find.byType(NavigationDestination), findsNWidgets(4));
    expect(find.byKey(const Key('nav.more')), findsOneWidget);
  });

  for (final (name, extended) in [('icon', false), ('labelled', true)]) {
    testWidgets("the rail's $name About button opens About", (tester) async {
      await pumpScreen(
        tester,
        Scaffold(
          body: Center(child: ShellAboutButton(extended: extended)),
        ),
        size: desktop,
        overrides: fakeOverrides(FakeTix()),
      );
      if (extended) {
        expect(find.text('About'), findsOneWidget);
      } else {
        expect(find.byTooltip('About'), findsOneWidget);
      }
      await tester.tap(find.byKey(const Key('shell.about')));
      await tester.pumpAndSettle();
      expect(find.text('route:/settings/about'), findsOneWidget);
    });
  }

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
    expect(
      find.text('projects,tasks,myWork,inbox,manage,settings'),
      findsOneWidget,
    );
  });

  testWidgets('a decorated destination keeps its badge on the bar or on More', (
    tester,
  ) async {
    final all = make(6);
    Widget decorate(ShellDestination d, Widget icon) =>
        d.id == 'd2' || d.id == 'd5'
        ? Badge(key: Key('badge.${d.id}'), child: icon)
        : icon;
    await pumpScreen(
      tester,
      Scaffold(
        bottomNavigationBar: ShellBottomBar(
          destinations: all,
          currentIndex: 0,
          onSelect: (_) {},
          decorate: decorate,
        ),
      ),
      overrides: fakeOverrides(FakeTix()),
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('nav.d2')),
        matching: find.byKey(const Key('badge.d2')),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('nav.more')),
        matching: find.byKey(const Key('badge.d5')),
      ),
      findsOneWidget,
    );
  });
}
