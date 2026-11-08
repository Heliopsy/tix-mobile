// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';

import '../../../helpers/app.dart';
import '../../../helpers/design.dart';

void main() {
  late List<String> ran;

  Future<void> pump(WidgetTester tester) async {
    ran = [];
    await pumpComponent(
      tester,
      TixShortcuts(
        child: CommandScope(
          commands: [
            TixCommand(
              id: 'tasks.new',
              label: 'New task',
              shortcut: const SingleActivator(LogicalKeyboardKey.keyN),
              run: () => ran.add('new'),
            ),
            TixCommand(
              id: 'go.settings',
              label: 'Go to settings',
              run: () => ran.add('settings'),
            ),
          ],
          child: const TextField(key: Key('field')),
        ),
      ),
      size: desktop,
    );
    await tester.pump();
  }

  testWidgets('a registered key runs its command', (tester) async {
    await pump(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
    expect(ran, ['new']);
  });

  testWidgets('keys typed into a field stay in the field', (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(const Key('field')));
    await tester.sendKeyEvent(LogicalKeyboardKey.keyN);
    await tester.pumpAndSettle();
    expect(ran, isEmpty);
    expect(find.byKey(const Key('shortcuts.help')), findsNothing);
  });

  testWidgets('? lists the shortcuts', (tester) async {
    await pump(tester);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
    await tester.sendKeyEvent(LogicalKeyboardKey.slash, character: '?');
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
    await tester.pumpAndSettle();
    final help = find.byKey(const Key('shortcuts.help'));
    expect(help, findsOneWidget);
    expect(
      find.descendant(of: help, matching: find.text('New task')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: help, matching: find.text('Go to settings')),
      findsNothing,
    );
  });

  testWidgets('Ctrl+K opens the palette, which narrows and runs', (
    tester,
  ) async {
    await pump(tester);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('palette')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('palette.query')), 'sett');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('palette.tasks.new')), findsNothing);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(ran, ['settings']);
  });

  testWidgets('a scope that leaves takes its commands with it', (tester) async {
    await pump(tester);
    final registry = ProviderScopeHelper.registry(tester);
    expect(registry.commands.map((c) => c.id), contains('tasks.new'));
    await pumpComponent(tester, const SizedBox());
    await tester.pump();
    expect(registry.commands, isEmpty);
  });

  test('shortcut labels read like the keyboard', () {
    expect(
      shortcutLabel(
        const SingleActivator(LogicalKeyboardKey.keyK, control: true),
      ),
      'Ctrl K',
    );
    expect(shortcutLabel(const CharacterActivator('?')), '?');
  });
}

/// Reads the registry the pumped scope uses.
abstract final class ProviderScopeHelper {
  static CommandRegistry registry(WidgetTester tester) {
    final element = tester.element(find.byType(TixShortcuts));
    return ProviderScope.containerOf(element).read(commandRegistryProvider);
  }
}
