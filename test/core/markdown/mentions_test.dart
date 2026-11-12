// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/markdown/mentions.dart';

void main() {
  test('a handle becomes a link, keeping the text around it', () {
    expect(
      linkMentions('ask @raj, then @ana.'),
      'ask [@raj](tix-actor:raj), then [@ana](tix-actor:ana).',
    );
  });

  test('handles may hold dots, dashes and underscores inside', () {
    expect(
      linkMentions('@build-bot_2.x done'),
      '[@build-bot_2.x](tix-actor:build-bot_2.x) done',
    );
  });

  final untouched = {
    'an email': 'mail ana@example.com',
    'inline code': 'run `ping @raj` now',
    'a link': 'see [@raj](https://example.com/@raj)',
    'an address': 'https://example.com/@raj/page',
    'an autolink': '<https://example.com/@raj>',
    'a fenced block': '```\n@raj\n```',
    'an indented block': '    @raj',
    'no handle': 'nothing to see',
  };
  for (final MapEntry(key: what, value: text) in untouched.entries) {
    test('$what is left alone', () => expect(linkMentions(text), text));
  }

  test('text after a fenced block is linked again', () {
    expect(
      linkMentions('```\n@a\n```\nhi @b'),
      '```\n@a\n```\nhi [@b](tix-actor:b)',
    );
  });
}
