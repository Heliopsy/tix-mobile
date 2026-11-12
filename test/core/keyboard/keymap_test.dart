// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show SingleActivator;
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/keyboard/keymap.dart';

const _g = KeyPress(LogicalKeyboardKey.keyG, character: 'g');
const _p = KeyPress(LogicalKeyboardKey.keyP, character: 'p');
const _j = KeyPress(LogicalKeyboardKey.keyJ, character: 'j');
const _x = KeyPress(LogicalKeyboardKey.keyX, character: 'x');
const _shift = KeyPress(LogicalKeyboardKey.shiftLeft, shift: true);
const _ctrlN = KeyPress(LogicalKeyboardKey.keyN, control: true);

List<String> _labels(Keymap k, String action) => [
  for (final b in k.bindingsFor(action)) b.label,
];

void main() {
  group('KeyBinding.parse', () {
    test('letters, shifted letters, chords, names and characters', () {
      expect(KeyBinding.parse('g g').label, 'g g');
      expect(KeyBinding.parse('G').steps.single.shift, isTrue);
      expect(KeyBinding.parse('G').label, 'G');
      expect(KeyBinding.parse('ctrl+k').label, 'Ctrl K');
      expect(KeyBinding.parse('ctrl+shift+v').label, 'Ctrl Shift V');
      expect(KeyBinding.parse('shift+down').label, 'Shift ↓');
      expect(KeyBinding.parse('alt+shift+comma').label, 'Alt <');
      expect(KeyBinding.parse('?').steps.single.character, '?');
      expect(KeyBinding.parse('ctrl+1').label, 'Ctrl 1');
    });

    test('a character stroke ignores Shift; a key stroke does not', () {
      final question = KeyBinding.parse('?').steps.single;
      expect(
        question.matches(
          const KeyPress(LogicalKeyboardKey.slash, character: '?', shift: true),
        ),
        isTrue,
      );
      final g = KeyBinding.parse('g').steps.single;
      expect(g.matches(_g), isTrue);
      expect(
        g.matches(const KeyPress(LogicalKeyboardKey.keyG, shift: true)),
        isFalse,
      );
      expect(
        g.matches(const KeyPress(LogicalKeyboardKey.keyG, control: true)),
        isFalse,
      );
    });
  });

  group('presets', () {
    test('Default is the key table tix web shares', () {
      final k = Keymap.of(KeymapPreset.standard);
      expect(_labels(k, KeyActions.listNext), ['j', '↓']);
      expect(_labels(k, KeyActions.listTop), ['g', 'Home']);
      expect(_labels(k, KeyActions.listDone), ['d']);
      expect(_labels(k, KeyActions.taskRename), ['e']);
      expect(_labels(k, KeyActions.taskDescribe), ['E']);
      expect(_labels(k, KeyActions.taskMove), ['t']);
      expect(_labels(k, KeyActions.taskComment), ['m']);
      expect(_labels(k, KeyActions.taskTag), ['#']);
      expect(_labels(k, KeyActions.taskStar), ['s', '*']);
      expect(_labels(k, KeyActions.taskCopy), ['y']);
      expect(_labels(k, KeyActions.taskAssign), ['a']);
    });

    test('destinations follow the navigation order', () {
      final k = Keymap.of(KeymapPreset.standard);
      expect(_labels(k, KeyActions.navInbox), ['g i', 'Ctrl 1']);
      expect(_labels(k, KeyActions.navMyWork), ['g m', 'Ctrl 2']);
      expect(_labels(k, KeyActions.navTasks), ['g t', 'Ctrl 3']);
      expect(_labels(k, KeyActions.navProjects), ['g p', 'Ctrl 4']);
      expect(_labels(k, KeyActions.navWatch), ['g a', 'g w', 'Ctrl 5']);
      expect(_labels(k, KeyActions.navManage), ['g M', 'Ctrl 6']);
      expect(_labels(k, KeyActions.navSettings), ['g s', 'Ctrl 7']);
    });

    test('no key runs two actions, Esc going back and clearing aside', () {
      const shared = {KeyActions.navBack, KeyActions.listClear};
      for (final preset in KeymapPreset.values) {
        final k = Keymap.of(preset);
        final owner = <KeyBinding, String>{};
        for (final action in k.actions) {
          for (final b in k.bindingsFor(action)) {
            final other = owner[b];
            if (other != null && shared.containsAll([other, action])) continue;
            expect(other, isNull, reason: '${preset.name} $b: $other, $action');
            owner[b] = action;
          }
        }
      }
    });

    test('Vim layers its keys over Default', () {
      final k = Keymap.of(KeymapPreset.vim);
      expect(_labels(k, KeyActions.listTop), ['g g', 'Home']);
      expect(_labels(k, KeyActions.listNew), ['o']);
      expect(_labels(k, KeyActions.listDone), ['d']);
      expect(_labels(k, KeyActions.listFilter), ['/', ':']);
      expect(_labels(k, KeyActions.taskDescribe), ['D']);
      expect(_labels(k, KeyActions.taskDelete), ['d d', 'x', 'Delete']);
      expect(_labels(k, KeyActions.taskAssign), ['a']);
      expect(_labels(k, KeyActions.taskComment), ['m']);
      for (final action in k.actions) {
        expect(_labels(k, action), isNot(contains('e')), reason: action);
      }
    });

    test('Emacs moves with C-n and opens the palette on M-x', () {
      final k = Keymap.of(KeymapPreset.emacs);
      expect(_labels(k, KeyActions.listNext), ['Ctrl N', '↓']);
      expect(_labels(k, KeyActions.paletteOpen), contains('Alt X'));
      expect(_labels(k, KeyActions.quickAdd), ['Alt N']);
      expect(k.bindingsFor(KeyActions.fieldLeave).map((b) => b.label), [
        'Esc',
        'Ctrl G',
      ]);
    });

    test('only the palette chord and leaving a field apply while typing', () {
      for (final preset in KeymapPreset.values) {
        final k = Keymap.of(preset);
        for (final action in k.actions) {
          for (final b in k.bindingsFor(action)) {
            if (b.fields == FieldRule.outside) continue;
            expect(
              action,
              anyOf(KeyActions.paletteOpen, KeyActions.fieldLeave),
              reason: '${preset.name} $b',
            );
          }
        }
      }
      expect(
        Keymap.of(KeymapPreset.emacs)
            .bindingsFor(KeyActions.paletteOpen)
            .last
            .fields,
        FieldRule.outside,
      );
    });

    test('Off keeps chords only, the palette included', () {
      final k = Keymap.of(KeymapPreset.off);
      for (final action in k.actions) {
        for (final b in k.bindingsFor(action)) {
          expect(b.chorded, isTrue, reason: '$action $b');
        }
      }
      expect(_labels(k, KeyActions.paletteOpen), ['Ctrl K', '⌘ K']);
      expect(k.bindingsFor(KeyActions.listNext), isEmpty);
      expect(
        k.forShortcut(const SingleActivator(LogicalKeyboardKey.keyU)),
        isEmpty,
      );
    });

    test('switched off, nothing is bound', () {
      final k = Keymap.of(KeymapPreset.vim, enabled: false);
      expect(k.bindingsFor(KeyActions.paletteOpen), isEmpty);
      expect(
        k.forShortcut(
          const SingleActivator(LogicalKeyboardKey.keyK, control: true),
        ),
        isEmpty,
      );
    });

    test('an unknown stored preset falls back to Default', () {
      expect(KeymapPreset.byId('helix'), KeymapPreset.standard);
      expect(KeymapPreset.byId('vim'), KeymapPreset.vim);
      expect(KeymapPreset.standard.id, 'default');
    });
  });

  group('KeySequencer', () {
    final top = KeyBinding.parse('g');
    final projects = KeyBinding.parse('g p');
    final next = KeyBinding.parse('j');
    final candidates = [(projects, 'projects'), (top, 'top'), (next, 'next')];

    test('a single key runs at once', () {
      final s = KeySequencer<String>(onTimeout: (_) {});
      expect(s.feed(_j, candidates), isA<KeyMatched<String>>());
    });

    test('a sequence completes within the timeout', () {
      fakeAsync((async) {
        final timedOut = <String>[];
        final s = KeySequencer<String>(onTimeout: timedOut.add);
        expect(s.feed(_g, candidates), isA<KeyPending<String>>());
        async.elapse(const Duration(milliseconds: 500));
        final done = s.feed(_p, candidates);
        expect((done as KeyMatched<String>).value, 'projects');
        async.elapse(const Duration(seconds: 2));
        expect(timedOut, isEmpty);
      });
    });

    test('a prefix that is also a binding runs when the wait ends', () {
      fakeAsync((async) {
        final timedOut = <String>[];
        final s = KeySequencer<String>(onTimeout: timedOut.add)
          ..feed(_g, candidates);
        async.elapse(const Duration(milliseconds: 999));
        expect(timedOut, isEmpty);
        async.elapse(const Duration(milliseconds: 1));
        expect(timedOut, ['top']);
        expect(s.pending, isEmpty);
      });
    });

    test('after the timeout the second key starts afresh', () {
      fakeAsync((async) {
        final s = KeySequencer<String>(onTimeout: (_) {})
          ..feed(_g, [(projects, 'projects')]);
        async.elapse(KeySequencer.defaultTimeout);
        expect(
          s.feed(_p, [(projects, 'projects')]),
          isA<KeyUnmatched<String>>(),
        );
      });
    });

    test('a key that breaks a sequence is tried on its own', () {
      fakeAsync((async) {
        final timedOut = <String>[];
        final s = KeySequencer<String>(onTimeout: timedOut.add)
          ..feed(_g, candidates);
        final then = s.feed(_j, candidates);
        expect((then as KeyMatched<String>).value, 'next');
        async.elapse(const Duration(seconds: 2));
        expect(timedOut, isEmpty);
      });
    });

    test('a modifier on its own keeps the sequence waiting', () {
      final s = KeySequencer<String>(onTimeout: (_) {})..feed(_g, candidates);
      expect(s.feed(_shift, candidates), isA<KeyPending<String>>());
      expect(s.pending, [_g]);
      s.reset();
    });

    test('the first candidate wins: the newest scope', () {
      final s = KeySequencer<String>(onTimeout: (_) {});
      final esc = KeyBinding.parse('esc');
      const press = KeyPress(LogicalKeyboardKey.escape);
      final out = s.feed(press, [(esc, 'clear'), (esc, 'back')]);
      expect((out as KeyMatched<String>).value, 'clear');
    });

    test('a chord matches with its modifiers', () {
      final s = KeySequencer<String>(onTimeout: (_) {});
      final k = Keymap.of(KeymapPreset.emacs);
      final out = s.feed(_ctrlN, [
        for (final b in k.bindingsFor(KeyActions.listNext)) (b, 'next'),
      ]);
      expect((out as KeyMatched<String>).value, 'next');
      expect(s.feed(_x, const []), isA<KeyUnmatched<String>>());
    });

    test('a timer factory replaces the clock', () {
      void Function()? fire;
      final timedOut = <String>[];
      KeySequencer<String>(
        onTimeout: timedOut.add,
        startTimer: (_, run) {
          fire = run;
          return Timer(Duration.zero, () {});
        },
      ).feed(_g, candidates);
      fire!();
      expect(timedOut, ['top']);
    });
  });
}
