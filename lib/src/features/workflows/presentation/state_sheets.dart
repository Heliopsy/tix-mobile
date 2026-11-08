// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/data/models/project_admin.dart';
import 'package:tix_mobile/src/data/models/workflow_draft.dart';

/// The colour family of a draft state: its category, or the one tix
/// derives when it has none (done when terminal, todo when [initial], in
/// progress otherwise).
StatusCategory statusCategoryOfDraft(StateDraft s, {required bool initial}) =>
    switch (s.category) {
      StateCategory.todo => StatusCategory.todo,
      StateCategory.inProgress => StatusCategory.inProgress,
      StateCategory.blocked => StatusCategory.blocked,
      StateCategory.waiting => StatusCategory.waiting,
      StateCategory.done => StatusCategory.done,
      StateCategory.cancelled => StatusCategory.cancelled,
      null =>
        s.terminal
            ? StatusCategory.done
            : initial
            ? StatusCategory.todo
            : StatusCategory.inProgress,
    };

/// The name a person reads for the category [c]; null is "derived".
String stateCategoryName(AppLocalizations l10n, StateCategory? c) =>
    switch (c) {
      StateCategory.todo => l10n.categoryTodo,
      StateCategory.inProgress => l10n.categoryInProgress,
      StateCategory.blocked => l10n.categoryBlocked,
      StateCategory.waiting => l10n.categoryWaiting,
      StateCategory.done => l10n.categoryDone,
      StateCategory.cancelled => l10n.categoryCancelled,
      null => l10n.categoryDerived,
    };

/// What the state sheet was closed with.
enum StateSheetAction {
  /// Keep the edited state.
  save,

  /// Remove the state.
  remove,
}

/// What the state sheet answers: the action, the state, and whether it
/// should be the initial one.
typedef StateSheetResult = ({
  StateSheetAction action,
  StateDraft state,
  bool initial,
});

/// Opens the form for [state] of [draft], or for a new state when null.
Future<StateSheetResult?> showStateSheet(
  BuildContext context, {
  required WorkflowDraft draft,
  StateDraft? state,
}) => showTixSheet<StateSheetResult>(
  context,
  builder: (_) => _StateSheet(draft: draft, state: state),
);

class _StateSheet extends StatefulWidget {
  const _StateSheet({required this.draft, this.state});

  final WorkflowDraft draft;
  final StateDraft? state;

  @override
  State<_StateSheet> createState() => _StateSheetState();
}

class _StateSheetState extends State<_StateSheet> {
  late final StateDraft? _s = widget.state;
  late final _key = TextEditingController(text: _s?.key ?? '');
  late final _label = TextEditingController(text: _s?.label ?? '');
  late StateCategory? _category = _s?.category;
  late bool _terminal = _s?.terminal ?? false;
  late bool _revert = _s?.revertOnLeaseExpiry ?? false;
  late String _revertTo = _s?.revertTo ?? '';
  late bool _initial = _s != null && widget.draft.initial == _s.key;

  @override
  void dispose() {
    _key.dispose();
    _label.dispose();
    super.dispose();
  }

  StateDraft get _edited => (_s ?? const StateDraft(key: '')).copyWith(
    key: _key.text.trim(),
    label: _label.text.trim(),
    category: () => _category,
    terminal: _terminal,
    revertOnLeaseExpiry: _revert,
    revertTo: _revert ? _revertTo : '',
  );

  bool get _keyTaken {
    final k = _key.text.trim();
    return widget.draft.states.any((x) => x.key == k && !identical(x, _s));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final others = [
      for (final x in widget.draft.states)
        if (!identical(x, _s)) x,
    ];
    final key = _key.text.trim();
    final canSave = key.isNotEmpty && !_keyTaken;
    return TixSheetBody(
      title: _s == null
          ? l10n.workflowAddState
          : l10n.workflowEditState(_s.name),
      actions: [
        if (_s != null)
          TixButton.danger(
            key: const Key('state.remove'),
            label: l10n.remove,
            onPressed: () => Navigator.of(
              context,
            ).pop((action: StateSheetAction.remove, state: _s, initial: false)),
          ),
        TixButton.quiet(
          label: l10n.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        TixButton.primary(
          key: const Key('state.save'),
          label: _s == null ? l10n.workflowAddState : l10n.manageSave,
          onPressed: canSave
              ? () => Navigator.of(context).pop((
                  action: StateSheetAction.save,
                  state: _edited,
                  initial: _initial,
                ))
              : null,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TixTextField(
            fieldKey: const Key('state.key'),
            label: l10n.workflowStateKey,
            controller: _key,
            autofocus: _s == null,
            help: _s?.savedKey != null
                ? l10n.workflowStateKeyRename
                : l10n.workflowStateKeyHelp,
            error: _keyTaken ? l10n.workflowStateKeyTaken : null,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: TixSpace.s3),
          TixTextField(
            fieldKey: const Key('state.label'),
            label: l10n.workflowStateLabel,
            controller: _label,
          ),
          const SizedBox(height: TixSpace.s3),
          TixSelectField<String>(
            fieldKey: const Key('state.category'),
            label: l10n.workflowStateCategory,
            info: l10n.workflowStateCategoryInfo,
            value: _category?.value ?? '',
            options: [
              TixOption('', stateCategoryName(l10n, null)),
              for (final c in StateCategory.values)
                TixOption(c.value, stateCategoryName(l10n, c)),
            ],
            onChanged: (v) => setState(() {
              _category = null;
              for (final c in StateCategory.values) {
                if (c.value == v) _category = c;
              }
            }),
          ),
          const SizedBox(height: TixSpace.s2),
          TixSwitchRow(
            key: const Key('state.initial'),
            title: l10n.workflowStateInitial,
            subtitle: l10n.workflowInitialHelp,
            value: _initial,
            onChanged: (v) => setState(() => _initial = v),
          ),
          TixSwitchRow(
            key: const Key('state.terminal'),
            title: l10n.workflowTerminal,
            subtitle: l10n.workflowTerminalHelp,
            value: _terminal,
            onChanged: (v) => setState(() => _terminal = v),
          ),
          TixSwitchRow(
            key: const Key('state.revert'),
            title: l10n.workflowRevert,
            subtitle: l10n.workflowRevertHelp,
            value: _revert,
            onChanged: others.isEmpty
                ? null
                : (v) => setState(() {
                    _revert = v;
                    if (v && _revertTo.isEmpty) _revertTo = others.first.key;
                  }),
          ),
          if (_revert)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: TixSpace.s4),
              child: TixSelectField<String>(
                fieldKey: const Key('state.revertTo'),
                label: l10n.workflowRevertTo,
                value: _revertTo,
                options: [for (final x in others) TixOption(x.key, x.name)],
                onChanged: (v) => setState(() => _revertTo = v ?? _revertTo),
              ),
            ),
        ],
      ),
    );
  }
}

/// What a move demands of whoever makes it.
typedef TransitionRules = ({bool requiresComment, Scope? requiresScope});

/// Opens the rules of the move [transition] from [from] to [to].
Future<TransitionRules?> showTransitionRulesSheet(
  BuildContext context, {
  required String from,
  required String to,
  required TransitionDraft transition,
}) => showTixSheet<TransitionRules>(
  context,
  builder: (_) => _RulesSheet(from: from, to: to, transition: transition),
);

class _RulesSheet extends StatefulWidget {
  const _RulesSheet({
    required this.from,
    required this.to,
    required this.transition,
  });

  final String from;
  final String to;
  final TransitionDraft transition;

  @override
  State<_RulesSheet> createState() => _RulesSheetState();
}

class _RulesSheetState extends State<_RulesSheet> {
  late bool _comment = widget.transition.requiresComment;
  late Scope? _scope = widget.transition.requiresScope;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TixSheetBody(
      title: l10n.workflowRulesTitle(widget.from, widget.to),
      actions: [
        TixButton.quiet(
          label: l10n.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        TixButton.primary(
          key: const Key('rules.save'),
          label: l10n.manageSave,
          onPressed: () =>
              Navigator.of(context)
                  .pop((requiresComment: _comment, requiresScope: _scope)),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TixSwitchRow(
            key: const Key('rules.comment'),
            title: l10n.workflowNeedsComment,
            subtitle: l10n.workflowNeedsCommentHelp,
            value: _comment,
            onChanged: (v) => setState(() => _comment = v),
          ),
          const SizedBox(height: TixSpace.s2),
          TixSelectField<String>(
            fieldKey: const Key('rules.scope'),
            label: l10n.workflowRequiredScope,
            help: l10n.workflowRequiredScopeHelp,
            value: _scope?.value ?? '',
            options: [
              TixOption('', l10n.workflowNoScope),
              for (final s in Scope.values)
                if (s != Scope.all) TixOption(s.value, s.value),
            ],
            onChanged: (v) => setState(() {
              _scope = null;
              for (final s in Scope.values) {
                if (s.value == v) _scope = s;
              }
            }),
          ),
        ],
      ),
    );
  }
}
