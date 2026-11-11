// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/l10n/via_label.dart';
import 'package:tix_mobile/src/core/platform/attachments.dart';
import 'package:tix_mobile/src/core/session/access.dart';
import 'package:tix_mobile/src/core/time/times.dart';
import 'package:tix_mobile/src/data/models/actor.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/features/tasks/application/task_detail.dart';
import 'package:tix_mobile/src/features/tasks/application/tasks.dart';
import 'package:tix_mobile/src/features/tasks/presentation/detail/actions.dart';
import 'package:tix_mobile/src/features/tasks/presentation/detail/editors.dart';
import 'package:tix_mobile/src/features/tasks/presentation/detail/mentions.dart';

/// The largest artifact tix stores inline: 1 MiB.
const int maxArtifactBytes = 1024 * 1024;

/// Which of the activity panels shows.
enum ActivityTab {
  /// The comments and the composer.
  comments,

  /// The audit trail.
  history,

  /// The artifacts.
  artifacts,
}

/// Comments, History and Artifacts behind one segmented control with
/// their counts, so each is one press away and none folds away.
class ActivitySection extends ConsumerWidget {
  /// The activity of [task], showing [tab].
  const ActivitySection({
    required this.task,
    required this.tab,
    required this.onTab,
    this.composerFocus,
    super.key,
  });

  /// The task.
  final Task task;

  /// The panel shown.
  final ActivityTab tab;

  /// Switches the panel.
  final ValueChanged<ActivityTab> onTab;

  /// The comment box's focus, so a key can move there.
  final FocusNode? composerFocus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final comments = ref.watch(taskCommentsProvider(task.ref)).value?.length;
    final artifacts = ref.watch(taskArtifactsProvider(task.ref)).value?.length;
    String label(String name, int? n) =>
        n == null || n == 0 ? name : '$name $n';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: TixSpace.s5),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<ActivityTab>(
              key: const Key('activity.tabs'),
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: ActivityTab.comments,
                  icon: const Icon(Icons.chat_bubble_outline, size: 16),
                  label: Text(label(l10n.taskDetailComments, comments)),
                ),
                ButtonSegment(
                  value: ActivityTab.history,
                  icon: const Icon(Icons.history, size: 16),
                  label: Text(l10n.taskDetailHistory),
                ),
                ButtonSegment(
                  value: ActivityTab.artifacts,
                  icon: const Icon(Icons.attach_file, size: 16),
                  label: Text(label(l10n.taskDetailArtifacts, artifacts)),
                ),
              ],
              selected: {tab},
              onSelectionChanged: (s) => onTab(s.first),
            ),
          ),
        ),
        const SizedBox(height: TixSpace.s3),
        switch (tab) {
          ActivityTab.comments => CommentsPanel(
            task: task,
            focusNode: composerFocus,
          ),
          ActivityTab.history => HistoryPanel(task: task),
          ActivityTab.artifacts => ArtifactsPanel(task: task),
        },
      ],
    );
  }
}

/// A task's comments, oldest first, and the box to add one.
class CommentsPanel extends ConsumerStatefulWidget {
  /// The comments of [task].
  const CommentsPanel({required this.task, this.focusNode, super.key});

  /// The task.
  final Task task;

  /// The composer's focus.
  final FocusNode? focusNode;

  @override
  ConsumerState<CommentsPanel> createState() => _CommentsPanelState();
}

class _CommentsPanelState extends ConsumerState<CommentsPanel> {
  final _composer = TextEditingController();
  var _sending = false;

  @override
  void initState() {
    super.initState();
    _composer.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _composer.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final body = _composer.text.trim();
    if (body.isEmpty || _sending) return;
    setState(() => _sending = true);
    final l10n = context.l10n;
    final ok = await tryAction(
      context,
      () => ref.read(taskCommentsProvider(widget.task.ref).notifier).add(body),
      success: l10n.taskDetailCommentAdded,
    );
    if (!mounted) return;
    setState(() => _sending = false);
    if (ok) _composer.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final provider = taskCommentsProvider(widget.task.ref);
    final comments = ref.watch(provider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        switch (comments) {
          AsyncData(:final value) when value.isEmpty => Padding(
            padding: const EdgeInsets.symmetric(vertical: TixSpace.s3),
            child: Text(
              l10n.taskDetailNoComments,
              style: TextStyle(color: context.tix.muted),
            ),
          ),
          AsyncData(:final value) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final c in value)
                _CommentTile(task: widget.task, comment: c),
            ],
          ),
          AsyncError(:final error) => ErrorState(
            error: error,
            compact: true,
            onRetry: () => ref.invalidate(provider),
          ),
          _ => const SkeletonList(rows: 2, inline: true),
        },
        const SizedBox(height: TixSpace.s3),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: TixMeasure.form),
          child: MentionTextField(
            fieldKey: const Key('comment.field'),
            controller: _composer,
            focusNode: widget.focusNode,
            label: l10n.taskDetailCommentLabel,
            hint: l10n.taskDetailCommentHint,
            minLines: 2,
            maxLines: 8,
            onSubmit: _send,
          ),
        ),
        const SizedBox(height: TixSpace.s2),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TixButton(
            key: const Key('comment.send'),
            label: l10n.taskDetailCommentSend,
            icon: Icons.send_outlined,
            busy: _sending,
            onPressed: _composer.text.trim().isEmpty ? null : _send,
          ),
        ),
      ],
    );
  }
}

class _CommentTile extends ConsumerWidget {
  const _CommentTile({required this.task, required this.comment});

  final Task task;
  final Comment comment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tix;
    final times = context.times;
    final author = ref.watch(actorProvider(comment.authorActorId)).value;
    final name = author?.label ?? comment.authorActorId;
    final provider = taskCommentsProvider(task.ref);
    Future<void> act() async {
      final choice = await showActionSheet<String>(
        context,
        title: l10n.taskDetailCommentActions,
        actions: [
          TixSheetAction(
            key: const Key('comment.edit'),
            value: 'edit',
            label: l10n.taskDetailEdit,
            icon: Icons.edit_outlined,
          ),
          TixSheetAction(
            key: const Key('comment.delete'),
            value: 'delete',
            label: l10n.taskDetailCommentDelete,
            icon: Icons.delete_outline,
            destructive: true,
          ),
        ],
      );
      if (!context.mounted) return;
      if (choice == 'edit') {
        final body = await askText(
          context,
          title: l10n.taskDetailCommentEdit,
          label: l10n.taskDetailCommentLabel,
          initial: comment.body,
          multiline: true,
          mentions: true,
          allowEmpty: false,
        );
        if (body == null || body == comment.body || !context.mounted) return;
        await tryAction(
          context,
          () => ref.read(provider.notifier).edit(comment.id, body),
          success: l10n.taskDetailSaved,
        );
      } else if (choice == 'delete') {
        final ok = await confirmDestructive(
          context,
          title: l10n.taskDetailCommentDeleteTitle,
          body: l10n.taskDetailCommentDeleteBody,
          action: l10n.taskDetailCommentDelete,
        );
        if (!ok || !context.mounted) return;
        await tryAction(
          context,
          () => ref.read(provider.notifier).delete(comment.id),
          success: l10n.taskDetailCommentDeleted,
        );
      }
    }

    final created = comment.createdAt;
    final channel = viaLabel(
      l10n,
      ref.watch(taskCommentChannelsProvider(task.ref)).value?[comment.id],
    );
    return Padding(
      key: Key('comment.${comment.id}'),
      padding: const EdgeInsets.only(bottom: TixSpace.s3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: TixSpace.s2),
            child: TixAvatar(
              label: name,
              seed: author?.handle ?? comment.authorActorId,
              size: 28,
              hued: true,
            ),
          ),
          const SizedBox(width: TixSpace.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (created != null) ...[
                      const SizedBox(width: TixSpace.s2),
                      Text(
                        times.shortStamp(created),
                        style: TextStyle(fontSize: TixText.xs, color: t.muted),
                      ),
                    ],
                    if (channel != null) ...[
                      const SizedBox(width: TixSpace.s2),
                      Flexible(
                        child: Text(
                          channel,
                          key: Key('comment.via.${comment.id}'),
                          style: TextStyle(
                            fontSize: TixText.xs,
                            color: t.muted,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    if (comment.edited) ...[
                      const SizedBox(width: TixSpace.s1),
                      Text(
                        l10n.taskDetailEdited,
                        style: TextStyle(fontSize: TixText.xs, color: t.muted),
                      ),
                    ],
                    const Spacer(),
                    TixIconButton(
                      key: Key('comment.menu.${comment.id}'),
                      icon: Icons.more_horiz,
                      tooltip: l10n.taskDetailCommentActions,
                      onPressed: act,
                    ),
                  ],
                ),
                TixMarkdown(
                  data: comment.body,
                  onLink: (uri) => openLink(ref, uri),
                ),
                CommentReactions(task: task, comment: comment),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The emoji the reaction picker offers, in tix's order.
const quickReactions = ['👍', '👎', '❤️', '🎉', '😄', '😕', '👀', '🚀'];

/// A comment's reactions as chips, and the button that adds one. The
/// button stays away on a server that answered a reaction with 404.
class CommentReactions extends ConsumerWidget {
  /// The reactions on [comment], a comment of [task].
  const CommentReactions({
    required this.task,
    required this.comment,
    super.key,
  });

  /// The task.
  final Task task;

  /// The comment.
  final Comment comment;

  Future<void> _toggle(
    BuildContext context,
    WidgetRef ref,
    String emoji, {
    required bool mine,
  }) => tryAction(
    context,
    () => ref
        .read(taskCommentsProvider(task.ref).notifier)
        .toggleReaction(comment.id, emoji, mine: mine),
  );

  Future<void> _pick(BuildContext context, WidgetRef ref, String me) async {
    final l10n = context.l10n;
    final emoji = await showTixSheet<String>(
      context,
      builder: (context) => TixSheetBody(
        title: l10n.taskDetailReactionPick,
        child: Wrap(
          spacing: TixSpace.s1,
          runSpacing: TixSpace.s1,
          children: [
            for (final e in quickReactions)
              SizedBox.square(
                dimension: TixSize.target,
                child: TextButton(
                  key: Key('reaction.pick.$e'),
                  onPressed: () => Navigator.of(context).pop(e),
                  child: Text(e, style: const TextStyle(fontSize: TixText.lg)),
                ),
              ),
          ],
        ),
      ),
    );
    if (emoji == null || !context.mounted) return;
    final mine = comment.reactions.any(
      (r) => r.emoji == emoji && r.actorIds.contains(me),
    );
    await _toggle(context, ref, emoji, mine: mine);
  }

  Future<void> _who(BuildContext context, Reaction reaction) =>
      showTixSheet<void>(
        context,
        builder: (context) => TixSheetBody(
          title: context.l10n.taskDetailReactionWho(reaction.emoji),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final id in reaction.actorIds) _Reactor(actorId: id),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final supported = ref.watch(reactionSupportProvider);
    final me = ref.watch(currentAccessProvider).value?.actor.id ?? '';
    final reactions = comment.reactions;
    if (!comment.sent || (reactions.isEmpty && !supported)) {
      return const SizedBox.shrink();
    }
    return Wrap(
      key: Key('comment.reactions.${comment.id}'),
      spacing: TixSpace.s1,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final r in reactions)
          ReactionChip(
            key: Key('reaction.${comment.id}.${r.emoji}'),
            emoji: r.emoji,
            count: r.count,
            mine: r.actorIds.contains(me),
            semanticLabel: l10n.taskDetailReactionLabel(r.emoji, '${r.count}'),
            onTap: supported
                ? () => _toggle(
                    context,
                    ref,
                    r.emoji,
                    mine: r.actorIds.contains(me),
                  )
                : null,
            onLongPress: () => _who(context, r),
          ),
        if (supported)
          TixIconButton(
            key: Key('reaction.add.${comment.id}'),
            icon: Icons.add_reaction_outlined,
            tooltip: l10n.taskDetailReactionAdd,
            onPressed: () => _pick(context, ref, me),
          ),
      ],
    );
  }
}

class _Reactor extends ConsumerWidget {
  const _Reactor({required this.actorId});

  final String actorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actor = ref.watch(actorProvider(actorId)).value;
    final name = actor?.label ?? actorId;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: TixSize.target),
      child: Row(
        children: [
          TixAvatar(
            label: name,
            seed: actor?.handle ?? actorId,
            size: 24,
            hued: true,
          ),
          const SizedBox(width: TixSpace.s3),
          Expanded(child: Text(name, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

/// The task's audit trail, newest first.
class HistoryPanel extends ConsumerWidget {
  /// The history of [task].
  const HistoryPanel({required this.task, super.key});

  /// The task.
  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final provider = taskHistoryProvider(task.ref);
    return switch (ref.watch(provider)) {
      AsyncData(:final value) when value.items.isEmpty => Text(
        l10n.taskDetailNoHistory,
        style: TextStyle(color: context.tix.muted),
      ),
      AsyncData(:final value) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final e in value.items) _HistoryTile(entry: e),
          if (value.moreError != null)
            ErrorState(
              error: value.moreError!,
              compact: true,
              onRetry: () => ref.read(provider.notifier).loadMore(),
            )
          else if (value.hasMore)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TixButton.quiet(
                key: const Key('history.more'),
                label: l10n.taskDetailHistoryMore,
                busy: value.loadingMore,
                onPressed: () => ref.read(provider.notifier).loadMore(),
              ),
            ),
        ],
      ),
      AsyncError(:final error) => ErrorState(
        error: error,
        compact: true,
        onRetry: () => ref.invalidate(provider),
      ),
      _ => const SkeletonList(rows: 3, inline: true),
    };
  }
}

class _HistoryTile extends ConsumerWidget {
  const _HistoryTile({required this.entry});

  final AuditEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tix;
    final times = context.times;
    final actor = entry.actorId.isEmpty
        ? null
        : ref.watch(actorProvider(entry.actorId)).value;
    final who = entry.actorId.isEmpty
        ? l10n.taskDetailSystem
        : actor?.label ?? entry.actorId;
    final changed = entry.changedKeys;
    final what = switch (entry.action) {
      'task.create' => l10n.taskDetailHistoryCreated,
      'task.delete' => l10n.taskDetailHistoryDeleted,
      'task.restore' => l10n.taskDetailHistoryRestored,
      'task.transition' => l10n.taskDetailHistoryMoved(
        _status(entry.before),
        _status(entry.after),
      ),
      _ when changed.isNotEmpty => l10n.taskDetailHistoryChanged(
        changed.map((k) => k.replaceAll('_', ' ')).join(', '),
      ),
      _ => entry.action,
    };
    final channel = viaLabel(l10n, entry.via) ?? entry.source?.value ?? '';
    final when = entry.occurredAt;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TixSpace.s2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(Icons.circle, size: 8, color: t.lineStrong),
          ),
          const SizedBox(width: TixSpace.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: who,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      TextSpan(text: ' $what'),
                    ],
                  ),
                ),
                Text(
                  key: Key('history.${entry.seq}.meta'),
                  [
                    if (when != null) times.stamp(when),
                    if (channel.isNotEmpty) channel,
                  ].join(' · '),
                  style: TextStyle(fontSize: TixText.xs, color: t.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _status(Object? record) =>
      record is Map ? '${record['status'] ?? ''}' : '';
}

/// The task's artifacts, and attaching a file or a photo.
class ArtifactsPanel extends ConsumerStatefulWidget {
  /// The artifacts of [task].
  const ArtifactsPanel({required this.task, super.key});

  /// The task.
  final Task task;

  @override
  ConsumerState<ArtifactsPanel> createState() => _ArtifactsPanelState();
}

class _ArtifactsPanelState extends ConsumerState<ArtifactsPanel> {
  var _busy = false;

  Future<void> _attach(Future<PickedFile?> Function() pick) async {
    final l10n = context.l10n;
    final file = await pick();
    if (file == null || !mounted) return;
    if (file.bytes.length > maxArtifactBytes) {
      showTixToast(context, l10n.taskDetailFileTooBig, tone: TixTone.danger);
      return;
    }
    setState(() => _busy = true);
    await tryAction(
      context,
      () => ref
          .read(taskArtifactsProvider(widget.task.ref).notifier)
          .attach(
            ArtifactInput(
              kind: ArtifactKind.file,
              name: file.name,
              contentType: file.mimeType,
              blob: base64Encode(file.bytes),
            ),
          ),
      success: l10n.taskDetailAttached(file.name),
    );
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final files = ref.watch(attachmentsProvider);
    final provider = taskArtifactsProvider(widget.task.ref);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: TixSpace.s2,
          runSpacing: TixSpace.s2,
          children: [
            TixButton(
              key: const Key('artifact.file'),
              label: l10n.taskDetailAttachFile,
              icon: Icons.upload_file_outlined,
              busy: _busy,
              onPressed: () => _attach(files.pickFile),
            ),
            if (files.hasCamera)
              TixButton(
                key: const Key('artifact.photo'),
                label: l10n.taskDetailTakePhoto,
                icon: Icons.photo_camera_outlined,
                onPressed: _busy ? null : () => _attach(files.takePhoto),
              ),
          ],
        ),
        const SizedBox(height: TixSpace.s3),
        switch (ref.watch(provider)) {
          AsyncData(:final value) when value.isEmpty => Text(
            l10n.taskDetailNoArtifacts,
            style: TextStyle(color: context.tix.muted),
          ),
          AsyncData(:final value) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [for (final a in value) _ArtifactTile(artifact: a)],
          ),
          AsyncError(:final error) => ErrorState(
            error: error,
            compact: true,
            onRetry: () => ref.invalidate(provider),
          ),
          _ => const SkeletonList(rows: 2, inline: true),
        },
      ],
    );
  }
}

class _ArtifactTile extends ConsumerWidget {
  const _ArtifactTile({required this.artifact});

  final Artifact artifact;

  Future<void> _open(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final a = artifact;
    if (a.blob.isNotEmpty) {
      final Uint8List bytes;
      try {
        bytes = base64Decode(a.blob);
      } on FormatException {
        showTixToast(
          context,
          l10n.taskDetailArtifactUnreadable,
          tone: TixTone.danger,
        );
        return;
      }
      final box = context.findRenderObject() as RenderBox?;
      final origin = box == null
          ? null
          : box.localToGlobal(Offset.zero) & box.size;
      await tryAction(
        context,
        () => ref
            .read(attachmentsProvider)
            .saveBytes(
              a.name.isEmpty ? '${a.kindName}-${a.id}' : a.name,
              bytes,
              a.contentType.isEmpty ? mimeTypeOf(a.name) : a.contentType,
              origin: origin,
            ),
      );
      return;
    }
    await showTixSheet<void>(
      context,
      builder: (context) => TixSheetBody(
        title: a.name.isEmpty ? a.kindName : a.name,
        actions: [
          TixButton.quiet(
            label: l10n.close,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
        child: SelectableText(
          const JsonEncoder.withIndent('  ').convert(a.payload),
          style: tixMono(context, size: TixText.sm),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tix;
    final times = context.times;
    final a = artifact;
    final size = a.blob.isEmpty ? null : (a.blob.length * 3) ~/ 4;
    final created = a.createdAt;
    return InkWell(
      key: Key('artifact.${a.id}'),
      onTap: () => _open(context, ref),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: TixSize.target),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: TixSpace.s2),
          child: Row(
            children: [
              Icon(switch (a.kindName) {
                'file' => Icons.insert_drive_file_outlined,
                'log' => Icons.receipt_long_outlined,
                'metric' => Icons.speed_outlined,
                _ => Icons.task_alt,
              }, color: t.muted),
              const SizedBox(width: TixSpace.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.name.isEmpty ? a.kindName : a.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      [
                        _kind(l10n, a.kindName),
                        if (size != null) _bytes(size),
                        if (created != null) times.shortStamp(created),
                      ].join(' · '),
                      style: TextStyle(fontSize: TixText.xs, color: t.muted),
                    ),
                  ],
                ),
              ),
              Icon(
                a.blob.isEmpty ? Icons.chevron_right : Icons.download_outlined,
                color: t.muted,
                semanticLabel: a.blob.isEmpty
                    ? l10n.taskDetailArtifactShow
                    : l10n.taskDetailArtifactSave,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _kind(AppLocalizations l10n, String kind) => switch (kind) {
    'file' => l10n.taskDetailArtifactFile,
    'log' => l10n.taskDetailArtifactLog,
    'metric' => l10n.taskDetailArtifactMetric,
    'result' => l10n.taskDetailArtifactResult,
    _ => kind,
  };

  static String _bytes(int n) {
    if (n < 1024) return '$n B';
    if (n < 1024 * 1024) return '${(n / 1024).toStringAsFixed(1)} KiB';
    return '${(n / 1024 / 1024).toStringAsFixed(1)} MiB';
  }
}
