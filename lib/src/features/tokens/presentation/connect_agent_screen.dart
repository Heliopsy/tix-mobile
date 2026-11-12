// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/router/routes.dart';
import 'package:tix_mobile/src/core/session/people.dart';
import 'package:tix_mobile/src/core/widgets/async_body.dart';
import 'package:tix_mobile/src/data/repositories/token_repository.dart';
import 'package:tix_mobile/src/features/tokens/application/connect_agent.dart';
import 'package:tix_mobile/src/features/tokens/presentation/token_sheets.dart';

/// How the screen's commands reach the server.
enum ConnectWay {
  /// The tix command line.
  cli,

  /// An MCP client running `tix mcp`.
  mcp,

  /// The terminal interface over SSH.
  ssh,

  /// The HTTP API.
  api,

  /// The agent skill.
  skill,
}

/// Every command a person needs to point a CLI, an MCP client or an agent at
/// the active server, filled in with its address, the tenant and, once one
/// is issued here, a token, as tix's web Connect an agent screen.
///
/// An issued token lives only in this screen's state: it is never stored,
/// and leaving the screen drops it.
class ConnectAgentScreen extends ConsumerStatefulWidget {
  /// Creates the screen.
  const ConnectAgentScreen({super.key});

  @override
  ConsumerState<ConnectAgentScreen> createState() => _ConnectAgentScreenState();
}

class _ConnectAgentScreenState extends ConsumerState<ConnectAgentScreen> {
  IssuedToken? _issued;
  ConnectWay _way = ConnectWay.cli;
  String _install = 'install-unix';
  String _client = 'claude-code';
  String _skill = 'skill-project';

  Future<void> _issue(Access access) async {
    final held = [
      for (final s in agentScopes)
        if (access.can(s)) s,
    ];
    final issued = await showTixSheet<IssuedToken>(
      context,
      builder: (_) => IssueTokenSheet(
        actorId: access.me.id,
        initialName: agentTokenName,
        initialScopes: held,
      ),
    );
    if (issued != null && mounted) setState(() => _issued = issued);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final target = ref.watch(connectTargetProvider);
    return TixPage(
      title: l10n.connectAgentTitle,
      body: AsyncBody(
        value: target,
        onRetry: () => ref.invalidate(connectTargetProvider),
        data: (base) {
          if (base == null) return const SizedBox.shrink();
          final access = ref.watch(currentAccessProvider).value;
          final issued = _issued;
          final t = issued == null
              ? base
              : OnboardTarget(
                  url: base.url,
                  tenant: base.tenant,
                  token: issued.token,
                  version: base.version,
                  sshHost: base.sshHost,
                );
          return ListView(
            padding: const EdgeInsets.only(bottom: TixSpace.s7),
            children: [
              _Intro(target: t, handle: access?.me.handle ?? ''),
              _Credential(
                issued: issued,
                canIssue: access?.can(Scopes.tokenAdmin) ?? false,
                onIssue: access == null ? null : () => _issue(access),
                onSsh: () => setState(() => _way = ConnectWay.ssh),
              ),
              TixSection(
                title: l10n.connectAgentStepPick,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(TixSpace.s3),
                    child: TixChoices<ConnectWay>(
                      key: const Key('connect.ways'),
                      choices: [
                        for (final w in ConnectWay.values)
                          TixChoice(w, _wayName(l10n, w)),
                      ],
                      selected: _way,
                      onSelected: (w) => setState(() => _way = w),
                    ),
                  ),
                ],
              ),
              TixSection(
                key: Key('connect.pane.${_way.name}'),
                title: l10n.connectAgentStepCopy(_wayName(l10n, _way)),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(TixSpace.s3),
                    child: switch (_way) {
                      ConnectWay.cli => _CliPane(
                        target: t,
                        install: _install,
                        onInstall: (id) => setState(() => _install = id),
                      ),
                      ConnectWay.mcp => _McpPane(
                        target: t,
                        client: _client,
                        onClient: (id) => setState(() => _client = id),
                        onInstall: () => setState(() => _way = ConnectWay.cli),
                      ),
                      ConnectWay.ssh => _SshPane(target: t),
                      ConnectWay.api => _ApiPane(target: t),
                      ConnectWay.skill => _SkillPane(
                        skill: _skill,
                        onSkill: (id) => setState(() => _skill = id),
                      ),
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  static String _wayName(AppLocalizations l10n, ConnectWay w) => switch (w) {
    ConnectWay.cli => l10n.connectAgentCli,
    ConnectWay.mcp => l10n.connectAgentMcp,
    ConnectWay.ssh => l10n.connectAgentSsh,
    ConnectWay.api => l10n.connectAgentApi,
    ConnectWay.skill => l10n.connectAgentSkill,
  };
}

class _Intro extends StatelessWidget {
  const _Intro({required this.target, required this.handle});

  final OnboardTarget target;
  final String handle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final mono = tixMono(context, size: TixText.sm);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        TixSpace.gutter,
        TixSpace.s2,
        TixSpace.gutter,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.connectAgentIntro,
                  style: TextStyle(color: context.tix.muted),
                ),
              ),
              InfoTip(l10n.connectAgentInfo),
            ],
          ),
          const SizedBox(height: TixSpace.s2),
          TixPropertyList(
            children: [
              TixPropertyRow(
                label: l10n.connectAgentServer,
                child: SelectableText(
                  target.url,
                  key: const Key('connect.server'),
                  style: mono,
                ),
              ),
              if (target.tenant.isNotEmpty)
                TixPropertyRow(
                  label: l10n.connectAgentTenant,
                  child: SelectableText(target.tenant, style: mono),
                ),
              if (handle.isNotEmpty)
                TixPropertyRow(
                  label: l10n.connectAgentSignedInAs,
                  child: SelectableText(handle, style: mono),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Credential extends StatelessWidget {
  const _Credential({
    required this.issued,
    required this.canIssue,
    required this.onIssue,
    required this.onSsh,
  });

  final IssuedToken? issued;
  final bool canIssue;
  final VoidCallback? onIssue;
  final VoidCallback onSsh;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final muted = TextStyle(color: context.tix.muted);
    final token = issued;
    return TixSection(
      key: const Key('connect.credential'),
      title: l10n.connectAgentStepCredential,
      children: [
        Padding(
          padding: const EdgeInsets.all(TixSpace.s3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (token != null) ...[
                OneTimeSecret(
                  key: const Key('connect.secret'),
                  heading: l10n.tokensIssuedTitle(token.name),
                  note: l10n.connectAgentTokenFilled,
                  values: [token.token],
                ),
                const SizedBox(height: TixSpace.s3),
                _Snippet(
                  snippet: exportSnippet(token.token),
                  note: l10n.connectAgentExportNote,
                ),
              ] else ...[
                Text(l10n.connectAgentTokenNeeded),
                const SizedBox(height: TixSpace.s3),
                if (canIssue)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TixButton.primary(
                      key: const Key('connect.issue'),
                      label: l10n.tokensIssue,
                      icon: Icons.add,
                      onPressed: onIssue,
                    ),
                  )
                else
                  Text(
                    l10n.connectAgentNoTokenAdmin,
                    key: const Key('connect.noAdmin'),
                    style: muted,
                  ),
              ],
              if (canIssue) ...[
                _Snippet(
                  snippet: OnboardSnippet('token-cmd', tokenCommand()),
                  title: l10n.connectAgentFromCli,
                ),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TixButton.quiet(
                    key: const Key('connect.myTokens'),
                    label: l10n.connectAgentSeeTokens,
                    onPressed: () => context.push(Routes.myTokens),
                  ),
                ),
              ],
              _Snippet(
                snippet: rotateSnippet,
                title: l10n.connectAgentRotate,
                note: l10n.connectAgentRotateNote,
              ),
              const SizedBox(height: TixSpace.s2),
              Text(l10n.connectAgentSshNoToken, style: muted),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TixButton.quiet(
                  key: const Key('connect.openSsh'),
                  label: l10n.connectAgentOpenSsh,
                  onPressed: onSsh,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CliPane extends StatelessWidget {
  const _CliPane({
    required this.target,
    required this.install,
    required this.onInstall,
  });

  final OnboardTarget target;
  final String install;
  final ValueChanged<String> onInstall;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ways = installSnippets(target);
    final chosen = ways.firstWhere(
      (s) => s.id == install,
      orElse: () => ways.first,
    );
    final cli = cliSnippets(target);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Heading(l10n.connectAgentInstall),
        Text(
          l10n.connectAgentInstallNote,
          style: TextStyle(color: context.tix.muted),
        ),
        const SizedBox(height: TixSpace.s2),
        TixChoices<String>(
          key: const Key('connect.install'),
          choices: [for (final s in ways) TixChoice(s.id, _title(l10n, s.id))],
          selected: chosen.id,
          onSelected: onInstall,
        ),
        _Snippet(snippet: chosen, note: _note(l10n, chosen.id)),
        for (final s in cli)
          _Snippet(
            snippet: s,
            title: _title(l10n, s.id),
            note: _note(l10n, s.id),
          ),
      ],
    );
  }
}

class _McpPane extends StatelessWidget {
  const _McpPane({
    required this.target,
    required this.client,
    required this.onClient,
    required this.onInstall,
  });

  final OnboardTarget target;
  final String client;
  final ValueChanged<String> onClient;
  final VoidCallback onInstall;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final clients = mcpClients(target);
    final chosen = clients.firstWhere(
      (c) => c.client.id == client,
      orElse: () => clients.first,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.connectAgentMcpNote,
          style: TextStyle(color: context.tix.muted),
        ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TixButton.quiet(
            label: l10n.connectAgentInstall,
            onPressed: onInstall,
          ),
        ),
        TixChoices<String>(
          key: const Key('connect.clients'),
          choices: [
            for (final c in clients) TixChoice(c.client.id, c.client.name),
          ],
          selected: chosen.client.id,
          onSelected: onClient,
        ),
        for (final s in chosen.snippets)
          _Snippet(
            snippet: s,
            title: s.path.isEmpty ? l10n.connectAgentCommandLine : null,
            note: _note(l10n, s.id),
          ),
        _Snippet(
          snippet: mcpPreviewSnippet,
          title: l10n.connectAgentSeeTools,
          note: l10n.connectAgentSeeToolsNote,
        ),
      ],
    );
  }
}

class _SshPane extends StatelessWidget {
  const _SshPane({required this.target});

  final OnboardTarget target;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final snippets = sshSnippets(target);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.connectAgentSshNote,
          style: TextStyle(color: context.tix.muted),
        ),
        const SizedBox(height: TixSpace.s2),
        Text(
          l10n.connectAgentSshAddress,
          key: const Key('connect.sshAddress'),
          style: TextStyle(color: context.tix.muted),
        ),
        for (final s in snippets)
          _Snippet(
            snippet: s,
            title: _title(l10n, s.id),
            note: _note(l10n, s.id),
          ),
      ],
    );
  }
}

class _ApiPane extends StatelessWidget {
  const _ApiPane({required this.target});

  final OnboardTarget target;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final s in restSnippets(target))
          _Snippet(snippet: s, title: _title(l10n, s.id)),
        const SizedBox(height: TixSpace.s2),
        Text(
          l10n.connectAgentOpenApi('${target.url}/api/v1/openapi.json'),
          style: TextStyle(color: context.tix.muted),
        ),
      ],
    );
  }
}

class _SkillPane extends StatelessWidget {
  const _SkillPane({required this.skill, required this.onSkill});

  final String skill;
  final ValueChanged<String> onSkill;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final skills = skillSnippets();
    final chosen = skills.firstWhere(
      (s) => s.id == skill,
      orElse: () => skills.first,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.connectAgentSkillNote,
          style: TextStyle(color: context.tix.muted),
        ),
        const SizedBox(height: TixSpace.s2),
        TixChoices<String>(
          key: const Key('connect.skills'),
          choices: [
            for (final s in skills) TixChoice(s.id, _title(l10n, s.id)),
          ],
          selected: chosen.id,
          onSelected: onSkill,
        ),
        _Snippet(snippet: chosen, note: _note(l10n, chosen.id)),
      ],
    );
  }
}

/// The title tix's web gives the snippet [id].
String _title(AppLocalizations l10n, String id) => switch (id) {
  'install-unix' => l10n.connectAgentInstallUnix,
  'install-windows' => l10n.connectAgentInstallWindows,
  'install-go' => l10n.connectAgentInstallGo,
  'install-container' => l10n.connectAgentInstallContainer,
  'cli-ctx' => l10n.connectAgentSaveContext,
  'cli-verify' => l10n.connectAgentVerify,
  'ssh-key' => l10n.connectAgentSshKey,
  'ssh-tui' => l10n.connectAgentSshTui,
  'ssh-cmd' => l10n.connectAgentSshCmd,
  'ssh-export' => l10n.connectAgentSshExport,
  'ssh-watch' => l10n.connectAgentSshWatch,
  'rest-whoami' => l10n.connectAgentRestWhoami,
  'rest-tasks' => l10n.connectAgentRestTasks,
  'skill-project' => l10n.connectAgentSkillProject,
  'skill-user' => l10n.connectAgentSkillUser,
  'skill-other' => l10n.connectAgentSkillOther,
  _ => id,
};

/// The note tix's web gives the snippet [id], or null for none.
String? _note(AppLocalizations l10n, String id) => switch (id) {
  'install-unix' => l10n.connectAgentInstallUnixNote,
  'install-windows' => l10n.connectAgentInstallWindowsNote,
  'install-go' => l10n.connectAgentInstallGoNote,
  'install-container' => l10n.connectAgentInstallContainerNote,
  'cli-ctx' => l10n.connectAgentSaveContextNote,
  'cli-verify' => l10n.connectAgentVerifyNote,
  'mcp-claude-code-2' => l10n.connectAgentMcpProjectRoot,
  'mcp-codex-2' => l10n.connectAgentMcpCodex,
  'mcp-opencode-1' => l10n.connectAgentMcpOpenCode,
  'mcp-gemini-1' => l10n.connectAgentMcpGemini,
  'mcp-claude-desktop-1' => l10n.connectAgentMcpClaudeDesktop,
  'mcp-cursor-1' => l10n.connectAgentMcpCursor,
  'mcp-vscode-1' => l10n.connectAgentMcpVscode,
  'mcp-vscode-2' => l10n.connectAgentMcpVscodeCli,
  'mcp-zed-1' => l10n.connectAgentMcpZed,
  'ssh-key' => l10n.connectAgentSshKeyNote,
  'ssh-cmd' => l10n.connectAgentSshCmdNote,
  'ssh-export' => l10n.connectAgentSshExportNote,
  'ssh-watch' => l10n.connectAgentSshWatchNote,
  'skill-project' => l10n.connectAgentSkillProjectNote,
  'skill-user' => l10n.connectAgentSkillUserNote,
  'skill-other' => l10n.connectAgentSkillOtherNote,
  _ => null,
};

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: TixSpace.s3, bottom: TixSpace.s1),
    child: Semantics(
      header: true,
      child: Text(text, style: Theme.of(context).textTheme.titleSmall),
    ),
  );
}

/// One copyable block: its title or file, a note, the text and Copy.
class _Snippet extends StatelessWidget {
  const _Snippet({required this.snippet, this.title, this.note});

  final OnboardSnippet snippet;
  final String? title;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tix;
    final heading = snippet.path.isNotEmpty ? snippet.path : title;
    return Column(
      key: Key('connect.snippet.${snippet.id}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (heading != null) _Heading(heading),
        if (note case final n?) ...[
          Text(
            n,
            style: TextStyle(color: t.muted, fontSize: TixText.sm),
          ),
          const SizedBox(height: TixSpace.s1),
        ],
        Container(
          margin: const EdgeInsets.only(top: TixSpace.s1),
          padding: const EdgeInsetsDirectional.only(start: TixSpace.s3),
          decoration: BoxDecoration(
            color: t.surface,
            border: Border.all(color: t.line),
            borderRadius: BorderRadius.circular(TixRadius.md),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: TixSpace.s3),
                  child: SelectableText(
                    snippet.text,
                    key: Key('connect.text.${snippet.id}'),
                    style: tixMono(context, size: TixText.sm, color: t.ink),
                  ),
                ),
              ),
              TixIconButton(
                key: Key('connect.copy.${snippet.id}'),
                icon: Icons.copy,
                tooltip: l10n.copyToClipboard,
                onPressed: () {
                  unawaited(
                    Clipboard.setData(ClipboardData(text: snippet.text)),
                  );
                  showTixToast(context, l10n.copiedToClipboard);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: TixSpace.s2),
      ],
    );
  }
}
