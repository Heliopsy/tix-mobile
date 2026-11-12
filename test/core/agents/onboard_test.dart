// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/agents/onboard.dart';

// Expected values are what tix's internal/onboard writes for the same target.
void main() {
  const t = OnboardTarget(
    url: 'https://tix.example.com',
    tenant: 'acme',
    version: '0.58.0',
    sshHost: 'tix.example.com:2222',
  );

  String text(List<OnboardSnippet> list, String id) =>
      list.firstWhere((s) => s.id == id).text;

  test('the agent token command names the preset scopes', () {
    expect(
      tokenCommand(),
      'tix token create mcp-agent --scope task:read --scope task:write '
      '--scope task:transition --scope task:claim --scope comment:write',
    );
  });

  test('install pins the running release', () {
    final list = installSnippets(t);
    expect(
      text(list, 'install-unix'),
      'curl -fsSL https://tix.red/install.sh | TIX_VERSION=v0.58.0 sh',
    );
    expect(
      text(list, 'install-windows'),
      r'$env:TIX_VERSION = "v0.58.0"; irm https://tix.red/install.ps1 | iex',
    );
    expect(
      text(list, 'install-go'),
      'go install github.com/heliopsy/tix@v0.58.0',
    );
    expect(
      text(list, 'install-container'),
      'podman run --rm -e TIX_SERVER_URL=https://tix.example.com '
      r'-e TIX_TOKEN=$TIX_TOKEN ghcr.io/heliopsy/tix:0.58.0 task ls',
    );
  });

  test('a development build installs the latest', () {
    const dev = OnboardTarget(url: 'https://tix.example.com', version: 'dev');
    expect(
      text(installSnippets(dev), 'install-go'),
      'go install github.com/heliopsy/tix@latest',
    );
  });

  test('the context is named after the tenant', () {
    expect(
      text(cliSnippets(t), 'cli-ctx'),
      r'tix ctx add acme --server https://tix.example.com --token $TIX_TOKEN '
      '--tenant acme --use',
    );
    const none = OnboardTarget(url: 'http://h', token: 'tok');
    expect(
      text(cliSnippets(none), 'cli-ctx'),
      'tix ctx add tix --server http://h --token tok --use',
    );
  });

  test('every documented client, in the docs order', () {
    expect(
      [for (final c in mcpClients(t)) c.client.id],
      [
        'claude-code',
        'codex',
        'opencode',
        'gemini',
        'claude-desktop',
        'cursor',
        'vscode',
        'zed',
      ],
    );
  });

  test('the client snippets carry the address and the token', () {
    const issued = OnboardTarget(url: 'https://tix.example.com', token: 'tk');
    final clients = {for (final c in mcpClients(issued)) c.client.id: c};
    expect(
      clients['claude-code']!.snippets.first.text,
      'claude mcp add tix --env TIX_SERVER_URL=https://tix.example.com '
      '--env TIX_TOKEN=tk -- tix mcp',
    );
    expect(clients['cursor']!.snippets.single.path, '.cursor/mcp.json');
    expect(
      clients['cursor']!.snippets.single.text,
      '{\n  "mcpServers": {\n    "tix": {\n      "type": "stdio",\n'
      '      "command": "tix",\n      "args": ["mcp"],\n      "env": {\n'
      '        "TIX_SERVER_URL": "https://tix.example.com",\n'
      '        "TIX_TOKEN": "tk"\n      }\n    }\n  }\n}',
    );
    expect(
      clients['codex']!.snippets.last.text,
      '[mcp_servers.tix]\ncommand = "tix"\nargs = ["mcp"]\n\n'
      '[mcp_servers.tix.env]\nTIX_SERVER_URL = "https://tix.example.com"\n'
      'TIX_TOKEN = "tk"',
    );
    expect(
      [for (final s in clients['vscode']!.snippets) s.id],
      ['mcp-vscode-1', 'mcp-vscode-2'],
    );
  });

  test('ssh puts the tenant as the user and a port other than 22', () {
    final list = sshSnippets(t);
    expect(text(list, 'ssh-tui'), 'ssh -p 2222 acme@tix.example.com');
    expect(
      text(list, 'ssh-cmd'),
      'ssh -p 2222 acme@tix.example.com task ls -o json',
    );
    const plain = OnboardTarget(url: 'https://h', sshHost: 'h');
    expect(text(sshSnippets(plain), 'ssh-tui'), 'ssh tix@h');
  });

  test('the API calls send the token', () {
    const issued = OnboardTarget(url: 'https://tix.example.com', token: 'tk');
    final list = restSnippets(issued);
    expect(
      text(list, 'rest-whoami'),
      'curl -fsS -H "Authorization: Bearer tk" '
      'https://tix.example.com/api/v1/whoami',
    );
    expect(
      text(list, 'rest-tasks'),
      'curl -fsS -H "Authorization: Bearer tk" '
      '"https://tix.example.com/api/v1/tasks?limit=5"',
    );
  });

  test('the skill fetches every reference file', () {
    expect(
      text(skillSnippets(), 'skill-project'),
      'mkdir -p .claude/skills/tix/reference\n'
      'curl -fsSL https://tix.red/skill.md -o .claude/skills/tix/SKILL.md\n'
      'for f in queries recovery setup ssh; do\n'
      r'  curl -fsSL https://tix.red/reference/$f.md -o '
      r'.claude/skills/tix/reference/$f.md'
      '\n'
      'done',
    );
  });

  test('a value the shell would split is quoted', () {
    expect(shellWord('plain-value'), 'plain-value');
    expect(shellWord("it's"), r"'it'\''s'");
  });
}
