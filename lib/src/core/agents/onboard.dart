// SPDX-License-Identifier: AGPL-3.0-or-later

// The commands and configuration that connect a CLI, an MCP client or an
// agent to one tix server, word for word what tix's web Connect an agent
// screen writes (tix `internal/onboard`). Only the commands live here; the
// titles and notes around them are the app's own strings.

import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:tix_mobile/src/core/agents/handoff.dart';

/// What stands in a command for a token none was issued for: the shell
/// variable tix's commands read.
const tokenPlaceholder = r'$TIX_TOKEN';

/// The name the docs and the token form give an agent's token.
const agentTokenName = 'mcp-agent';

/// Where the agent skill is published.
const skillUrl = 'https://tix.red/skill.md';

/// The reference files beside the skill, under https://tix.red/reference/.
const skillReferences = ['queries', 'recovery', 'setup', 'ssh'];

/// The scopes the agent preset grants, as tix's `onboard.AgentScopes`.
const agentScopes = [
  'task:read',
  'task:write',
  'task:transition',
  'task:claim',
  'comment:write',
];

/// What every snippet is filled in with.
@immutable
class OnboardTarget {
  /// Snippets for the server at [url].
  const OnboardTarget({
    required this.url,
    this.tenant = '',
    this.token = tokenPlaceholder,
    this.version = '',
    this.sshHost = '',
  });

  /// The server's base address, such as https://tix.example.com.
  final String url;

  /// The tenant key, empty when unknown.
  final String tenant;

  /// Written wherever a command needs the API token.
  final String token;

  /// The running version; a release pins the install commands to it.
  final String version;

  /// Where people reach the SSH listener, host or host:port.
  final String sshHost;

  static final _release = RegExp(r'^v?\d+\.\d+\.\d+$');

  /// The release tag of [version], or empty for a development build.
  String get tag => _release.hasMatch(version)
      ? 'v${version.startsWith('v') ? version.substring(1) : version}'
      : '';
}

/// One copyable block, its title and note the screen's own by [id].
@immutable
class OnboardSnippet {
  /// The block [id] holding [text], going in the file at [path] if any.
  const OnboardSnippet(this.id, this.text, {this.path = ''});

  /// Stable and unique on the screen, as tix's web names it.
  final String id;

  /// The file the snippet goes in, named instead of a title.
  final String path;

  /// The snippet itself.
  final String text;
}

/// One MCP client and the ways to register tix with it.
@immutable
class OnboardClient {
  /// [client] with its [snippets].
  const OnboardClient(this.client, this.snippets);

  /// The client, as the hand-off names it.
  final HandoffClient client;

  /// Its snippets, in the order tix's docs give them.
  final List<OnboardSnippet> snippets;
}

final _shellSafe = RegExp(r'^[A-Za-z0-9_./:@%+=,~-]+$');

/// [s] quoted for a POSIX shell when it needs quoting.
String shellWord(String s) => _shellSafe.hasMatch(s) ? s : shellQuote(s);

/// [s] as a JSON string, also a valid TOML basic string for these values.
String _quote(String s) => jsonEncode(s);

/// The command that mints the agent token.
String tokenCommand() =>
    'tix token create $agentTokenName'
    '${agentScopes.map((s) => ' --scope $s').join()}';

/// Replaces the agent token, keeping the old value for ten minutes.
const rotateSnippet = OnboardSnippet(
  'token-rotate',
  'tix token rotate $agentTokenName --grace 10m',
);

/// Exports the issued [token] into the shell, for the commands that read it.
OnboardSnippet exportSnippet(String token) =>
    OnboardSnippet('token-export', 'export TIX_TOKEN=${shellWord(token)}');

/// The ways to put the CLI on a machine, pinned to the running release.
List<OnboardSnippet> installSnippets(OnboardTarget t) {
  final tag = t.tag;
  var unix = 'curl -fsSL https://tix.red/install.sh | sh';
  var windows = 'irm https://tix.red/install.ps1 | iex';
  var goGet = 'go install github.com/heliopsy/tix@latest';
  var image = 'ghcr.io/heliopsy/tix:latest';
  if (tag.isNotEmpty) {
    unix = 'curl -fsSL https://tix.red/install.sh | TIX_VERSION=$tag sh';
    windows = '\$env:TIX_VERSION = "$tag"; $windows';
    goGet = 'go install github.com/heliopsy/tix@$tag';
    image = 'ghcr.io/heliopsy/tix:${tag.substring(1)}';
  }
  return [
    OnboardSnippet('install-unix', unix),
    OnboardSnippet('install-windows', windows),
    OnboardSnippet('install-go', goGet),
    OnboardSnippet(
      'install-container',
      'podman run --rm -e TIX_SERVER_URL=${shellWord(t.url)} '
          '-e TIX_TOKEN=${t.token} $image task ls',
    ),
  ];
}

/// Points the command line at the server with a named context, then checks
/// it.
List<OnboardSnippet> cliSnippets(OnboardTarget t) {
  final name = t.tenant.isEmpty ? 'tix' : shellWord(t.tenant);
  final tenant = t.tenant.isEmpty ? '' : ' --tenant ${shellWord(t.tenant)}';
  return [
    OnboardSnippet(
      'cli-ctx',
      'tix ctx add $name --server ${shellWord(t.url)} '
          '--token ${t.token}$tenant --use',
    ),
    const OnboardSnippet('cli-verify', 'tix task ls --limit 5'),
  ];
}

/// Lists the tools `tix mcp` would serve, without a server.
const mcpPreviewSnippet = OnboardSnippet('mcp-list', 'tix mcp --list');

/// The MCP clients tix's docs name, with their snippets.
List<OnboardClient> mcpClients(OnboardTarget t) {
  final env =
      '--env TIX_SERVER_URL=${shellWord(t.url)} '
      '--env TIX_TOKEN=${t.token} -- tix mcp';
  final servers = _serversJson('mcpServers', t);
  final stdio = _serversJson('mcpServers', t, lead: ['"type": "stdio"']);
  final snippets = <String, List<(String, String)>>{
    'claude-code': [('', 'claude mcp add tix $env'), ('.mcp.json', servers)],
    'codex': [
      ('', 'codex mcp add tix $env'),
      (
        '~/.codex/config.toml',
        '[mcp_servers.tix]\ncommand = "tix"\nargs = ["mcp"]\n\n'
            '[mcp_servers.tix.env]\nTIX_SERVER_URL = ${_quote(t.url)}\n'
            'TIX_TOKEN = ${_quote(t.token)}',
      ),
    ],
    'opencode': [('opencode.json', _openCodeJson(t))],
    'gemini': [('.gemini/settings.json', servers)],
    'claude-desktop': [('claude_desktop_config.json', servers)],
    'cursor': [('.cursor/mcp.json', stdio)],
    'vscode': [
      (
        '.vscode/mcp.json',
        _serversJson('servers', t, lead: ['"type": "stdio"']),
      ),
      ('', _vscodeCli(t)),
    ],
    'zed': [('settings.json', _serversJson('context_servers', t))],
  };
  return [
    for (final c in handoffClients)
      if (snippets[c.id] case final list?)
        OnboardClient(c, [
          for (var i = 0; i < list.length; i++)
            OnboardSnippet(
              'mcp-${c.id}-${i + 1}',
              list[i].$2,
              path: list[i].$1,
            ),
        ]),
  ];
}

String _serversJson(
  String top,
  OnboardTarget t, {
  List<String> lead = const [],
}) {
  final b = StringBuffer('{\n  "$top": {\n    "tix": {\n');
  for (final l in lead) {
    b.write('      $l,\n');
  }
  b
    ..write('      "command": "tix",\n      "args": ["mcp"],\n      "env": {\n')
    ..write('        "TIX_SERVER_URL": ${_quote(t.url)},\n')
    ..write('        "TIX_TOKEN": ${_quote(t.token)}\n')
    ..write('      }\n    }\n  }\n}');
  return b.toString();
}

String _vscodeCli(OnboardTarget t) {
  final server = {
    'name': 'tix',
    'type': 'stdio',
    'command': 'tix',
    'args': ['mcp'],
    'env': {'TIX_SERVER_URL': t.url, 'TIX_TOKEN': t.token},
  };
  return "code --add-mcp '${jsonEncode(server)}'";
}

String _openCodeJson(OnboardTarget t) =>
    '{\n  "\$schema": "https://opencode.ai/config.json",\n  "mcp": {\n'
    '    "tix": {\n      "type": "local",\n      "command": ["tix", "mcp"],\n'
    '      "enabled": true,\n      "environment": {\n'
    '        "TIX_SERVER_URL": ${_quote(t.url)},\n'
    '        "TIX_TOKEN": ${_quote(t.token)}\n      }\n    }\n  }\n}';

/// Installs the agent skill.
List<OnboardSnippet> skillSnippets() {
  String fetch(String dir) =>
      'mkdir -p $dir/reference\n'
      'curl -fsSL $skillUrl -o $dir/SKILL.md\n'
      'for f in ${skillReferences.join(' ')}; do\n'
      '  curl -fsSL https://tix.red/reference/\$f.md -o $dir/reference/\$f.md\n'
      'done';
  return [
    OnboardSnippet('skill-project', fetch('.claude/skills/tix')),
    OnboardSnippet('skill-user', fetch('~/.claude/skills/tix')),
    const OnboardSnippet(
      'skill-other',
      "printf '%s\\n' 'Track work in tix. Read $skillUrl before you use it.' "
          '>> AGENTS.md',
    ),
  ];
}

/// The terminal interface over SSH, or nothing without an SSH host.
List<OnboardSnippet> sshSnippets(OnboardTarget t) {
  if (t.sshHost.isEmpty) return const [];
  final (host, port) = _splitHostPort(t.sshHost);
  final user = t.tenant.isEmpty ? 'tix' : t.tenant;
  final dest =
      'ssh ${port.isNotEmpty && port != '22' ? '-p $port ' : ''}$user@$host';
  return [
    const OnboardSnippet(
      'ssh-key',
      'tix user key add --file ~/.ssh/id_ed25519.pub',
    ),
    OnboardSnippet('ssh-tui', dest),
    OnboardSnippet('ssh-cmd', '$dest task ls -o json'),
    OnboardSnippet('ssh-export', '$dest export > snapshot.ndjson'),
    OnboardSnippet('ssh-watch', '$dest watch -o ndjson'),
  ];
}

(String, String) _splitHostPort(String addr) {
  if (addr.startsWith('[')) {
    final end = addr.indexOf(']');
    if (end > 0) {
      final rest = addr.substring(end + 1);
      return (
        addr.substring(1, end),
        rest.startsWith(':') ? rest.substring(1) : '',
      );
    }
  }
  final colon = addr.lastIndexOf(':');
  if (colon > 0 && addr.indexOf(':') == colon) {
    return (addr.substring(0, colon), addr.substring(colon + 1));
  }
  return (addr, '');
}

/// Calls the HTTP API with the token.
List<OnboardSnippet> restSnippets(OnboardTarget t) {
  final auth = 'curl -fsS -H "Authorization: Bearer ${t.token}" ';
  return [
    OnboardSnippet(
      'rest-whoami',
      '$auth${shellWord('${t.url}/api/v1/whoami')}',
    ),
    OnboardSnippet('rest-tasks', '$auth"${t.url}/api/v1/tasks?limit=5"'),
  ];
}
