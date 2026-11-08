// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/durations.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/router/routes.dart';
import 'package:tix_mobile/src/core/session/access.dart';
import 'package:tix_mobile/src/core/widgets/async_body.dart';
import 'package:tix_mobile/src/data/models/project_admin.dart';
import 'package:tix_mobile/src/data/models/workflow_draft.dart';
import 'package:tix_mobile/src/features/workflows/application/workflows.dart';
import 'package:tix_mobile/src/features/workflows/presentation/state_sheets.dart';

/// One workflow's editor: its name and lease, its states in order, which
/// state can move to which, the routes from the initial state, where the
/// tasks of removed states go, and delete.
class WorkflowEditorScreen extends ConsumerWidget {
  /// The editor of workflow [workflowKey].
  const WorkflowEditorScreen({required this.workflowKey, super.key});

  /// The workflow's key.
  final String workflowKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final access = ref.watch(currentAccessProvider).value ?? Access.none;
    return AsyncBody(
      value: ref.watch(workflowDetailProvider(workflowKey)),
      onRetry: () => ref.invalidate(workflowDetailProvider(workflowKey)),
      loading: TixPage(title: l10n.workflowTitle, body: const SkeletonList()),
      data: (w) => _Editor(
        key: ValueKey(w.updatedAt ?? w.key),
        saved: w,
        canWrite: access.has(Scope.workflowWrite),
      ),
    );
  }
}

class _Editor extends ConsumerStatefulWidget {
  const _Editor({required this.saved, required this.canWrite, super.key});

  final Workflow saved;
  final bool canWrite;

  @override
  ConsumerState<_Editor> createState() => _EditorState();
}

class _EditorState extends ConsumerState<_Editor> {
  late final _original = WorkflowDraft.of(widget.saved);
  late WorkflowDraft _draft = _original;
  late final _name = TextEditingController(text: _draft.name);
  late final _lease = TextEditingController(text: _draft.defaultLease);
  Object? _error;
  var _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _lease.dispose();
    super.dispose();
  }

  void _edit(WorkflowDraft d) => setState(() => _draft = d);

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(workflowDetailProvider(widget.saved.key).notifier)
          .save(_draft.toInput());
      if (mounted) showTixToast(context, context.l10n.workflowSaved);
    } on Object catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = e;
        });
      }
    }
  }

  Future<void> _delete() async {
    final l10n = context.l10n;
    final ok = await confirmDestructive(
      context,
      title: l10n.workflowDeleteTitle(widget.saved.key),
      body: l10n.workflowDeleteBody,
      action: l10n.manageDelete,
    );
    if (!ok || !mounted) return;
    try {
      await ref
          .read(workflowDetailProvider(widget.saved.key).notifier)
          .delete();
      if (!mounted) return;
      showTixToast(context, l10n.workflowDeleted(widget.saved.key));
      context.go(Routes.workflows);
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _editState(int? index) async {
    final draft = _draft;
    final result = await showStateSheet(
      context,
      draft: draft,
      state: index == null ? null : draft.states[index],
    );
    if (result == null || !mounted) return;
    var next = switch (result.action) {
      StateSheetAction.save =>
        index == null
            ? draft.addState(result.state)
            : draft.replaceState(index, result.state),
      StateSheetAction.remove => draft.removeState(index!),
    };
    if (result.action == StateSheetAction.save && result.initial) {
      next = next.copyWith(initial: result.state.key);
    }
    _edit(next);
  }

  Future<void> _editRules(String from, String to) async {
    final t = _draft.transition(from, to);
    if (t == null) return;
    final rules = await showTransitionRulesSheet(
      context,
      from: _draft.state(from)?.name ?? from,
      to: _draft.state(to)?.name ?? to,
      transition: t,
    );
    if (rules == null || !mounted) return;
    _edit(
      _draft.setRules(
        from,
        to,
        requiresComment: rules.requiresComment,
        requiresScope: rules.requiresScope,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final write = widget.canWrite;
    final error = _error;
    final draft = _draft;
    final dirty = draft != _original;
    final removed = draft.removedFrom(widget.saved);
    final steps = draft.stepsFromInitial();
    return TixPage(
      title: draft.name.isEmpty ? draft.key : draft.name,
      subtitle: l10n.workflowSubtitle(draft.key),
      primaryAction: write && dirty
          ? TixAction(
              key: const Key('workflow.save'),
              label: l10n.manageSaveChanges,
              icon: Icons.check,
              onPressed: _busy ? () {} : _save,
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.only(bottom: TixSpace.s7 * 2),
        children: [
          Align(
            alignment: AlignmentDirectional.topStart,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: TixMeasure.form),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!write)
                    _Padded(
                      TixNotice(
                        l10n.workflowReadOnly,
                        key: const Key('workflow.readOnly'),
                      ),
                    ),
                  if (error != null)
                    _Padded(
                      TixNotice(
                        errorDetail(l10n, error),
                        key: const Key('workflow.error'),
                        title: l10n.workflowRefused,
                        tone: TixNoticeTone.danger,
                      ),
                    ),
                  TixSection(
                    title: l10n.workflowSectionGeneral,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(TixSpace.s4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TixTextField(
                              fieldKey: const Key('workflow.name'),
                              label: l10n.workflowName,
                              controller: _name,
                              enabled: write,
                              onChanged: (v) =>
                                  _edit(_draft.copyWith(name: v.trim())),
                            ),
                            const SizedBox(height: TixSpace.s3),
                            TixSelectField<String>(
                              fieldKey: const Key('workflow.initial'),
                              label: l10n.workflowInitial,
                              help: l10n.workflowInitialHelp,
                              value: draft.initial,
                              options: [
                                for (final s in draft.states)
                                  TixOption(s.key, s.name),
                              ],
                              onChanged: write
                                  ? (k) =>
                                        _edit(_draft.copyWith(initial: k ?? ''))
                                  : null,
                            ),
                            const SizedBox(height: TixSpace.s3),
                            TixTextField(
                              fieldKey: const Key('workflow.lease'),
                              label: l10n.workflowDefaultLease,
                              controller: _lease,
                              enabled: write,
                              hint: l10n.manageInherited,
                              help: _original.defaultLease.isEmpty
                                  ? l10n.manageDurationHelp
                                  : l10n.manageDurationSaved(
                                      humanDuration(
                                        l10n,
                                        _original.defaultLease,
                                      ),
                                    ),
                              onChanged: (v) => _edit(
                                _draft.copyWith(defaultLease: v.trim()),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  TixSection(
                    title: l10n.workflowSectionStates,
                    subtitle: write ? l10n.workflowStatesHelp : null,
                    trailing: write
                        ? TixButton(
                            key: const Key('workflow.addState'),
                            label: l10n.workflowAddState,
                            icon: Icons.add,
                            size: TixButtonSize.small,
                            onPressed: () => _editState(null),
                          )
                        : null,
                    children: [
                      ReorderableListView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        buildDefaultDragHandles: false,
                        proxyDecorator: (child, _, _) => Material(
                          color: context.tix.bg,
                          elevation: 2,
                          child: child,
                        ),
                        onReorderItem: write
                            ? (from, to) => _edit(_draft.moveState(from, to))
                            : (_, _) {},
                        children: [
                          for (final (i, s) in draft.states.indexed)
                            _StateRow(
                              key: ValueKey('state.$i.${s.key}'),
                              state: s,
                              index: i,
                              initial: s.key == draft.initial,
                              write: write,
                              onTap: write ? () => _editState(i) : null,
                            ),
                        ],
                      ),
                    ],
                  ),
                  TixSection(
                    title: l10n.workflowSectionTransitions,
                    subtitle: l10n.workflowTransitionsHelp,
                    children: [
                      for (final s in draft.states)
                        _MovesFrom(
                          key: Key('moves.${s.key}'),
                          draft: draft,
                          from: s,
                          write: write,
                          onToggle: (to) =>
                              _edit(_draft.toggleTransition(s.key, to)),
                          onRules: (to) => _editRules(s.key, to),
                        ),
                    ],
                  ),
                  TixSection(
                    title: l10n.workflowSectionRoutes,
                    info: l10n.workflowRoutesInfo,
                    children: [
                      for (final s in draft.states)
                        ListTile(
                          key: Key('route.${s.key}'),
                          dense: true,
                          title: Text(s.name),
                          trailing: switch (steps[s.key]) {
                            null => TixBadge(
                              l10n.workflowUnreachable,
                              tone: TixTone.warn,
                            ),
                            0 => TixBadge(
                              l10n.workflowInitialBadge,
                              tone: TixTone.accent,
                            ),
                            final n => Text(l10n.workflowSteps(n)),
                          },
                        ),
                    ],
                  ),
                  if (removed.isNotEmpty)
                    TixSection(
                      title: l10n.workflowSectionRemoved,
                      subtitle: l10n.workflowRemovedHelp,
                      children: [
                        for (final gone in removed)
                          Padding(
                            padding: const EdgeInsets.all(TixSpace.s4),
                            child: TixSelectField<String>(
                              fieldKey: Key('migrate.$gone'),
                              label: l10n.workflowMigrate(gone),
                              value: draft.migrate[gone] ?? '',
                              options: [
                                TixOption('', l10n.workflowMigrateNone),
                                for (final s in draft.states)
                                  TixOption(s.key, s.name),
                              ],
                              onChanged: write
                                  ? (to) => _edit(
                                      _draft.setMigration(
                                        gone,
                                        (to ?? '').isEmpty ? null : to,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                      ],
                    ),
                  if (write && !widget.saved.builtin)
                    TixSection(
                      title: l10n.manageDangerZone,
                      danger: true,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(TixSpace.s4),
                          child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: TixSpace.s3,
                            runSpacing: TixSpace.s2,
                            children: [
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: TixMeasure.text,
                                ),
                                child: Text(
                                  l10n.workflowDeleteHelp,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                              TixButton.danger(
                                key: const Key('workflow.delete'),
                                label: l10n.workflowDelete,
                                onPressed: _delete,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StateRow extends StatelessWidget {
  const _StateRow({
    required this.state,
    required this.index,
    required this.initial,
    required this.write,
    required this.onTap,
    super.key,
  });

  final StateDraft state;
  final int index;
  final bool initial;
  final bool write;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tix;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: TixSize.target + 8),
          padding: const EdgeInsets.only(left: TixSpace.s4),
          decoration: index == 0
              ? null
              : BoxDecoration(
                  border: Border(top: BorderSide(color: t.line)),
                ),
          child: Row(
            children: [
              StatusPill(
                label: state.name,
                category: statusCategoryOfDraft(state, initial: initial),
              ),
              const SizedBox(width: TixSpace.s2),
              Expanded(
                child: Wrap(
                  spacing: TixSpace.s2,
                  runSpacing: TixSpace.s1,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(state.key, style: tixMono(context)),
                    if (initial)
                      TixBadge(l10n.workflowInitialBadge, tone: TixTone.accent),
                    if (state.terminal) TixBadge(l10n.workflowTerminal),
                    if (state.revertOnLeaseExpiry)
                      TixBadge(l10n.workflowRevertsTo(state.revertTo)),
                  ],
                ),
              ),
              if (write)
                ReorderableDragStartListener(
                  index: index,
                  child: Tooltip(
                    message: l10n.manageDragToReorder,
                    child: SizedBox.square(
                      dimension: TixSize.target,
                      child: Icon(Icons.drag_handle, color: t.muted),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MovesFrom extends StatelessWidget {
  const _MovesFrom({
    required this.draft,
    required this.from,
    required this.write,
    required this.onToggle,
    required this.onRules,
    super.key,
  });

  final WorkflowDraft draft;
  final StateDraft from;
  final bool write;
  final ValueChanged<String> onToggle;
  final ValueChanged<String> onRules;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tix;
    return Padding(
      padding: const EdgeInsets.all(TixSpace.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.workflowCanMoveTo(from.name),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: TixSpace.s2),
          Wrap(
            spacing: TixSpace.s2,
            runSpacing: TixSpace.s1,
            children: [
              for (final to in draft.states)
                if (to.key != from.key)
                  _MoveChip(
                    key: Key('move.${from.key}.${to.key}'),
                    label: to.name,
                    transition: draft.transition(from.key, to.key),
                    write: write,
                    onToggle: () => onToggle(to.key),
                    onRules: () => onRules(to.key),
                  ),
            ],
          ),
          if (draft.transitions.every((x) => x.from != from.key))
            Padding(
              padding: const EdgeInsets.only(top: TixSpace.s1),
              child: Text(
                l10n.workflowNoMoves,
                style: TextStyle(fontSize: TixText.xs, color: t.muted),
              ),
            ),
        ],
      ),
    );
  }
}

class _MoveChip extends StatelessWidget {
  const _MoveChip({
    required this.label,
    required this.transition,
    required this.write,
    required this.onToggle,
    required this.onRules,
    super.key,
  });

  final String label;
  final TransitionDraft? transition;
  final bool write;
  final VoidCallback onToggle;
  final VoidCallback onRules;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tix;
    final tr = transition;
    final selected = tr != null;
    final ruled =
        tr != null && (tr.requiresComment || tr.requiresScope != null);
    return InputChip(
      selected: selected,
      onSelected: write ? (_) => onToggle() : null,
      isEnabled: write || selected,
      avatar: ruled
          ? Icon(
              tr.requiresComment
                  ? Icons.chat_bubble_outline
                  : Icons.lock_outline,
              size: 16,
              color: t.accent,
            )
          : null,
      showCheckmark: !ruled,
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: TixText.xs,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        color: selected ? t.accent : t.ink,
      ),
      side: BorderSide(color: selected ? t.accent : t.line),
      backgroundColor: t.bg,
      selectedColor: t.accentSoft,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      deleteIcon: selected && write
          ? Icon(Icons.tune, size: 16, color: t.accent)
          : null,
      deleteButtonTooltipMessage: l10n.workflowMoveRules,
      onDeleted: selected && write ? onRules : null,
      tooltip: tr == null
          ? null
          : [
              if (tr.requiresComment) l10n.workflowNeedsComment,
              if (tr.requiresScope != null)
                l10n.workflowNeedsScope(tr.requiresScope!.value),
            ].join('\n').ifEmpty(null),
    );
  }
}

extension on String {
  String? ifEmpty(String? other) => isEmpty ? other : this;
}

class _Padded extends StatelessWidget {
  const _Padded(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      TixSpace.s4,
      TixSpace.s4,
      TixSpace.s4,
      0,
    ),
    child: child,
  );
}
