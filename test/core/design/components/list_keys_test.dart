// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';

import '../../../helpers/app.dart';
import '../../../helpers/design.dart';

void main() {
  late List<String> opened;

  Future<void> pump(WidgetTester tester, KeymapPreset preset) async {
    opened = [];
    final container = await pumpComponent(
      tester,
      TixShortcuts(
        child: TixPage(
          title: 'Rows',
          body: ListView(
            children: [
              const Padding(
                padding: EdgeInsets.all(8),
                child: TextField(key: Key('search')),
              ),
              for (var i = 0; i < 4; i++)
                ListTile(
                  key: Key('row$i'),
                  title: Text('Row $i'),
                  onTap: () => opened.add('row$i'),
                ),
            ],
          ),
        ),
      ),
      size: desktop,
    );
    await container.read(keyboardSettingProvider.notifier).setPreset(preset);
    await tester.pumpAndSettle();
  }

  Future<void> press(WidgetTester tester, LogicalKeyboardKey key) async {
    await tester.sendKeyEvent(key);
    await tester.pump();
  }

  Future<void> ctrl(WidgetTester tester, LogicalKeyboardKey key) async {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(key);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();
  }

  bool focusedIn(WidgetTester tester, String key) {
    final focus = FocusManager.instance.primaryFocus?.context;
    if (focus == null) return false;
    return find
        .ancestor(
          of: find.byWidget(focus.widget),
          matching: find.byKey(Key(key)),
        )
        .evaluate()
        .isNotEmpty;
  }

  testWidgets('Vim: j and k move focus over the rows and Enter opens', (
    tester,
  ) async {
    await pump(tester, KeymapPreset.vim);
    await press(tester, LogicalKeyboardKey.keyJ);
    expect(focusedIn(tester, 'row0'), isTrue, reason: 'skips the field');
    await press(tester, LogicalKeyboardKey.keyJ);
    await press(tester, LogicalKeyboardKey.keyJ);
    expect(focusedIn(tester, 'row2'), isTrue);
    await press(tester, LogicalKeyboardKey.keyK);
    expect(focusedIn(tester, 'row1'), isTrue);
    await press(tester, LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(opened, ['row1']);
  });

  testWidgets('Vim: G and gg jump to the ends, l opens', (tester) async {
    await pump(tester, KeymapPreset.vim);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyG);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pumpAndSettle();
    expect(focusedIn(tester, 'row3'), isTrue);
    await press(tester, LogicalKeyboardKey.keyG);
    await press(tester, LogicalKeyboardKey.keyG);
    await tester.pumpAndSettle();
    expect(focusedIn(tester, 'row0'), isTrue);
    await press(tester, LogicalKeyboardKey.keyL);
    await tester.pumpAndSettle();
    expect(opened, ['row0']);
  });

  testWidgets('Emacs: Ctrl+N and Ctrl+P move', (tester) async {
    await pump(tester, KeymapPreset.emacs);
    await ctrl(tester, LogicalKeyboardKey.keyN);
    await ctrl(tester, LogicalKeyboardKey.keyN);
    expect(focusedIn(tester, 'row1'), isTrue);
    await ctrl(tester, LogicalKeyboardKey.keyP);
    expect(focusedIn(tester, 'row0'), isTrue);
    await press(tester, LogicalKeyboardKey.keyJ);
    expect(focusedIn(tester, 'row0'), isTrue, reason: 'j is not Emacs');
  });

  testWidgets('Off: j moves nothing', (tester) async {
    await pump(tester, KeymapPreset.off);
    expect(await tester.sendKeyEvent(LogicalKeyboardKey.keyJ), isFalse);
    await tester.pump();
    expect(focusedIn(tester, 'row0'), isFalse);
    expect(opened, isEmpty);
  });

  testWidgets('typing j into the field leaves the rows alone', (tester) async {
    await pump(tester, KeymapPreset.vim);
    await tester.tap(find.byKey(const Key('search')));
    await tester.pump();
    expect(await tester.sendKeyEvent(LogicalKeyboardKey.keyJ), isFalse);
    expect(focusedIn(tester, 'row0'), isFalse);
  });

  testWidgets('a page inside OwnListKeys adds no list keys', (tester) async {
    await pumpComponent(
      tester,
      const TixShortcuts(
        child: OwnListKeys(
          child: TixPage(title: 'Rows', body: SizedBox()),
        ),
      ),
      size: desktop,
    );
    await tester.pump();
    final registry = ProviderScope.containerOf(
      tester.element(find.byType(TixShortcuts)),
    ).read(commandRegistryProvider);
    expect(registry.commands, isEmpty);
  });
}
