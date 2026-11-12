// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';

import '../../../helpers/app.dart';
import '../../../helpers/design.dart';

void main() {
  late List<String> ran;

  Future<ProviderContainer> pump(
    WidgetTester tester, {
    KeymapPreset preset = KeymapPreset.standard,
    bool enabled = true,
    bool shown = true,
  }) async {
    ran = [];
    final container = await pumpComponent(
      tester,
      TixShortcuts(
        child: TickerMode(
          enabled: shown,
          child: CommandScope(
            commands: [
              TixCommand(
                id: 'tasks.new',
                label: 'New task',
                shortcut: const SingleActivator(LogicalKeyboardKey.keyN),
                run: () => ran.add('new'),
              ),
              TixCommand(
                id: 'tasks.select',
                label: 'Select a task',
                action: KeyActions.listSelect,
                run: () => ran.add('select'),
              ),
              TixCommand(
                id: 'tasks.next',
                label: 'Next task',
                action: KeyActions.listNext,
                run: () => ran.add('next'),
              ),
              TixCommand(
                id: 'tasks.first',
                label: 'First task',
                action: KeyActions.listTop,
                run: () => ran.add('top'),
              ),
              TixCommand(
                id: 'go.projects',
                label: 'Go to projects',
                action: KeyActions.navProjects,
                run: () => ran.add('projects'),
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
      ),
      size: desktop,
    );
    final keyboard = container.read(keyboardSettingProvider.notifier);
    await keyboard.setPreset(preset);
    await keyboard.setEnabled(on: enabled);
    await tester.pump();
    return container;
  }

  Future<bool> chord(WidgetTester tester, LogicalKeyboardKey key) async {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    final handled = await tester.sendKeyEvent(key);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    return handled;
  }

  Future<void> question(WidgetTester tester) async {
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shift);
    await tester.sendKeyEvent(LogicalKeyboardKey.slash, character: '?');
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shift);
    await tester.pumpAndSettle();
  }

  Finder inHelp(String text) => find.descendant(
    of: find.byKey(const Key('shortcuts.help')),
    matching: find.text(text),
  );

  testWidgets('a registered key runs its command', (tester) async {
    await pump(tester);
    expect(await tester.sendKeyEvent(LogicalKeyboardKey.keyN), isTrue);
    expect(ran, ['new']);
  });

  testWidgets('keys typed into a field stay in the field', (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(const Key('field')));
    // Unhandled, so the platform hands the key to the field's text input. A
    // handled key would be swallowed and never typed.
    expect(await tester.sendKeyEvent(LogicalKeyboardKey.keyN), isFalse);
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

  testWidgets('an action runs on the preset key', (tester) async {
    await pump(tester);
    expect(await tester.sendKeyEvent(LogicalKeyboardKey.keyJ), isTrue);
    expect(ran, ['next']);
  });

  testWidgets('Emacs moves with Ctrl+N and leaves j alone', (tester) async {
    await pump(tester, preset: KeymapPreset.emacs);
    expect(await chord(tester, LogicalKeyboardKey.keyN), isTrue);
    expect(await tester.sendKeyEvent(LogicalKeyboardKey.keyJ), isFalse);
    expect(ran, ['next']);
  });

  testWidgets('g then p runs the sequence, not the first key', (tester) async {
    await pump(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyG);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyP);
    await tester.pump(const Duration(seconds: 2));
    expect(ran, ['projects']);
  });

  testWidgets('g alone runs when the wait ends', (tester) async {
    await pump(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyG);
    expect(ran, isEmpty);
    await tester.pump(KeySequencer.defaultTimeout);
    expect(ran, ['top']);
  });

  testWidgets('Vim waits for the second g', (tester) async {
    await pump(tester, preset: KeymapPreset.vim);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyG);
    await tester.pump(KeySequencer.defaultTimeout);
    expect(ran, isEmpty);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyG);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyG);
    expect(ran, ['top']);
  });

  testWidgets('Off drops single keys and keeps the palette chord', (
    tester,
  ) async {
    await pump(tester, preset: KeymapPreset.off);
    expect(await tester.sendKeyEvent(LogicalKeyboardKey.keyN), isFalse);
    expect(await tester.sendKeyEvent(LogicalKeyboardKey.keyJ), isFalse);
    await question(tester);
    expect(find.byKey(const Key('shortcuts.help')), findsNothing);
    expect(ran, isEmpty);
    expect(await chord(tester, LogicalKeyboardKey.keyK), isTrue);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('palette')), findsOneWidget);
  });

  testWidgets('switched off, even the palette chord does nothing', (
    tester,
  ) async {
    await pump(tester, enabled: false);
    expect(await chord(tester, LogicalKeyboardKey.keyK), isFalse);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('palette')), findsNothing);
  });

  for (final preset in KeymapPreset.values) {
    testWidgets('${preset.name}: typing in a field triggers nothing', (
      tester,
    ) async {
      await pump(tester, preset: preset);
      await tester.tap(find.byKey(const Key('field')));
      for (final key in [
        LogicalKeyboardKey.keyN,
        LogicalKeyboardKey.keyJ,
        LogicalKeyboardKey.keyX,
        LogicalKeyboardKey.keyG,
        LogicalKeyboardKey.keyP,
      ]) {
        expect(await tester.sendKeyEvent(key), isFalse, reason: '$key');
      }
      expect(await chord(tester, LogicalKeyboardKey.keyN), isFalse);
      await tester.pump(const Duration(seconds: 2));
      expect(ran, isEmpty);
    });
  }

  testWidgets('Esc leaves the field, then keys act again', (tester) async {
    await pump(tester, preset: KeymapPreset.vim);
    await tester.tap(find.byKey(const Key('field')));
    expect(await tester.sendKeyEvent(LogicalKeyboardKey.escape), isTrue);
    await tester.pump();
    expect(typingInField(), isFalse);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyJ);
    expect(ran, ['next']);
  });

  testWidgets('Emacs: Ctrl+G leaves the field', (tester) async {
    await pump(tester, preset: KeymapPreset.emacs);
    await tester.tap(find.byKey(const Key('field')));
    expect(await chord(tester, LogicalKeyboardKey.keyG), isTrue);
    await tester.pump();
    expect(typingInField(), isFalse);
  });

  testWidgets('the help shows the active preset', (tester) async {
    await pump(tester);
    await question(tester);
    expect(inHelp('Select or unselect the focused task'), findsOneWidget);
    expect(inHelp('x'), findsOneWidget);
    expect(inHelp('v'), findsNothing);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('shortcuts.help')), findsNothing);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(TixShortcuts)),
    );
    await container
        .read(keyboardSettingProvider.notifier)
        .setPreset(KeymapPreset.vim);
    await question(tester);
    expect(inHelp('v'), findsOneWidget);
    expect(inHelp('x'), findsNothing);
    expect(inHelp('g'), findsWidgets);
  });

  testWidgets('the help groups keys and words them as tix web does', (
    tester,
  ) async {
    await pump(tester);
    await question(tester);
    Finder heading(KeyGroup g) => find.byKey(Key('shortcuts.help.${g.name}'));
    expect(
      find.descendant(
        of: heading(KeyGroup.navigate),
        matching: find.text('Navigate'),
      ),
      findsOneWidget,
    );
    expect(heading(KeyGroup.task), findsNothing);
    expect(inHelp('Go to Projects'), findsOneWidget);
    expect(inHelp('Go to projects'), findsNothing);
    expect(inHelp('Move selection down'), findsOneWidget);
    expect(inHelp('Next task'), findsNothing);
    expect(inHelp('Open the command palette'), findsOneWidget);
    expect(inHelp('Show this help'), findsOneWidget);
    double top(Finder f) => tester.getTopLeft(f).dy;
    expect(
      top(heading(KeyGroup.navigate)),
      lessThan(top(heading(KeyGroup.lists))),
    );
    expect(
      top(heading(KeyGroup.lists)),
      lessThan(top(inHelp('Move selection down'))),
    );
    expect(
      top(inHelp('Move selection down')),
      lessThan(top(heading(KeyGroup.general))),
    );
    expect(top(heading(KeyGroup.general)), lessThan(top(inHelp('New task'))));
    expect(
      top(heading(KeyGroup.general)),
      lessThan(top(inHelp('Show this help'))),
    );
  });

  test('a key registered by two scopes is listed once', () {
    TixCommand c(String id) =>
        TixCommand(id: id, label: id, action: KeyActions.navBack, run: () {});
    final groups = shortcutGroups(lookupAppLocalizations(const Locale('en')), [
      c('shell.back'),
      c('page.back'),
    ], Keymap.of(KeymapPreset.standard));
    final rows = [for (final g in groups) ...g.rows];
    expect(rows.where((r) => r.label == 'Go back'), hasLength(1));
  });

  testWidgets('a scope that is not shown answers no keys', (tester) async {
    await pump(tester, shown: false);
    expect(await tester.sendKeyEvent(LogicalKeyboardKey.keyJ), isFalse);
    expect(ProviderScopeHelper.registry(tester).commands, isEmpty);
  });

  test('a scope registering again keeps its place', () {
    final registry = CommandRegistry();
    final shell = Object();
    final page = Object();
    TixCommand c(String id) => TixCommand(id: id, label: id, run: () {});
    registry
      ..register(shell, [c('back')])
      ..register(page, [c('clear')])
      ..register(shell, [c('back')]);
    expect(registry.commands.map((c) => c.id), ['back', 'clear']);
    registry.dispose();
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
