// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';

import '../../../helpers/app.dart';
import '../../../helpers/design.dart';

TixCommand cmd(String id, String label, {String keywords = ''}) =>
    TixCommand(id: id, label: label, keywords: keywords, run: () {});

void main() {
  group('fuzzyScore', () {
    test('letters must appear in order', () {
      expect(fuzzyScore('infr', 'Infrastructure'), isNotNull);
      expect(fuzzyScore('rfni', 'Infrastructure'), isNull);
      expect(fuzzyScore('', 'anything'), 0);
    });

    test('a prefix beats letters spread out', () {
      expect(
        fuzzyScore('set', 'Settings'),
        greaterThan(fuzzyScore('set', 'Show every task')!),
      );
    });

    test('word starts beat the middle of a word', () {
      expect(
        fuzzyScore('gp', 'Go to projects'),
        greaterThan(fuzzyScore('gp', 'Upgrade plan')!),
      );
    });
  });

  group('CommandRegistry.search', () {
    late CommandRegistry registry;

    setUp(() {
      registry = CommandRegistry()
        ..register(
          'screen',
          [cmd('go.settings', 'Go to settings')],
          sources: [
            (q) => [
              cmd('project.infra', 'Infrastructure', keywords: 'infra'),
              cmd('project.web', 'Web UI', keywords: 'web'),
            ],
            (q) => q == 'web-12' ? [cmd('open.web-12', 'Open web-12')] : [],
          ],
        );
      addTearDown(registry.dispose);
    });

    test('an empty query lists commands then source results', () {
      expect(registry.search('').map((c) => c.id), [
        'go.settings',
        'project.infra',
        'project.web',
      ]);
    });

    test('a query ranks matches and drops the rest', () {
      expect(registry.search('infr').map((c) => c.id), ['project.infra']);
      expect(registry.search('web-12').first.id, 'open.web-12');
    });

    test('keywords match too', () {
      expect(registry.search('web').map((c) => c.id), contains('project.web'));
    });

    test('unregister removes the sources', () {
      registry.unregister('screen');
      expect(registry.search(''), isEmpty);
    });
  });

  testWidgets('the palette asks the sources as the person types', (
    tester,
  ) async {
    final asked = <String>[];
    var opened = '';
    await pumpComponent(
      tester,
      TixShortcuts(
        child: CommandScope(
          commands: const [],
          sources: [
            (q) {
              asked.add(q);
              return [
                TixCommand(
                  id: 'project.infra',
                  label: 'Infrastructure',
                  keywords: 'infra',
                  run: () => opened = 'infra',
                ),
              ];
            },
          ],
          child: const SizedBox.expand(),
        ),
      ),
      size: desktop,
    );
    await tester.pump();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('palette.query')), 'nfra');
    await tester.pump();
    expect(asked, contains('nfra'));
    expect(
      find.descendant(
        of: find.byKey(const Key('palette')),
        matching: find.byKey(const Key('palette.project.infra')),
      ),
      findsOneWidget,
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(opened, 'infra');
  });
}
