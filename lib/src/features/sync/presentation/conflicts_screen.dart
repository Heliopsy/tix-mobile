// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/offline/outbox.dart';
import 'package:tix_mobile/src/core/router/routes.dart';
import 'package:tix_mobile/src/core/theme/layout.dart';
import 'package:tix_mobile/src/core/widgets/async_body.dart';

/// Conflicts waiting for the person, writes waiting to be sent, and the
/// history of settled conflicts, each reversible.
class ConflictsScreen extends ConsumerWidget {
  /// Creates the screen.
  const ConflictsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(syncStateProvider);
    final running = ref.watch(outboxSyncProvider.select((s) => s.running));
    final center = ref.read(outboxSyncProvider.notifier);
    return TixPage(
      title: l10n.syncConflictsTitle,
      subtitle: l10n.syncConflictsSubtitle,
      actions: [
        TixButton(
          key: const Key('sync.now'),
          label: l10n.syncSendNow,
          icon: Icons.sync,
          busy: running,
          onPressed: () => unawaited(center.replayNow()),
        ),
      ],
      body: AsyncBody(
        value: state,
        onRetry: () => ref.invalidate(syncStateProvider),
        data: (snap) => _Body(snap: snap),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.snap});

  final SyncSnapshot snap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final open = [
      for (final r in snap.conflicts)
        if (r.resolution == null) r,
    ];
    final settled = [
      for (final r in snap.conflicts)
        if (r.resolution != null) r,
    ];
    final waiting = [
      for (final e in snap.entries)
        if (e.state != OutboxState.conflict) e,
    ]..sort((a, b) => a.seq.compareTo(b.seq));
    if (open.isEmpty && settled.isEmpty && waiting.isEmpty) {
      return EmptyState(
        icon: Icons.cloud_done_outlined,
        title: l10n.syncEmptyTitle,
        body: l10n.syncConflictsEmptyBody,
      );
    }
    final center = ref.read(outboxSyncProvider.notifier);
    final fields = open.where((r) => r.kind == ConflictKind.fields).length;
    return ListView(
      key: const Key('sync.list'),
      padding: const EdgeInsets.only(bottom: TixSpace.s6),
      children: [
        if (open.isNotEmpty)
          TixSection(
            key: const Key('sync.conflicts'),
            title: l10n.syncConflicts(open.length),
            subtitle: l10n.syncConflictsHelp,
            children: [
              if (fields > 1)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    TixSpace.s3,
                    TixSpace.s2,
                    TixSpace.s3,
                    0,
                  ),
                  child: Wrap(
                    spacing: TixSpace.s2,
                    runSpacing: TixSpace.s2,
                    children: [
                      TixButton(
                        key: const Key('sync.keepAllMine'),
                        label: l10n.syncKeepAllMine,
                        size: TixButtonSize.small,
                        onPressed: () =>
                            unawaited(center.resolveAll(Resolution.mine)),
                      ),
                      TixButton(
                        key: const Key('sync.keepAllTheirs'),
                        label: l10n.syncKeepAllTheirs,
                        size: TixButtonSize.small,
                        onPressed: () =>
                            unawaited(center.resolveAll(Resolution.theirs)),
                      ),
                    ],
                  ),
                ),
              for (final r in open) ConflictCard(record: r),
            ],
          ),
        if (waiting.isNotEmpty)
          TixSection(
            key: const Key('sync.waiting'),
            title: l10n.syncWaiting(waiting.length),
            children: [for (final e in waiting) _EntryRow(entry: e)],
          ),
        if (settled.isNotEmpty)
          TixSection(
            key: const Key('sync.history'),
            title: l10n.syncHistory,
            subtitle: l10n.syncHistoryHelp,
            children: [for (final r in settled) _HistoryRow(record: r)],
          ),
      ],
    );
  }
}

/// The label of the attribute [field] as the person knows it.
String fieldLabel(AppLocalizations l10n, String field) => switch (field) {
  'title' => l10n.syncFieldTitle,
  'body' => l10n.syncFieldBody,
  'priority' => l10n.syncFieldPriority,
  'assignee_actor_id' => l10n.syncFieldAssignee,
  'due_at' => l10n.syncFieldDue,
  'tags' => l10n.syncFieldTags,
  'status' => l10n.syncFieldStatus,
  'recurrence' => l10n.syncFieldRecurrence,
  'parent_ref' => l10n.syncFieldParent,
  _ when field.startsWith('custom_fields.') => field.substring(14),
  _ => field,
};

/// [value] as text, or a dash for nothing.
String valueText(AppLocalizations l10n, Object? value) => switch (value) {
  null || '' => l10n.syncValueEmpty,
  final List<Object?> l => l.join(', '),
  _ => '$value',
};

/// One open conflict: what each side has, and the person's choices.
class ConflictCard extends ConsumerWidget {
  /// Draws [record].
  const ConflictCard({required this.record, super.key});

  /// The conflict.
  final ConflictRecord record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tix;
    final center = ref.read(outboxSyncProvider.notifier);
    final heading = record.taskTitle.isEmpty
        ? record.taskRef
        : '${record.taskRef}  ${record.taskTitle}';
    Widget actions(List<Widget> children) => Padding(
      padding: const EdgeInsets.only(top: TixSpace.s2),
      child: Wrap(
        spacing: TixSpace.s2,
        runSpacing: TixSpace.s2,
        children: children,
      ),
    );
    final body = switch (record.kind) {
      ConflictKind.fields => [
        for (final f in record.fields) _FieldSides(conflict: f),
        actions([
          TixButton(
            key: Key('sync.mine.${record.id}'),
            label: l10n.syncKeepMine,
            onPressed: () =>
                unawaited(center.resolve(record.id, Resolution.mine)),
          ),
          TixButton(
            key: Key('sync.theirs.${record.id}'),
            label: l10n.syncKeepTheirs,
            onPressed: () =>
                unawaited(center.resolve(record.id, Resolution.theirs)),
          ),
          TixButton.quiet(
            key: Key('sync.edit.${record.id}'),
            label: l10n.syncEditChange,
            icon: Icons.edit_outlined,
            onPressed: () => unawaited(_edit(context, ref)),
          ),
        ]),
      ],
      ConflictKind.deleted => [
        Text(l10n.syncDeletedBody, style: TextStyle(color: t.muted)),
        actions([
          TixButton(
            key: Key('sync.restore.${record.id}'),
            label: l10n.syncRestoreApply,
            onPressed: () =>
                unawaited(center.resolve(record.id, Resolution.restored)),
          ),
          TixButton.danger(
            key: Key('sync.discard.${record.id}'),
            label: l10n.syncDiscardMine,
            onPressed: () async {
              final ok = await confirmDestructive(
                context,
                title: l10n.syncDiscardMineTitle,
                body: l10n.syncDiscardMineBody,
                action: l10n.syncDiscardMine,
              );
              if (ok) await center.resolve(record.id, Resolution.discarded);
            },
          ),
        ]),
      ],
      ConflictKind.invalidMove => [
        Text(
          l10n.syncMoveRefused(record.wanted, record.reason),
          style: TextStyle(color: t.muted),
        ),
        actions([
          TixButton(
            key: Key('sync.edit.${record.id}'),
            label: l10n.syncMoveElsewhere,
            onPressed: () => unawaited(_edit(context, ref)),
          ),
          TixButton.quiet(
            key: Key('sync.theirs.${record.id}'),
            label: l10n.syncKeepTheirs,
            onPressed: () =>
                unawaited(center.resolve(record.id, Resolution.theirs)),
          ),
        ]),
      ],
    };
    return Padding(
      padding: const EdgeInsets.all(TixSpace.s3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SyncMark(SyncMarkKind.conflict),
              const SizedBox(width: TixSpace.s2),
              Expanded(
                child: InkWell(
                  onTap: () => context.go(
                    Routes.task(_projectOf(record.taskRef), record.taskRef),
                  ),
                  child: Text(
                    heading,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: TixSpace.s2),
          ...body,
        ],
      ),
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final move =
        record.kind == ConflictKind.invalidMove ||
        record.fields.any((f) => f.field == 'status');
    final fields = move
        ? [
            FieldConflict(
              field: 'to',
              mine: record.wanted.isEmpty
                  ? record.fields.first.mine
                  : record.wanted,
            ),
          ]
        : record.fields;
    final texts = await showTixSheet<Map<String, String>>(
      context,
      builder: (context) => _ValuesSheet(
        fields: [
          for (final f in fields)
            (
              key: f.field,
              label: f.field == 'to'
                  ? l10n.syncFieldStatus
                  : fieldLabel(l10n, f.field),
              initial: f.mine?.toString() ?? '',
              help: f.theirs == null
                  ? null
                  : l10n.syncTheirsWas(valueText(l10n, f.theirs)),
            ),
        ],
      ),
    );
    if (texts == null) return;
    final edited = {
      for (final f in fields) f.field: _typed(f.mine, texts[f.field] ?? ''),
    };
    await ref
        .read(outboxSyncProvider.notifier)
        .resolve(record.id, Resolution.edited, edited: edited);
  }

  static Object? _typed(Object? like, String text) => switch (like) {
    int _ => int.tryParse(text.trim()) ?? like,
    List<Object?> _ => [
      for (final s in text.split(','))
        if (s.trim().isNotEmpty) s.trim(),
    ],
    _ => text,
  };
}

String _projectOf(String ref) {
  final at = ref.lastIndexOf('-');
  return at <= 0 ? ref : ref.substring(0, at);
}

class _FieldSides extends StatelessWidget {
  const _FieldSides({required this.conflict});

  final FieldConflict conflict;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tix;
    Widget side(String label, Object? value, Key key) => Container(
      key: key,
      padding: const EdgeInsets.all(TixSpace.s2),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(TixRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: TixText.xs, color: t.muted),
          ),
          Text(valueText(l10n, value)),
        ],
      ),
    );
    final mine = side(
      l10n.syncMine,
      conflict.mine,
      Key('sync.side.mine.${conflict.field}'),
    );
    final theirs = side(
      l10n.syncTheirs,
      conflict.theirs,
      Key('sync.side.theirs.${conflict.field}'),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: TixSpace.s2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fieldLabel(l10n, conflict.field),
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: TixSpace.s1),
          if (context.isCompact)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                mine,
                const SizedBox(height: TixSpace.s1),
                theirs,
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: mine),
                const SizedBox(width: TixSpace.s2),
                Expanded(child: theirs),
              ],
            ),
        ],
      ),
    );
  }
}

/// What a waiting write does, in a few words.
String describeEntry(AppLocalizations l10n, OutboxEntry e) {
  final ref = e.target;
  return switch (e.op) {
    OutboxOp.update => l10n.syncOpUpdate(
      ref,
      [for (final k in e.values.keys) fieldLabel(l10n, k)].join(', '),
    ),
    OutboxOp.check => l10n.syncOpCheck(ref),
    OutboxOp.move => l10n.syncOpMove(ref, '${e.values['to']}'),
    OutboxOp.star => l10n.syncOpStar(ref),
    OutboxOp.unstar => l10n.syncOpUnstar(ref),
    OutboxOp.snooze => l10n.syncOpSnooze(ref),
    OutboxOp.create => l10n.syncOpCreate('${e.values['title']}'),
    OutboxOp.comment => l10n.syncOpComment(ref),
    OutboxOp.tagAdd => l10n.syncOpTagAdd(ref, '${e.values['name']}'),
    OutboxOp.tagRemove => l10n.syncOpTagRemove(ref, '${e.values['name']}'),
    OutboxOp.dependencyAdd => l10n.syncOpDependency(
      ref,
      '${e.values['depends_on']}',
    ),
    OutboxOp.artifactAdd => l10n.syncOpArtifact(ref),
    OutboxOp.restore => l10n.syncOpRestore(ref),
  };
}

class _EntryRow extends ConsumerWidget {
  const _EntryRow({required this.entry});

  final OutboxEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tix;
    final center = ref.read(outboxSyncProvider.notifier);
    final mark = switch (entry.state) {
      OutboxState.failed => SyncMarkKind.failed,
      OutboxState.needsCheck => SyncMarkKind.check,
      OutboxState.conflict => SyncMarkKind.conflict,
      OutboxState.pending =>
        entry.op == OutboxOp.create
            ? SyncMarkKind.draft
            : SyncMarkKind.unsynced,
    };
    Future<void> discard() async {
      final ok = await confirmDestructive(
        context,
        title: l10n.syncDiscardTitle,
        body: describeEntry(l10n, entry),
        action: l10n.syncDiscard,
      );
      if (ok) await center.discard(entry.id);
    }

    return Padding(
      key: Key('sync.entry.${entry.id}'),
      padding: const EdgeInsets.symmetric(
        horizontal: TixSpace.s3,
        vertical: TixSpace.s2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SyncMark(mark),
              const SizedBox(width: TixSpace.s2),
              Expanded(child: Text(describeEntry(l10n, entry))),
            ],
          ),
          if (entry.state == OutboxState.failed)
            Padding(
              padding: const EdgeInsets.only(top: TixSpace.s1),
              child: Text(
                l10n.syncRefused(
                  entry.errorMessage.isEmpty
                      ? entry.errorCode
                      : entry.errorMessage,
                ),
                style: TextStyle(color: t.danger, fontSize: TixText.sm),
              ),
            ),
          if (entry.state == OutboxState.needsCheck)
            Padding(
              padding: const EdgeInsets.only(top: TixSpace.s1),
              child: Text(
                l10n.syncCheckBody,
                style: TextStyle(color: t.muted, fontSize: TixText.sm),
              ),
            ),
          if (entry.state != OutboxState.pending)
            Padding(
              padding: const EdgeInsets.only(top: TixSpace.s2),
              child: Wrap(
                spacing: TixSpace.s2,
                runSpacing: TixSpace.s2,
                children: [
                  if (entry.state == OutboxState.needsCheck) ...[
                    TixButton(
                      key: Key('sync.sendAnyway.${entry.id}'),
                      label: l10n.syncSendAnyway,
                      size: TixButtonSize.small,
                      onPressed: () => unawaited(center.retry(entry.id)),
                    ),
                    TixButton.quiet(
                      key: Key('sync.alreadyThere.${entry.id}'),
                      label: l10n.syncAlreadyThere,
                      size: TixButtonSize.small,
                      onPressed: () => unawaited(center.forgetCreate(entry.id)),
                    ),
                  ] else ...[
                    TixButton(
                      key: Key('sync.retry.${entry.id}'),
                      label: l10n.syncRetry,
                      size: TixButtonSize.small,
                      onPressed: () => unawaited(center.retry(entry.id)),
                    ),
                    if (entry.op == OutboxOp.update)
                      TixButton.quiet(
                        key: Key('sync.editEntry.${entry.id}'),
                        label: l10n.syncEditChange,
                        size: TixButtonSize.small,
                        onPressed: () => unawaited(_edit(context, ref)),
                      ),
                  ],
                  TixButton.danger(
                    key: Key('sync.discardEntry.${entry.id}'),
                    label: l10n.syncDiscard,
                    size: TixButtonSize.small,
                    onPressed: () => unawaited(discard()),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final editable = [
      for (final MapEntry(:key, :value) in entry.values.entries)
        if (value is String || value is num) key,
    ];
    final texts = await showTixSheet<Map<String, String>>(
      context,
      builder: (context) => _ValuesSheet(
        fields: [
          for (final key in editable)
            (
              key: key,
              label: fieldLabel(l10n, key),
              initial: '${entry.values[key]}',
              help: null,
            ),
        ],
      ),
    );
    if (texts == null) return;
    final edited = {
      ...entry.values,
      for (final key in editable)
        key: entry.values[key] is num
            ? num.tryParse(texts[key]!.trim()) ?? entry.values[key]
            : texts[key],
    };
    await ref.read(outboxSyncProvider.notifier).retry(entry.id, values: edited);
  }
}

class _HistoryRow extends ConsumerWidget {
  const _HistoryRow({required this.record});

  final ConflictRecord record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tix;
    final what = switch (record.resolution!) {
      Resolution.mine => l10n.syncKeptMine,
      Resolution.theirs => l10n.syncKeptTheirs,
      Resolution.edited => l10n.syncKeptEdited,
      Resolution.restored => l10n.syncKeptRestored,
      Resolution.discarded => l10n.syncKeptDiscarded,
    };
    final fields = [for (final f in record.fields) fieldLabel(l10n, f.field)]
        .join(', ');
    return Padding(
      key: Key('sync.history.${record.id}'),
      padding: const EdgeInsets.symmetric(
        horizontal: TixSpace.s3,
        vertical: TixSpace.s2,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fields.isEmpty
                      ? record.taskRef
                      : '${record.taskRef} · $fields',
                ),
                Text(
                  record.auto ? l10n.syncByPolicy(what) : what,
                  style: TextStyle(color: t.muted, fontSize: TixText.sm),
                ),
              ],
            ),
          ),
          if (Outbox.reversible(record))
            TixButton.quiet(
              key: Key('sync.reverse.${record.id}'),
              label: l10n.syncReverse,
              icon: Icons.undo,
              size: TixButtonSize.small,
              onPressed: () => unawaited(
                ref.read(outboxSyncProvider.notifier).reverse(record.id),
              ),
            ),
        ],
      ),
    );
  }
}

/// One field of a [_ValuesSheet].
typedef _SheetField = ({
  String key,
  String label,
  String initial,
  String? help,
});

/// A sheet of text fields that answers with what was typed, by key.
class _ValuesSheet extends StatefulWidget {
  const _ValuesSheet({required this.fields});

  final List<_SheetField> fields;

  @override
  State<_ValuesSheet> createState() => _ValuesSheetState();
}

class _ValuesSheetState extends State<_ValuesSheet> {
  late final Map<String, TextEditingController> _controllers = {
    for (final f in widget.fields)
      f.key: TextEditingController(text: f.initial),
  };

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TixSheetBody(
      title: l10n.syncEditChangeTitle,
      actions: [
        TixButton.quiet(
          label: l10n.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        TixButton.primary(
          key: const Key('sync.edit.save'),
          label: l10n.syncEditSend,
          onPressed: () => Navigator.of(context).pop({
            for (final MapEntry(:key, :value) in _controllers.entries)
              key: value.text,
          }),
        ),
      ],
      child: Column(
        children: [
          for (final f in widget.fields)
            TixTextField(
              key: Key('sync.edit.${f.key}'),
              label: f.label,
              controller: _controllers[f.key],
              maxLines: f.key == 'body' ? 6 : 1,
              help: f.help,
            ),
        ],
      ),
    );
  }
}
