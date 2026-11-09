// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/session/project_stars.dart';
import 'package:tix_mobile/src/core/theme/layout.dart';
import 'package:tix_mobile/src/data/models/bulk.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/data/models/workflow.dart';
import 'package:tix_mobile/src/features/tasks/application/listing.dart';
import 'package:tix_mobile/src/features/tasks/application/screen.dart';
import 'package:tix_mobile/src/features/tasks/presentation/detail/editors.dart';

/// The bulk actions, in the order the bar offers them.
enum BulkChoice {
  /// Move to a status.
  move,

  /// Set the priority.
  priority,

  /// Add a tag.
  tagAdd,

  /// Remove a tag.
  tagRemove,

  /// Assign.
  assign,

  /// Star.
  star,

  /// Unstar.
  unstar,

  /// Copy to a project.
  copy,

  /// Delete.
  delete,
}

/// Asks for one line of text in a sheet; null when cancelled.
Future<String?> askText(
  BuildContext context, {
  required String title,
  required String label,
  required String action,
  String initial = '',
}) => showTixSheet<String>(
  context,
  builder: (context) =>
      _TextSheet(title: title, label: label, action: action, initial: initial),
);

class _TextSheet extends StatefulWidget {
  const _TextSheet({
    required this.title,
    required this.label,
    required this.action,
    required this.initial,
  });

  final String title;
  final String label;
  final String action;
  final String initial;

  @override
  State<_TextSheet> createState() => _TextSheetState();
}

class _TextSheetState extends State<_TextSheet> {
  late final _text = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _submit() {
    final v = _text.text.trim();
    if (v.isNotEmpty) Navigator.of(context).pop(v);
  }

  @override
  Widget build(BuildContext context) => TixSheetBody(
    title: widget.title,
    actions: [
      TixButton.quiet(
        label: context.l10n.cancel,
        onPressed: () => Navigator.of(context).pop(),
      ),
      TixButton.primary(
        key: const Key('ask.ok'),
        label: widget.action,
        onPressed: _submit,
      ),
    ],
    child: TixTextField(
      label: widget.label,
      controller: _text,
      autofocus: true,
      fieldKey: const Key('ask.field'),
      onSubmitted: (_) => _submit(),
    ),
  );
}

/// The bar under a list in select mode: how many are picked, announced as
/// it changes, the actions that apply to all of them as one request with
/// one Undo, and the way out of select mode.
class BulkBar extends ConsumerWidget {
  /// Acts on the picked tasks of the listing for [query].
  const BulkBar({required this.query, super.key});

  /// The listing.
  final TaskQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tix;
    final selection = ref.watch(taskSelectionProvider(query.scope));
    final compact = context.isCompact;
    Widget button(BulkChoice c, IconData icon, String label) => TixIconButton(
      key: Key('bulk.${c.name}'),
      icon: icon,
      tooltip: label,
      color: c == BulkChoice.delete ? t.danger : null,
      onPressed: selection.isEmpty
          ? null
          : () => runBulkChoice(context, ref, query, c),
    );
    final primary = [
      button(BulkChoice.move, Icons.arrow_forward, l10n.bulkMove),
      button(BulkChoice.star, Icons.star, l10n.star),
      button(BulkChoice.assign, Icons.person_add_alt, l10n.assign),
      if (!compact) ...[
        button(BulkChoice.priority, Icons.low_priority, l10n.fieldPriority),
        button(BulkChoice.tagAdd, Icons.label_outline, l10n.bulkTagAdd),
        button(
          BulkChoice.tagRemove,
          Icons.label_off_outlined,
          l10n.bulkTagRemove,
        ),
        button(BulkChoice.unstar, Icons.star_outline, l10n.unstar),
        button(BulkChoice.copy, Icons.copy_all_outlined, l10n.bulkCopy),
      ],
      button(BulkChoice.delete, Icons.delete_outline, l10n.bulkDelete),
    ];
    return Material(
      key: const Key('bulk.bar'),
      color: t.accentSoft,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: t.line)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: TixSpace.s2),
          child: Row(
            children: [
              TixIconButton(
                key: const Key('bulk.clear'),
                icon: Icons.close,
                tooltip: l10n.bulkExit,
                onPressed: () => ref
                    .read(taskSelectionProvider(query.scope).notifier)
                    .exit(),
              ),
              Expanded(
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    l10n.bulkSelected(selection.length),
                    key: const Key('bulk.count'),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: t.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              ...primary,
              if (compact)
                PopupMenuButton<BulkChoice>(
                  key: const Key('bulk.more'),
                  tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
                  enabled: selection.isNotEmpty,
                  onSelected: (c) => runBulkChoice(context, ref, query, c),
                  itemBuilder: (_) => [
                    for (final (c, label) in [
                      (BulkChoice.priority, l10n.fieldPriority),
                      (BulkChoice.tagAdd, l10n.bulkTagAdd),
                      (BulkChoice.tagRemove, l10n.bulkTagRemove),
                      (BulkChoice.unstar, l10n.unstar),
                      (BulkChoice.copy, l10n.bulkCopy),
                    ])
                      PopupMenuItem(
                        key: Key('bulk.menu.${c.name}'),
                        value: c,
                        child: Text(label),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Asks what [choice] needs, then runs it over the picked tasks.
Future<void> runBulkChoice(
  BuildContext context,
  WidgetRef ref,
  TaskQuery query,
  BulkChoice choice,
) async {
  final l10n = context.l10n;
  final refs = ref.read(taskSelectionProvider(query.scope)).refs.toList();
  if (refs.isEmpty) return;
  final loaded = {
    for (final t
        in ref.read(taskListingProvider(query)).value?.items ?? const <Task>[])
      t.ref: t,
  };
  final picked = [for (final r in refs) ?loaded[r]];
  final taskContext = ref.read(taskContextProvider).value;
  BulkTaskInput? request;
  switch (choice) {
    case BulkChoice.move:
      final states = <String, WorkflowState>{};
      for (final task in picked) {
        final w = taskContext?.workflowOf(task);
        for (final s in w?.states ?? const <WorkflowState>[]) {
          states.putIfAbsent(s.id, () => s);
        }
      }
      final to = await showActionSheet<String>(
        context,
        title: l10n.bulkMoveTitle(refs.length),
        actions: [
          for (final s in states.values)
            TixSheetAction(
              key: Key('move.${s.id}'),
              value: s.id,
              label: s.name,
            ),
        ],
      );
      if (to != null) {
        request = BulkTaskInput(action: BulkAction.move, refs: refs, to: to);
      }
    case BulkChoice.priority:
      if (!context.mounted) return;
      final p = await showActionSheet<int>(
        context,
        title: l10n.fieldPriority,
        actions: [
          for (var i = 1; i <= 5; i++)
            TixSheetAction(
              key: Key('priority.$i'),
              value: i,
              label: l10n.priorityLabel('$i'),
            ),
        ],
      );
      if (p != null) {
        request = BulkTaskInput(
          action: BulkAction.priority,
          refs: refs,
          priority: p,
        );
      }
    case BulkChoice.tagAdd:
      final tag = await askText(
        context,
        title: l10n.bulkTagAdd,
        label: l10n.fieldTags,
        action: l10n.bulkTagAdd,
      );
      if (tag != null) {
        request = BulkTaskInput(
          action: BulkAction.tagAdd,
          refs: refs,
          tag: tag,
        );
      }
    case BulkChoice.tagRemove:
      final tags = {for (final task in picked) ...task.tags}.toList()..sort();
      final tag = await showActionSheet<String>(
        context,
        title: l10n.bulkTagRemove,
        actions: [
          for (final tg in tags)
            TixSheetAction(key: Key('tag.$tg'), value: tg, label: tg),
        ],
      );
      if (tag != null) {
        request = BulkTaskInput(
          action: BulkAction.tagRemove,
          refs: refs,
          tag: tag,
        );
      }
    case BulkChoice.assign:
      final picked = await pickActor(context, current: '', title: l10n.assign);
      if (picked != null) {
        request = BulkTaskInput(
          action: BulkAction.assign,
          refs: refs,
          assigneeActorId: picked.value,
        );
      }
    case BulkChoice.star:
      request = BulkTaskInput(action: BulkAction.star, refs: refs);
    case BulkChoice.unstar:
      request = BulkTaskInput(action: BulkAction.unstar, refs: refs);
    case BulkChoice.copy:
      final projects = taskContext?.projects ?? const <Project>[];
      final to = await showProjectPicker(
        context,
        title: l10n.bulkCopyTitle(refs.length),
        keyPrefix: 'copy',
        starred: ref.read(projectStarsProvider).value?.keys ?? const {},
        projects: [
          for (final p in projects)
            if (p.archivedAt == null) p,
        ],
      );
      if (to != null) {
        request = BulkTaskInput(
          action: BulkAction.copy,
          refs: refs,
          projectRef: to,
        );
      }
    case BulkChoice.delete:
      final ok = await confirmDestructive(
        context,
        title: l10n.bulkDeleteTitle(refs.length),
        body: l10n.bulkDeleteBody,
        action: l10n.bulkDelete,
      );
      if (ok) request = BulkTaskInput(action: BulkAction.delete, refs: refs);
  }
  if (request == null || !context.mounted) return;
  await runBulk(context, ref, query, request);
}

/// Sends [request] over the listing for [query] and says what happened,
/// with one Undo for everything that changed.
Future<void> runBulk(
  BuildContext context,
  WidgetRef ref,
  TaskQuery query,
  BulkTaskInput request,
) async {
  final l10n = context.l10n;
  final listing = ref.read(taskListingProvider(query).notifier);
  final BulkRun run;
  try {
    run = await listing.bulk(request);
  } on Object catch (e) {
    unawaited(TixHaptics.refuse());
    if (context.mounted) {
      showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
    }
    return;
  }
  ref.read(taskSelectionProvider(query.scope).notifier).exit();
  if (!context.mounted) return;
  final refused = run.result.refusals;
  final applied = run.result.applied;
  final message = refused.isEmpty
      ? l10n.bulkDone(applied)
      : l10n.bulkPartly(
          applied,
          refused.map((o) => '${o.ref}: ${o.error}').join('; '),
        );
  if (refused.isNotEmpty) unawaited(TixHaptics.refuse());
  showTixToast(
    context,
    message,
    tone: applied == 0 ? TixTone.danger : TixTone.accent,
    onUndo: applied == 0
        ? null
        : () async {
            try {
              await listing.undo(run);
            } on Object catch (e) {
              if (context.mounted) {
                showTixToast(
                  context,
                  errorMessage(l10n, e),
                  tone: TixTone.danger,
                );
              }
            }
          },
  );
}
