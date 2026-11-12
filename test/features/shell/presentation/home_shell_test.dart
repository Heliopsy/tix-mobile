// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/gestures.dart'
    show kDoubleTapMinTime, kDoubleTapTimeout;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/router/router.dart';
import 'package:tix_mobile/src/features/shell/presentation/home_shell.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_tix.dart';
import '../../../helpers/stores.dart';

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

  testWidgets("the shell lists its destinations in tix web's order", (
    tester,
  ) async {
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
      find.text('inbox,myWork,tasks,projects,activity,manage,settings'),
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

  group('the wide frame', () {
    late MemoryKeyValueStore settings;

    setUp(() => settings = MemoryKeyValueStore());

    Future<void> frame(WidgetTester tester, {Size size = desktop}) async {
      await pumpScreen(
        tester,
        TixShortcuts(
          child: WideShellFrame(
            rail: (context, {required extended, required width}) => Column(
              key: Key(extended ? 'rail.extended' : 'rail.collapsed'),
              children: const [SidebarToggle()],
            ),
            child: const Text('screens'),
          ),
        ),
        size: size,
        overrides: fakeOverrides(FakeTix(), settings: settings),
      );
    }

    final sidebar = find.byKey(const Key('shell.sidebar'));
    final handle = find.byKey(const Key('shell.sidebar.resize'));
    final toggle = find.byKey(const Key('shell.sidebar.toggle'));
    double width(WidgetTester tester) => tester.getSize(sidebar).width;

    testWidgets('drags wider and keeps the width', (tester) async {
      await frame(tester);
      expect(width(tester), 256);
      await tester.drag(handle, const Offset(100, 0));
      await tester.pump(kDoubleTapTimeout);
      await tester.pumpAndSettle();
      expect(width(tester), 356);
      expect(settings.values['layout.sidebar.width'], '356');
      expect(settings.values['layout.sidebar.collapsed'], '0');
    });

    testWidgets('a drag past the minimum collapses it to the rail', (
      tester,
    ) async {
      await frame(tester);
      await tester.drag(handle, const Offset(-200, 0));
      await tester.pump(kDoubleTapTimeout);
      await tester.pumpAndSettle();
      expect(sidebar, findsNothing);
      expect(find.byKey(const Key('rail.collapsed')), findsOneWidget);
      expect(settings.values['layout.sidebar.collapsed'], '1');
    });

    testWidgets('a double click restores the default width', (tester) async {
      settings.values['layout.sidebar.width'] = '400';
      await frame(tester);
      expect(width(tester), 400);
      await tester.tap(handle);
      await tester.pump(kDoubleTapMinTime);
      await tester.tap(handle);
      await tester.pumpAndSettle();
      expect(width(tester), 256);
      expect(settings.values.containsKey('layout.sidebar.width'), isFalse);
    });

    testWidgets('the toggle collapses and expands, and says which', (
      tester,
    ) async {
      await frame(tester);
      expect(find.byTooltip('Collapse sidebar'), findsOneWidget);
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('rail.collapsed')), findsOneWidget);
      expect(find.byTooltip('Expand sidebar'), findsOneWidget);
      expect(settings.values['layout.sidebar.collapsed'], '1');
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('rail.extended')), findsOneWidget);
      expect(settings.values['layout.sidebar.collapsed'], '0');
    });

    testWidgets('the palette collapses it too', (tester) async {
      await frame(tester);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('palette.query')),
        'collapse sidebar',
      );
      await tester.pump();
      await tester.tap(find.byKey(const Key('palette.shell.sidebar')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('rail.collapsed')), findsOneWidget);
    });

    testWidgets('the keyboard resizes, collapses and expands it', (
      tester,
    ) async {
      await frame(tester);
      Focus.of(
        tester.element(
          find.descendant(of: handle, matching: find.byType(MouseRegion)),
        ),
      ).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(width(tester), 272);
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pumpAndSettle();
      expect(width(tester), 180);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pumpAndSettle();
      expect(sidebar, findsNothing);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      expect(width(tester), 180);
      expect(settings.values['layout.sidebar.width'], '180');
    });

    testWidgets('a restart restores what was kept', (tester) async {
      settings.values
        ..['layout.sidebar.width'] = '300'
        ..['layout.sidebar.collapsed'] = '1';
      await frame(tester);
      expect(find.byKey(const Key('rail.collapsed')), findsOneWidget);
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(width(tester), 300);
    });

    testWidgets('untouched, it is a rail under 1200 wide', (tester) async {
      await frame(tester, size: const Size(900, 800));
      expect(find.byKey(const Key('rail.collapsed')), findsOneWidget);
    });

    testWidgets('a kept width never takes more than half the window', (
      tester,
    ) async {
      settings.values
        ..['layout.sidebar.width'] = '480'
        ..['layout.sidebar.collapsed'] = '0';
      await frame(tester, size: const Size(700, 800));
      expect(width(tester), 350);
      expect(settings.values['layout.sidebar.width'], '480');
    });
  });
}
