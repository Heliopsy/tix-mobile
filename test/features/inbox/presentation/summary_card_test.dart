// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/features/inbox/application/inbox.dart';
import 'package:tix_mobile/src/features/inbox/presentation/summary_card.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  const stats = ['overdue', 'today', 'open', 'done'];

  Finder stat(String id) => find.byKey(Key('inbox.summary.$id'));

  InboxSummary summaryOf(int n) => InboxSummary(
    byCategory: {StateCategory.todo: n},
    completed: n,
    overdue: n,
    dueToday: n,
  );

  Future<void Function(int)> pump(
    WidgetTester tester, {
    Size size = phone,
    double? width,
    double scale = 1,
  }) async {
    var summary = summaryOf(9);
    final container = await pumpScreen(
      tester,
      Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: Scaffold(
            body: ListView(
              children: [
                Align(
                  alignment: AlignmentDirectional.topStart,
                  child: SizedBox(
                    width: width ?? size.width,
                    child: const InboxSummaryCard(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      size: size,
      overrides: [
        ...fakeOverrides(FakeTix()),
        inboxSummaryProvider.overrideWith((ref) async => summary),
      ],
    );
    void set(int n) {
      summary = summaryOf(n);
      container.invalidate(inboxSummaryProvider);
    }

    return set;
  }

  Map<String, Rect> rects(WidgetTester tester) => {
    for (final id in stats) id: tester.getRect(stat(id)),
  };

  void expectRowsEven(Map<String, Rect> r) {
    for (final a in r.values) {
      for (final b in r.values) {
        if (a.top == b.top) expect(a.height, b.height);
      }
    }
  }

  for (final (name, size, width, scale) in [
    ('phone', phone, null, 1.0),
    ('phone at 200% text', phone, null, 2.0),
    ('narrow phone at 200% text', const Size(320, 640), null, 2.0),
    ('desktop', desktop, null, 1.0),
    ('the inbox side panel', desktop, 320.0, 1.0),
    ('the inbox side panel at 200% text', desktop, 320.0, 2.0),
  ]) {
    testWidgets('$name: a tile keeps its size as the count grows', (
      tester,
    ) async {
      final set = await pump(tester, size: size, width: width, scale: scale);
      final before = rects(tester);
      expectRowsEven(before);
      for (final n in [10, 99, 100, 999, 1000, 123456, 99999999]) {
        set(n);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$n');
        expect(rects(tester), before, reason: '$n');
      }
    });
  }

  testWidgets('four to a row on a phone, all the same width', (tester) async {
    await pump(tester);
    final r = rects(tester);
    expect(r.values.map((e) => e.top).toSet(), hasLength(1));
    expect(r.values.map((e) => e.width).toSet(), hasLength(1));
  });

  testWidgets('two to a row at 200% text', (tester) async {
    await pump(tester, scale: 2);
    final r = rects(tester);
    expect(r.values.map((e) => e.top).toSet(), hasLength(2));
    expect(r.values.map((e) => e.width).toSet(), hasLength(1));
  });

  testWidgets('counts use tabular figures and abbreviate past 999', (
    tester,
  ) async {
    final set = await pump(tester);
    Text number() => tester.widget<Text>(
      find.descendant(of: stat('overdue'), matching: find.byType(Text)).first,
    );
    expect(number().data, '9');
    expect(
      number().style!.fontFeatures,
      contains(const FontFeature.tabularFigures()),
    );
    set(999);
    await tester.pumpAndSettle();
    expect(number().data, '999');
    set(1234);
    await tester.pumpAndSettle();
    expect(number().data, '1.23K');
    final semantics = tester.widget<Semantics>(
      find.descendant(of: stat('overdue'), matching: find.byType(Semantics)),
    );
    expect(semantics.properties.label, endsWith('1,234'));
  });
}
