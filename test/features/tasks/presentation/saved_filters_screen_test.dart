// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/platform/deep_links.dart';
import 'package:tix_mobile/src/core/platform/pinned_shortcuts.dart';
import 'package:tix_mobile/src/features/tasks/presentation/saved_filters_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_pins.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;

  setUp(() => server = FakeTix());

  Future<void> pump(
    WidgetTester tester, {
    Size size = phone,
    FakePins? pins,
  }) async {
    final stores = signedInStores();
    await pumpScreen(
      tester,
      const SavedFiltersScreen(),
      size: size,
      overrides: [
        ...fakeOverrides(
          server,
          settings: stores.settings,
          secrets: stores.secrets,
        ),
        if (pins != null) pinnedShortcutsProvider.overrideWithValue(pins),
      ],
    );
  }

  Map<String, Object?> filter(
    String id,
    String name, {
    bool mine = true,
    bool shared = false,
    String view = '',
  }) => {
    'id': id,
    'name': name,
    'query': 'status:todo',
    'view': view,
    'mine': mine,
    'editable': mine,
    'shared': shared,
  };

  for (final MapEntry(key: width, value: size) in widths.entries) {
    testWidgets('$width: empty says where filters come from', (tester) async {
      await pump(tester, size: size);
      expect(find.text('No saved filters'), findsOneWidget);
      await tester.tap(find.text('Go to Tasks'));
      await tester.pumpAndSettle();
      expect(find.text('route:/tasks'), findsOneWidget);
    });
  }

  List<Object?> sentOrder() => [
    for (final r in server.requestsTo('/api/v1/filters/order'))
      r.body['filters'],
  ];

  Finder tileOf(String id) => find.byKey(Key('savedFilter.$id'));

  for (final MapEntry(key: width, value: size) in widths.entries) {
    group(width, () {
      testWidgets('dragging an own filter to the top stores the order', (
        tester,
      ) async {
        server.filters.addAll([
          filter('a', 'Alpha'),
          filter('b', 'Bravo'),
          filter('c', 'Charlie'),
          filter('s', 'Team', mine: false, shared: true),
        ]);
        await pump(tester, size: size);
        expect(find.textContaining('Drag your filters'), findsOneWidget);
        expect(find.byKey(const Key('savedFilter.drag.s')), findsNothing);
        final handle = find.byKey(const Key('savedFilter.drag.c'));
        final gesture = await tester.startGesture(tester.getCenter(handle));
        await tester.pump();
        final distance =
            tester.getTopLeft(tileOf('a')).dy - tester.getCenter(handle).dy;
        for (var i = 0; i < 10; i++) {
          await gesture.moveBy(Offset(0, distance / 10 - 2));
          await tester.pump(const Duration(milliseconds: 50));
        }
        await gesture.up();
        await tester.pumpAndSettle();
        expect(sentOrder(), [
          ['c', 'a', 'b'],
        ]);
        expect(
          tester.getTopLeft(tileOf('c')).dy,
          lessThan(tester.getTopLeft(tileOf('a')).dy),
        );
        expect(
          tester.getTopLeft(tileOf('s')).dy,
          greaterThan(tester.getTopLeft(tileOf('b')).dy),
        );
      });

      testWidgets('the menu moves a filter only where it has a neighbour', (
        tester,
      ) async {
        server.filters.addAll([filter('a', 'Alpha'), filter('b', 'Bravo')]);
        await pump(tester, size: size);
        await tester.tap(find.text('Alpha'));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('saved.earlier')), findsNothing);
        await tester.tap(find.byKey(const Key('saved.later')));
        await tester.pumpAndSettle();
        expect(sentOrder(), [
          ['b', 'a'],
        ]);
        await tester.tap(find.text('Alpha'));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('saved.later')), findsNothing);
        expect(find.byKey(const Key('saved.earlier')), findsOneWidget);
      });
    });
  }

  testWidgets('a single own filter has no handle and no drag help', (
    tester,
  ) async {
    server.filters.add(filter('a', 'Alpha'));
    await pump(tester);
    expect(find.byKey(const Key('savedFilter.drag.a')), findsNothing);
    expect(find.textContaining('Drag your filters'), findsNothing);
    await tester.tap(find.text('Alpha'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('saved.earlier')), findsNothing);
    expect(find.byKey(const Key('saved.later')), findsNothing);
  });

  testWidgets('a refused drag says so and keeps the server order', (
    tester,
  ) async {
    server.filters.addAll([filter('a', 'Alpha'), filter('b', 'Bravo')]);
    server.failing['/api/v1/filters/order'] = FakeResponse(
      400,
      envelope('invalid', 'not yours'),
    );
    await pump(tester);
    await tester.tap(find.text('Bravo'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('saved.earlier')));
    await tester.pumpAndSettle();
    expect(find.textContaining('not yours'), findsOneWidget);
    expect(
      tester.getTopLeft(tileOf('a')).dy,
      lessThan(tester.getTopLeft(tileOf('b')).dy),
    );
  });

  testWidgets('a row names the view its filter opens in', (tester) async {
    server.filters.addAll([
      filter('a', 'Alpha', view: 'lanes'),
      filter('b', 'Bravo'),
    ]);
    await pump(tester);
    expect(
      find.descendant(
        of: tileOf('a'),
        matching: find.textContaining('View: Lanes'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: tileOf('b'), matching: find.textContaining('View:')),
      findsNothing,
    );
  });

  testWidgets('lists own and shared filters; only own ones open a menu', (
    tester,
  ) async {
    server.filters.addAll([
      filter('f1', 'Mine'),
      filter('f2', 'Team', mine: false, shared: true),
    ]);
    await pump(tester);
    expect(find.text('Mine'), findsOneWidget);
    expect(find.text('Shared'), findsOneWidget);
    expect(find.textContaining('only its owner'), findsOneWidget);
    await tester.tap(find.text('Team'));
    await tester.pumpAndSettle();
    expect(find.text('Rename'), findsNothing);
    await tester.tap(find.text('Mine'));
    await tester.pumpAndSettle();
    expect(find.text('Rename'), findsOneWidget);
  });

  testWidgets('where the launcher pins, any filter goes on the home screen', (
    tester,
  ) async {
    server.filters.add(filter('f2', 'Team', mine: false, shared: true));
    final pins = FakePins();
    await pump(tester, pins: pins);
    await tester.tap(find.text('Team'));
    await tester.pumpAndSettle();
    expect(find.text('Rename'), findsNothing);
    await tester.tap(find.byKey(const Key('saved.pin')));
    await tester.pumpAndSettle();
    final shortcut = pins.pinned.single;
    expect(shortcut.label, 'Team');
    final link = parseTixLink(shortcut.link)!;
    expect(link.route, '/tasks?filter=f2');
    expect(link.context, startsWith('c1.'));
    expect(shortcut.id, 'pin.${link.context}.filter.f2');
  });

  testWidgets('says so when the launcher could not be asked', (tester) async {
    server.filters.add(filter('f1', 'Mine'));
    await pump(tester, pins: FakePins(agrees: false));
    await tester.tap(find.text('Mine'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('saved.pin')));
    await tester.pumpAndSettle();
    expect(find.text("Couldn't add it to the home screen"), findsOneWidget);
  });

  testWidgets('no Add to home screen where pinning is not supported', (
    tester,
  ) async {
    server.filters.add(filter('f1', 'Mine'));
    await pump(tester, pins: FakePins(canPin: false));
    await tester.tap(find.text('Mine'));
    await tester.pumpAndSettle();
    expect(find.text('Rename'), findsOneWidget);
    expect(find.byKey(const Key('saved.pin')), findsNothing);
  });

  testWidgets('deletes a filter after asking', (tester) async {
    server.filters.add(filter('f1', 'Mine'));
    await pump(tester);
    await tester.tap(find.text('Mine'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('saved.delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm.ok')));
    await tester.pumpAndSettle();
    expect(server.filters, isEmpty);
    expect(find.text('No saved filters'), findsOneWidget);
  });

  testWidgets('a failure offers retry', (tester) async {
    server.failing['/api/v1/filters'] = FakeResponse(
      500,
      envelope('internal', 'down'),
    );
    await pump(tester);
    expect(find.text('Retry'), findsOneWidget);
  });
}
