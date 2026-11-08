// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';

import '../../../helpers/app.dart';
import '../../../helpers/design.dart';

void main() {
  const body = '''
Intro with [a link](https://example.com) and [a script](javascript:alert(1)).

- [x] first
- [ ] second
  - [ ] nested

```
- [ ] not an item
```

![chart](https://example.com/chart.png)
''';

  Finder box(int item) => find.descendant(
    of: find.byKey(ValueKey('checklist.$item')),
    matching: find.byType(Checkbox),
  );

  testWidgets('each checklist item is a tick reporting its number', (
    tester,
  ) async {
    final toggled = <(int, bool)>[];
    await pumpComponent(
      tester,
      SingleChildScrollView(
        child: TixMarkdown(
          data: body,
          onToggle: (item, {required done}) => toggled.add((item, done)),
        ),
      ),
    );
    expect(box(1), findsOneWidget);
    expect(box(3), findsOneWidget);
    expect(box(4), findsNothing);
    expect(tester.widget<Checkbox>(box(1)).value, isTrue);
    expect(tester.widget<Checkbox>(box(2)).value, isFalse);
    await tester.tap(box(3));
    await tester.tap(box(1));
    expect(toggled, [(3, true), (1, false)]);
    expect(tester.getSize(box(2)).height, greaterThanOrEqualTo(48));
  });

  testWidgets('without a callback the ticks are read-only', (tester) async {
    await pumpComponent(tester, const TixMarkdown(data: '- [ ] one'));
    expect(tester.widget<Checkbox>(box(1)).onChanged, isNull);
  });

  testWidgets('an image is a link, never loaded', (tester) async {
    final opened = <Uri>[];
    await pumpComponent(
      tester,
      SingleChildScrollView(
        child: TixMarkdown(data: body, onLink: opened.add),
      ),
    );
    expect(find.byType(Image), findsNothing);
    await tester.tap(find.textContaining('chart'));
    expect(opened, [Uri.parse('https://example.com/chart.png')]);
  });

  testWidgets('only http, https and mailto links open', (tester) async {
    final opened = <Uri>[];
    await pumpComponent(tester, TixMarkdown(data: body, onLink: opened.add));
    final markdown = tester
        .widgetList<MarkdownBody>(find.byType(MarkdownBody))
        .first;
    markdown.onTapLink!('a link', 'https://example.com', '');
    markdown.onTapLink!('a script', 'javascript:alert(1)', '');
    markdown.onTapLink!('mail', 'mailto:ops@example.com', '');
    expect(opened, [
      Uri.parse('https://example.com'),
      Uri.parse('mailto:ops@example.com'),
    ]);
  });

  for (final locale in textLocales) {
    for (final MapEntry(key: width, value: size) in widths.entries) {
      testWidgets('$width, $locale: survives twice the text size', (
        tester,
      ) async {
        await pumpComponent(
          tester,
          SingleChildScrollView(
            child: TixMarkdown(data: body, onToggle: (_, {required done}) {}),
          ),
          size: size,
          textScale: 2,
          locale: locale,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }
}
