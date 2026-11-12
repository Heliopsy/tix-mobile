// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/data/models/task_link.dart';

void main() {
  // The cases tix's internal/tasklink tests, so the app copies what the web,
  // the command line and the terminal interface copy.
  const cases = [
    (
      'plain',
      'INFRA-12',
      'Fix the build',
      'https://tix.example.com',
      'https://tix.example.com/tasks/INFRA-12',
      'INFRA-12 Fix the build',
      '[INFRA-12 Fix the build](https://tix.example.com/tasks/INFRA-12)',
    ),
    (
      'trailing slash',
      'infra-12',
      'x',
      'https://tix.example.com/',
      'https://tix.example.com/tasks/infra-12',
      'infra-12 x',
      '[infra-12 x](https://tix.example.com/tasks/infra-12)',
    ),
    (
      'brackets',
      'INFRA-3',
      r'see [docs] \ here',
      'http://h:8080',
      'http://h:8080/tasks/INFRA-3',
      r'INFRA-3 see [docs] \ here',
      r'[INFRA-3 see \[docs\] \\ here](http://h:8080/tasks/INFRA-3)',
    ),
    (
      'lines',
      'INFRA-4',
      'one\n  two\tthree ',
      'https://h',
      'https://h/tasks/INFRA-4',
      'INFRA-4 one two three',
      '[INFRA-4 one two three](https://h/tasks/INFRA-4)',
    ),
    (
      'no title',
      'INFRA-5',
      '  ',
      'https://h',
      'https://h/tasks/INFRA-5',
      'INFRA-5',
      '[INFRA-5](https://h/tasks/INFRA-5)',
    ),
  ];

  for (final (name, ref, title, base, url, text, markdown) in cases) {
    test(name, () {
      expect(taskLink(ref, '', base), url);
      expect(taskLinkText(ref, title), text);
      expect(taskLinkMarkdown(ref, title, url), markdown);
    });
  }

  test("the server's web_url wins over the connection's address", () {
    expect(
      taskLink('infra-1', 'https://public.example/tasks/infra-1', 'http://h'),
      'https://public.example/tasks/infra-1',
    );
  });
}
