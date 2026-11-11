// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/features/tasks/application/handoff.dart';

/// Opens the Hand to an agent sheet for [task].
Future<void> showHandoff(BuildContext context, Task task) =>
    showTixSheet<void>(context, builder: (_) => HandoffSheet(task: task));

/// Copy-ready text that hands one task to a coding agent, as tix's web UI
/// offers it: the CLI prompt, the command that starts each client on it,
/// and the prompt for an agent holding the tix MCP tools. Nothing is sent.
class HandoffSheet extends ConsumerStatefulWidget {
  /// Hands [task] off.
  const HandoffSheet({required this.task, super.key});

  /// The task.
  final Task task;

  @override
  ConsumerState<HandoffSheet> createState() => _HandoffSheetState();
}

class _HandoffSheetState extends ConsumerState<HandoffSheet> {
  HandoffClient _client = handoffClients.first;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final muted = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: context.tix.muted);
    final server = ref.watch(sessionControllerProvider).value?.baseUrl ?? '';
    final task = HandoffTask(
      ref: widget.task.ref,
      title: widget.task.title,
      server: server,
    );
    final snippet = handoffFor(task, _client);
    return TixSheetBody(
      title: l10n.taskHandoff,
      actions: [
        TixButton.quiet(
          key: const Key('handoff.close'),
          label: l10n.close,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.taskHandoffNote, style: muted),
          _Heading(l10n.taskHandoffPrompt),
          _CopyText(
            key: const Key('handoff.prompt'),
            text: handoffPrompt(task),
          ),
          _Heading(l10n.taskHandoffClient),
          TixChoices<HandoffClient>(
            key: const Key('handoff.clients'),
            choices: [for (final c in handoffClients) TixChoice(c, c.name)],
            selected: _client,
            onSelected: (c) => setState(() => _client = c),
          ),
          const SizedBox(height: TixSpace.s2),
          if (snippet.command.isNotEmpty) ...[
            Text(l10n.taskHandoffRunHere, style: muted),
            const SizedBox(height: TixSpace.s2),
            _CopyText(key: const Key('handoff.command'), text: snippet.command),
          ] else ...[
            Text(l10n.taskHandoffPasteInto(_client.name), style: muted),
            const SizedBox(height: TixSpace.s2),
            _CopyText(key: const Key('handoff.paste'), text: snippet.prompt),
          ],
          _Heading(l10n.taskHandoffMcp),
          _CopyText(
            key: const Key('handoff.mcp'),
            text: handoffMcpPrompt(task),
          ),
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: TixSpace.s4, bottom: TixSpace.s2),
    child: Semantics(
      header: true,
      child: Text(text, style: Theme.of(context).textTheme.titleSmall),
    ),
  );
}

class _CopyText extends StatelessWidget {
  const _CopyText({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SelectableText(
            text,
            style: tixMono(context, size: TixText.sm),
          ),
        ),
        TixIconButton(
          key: const Key('handoff.copy'),
          icon: Icons.copy,
          tooltip: l10n.copyToClipboard,
          onPressed: () {
            unawaited(Clipboard.setData(ClipboardData(text: text)));
            showTixToast(context, l10n.copiedToClipboard);
          },
        ),
      ],
    );
  }
}
