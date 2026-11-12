// SPDX-License-Identifier: AGPL-3.0-or-later

// The text that hands one task to a coding agent, word for word what tix's
// web UI writes in its Hand to an agent dialog (tix `internal/handoff`). The
// prompts stay in English there too: an agent reads them, not the person.
// None of it carries a token; the agent brings its own.

import 'package:meta/meta.dart';

/// One task as a hand-off names it.
@immutable
class HandoffTask {
  /// The task [ref] titled [title] on the server at [server].
  const HandoffTask({
    required this.ref,
    required this.title,
    required this.server,
  });

  /// The task's reference, as tix shows it.
  final String ref;

  /// The task's title.
  final String title;

  /// The address of the server the task lives on.
  final String server;
}

/// The prompt for an agent that runs the tix CLI.
String handoffPrompt(HandoffTask t) {
  final ref = showRef(t.ref);
  return '${_intro(t)} '
      'Claim it first with `tix claim task $ref -o json` and keep the '
      'lease_token it prints. Read it with `tix task show $ref`, post progress '
      'as comments with `tix comment add $ref "..."`, and when it is finished '
      'close it with `tix claim release $ref --token <lease_token> --status '
      'done --comment "what you did"`.';
}

/// The MCP tools [handoffMcpPrompt] names, in the order it names them.
const handoffMcpTools = [
  'claim_task',
  'task_show',
  'comment_add',
  'claim_release',
];

/// The prompt for an agent that holds the tix MCP tools.
String handoffMcpPrompt(HandoffTask t) =>
    '${_intro(t)} Use the tix MCP tools. '
    'Claim it first with ${handoffMcpTools[0]} and keep the lease_token it '
    'returns. Read it with ${handoffMcpTools[1]}, post progress as comments '
    'with ${handoffMcpTools[2]}, and when it is finished close it with '
    '${handoffMcpTools[3]}, passing the lease token, status done and a '
    'comment saying what you did.';

String _intro(HandoffTask t) =>
    'Work on tix task ${showRef(t.ref)} ("${oneLine(t.title)}") '
    'on the tix server at ${t.server}.';

final _projectRef = RegExp(r'^.+-([0-9]+)$');

/// [ref] as tix shows it: a project reference in capitals, an id as it is.
String showRef(String ref) {
  final m = _projectRef.firstMatch(ref.trim());
  if (m == null || (int.tryParse(m[1]!) ?? 0) <= 0) return ref;
  return ref.toUpperCase();
}

/// [s] with every run of whitespace and control characters folded into one
/// space, so a title cannot break a command over two lines.
String oneLine(String s) => s
    .split(RegExp(r'[\s\x00-\x1f\x7f-\x9f]+'))
    .where((w) => w.isNotEmpty)
    .join(' ');

/// [s] as one word a POSIX shell passes on unexpanded.
String shellQuote(String s) => "'${s.replaceAll("'", r"'\''")}'";

/// One agent a task can be handed to.
@immutable
class HandoffClient {
  /// The client [id] named [name], started by [launch] with a prompt, or
  /// pasted into when [launch] is empty; [mcp] when it takes the MCP prompt.
  const HandoffClient(
    this.id,
    this.name, {
    this.launch = const [],
    this.mcp = false,
  });

  /// A stable id.
  final String id;

  /// What it is called.
  final String name;

  /// The words that start it with a prompt; empty when it has none.
  final List<String> launch;

  /// Whether it takes the MCP prompt rather than the CLI one.
  final bool mcp;
}

/// The clients tix documents, in its order.
const handoffClients = [
  HandoffClient('claude-code', 'Claude Code', launch: ['claude']),
  HandoffClient('codex', 'Codex', launch: ['codex']),
  HandoffClient('opencode', 'OpenCode', launch: ['opencode', '--prompt']),
  HandoffClient('gemini', 'Gemini CLI', launch: ['gemini', '-i']),
  HandoffClient('claude-desktop', 'Claude Desktop', mcp: true),
  HandoffClient('cursor', 'Cursor', launch: ['agent']),
  HandoffClient('vscode', 'VS Code', launch: ['code', 'chat']),
  HandoffClient('zed', 'Zed', mcp: true),
];

/// One client's hand-off: the command to run, empty when the client has
/// none, and the prompt it carries.
@immutable
class HandoffSnippet {
  /// [client]'s [command] carrying [prompt].
  const HandoffSnippet(this.client, this.command, this.prompt);

  /// The client.
  final HandoffClient client;

  /// The shell command that starts it, or empty.
  final String command;

  /// The prompt.
  final String prompt;
}

/// The hand-off of [t] to [client].
HandoffSnippet handoffFor(HandoffTask t, HandoffClient client) {
  final prompt = client.mcp ? handoffMcpPrompt(t) : handoffPrompt(t);
  final command = client.launch.isEmpty
      ? ''
      : '${client.launch.join(' ')} ${shellQuote(prompt)}';
  return HandoffSnippet(client, command, prompt);
}
