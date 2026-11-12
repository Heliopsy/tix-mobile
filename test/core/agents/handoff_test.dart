// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/agents/handoff.dart';

void main() {
  const task = HandoffTask(
    ref: 'infra-12',
    title: 'Fix the\nbuild',
    server: 'https://tix.example.com',
  );

  test("the CLI prompt is tix web's, word for word", () {
    expect(
      handoffPrompt(task),
      'Work on tix task INFRA-12 ("Fix the build") on the tix server at '
      'https://tix.example.com. Claim it first with `tix claim task INFRA-12 '
      '-o json` and keep the lease_token it prints. Read it with `tix task '
      'show INFRA-12`, post progress as comments with `tix comment add '
      'INFRA-12 "..."`, and when it is finished close it with `tix claim '
      'release INFRA-12 --token <lease_token> --status done --comment "what '
      'you did"`.',
    );
  });

  test('the MCP prompt names the tools tix mcp exposes', () {
    expect(
      handoffMcpPrompt(task),
      'Work on tix task INFRA-12 ("Fix the build") on the tix server at '
      'https://tix.example.com. Use the tix MCP tools. Claim it first with '
      'claim_task and keep the lease_token it returns. Read it with '
      'task_show, post progress as comments with comment_add, and when it is '
      'finished close it with claim_release, passing the lease token, status '
      'done and a comment saying what you did.',
    );
  });

  test('a project reference shows in capitals, an id as it is', () {
    expect(showRef('infra-12'), 'INFRA-12');
    expect(showRef('my-proj-3'), 'MY-PROJ-3');
    expect(showRef('01hzx9k2'), '01hzx9k2');
    expect(showRef('infra-0'), 'infra-0');
  });

  test('a client with no command takes the MCP prompt to paste', () {
    final zed = handoffClients.firstWhere((c) => c.id == 'zed');
    final s = handoffFor(task, zed);
    expect(s.command, isEmpty);
    expect(s.prompt, handoffMcpPrompt(task));
    final claude = handoffFor(task, handoffClients.first);
    expect(claude.command, startsWith("claude 'Work on tix task INFRA-12"));
    expect(claude.prompt, handoffPrompt(task));
  });

  test('no hand-off carries a token', () {
    for (final c in handoffClients) {
      final s = handoffFor(task, c);
      for (final text in [s.command, s.prompt]) {
        expect(text, isNot(contains('TIX_TOKEN')));
        expect(
          text.replaceAll('--token <lease_token>', ''),
          isNot(contains('--token')),
        );
      }
    }
  });

  const hostile = [
    'plain title',
    "it's here",
    'say "hi"',
    r'$(touch /tmp/pwned) and ${HOME}',
    '`whoami` ran',
    'two\nlines\r\nand\ta tab',
    r"back\slash \' and '\''",
    '!event #comment ; & | > < * ? ~',
    '\x00nul\x1bescape separator',
    "'",
    '',
  ];

  test('every command reaches the client as one word', () async {
    for (final title in hostile) {
      final t = HandoffTask(ref: 'INFRA-12', title: title, server: 'http://x');
      for (final c in handoffClients) {
        final s = handoffFor(t, c);
        if (s.command.isEmpty) continue;
        expect(s.command, isNot(matches(RegExp('[\r\n]'))));
        final rest = s.command.substring(c.launch.join(' ').length + 1);
        final r = await Process.run('sh', [
          '-c',
          'f() { printf \'%s\\n\' "\$#"; printf \'%s\' "\$1"; }; f $rest',
        ]);
        expect(r.stdout, '1\n${s.prompt}', reason: '${c.name}: $title');
      }
    }
  }, skip: Platform.isWindows ? 'needs a POSIX shell' : null);
}
