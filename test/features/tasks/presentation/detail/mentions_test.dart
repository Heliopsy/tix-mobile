// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/features/tasks/presentation/detail/mentions.dart';

void main() {
  group('mentionAt', () {
    test('reads the handle being typed before the cursor', () {
      expect(mentionAt('hi @ra', 6), 'ra');
      expect(mentionAt('@', 1), '');
      expect(mentionAt('hi @ra and', 6), 'ra');
    });

    test('is null away from a mention', () {
      expect(mentionAt('hi @ra ', 7), isNull);
      expect(mentionAt('mail a@b', 8), isNull);
      expect(mentionAt('plain', 5), isNull);
    });

    test('is null for a cursor outside the text', () {
      expect(mentionAt('@ra', -1), isNull);
      expect(mentionAt('@ra', 9), isNull);
    });
  });

  group('completeMention', () {
    test('replaces the partial handle and moves the cursor after it', () {
      final done = completeMention('hi @ra', 6, 'raj');
      expect(done.text, 'hi @raj ');
      expect(done.cursor, 8);
    });

    test('keeps the text after the cursor', () {
      final done = completeMention('@r tomorrow', 2, 'raj');
      expect(done.text, '@raj  tomorrow');
      expect(done.cursor, 5);
    });
  });
}
