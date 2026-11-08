// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/clock/clock.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/session/people.dart';
import 'package:tix_mobile/src/data/repositories/token_repository.dart';
import 'package:tix_mobile/src/features/tokens/application/tokens.dart';

/// Opens the form that issues a token for [actorId] (the caller when null),
/// then shows the value once.
Future<void> showIssueTokenSheet(
  BuildContext context, {
  required String? actorId,
}) async {
  final issued = await showTixSheet<IssuedToken>(
    context,
    builder: (_) => IssueTokenSheet(actorId: actorId),
  );
  if (issued != null && context.mounted) {
    await showTixSheet<void>(
      context,
      dismissible: false,
      builder: (_) => TokenValueSheet(issued: issued),
    );
  }
}

/// The issue-a-token form: a name, scopes the caller holds, an expiry.
class IssueTokenSheet extends ConsumerStatefulWidget {
  /// Issues into the listing of [actorId].
  const IssueTokenSheet({required this.actorId, super.key});

  /// The listing the token joins.
  final String? actorId;

  @override
  ConsumerState<IssueTokenSheet> createState() => _IssueTokenSheetState();
}

class _IssueTokenSheetState extends ConsumerState<IssueTokenSheet> {
  final _name = TextEditingController();
  final _scopes = <String>{};
  String _expiry = defaultTokenExpiry;
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final now = ref.read(clockProvider)();
    final choice = tokenExpiries.firstWhere((e) => e.key == _expiry);
    try {
      final issued = await ref
          .read(tokensProvider(widget.actorId).notifier)
          .issue(
            name: _name.text,
            scopes: [..._scopes],
            expiresAt: choice.from(now),
          );
      if (mounted) Navigator.of(context).pop(issued);
    } on TixException catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = errorMessage(context.l10n, e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final access = ref.watch(currentAccessProvider).value;
    final theme = Theme.of(context);
    bool held(String s) => access?.can(s) ?? false;
    return TixSheetBody(
      title: l10n.tokensIssue,
      actions: [
        TixButton.quiet(
          label: l10n.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        TixButton.primary(
          key: const Key('tokens.submit'),
          label: l10n.tokensIssueButton,
          busy: _busy,
          onPressed: _name.text.trim().isEmpty || _scopes.isEmpty
              ? null
              : _submit,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TixTextField(
            label: l10n.tokensName,
            controller: _name,
            fieldKey: const Key('tokens.name'),
            help: l10n.tokensNameHelp,
            autofocus: true,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: TixSpace.s4),
          Text(l10n.tokensScopes, style: theme.textTheme.titleMedium),
          const SizedBox(height: TixSpace.s2),
          Wrap(
            spacing: TixSpace.s2,
            runSpacing: TixSpace.s2,
            children: [
              for (final MapEntry(key: id, value: scopes)
                  in Scopes.presets.entries)
                if (scopes.every(held))
                  ActionChip(
                    key: Key('tokens.preset.$id'),
                    avatar: const Icon(Icons.auto_awesome_outlined, size: 16),
                    label: Text(_presetName(l10n, id)),
                    tooltip: _presetNote(l10n, id),
                    onPressed: () => setState(
                      () => _scopes
                        ..clear()
                        ..addAll(scopes),
                    ),
                  ),
            ],
          ),
          if (access?.canAll ?? false)
            CheckboxListTile(
              key: const Key('tokens.scope.*'),
              contentPadding: EdgeInsets.zero,
              value: _scopes.contains(Scopes.all),
              onChanged: (v) => setState(
                () => v! ? _scopes.add(Scopes.all) : _scopes.remove(Scopes.all),
              ),
              title: Text(
                Scopes.all,
                style: tixMono(context, size: TixText.sm),
              ),
              subtitle: Text(l10n.scopeAll),
            ),
          for (final MapEntry(key: group, value: scopes)
              in Scopes.groups.entries) ...[
            const SizedBox(height: TixSpace.s2),
            Text(_groupName(l10n, group), style: theme.textTheme.labelLarge),
            for (final s in scopes)
              CheckboxListTile(
                key: Key('tokens.scope.$s'),
                contentPadding: EdgeInsets.zero,
                dense: true,
                value: _scopes.contains(s),
                onChanged: held(s)
                    ? (v) => setState(
                        () => v! ? _scopes.add(s) : _scopes.remove(s),
                      )
                    : null,
                title: Text(s, style: tixMono(context, size: TixText.sm)),
                subtitle: Text(
                  held(s) ? scopeNote(l10n, s) : l10n.tokensNotHeld,
                ),
              ),
          ],
          const SizedBox(height: TixSpace.s3),
          Row(
            children: [
              Text(l10n.tokensExpiry, style: theme.textTheme.titleMedium),
              InfoTip(l10n.tokensExpiryInfo, size: 32),
            ],
          ),
          const SizedBox(height: TixSpace.s2),
          Wrap(
            spacing: TixSpace.s2,
            runSpacing: TixSpace.s2,
            children: [
              for (final e in tokenExpiries)
                ChoiceChip(
                  key: Key('tokens.expiry.${e.key}'),
                  label: Text(
                    e.days == 0
                        ? l10n.tokensNever
                        : e.days == 365
                        ? l10n.peopleYear
                        : l10n.peopleDays(e.days),
                  ),
                  selected: _expiry == e.key,
                  onSelected: (_) => setState(() => _expiry = e.key),
                ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: TixSpace.s3),
            Text(_error!, style: TextStyle(color: context.tix.danger)),
          ],
        ],
      ),
    );
  }

  static String _presetName(AppLocalizations l10n, String id) =>
      id == 'agent' ? l10n.tokensPresetAgent : l10n.tokensPresetRead;

  static String _presetNote(AppLocalizations l10n, String id) =>
      id == 'agent' ? l10n.tokensPresetAgentNote : l10n.tokensPresetReadNote;

  static String _groupName(AppLocalizations l10n, String id) => switch (id) {
    'tasks' => l10n.scopeGroupTasks,
    'projects' => l10n.scopeGroupProjects,
    'workflows' => l10n.scopeGroupWorkflows,
    'comments' => l10n.scopeGroupComments,
    'events' => l10n.scopeGroupEvents,
    'admin' => l10n.scopeGroupAdmin,
    _ => l10n.scopeGroupAccount,
  };
}

/// What [scope] allows, in one line.
String scopeNote(AppLocalizations l10n, String scope) => switch (scope) {
  Scopes.taskRead => l10n.scopeTaskRead,
  Scopes.taskWrite => l10n.scopeTaskWrite,
  Scopes.taskTransition => l10n.scopeTaskTransition,
  Scopes.taskClaim => l10n.scopeTaskClaim,
  Scopes.taskDelete => l10n.scopeTaskDelete,
  Scopes.taskReclaim => l10n.scopeTaskReclaim,
  Scopes.projectRead => l10n.scopeProjectRead,
  Scopes.projectWrite => l10n.scopeProjectWrite,
  Scopes.workflowRead => l10n.scopeWorkflowRead,
  Scopes.workflowWrite => l10n.scopeWorkflowWrite,
  Scopes.commentWrite => l10n.scopeCommentWrite,
  Scopes.artifactWrite => l10n.scopeArtifactWrite,
  Scopes.eventSubscribe => l10n.scopeEventSubscribe,
  Scopes.userAdmin => l10n.scopeUserAdmin,
  Scopes.totpAdmin => l10n.scopeTotpAdmin,
  Scopes.tokenAdmin => l10n.scopeTokenAdmin,
  Scopes.webhookAdmin => l10n.scopeWebhookAdmin,
  Scopes.tenantAdmin => l10n.scopeTenantAdmin,
  Scopes.syncAdmin => l10n.scopeSyncAdmin,
  Scopes.auditRead => l10n.scopeAuditRead,
  Scopes.export => l10n.scopeExport,
  Scopes.import => l10n.scopeImport,
  Scopes.globalAdmin => l10n.scopeGlobalAdmin,
  Scopes.accountRead => l10n.scopeAccountRead,
  _ => scope,
};

/// A token's value, shown once with Copy and a warning.
class TokenValueSheet extends StatelessWidget {
  /// Shows [issued]'s value.
  const TokenValueSheet({required this.issued, super.key});

  /// The token as issued, value and all.
  final IssuedToken issued;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TixSheetBody(
      title: l10n.tokensIssuedTitle(issued.name),
      actions: [
        TixButton.primary(
          key: const Key('secret.done'),
          label: l10n.secretDone,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
      child: OneTimeSecret(
        heading: l10n.tokensValue,
        note: l10n.tokensValueWarning,
        values: [issued.token],
      ),
    );
  }
}
