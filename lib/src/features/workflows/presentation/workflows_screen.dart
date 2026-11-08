// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/router/routes.dart';
import 'package:tix_mobile/src/core/session/access.dart';
import 'package:tix_mobile/src/core/widgets/async_body.dart';
import 'package:tix_mobile/src/data/models/project_admin.dart';
import 'package:tix_mobile/src/data/models/workflow_draft.dart';
import 'package:tix_mobile/src/features/workflows/application/workflows.dart';

/// The tenant's workflows, with a New workflow action for a credential
/// that may write them.
class WorkflowsScreen extends ConsumerWidget {
  /// Creates the screen.
  const WorkflowsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tix;
    final access = ref.watch(currentAccessProvider).value ?? Access.none;
    final list = ref.watch(workflowsProvider);
    final action = access.has(Scope.workflowWrite)
        ? TixAction(
            key: const Key('workflow.new'),
            label: l10n.workflowNew,
            icon: Icons.add,
            onPressed: () => showCreateWorkflowSheet(context, list.value ?? []),
          )
        : null;
    return TixPage(
      title: l10n.workflowsTitle,
      subtitle: l10n.workflowsSubtitle,
      primaryAction: action,
      body: AsyncBody(
        value: list,
        onRetry: () => ref.invalidate(workflowsProvider),
        data: (workflows) => workflows.isEmpty
            ? EmptyState(
                icon: Icons.account_tree_outlined,
                title: l10n.workflowsEmpty,
                action: action,
              )
            : RefreshIndicator(
                onRefresh: () => ref.refresh(workflowsProvider.future),
                child: ListView(
                  padding: const EdgeInsets.only(bottom: TixSpace.s7 * 2),
                  children: [
                    for (final w in workflows)
                      ListTile(
                        key: Key('workflow.${w.key}'),
                        leading: Icon(
                          Icons.account_tree_outlined,
                          color: t.muted,
                        ),
                        title: Wrap(
                          spacing: TixSpace.s2,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(w.name.isEmpty ? w.key : w.name),
                            Text(w.key, style: tixMono(context)),
                            if (w.builtin) TixBadge(l10n.workflowBuiltin),
                          ],
                        ),
                        subtitle: Text(
                          l10n.workflowStateCount(
                            w.definition?.states?.length ?? 0,
                          ),
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: t.lineStrong,
                        ),
                        onTap: () => context.go(Routes.workflow(w.key)),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

/// Opens the New workflow form: a key, a name and what to start from.
Future<void> showCreateWorkflowSheet(
  BuildContext context,
  List<Workflow> existing,
) => showTixSheet<void>(
  context,
  builder: (_) => _CreateWorkflow(existing: existing),
);

class _CreateWorkflow extends ConsumerStatefulWidget {
  const _CreateWorkflow({required this.existing});

  final List<Workflow> existing;

  @override
  ConsumerState<_CreateWorkflow> createState() => _CreateWorkflowState();
}

class _CreateWorkflowState extends ConsumerState<_CreateWorkflow> {
  final _key = TextEditingController();
  final _name = TextEditingController();
  String _from = '';
  Object? _error;
  var _busy = false;

  @override
  void dispose() {
    _key.dispose();
    _name.dispose();
    super.dispose();
  }

  bool get _taken =>
      widget.existing.any((w) => w.key == _key.text.trim().toLowerCase());

  Future<void> _create() async {
    final key = _key.text.trim();
    final name = _name.text.trim().isEmpty ? key : _name.text.trim();
    var draft = WorkflowDraft.minimal(key, name);
    for (final w in widget.existing) {
      if (w.key == _from) {
        draft = WorkflowDraft.of(w).copyWith(key: key, name: name);
      }
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final created = await ref
          .read(workflowsProvider.notifier)
          .create(draft.toInput());
      if (!mounted) return;
      final router = GoRouter.of(context);
      showTixToast(context, context.l10n.workflowCreated(created.name));
      Navigator.of(context).pop();
      router.go(Routes.workflow(created.key));
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = e;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final error = _error;
    return TixSheetBody(
      title: l10n.workflowNew,
      actions: [
        TixButton.quiet(
          label: l10n.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        TixButton.primary(
          key: const Key('workflow.create'),
          label: l10n.workflowCreate,
          icon: Icons.add,
          busy: _busy,
          onPressed: _taken ? null : _create,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (error != null) ...[
            TixNotice(
              errorDetail(l10n, error),
              key: const Key('workflow.error'),
              tone: TixNoticeTone.danger,
            ),
            const SizedBox(height: TixSpace.s3),
          ],
          TixTextField(
            fieldKey: const Key('workflow.key'),
            label: l10n.workflowKey,
            controller: _key,
            autofocus: true,
            help: l10n.workflowKeyHelp,
            error: _taken ? l10n.workflowKeyTaken : null,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: TixSpace.s3),
          TixTextField(
            fieldKey: const Key('workflow.name'),
            label: l10n.workflowName,
            controller: _name,
          ),
          const SizedBox(height: TixSpace.s3),
          TixSelectField<String>(
            fieldKey: const Key('workflow.from'),
            label: l10n.workflowStartFrom,
            value: _from,
            options: [
              TixOption('', l10n.workflowMinimal),
              for (final w in widget.existing)
                TixOption(
                  w.key,
                  l10n.workflowCopyOf(w.name.isEmpty ? w.key : w.name),
                ),
            ],
            onChanged: (v) => setState(() => _from = v ?? ''),
          ),
        ],
      ),
    );
  }
}
