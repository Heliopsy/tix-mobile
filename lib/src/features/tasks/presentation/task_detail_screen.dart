// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/clock/clock.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/offline/outbox.dart';
import 'package:tix_mobile/src/core/router/routes.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/widgets/async_body.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/features/tasks/application/task_detail.dart';
import 'package:tix_mobile/src/features/tasks/presentation/detail/actions.dart';
import 'package:tix_mobile/src/features/tasks/presentation/detail/activity.dart';
import 'package:tix_mobile/src/features/tasks/presentation/detail/editors.dart';
import 'package:tix_mobile/src/features/tasks/presentation/detail/properties.dart';
import 'package:tix_mobile/src/features/tasks/presentation/detail/reclaim.dart';
import 'package:tix_mobile/src/features/tasks/presentation/detail/sections.dart';

export 'package:tix_mobile/src/features/tasks/presentation/detail/properties.dart'
    show AssigneeName;

/// From this pane width the properties sit beside the description.
const sidePropertiesMinWidth = 760.0;

/// One task on a screen of its own, as phones show it.
class TaskDetailScreen extends StatelessWidget {
  /// Shows the task [taskRef].
  const TaskDetailScreen({required this.taskRef, super.key});

  /// The task's reference, such as `infra-8`.
  final String taskRef;

  @override
  Widget build(BuildContext context) => TixPage(
    title: taskRef,
    titleWidget: Text(
      taskRef,
      style: tixMono(context, size: TixText.md, color: context.tix.muted),
    ),
    body: TaskDetailView(taskRef: taskRef, showRef: false),
  );
}

/// A task, everything about it editable, without a frame: the hub the task
/// screen and the wide list's second pane both show.
class TaskDetailView extends ConsumerWidget {
  /// Shows the task [taskRef].
  const TaskDetailView({
    required this.taskRef,
    this.showRef = true,
    this.onClose,
    super.key,
  });

  /// The task's reference.
  final String taskRef;

  /// Whether the reference heads the view; off when a page header has it.
  final bool showRef;

  /// Closes the pane the view sits in; null draws no close button.
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = taskDetailControllerProvider(taskRef);
    final value = ref.watch(provider);
    final body = AsyncBody(
      value: value,
      onRetry: () => ref.invalidate(provider),
      loading: const _DetailSkeleton(),
      data: (task) => _TaskHub(task: task, showRef: showRef, onClose: onClose),
    );
    final close = onClose;
    if (close == null || value.hasValue) return body;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: CloseTaskButton(onPressed: close),
        ),
        Expanded(child: body),
      ],
    );
  }
}

/// Closes the task open beside a list.
class CloseTaskButton extends StatelessWidget {
  /// A button that calls [onPressed].
  const CloseTaskButton({required this.onPressed, super.key});

  /// Closes the pane.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => TixIconButton(
    key: const Key('tasks.detail.close'),
    icon: Icons.close,
    tooltip: context.l10n.taskPanelClose,
    onPressed: onPressed,
  );
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) => Semantics(
    label: context.l10n.loading,
    child: const Padding(
      padding: EdgeInsets.all(TixSpace.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(width: 64),
          SizedBox(height: TixSpace.s3),
          SkeletonBox(width: 280, height: 22),
          SizedBox(height: TixSpace.s5),
          SkeletonBox(width: 200),
          SizedBox(height: TixSpace.s3),
          SkeletonBox(width: 160),
          SizedBox(height: TixSpace.s3),
          SkeletonBox(width: 220),
        ],
      ),
    ),
  );
}

class _TaskHub extends ConsumerStatefulWidget {
  const _TaskHub({required this.task, required this.showRef, this.onClose});

  final Task task;
  final bool showRef;
  final VoidCallback? onClose;

  @override
  ConsumerState<_TaskHub> createState() => _TaskHubState();
}

class _TaskHubState extends ConsumerState<_TaskHub> {
  ActivityTab _tab = ActivityTab.comments;
  var _editingTitle = false;
  var _titleChanged = false;
  final _composer = FocusNode();

  @override
  void didUpdateWidget(_TaskHub old) {
    super.didUpdateWidget(old);
    if (_editingTitle &&
        old.task.version != widget.task.version &&
        old.task.title != widget.task.title) {
      _titleChanged = true;
    }
  }

  void _editTitle(bool editing) => setState(() {
    _editingTitle = editing;
    _titleChanged = false;
  });

  @override
  void dispose() {
    _composer.dispose();
    super.dispose();
  }

  Task get task => widget.task;

  void _comment() {
    setState(() => _tab = ActivityTab.comments);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _composer.requestFocus();
    });
  }

  Future<void> _copy() async {
    final l10n = context.l10n;
    final request = await askCopy(context, task);
    if (request == null || !mounted) return;
    final controller = ref.read(
      taskDetailControllerProvider(task.ref).notifier,
    );
    try {
      final copy = await controller.copy(request);
      if (!mounted) return;
      final router = GoRouter.of(context);
      showTixToast(
        context,
        l10n.taskDetailCopied(copy.ref),
        actionLabel: l10n.taskDetailOpen,
        onAction: () =>
            router.go(Routes.task(projectKeyOf(copy.ref), copy.ref)),
      );
    } on Object catch (e) {
      if (mounted) {
        showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
      }
    }
  }

  Future<void> _delete({bool hard = false}) async {
    final l10n = context.l10n;
    final container = ProviderScope.containerOf(context);
    final router = GoRouter.of(context);
    final root = Navigator.of(context, rootNavigator: true).context;
    TrashStatus trash;
    try {
      trash = await ref.read(trashStatusProvider.future);
    } on Object {
      trash = const TrashStatus();
    }
    final subtasks = ref.read(taskSubtasksProvider(task.ref)).value ?? [];
    final cascade = subtasks.isNotEmpty;
    final permanent = hard || !trash.enabled;
    if (!mounted) return;
    if (permanent || cascade) {
      final ok = await confirmDestructive(
        context,
        title: l10n.taskDetailDeleteTitle(task.ref),
        body: [
          if (permanent) l10n.taskDetailDeletePermanentBody,
          if (!permanent) l10n.taskDetailDeleteTrashBody,
          if (cascade) l10n.taskDetailDeleteSubtasksBody(subtasks.length),
        ].join(' '),
        action: permanent
            ? l10n.taskDetailDeleteForGood
            : l10n.taskDetailDelete,
      );
      if (!ok || !mounted) return;
    }
    final controller = ref.read(
      taskDetailControllerProvider(task.ref).notifier,
    );
    final ok = await tryAction(
      context,
      () => controller.delete(hard: hard, cascade: cascade),
    );
    if (!ok) return;
    unawaited(TixHaptics.confirm());
    final taskRef = task.ref;
    final key = projectKeyOf(taskRef);
    router.go(Routes.project(key));
    if (!root.mounted) return;
    showTixToast(
      root,
      l10n.taskDetailDeleted(taskRef),
      onUndo: permanent
          ? null
          : () async {
              try {
                await container
                    .read(taskDetailRepositoryProvider)
                    .restore(taskRef);
                container.invalidate(taskDetailControllerProvider(taskRef));
                router.go(Routes.task(key, taskRef));
              } on Object catch (e) {
                if (root.mounted) {
                  showTixToast(
                    root,
                    errorMessage(l10n, e),
                    tone: TixTone.danger,
                  );
                }
              }
            },
    );
  }

  Future<void> _reclaim() async {
    final l10n = context.l10n;
    final done = await showTixSheet<Object>(
      context,
      builder: (_) => ReclaimForm(taskRef: task.ref),
    );
    if (done != null && done != false && mounted) {
      showTixToast(context, l10n.taskReclaimed(task.ref));
    }
  }

  Future<void> _copyRef() async {
    await Clipboard.setData(ClipboardData(text: task.ref));
    if (mounted) showTixToast(context, context.l10n.taskDetailRefCopied);
  }

  Future<void> _menu() async {
    final l10n = context.l10n;
    final snoozed = _snoozed;
    final choice = await showActionSheet<String>(
      context,
      title: l10n.taskDetailActionsFor(task.ref),
      actions: [
        TixSheetAction(
          key: const Key('menu.rename'),
          value: 'rename',
          label: l10n.taskDetailRename,
          icon: Icons.title,
        ),
        TixSheetAction(
          key: const Key('menu.move'),
          value: 'move',
          label: l10n.taskDetailMoveTitle,
          icon: Icons.swap_horiz,
        ),
        TixSheetAction(
          key: const Key('menu.star'),
          value: 'star',
          label: task.starred ? l10n.taskDetailUnstar : l10n.taskDetailStar,
          icon: task.starred ? Icons.star_rounded : Icons.star_border_rounded,
        ),
        TixSheetAction(
          key: const Key('menu.snooze'),
          value: 'snooze',
          label: snoozed ? l10n.taskDetailWake : l10n.taskDetailSnooze,
          icon: snoozed ? Icons.alarm_off : Icons.snooze,
        ),
        TixSheetAction(
          key: const Key('menu.comment'),
          value: 'comment',
          label: l10n.taskDetailCommentLabel,
          icon: Icons.chat_bubble_outline,
        ),
        TixSheetAction(
          key: const Key('menu.copy'),
          value: 'copy',
          label: l10n.taskDetailCopyTo,
          icon: Icons.copy_all_outlined,
        ),
        TixSheetAction(
          key: const Key('menu.ref'),
          value: 'ref',
          label: l10n.taskDetailCopyRef,
          icon: Icons.tag,
        ),
        if (task.claimedByActorId.isNotEmpty)
          TixSheetAction(
            key: const Key('menu.reclaim'),
            value: 'reclaim',
            label: l10n.taskReclaim,
            icon: Icons.lock_open,
            destructive: true,
          ),
        TixSheetAction(
          key: const Key('menu.delete'),
          value: 'delete',
          label: l10n.taskDetailDelete,
          icon: Icons.delete_outline,
          destructive: true,
        ),
        TixSheetAction(
          key: const Key('menu.purge'),
          value: 'purge',
          label: l10n.taskDetailDeleteForGood,
          icon: Icons.delete_forever_outlined,
          destructive: true,
        ),
      ],
    );
    if (!mounted || choice == null) return;
    switch (choice) {
      case 'rename':
        _editTitle(true);
      case 'move':
        await ref.moveTask(context, task);
      case 'star':
        await ref.toggleStar(context, task);
      case 'snooze':
        await ref.snooze(context, task);
      case 'comment':
        _comment();
      case 'copy':
        await _copy();
      case 'ref':
        await _copyRef();
      case 'reclaim':
        await _reclaim();
      case 'delete':
        await _delete();
      case 'purge':
        await _delete(hard: true);
    }
  }

  bool get _snoozed {
    final until = task.snoozedUntil;
    return until != null && until.isAfter(ref.read(clockProvider)());
  }

  List<TixCommand> _commands(AppLocalizations l10n) {
    final group = l10n.taskDetailCommands;
    TixCommand cmd(
      String id,
      String label,
      IconData icon,
      LogicalKeyboardKey key,
      VoidCallback run,
    ) => TixCommand(
      id: 'taskDetail.$id',
      label: label,
      group: group,
      icon: icon,
      shortcut: SingleActivator(key),
      run: run,
    );
    return [
      cmd(
        'rename',
        l10n.taskDetailRename,
        Icons.title,
        LogicalKeyboardKey.keyE,
        () => _editTitle(true),
      ),
      cmd(
        'describe',
        l10n.taskDetailEditDescription,
        Icons.notes,
        LogicalKeyboardKey.keyD,
        () => editDescription(context, ref, task),
      ),
      cmd(
        'move',
        l10n.taskDetailMoveTitle,
        Icons.swap_horiz,
        LogicalKeyboardKey.keyM,
        () => ref.moveTask(context, task),
      ),
      cmd(
        'priority',
        l10n.taskDetailPriorityTitle,
        Icons.flag_outlined,
        LogicalKeyboardKey.keyP,
        () => ref.setPriority(context, task),
      ),
      cmd(
        'assign',
        l10n.taskDetailAssigneeTitle,
        Icons.person_outline,
        LogicalKeyboardKey.keyA,
        () => ref.setAssignee(context, task),
      ),
      cmd(
        'due',
        l10n.taskDetailDueTitle,
        Icons.event_outlined,
        LogicalKeyboardKey.keyU,
        () => ref.setDue(context, task),
      ),
      cmd(
        'tag',
        l10n.taskDetailAddTag,
        Icons.sell_outlined,
        LogicalKeyboardKey.keyT,
        () => ref.addTag(context, task),
      ),
      cmd(
        'star',
        task.starred ? l10n.taskDetailUnstar : l10n.taskDetailStar,
        Icons.star_border_rounded,
        LogicalKeyboardKey.keyS,
        () => ref.toggleStar(context, task),
      ),
      cmd(
        'snooze',
        _snoozed ? l10n.taskDetailWake : l10n.taskDetailSnooze,
        Icons.snooze,
        LogicalKeyboardKey.keyZ,
        () => ref.snooze(context, task),
      ),
      cmd(
        'comment',
        l10n.taskDetailCommentLabel,
        Icons.chat_bubble_outline,
        LogicalKeyboardKey.keyC,
        _comment,
      ),
      cmd(
        'copy',
        l10n.taskDetailCopyTo,
        Icons.copy_all_outlined,
        LogicalKeyboardKey.keyY,
        _copy,
      ),
      cmd(
        'delete',
        l10n.taskDetailDelete,
        Icons.delete_outline,
        LogicalKeyboardKey.delete,
        _delete,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = taskDetailControllerProvider(task.ref);
    final header = _Header(
      task: task,
      showRef: widget.showRef,
      editingTitle: _editingTitle,
      titleChanged: _titleChanged,
      onKeepTitle: () => setState(() => _titleChanged = false),
      snoozed: _snoozed,
      onEditTitle: _editTitle,
      onMenu: _menu,
      onClose: widget.onClose,
    );
    final props = TaskProperties(task: task);
    final main = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DescriptionSection(task: task),
        SubtasksSection(task: task),
        DependenciesSection(task: task),
        ActivitySection(
          task: task,
          tab: _tab,
          onTab: (t) => setState(() => _tab = t),
          composerFocus: _composer,
        ),
      ],
    );
    return CommandScope(
      commands: _commands(l10n),
      child: RefreshIndicator(
        onRefresh: () async {
          ref
            ..invalidate(taskCommentsProvider(task.ref))
            ..invalidate(taskSubtasksProvider(task.ref))
            ..invalidate(taskDependenciesProvider(task.ref))
            ..invalidate(taskArtifactsProvider(task.ref))
            ..invalidate(taskHistoryProvider(task.ref));
          await ref.read(controller.notifier).reload();
        },
        child: LayoutBuilder(
          builder: (context, box) {
            final wide = box.maxWidth >= sidePropertiesMinWidth;
            return ListView(
              key: const Key('task.detail'),
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                wide ? TixSpace.s5 : TixSpace.s4,
                TixSpace.s4,
                wide ? TixSpace.s5 : TixSpace.s4,
                TixSpace.s7,
              ),
              children: [
                header,
                _SyncStrip(task: task),
                const SizedBox(height: TixSpace.s4),
                if (wide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: main),
                      const SizedBox(width: TixSpace.s5),
                      SizedBox(width: 340, child: props),
                    ],
                  )
                else ...[
                  props,
                  main,
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

/// What the outbox says about the task [ref] with [writes] waiting.
SyncMarkKind? _markOf(List<OutboxEntry> writes, String ref) {
  if (writes.any((e) => e.state == OutboxState.conflict)) {
    return SyncMarkKind.conflict;
  }
  if (writes.any((e) => e.state == OutboxState.failed)) {
    return SyncMarkKind.failed;
  }
  if (writes.any((e) => e.state == OutboxState.needsCheck)) {
    return SyncMarkKind.check;
  }
  if (isDraftRef(ref)) return SyncMarkKind.draft;
  return writes.isEmpty ? null : SyncMarkKind.unsynced;
}

/// Says the task's changes wait to sync, or need a decision, with the way
/// to the Conflicts screen.
class _SyncStrip extends ConsumerWidget {
  const _SyncStrip({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final writes = ref.watch(pendingWritesProvider(task.ref));
    final mark = _markOf(writes, task.ref);
    if (mark == null) return const SizedBox.shrink();
    final attention =
        mark == SyncMarkKind.conflict ||
        mark == SyncMarkKind.failed ||
        mark == SyncMarkKind.check;
    return Padding(
      padding: const EdgeInsets.only(top: TixSpace.s3),
      child: SyncBanner(
        key: const Key('task.syncBanner'),
        message: attention
            ? l10n.syncBannerConflict
            : mark == SyncMarkKind.draft
            ? l10n.syncBannerDraft
            : l10n.syncBannerWaiting(writes.length),
        attention: attention,
        actionLabel: attention ? l10n.syncResolve : null,
        onAction: attention ? () => context.go(Routes.conflicts) : null,
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({
    required this.task,
    required this.showRef,
    required this.editingTitle,
    required this.titleChanged,
    required this.onKeepTitle,
    required this.snoozed,
    required this.onEditTitle,
    required this.onMenu,
    this.onClose,
  });

  final Task task;
  final bool showRef;
  final bool editingTitle;

  /// Whether the title changed elsewhere while it is being edited.
  final bool titleChanged;

  /// Hides the changed-elsewhere banner and keeps the edit.
  final VoidCallback onKeepTitle;
  final bool snoozed;
  final ValueChanged<bool> onEditTitle;
  final VoidCallback onMenu;

  /// Closes the pane the task sits in; null draws no close button.
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tix;
    final theme = Theme.of(context);
    final until = task.snoozedUntil;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (showRef) RefText(task.ref, size: TixText.sm),
            if (_markOf(ref.watch(pendingWritesProvider(task.ref)), task.ref)
                case final SyncMarkKind kind) ...[
              const SizedBox(width: TixSpace.s2),
              SyncMark(kind, key: const Key('task.syncMark')),
            ],
            if (task.recurrence.isNotEmpty) ...[
              const SizedBox(width: TixSpace.s2),
              Icon(
                Icons.repeat,
                size: 14,
                color: t.muted,
                semanticLabel: l10n.taskDetailRepeats,
              ),
            ],
            if (snoozed && until != null) ...[
              const SizedBox(width: TixSpace.s2),
              Flexible(child: SnoozeMark(until: until)),
            ],
            const Spacer(),
            TixIconButton(
              key: const Key('task.star'),
              icon: task.starred
                  ? Icons.star_rounded
                  : Icons.star_border_rounded,
              color: task.starred ? t.accent : null,
              selected: task.starred,
              tooltip: task.starred
                  ? l10n.taskDetailUnstar
                  : l10n.taskDetailStar,
              onPressed: () => ref.toggleStar(context, task),
            ),
            TixIconButton(
              key: const Key('task.snooze'),
              icon: snoozed ? Icons.alarm_off : Icons.snooze,
              tooltip: snoozed ? l10n.taskDetailWake : l10n.taskDetailSnooze,
              onPressed: () => ref.snooze(context, task),
            ),
            TixIconButton(
              key: const Key('task.menu'),
              icon: Icons.more_vert,
              tooltip: l10n.taskDetailActionsFor(task.ref),
              onPressed: onMenu,
            ),
            if (onClose case final close?) CloseTaskButton(onPressed: close),
          ],
        ),
        if (editingTitle && titleChanged)
          Padding(
            padding: const EdgeInsets.only(bottom: TixSpace.s2),
            child: ChangedElsewhereBanner(
              key: const Key('title.changed'),
              onReload: () => onEditTitle(false),
              onDismiss: onKeepTitle,
            ),
          ),
        if (editingTitle)
          _TitleField(
            task: task,
            onDone: () => onEditTitle(false),
            onSave: (title) =>
                patchTask(context, ref, task, TaskPatch.title(title)),
          )
        else
          Semantics(
            button: true,
            hint: l10n.taskDetailRename,
            child: InkWell(
              key: const Key('task.title'),
              borderRadius: BorderRadius.circular(TixRadius.md),
              onTap: () => onEditTitle(true),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: TixSize.target),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(task.title, style: theme.textTheme.headlineSmall),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _TitleField extends StatefulWidget {
  const _TitleField({
    required this.task,
    required this.onDone,
    required this.onSave,
  });

  final Task task;
  final VoidCallback onDone;
  final ValueChanged<String> onSave;

  @override
  State<_TitleField> createState() => _TitleFieldState();
}

class _TitleFieldState extends State<_TitleField> {
  late final _controller = TextEditingController(text: widget.task.title)
    ..selection = TextSelection(
      baseOffset: 0,
      extentOffset: widget.task.title.length,
    );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final title = _controller.text.trim();
    widget.onDone();
    if (title.isEmpty || title == widget.task.title) return;
    widget.onSave(title);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): widget.onDone,
      },
      child: Row(
        children: [
          Expanded(
            child: TextField(
              key: const Key('title.field'),
              controller: _controller,
              autofocus: true,
              style: Theme.of(context).textTheme.headlineSmall,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(labelText: l10n.taskDetailTitleLabel),
              onSubmitted: (_) => _save(),
            ),
          ),
          TixIconButton(
            key: const Key('title.cancel'),
            icon: Icons.close,
            tooltip: l10n.cancel,
            onPressed: widget.onDone,
          ),
          TixIconButton(
            key: const Key('title.save'),
            icon: Icons.check,
            tooltip: l10n.taskDetailSave,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
