// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/clock/clock.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/data/models/workflow.dart';
import 'package:tix_mobile/src/features/tasks/application/listing.dart';
import 'package:tix_mobile/src/features/tasks/application/tasks.dart';
import 'package:tix_mobile/src/features/tasks/presentation/detail/editors.dart';

/// The design system's category for a workflow category key.
StatusCategory statusCategoryOf(String? category) => switch (category) {
  'todo' => StatusCategory.todo,
  'in_progress' => StatusCategory.inProgress,
  'blocked' => StatusCategory.blocked,
  'waiting' => StatusCategory.waiting,
  'done' => StatusCategory.done,
  'cancelled' => StatusCategory.cancelled,
  _ => StatusCategory.unknown,
};

/// What a row or card shows about [task] beyond itself.
TaskFacts factsFor(
  Task task,
  TaskIndex? context, {
  String handle = '',
  bool showProject = true,
}) {
  final project = context?.projectOf(task);
  final category = context?.categoryOf(task);
  return TaskFacts(
    projectKey: showProject ? project?.key ?? '' : '',
    projectColour: project?.color ?? '',
    projectIcon: showProject ? project?.icon ?? '' : '',
    assigneeHandle: handle,
    statusCategory: category == null ? null : statusCategoryOf(category),
  );
}

/// The handle of [task]'s assignee, once looked up.
String assigneeHandle(WidgetRef ref, Task task) => task.assigneeActorId.isEmpty
    ? ''
    : ref.watch(actorProvider(task.assigneeActorId)).value?.handle ?? '';

/// Quick actions on one task in one listing: each changes the screen at
/// once, sends, rolls back on refusal and offers Undo.
class TaskQuickActions {
  /// Acts on rows of the listing for [query].
  TaskQuickActions(this.context, this.ref, this.query);

  /// Where toasts show.
  final BuildContext context;

  /// The provider container.
  final WidgetRef ref;

  /// The listing the task is drawn in.
  final TaskQuery query;

  TaskListing get _listing => ref.read(taskListingProvider(query).notifier);

  TaskIndex? get _context => ref.read(taskContextProvider).value;

  String _describe(Object e) => errorMessage(context.l10n, e);

  /// Whether [task] is finished.
  bool isDone(Task task) => _context?.isFinished(task) ?? isTaskDone(task);

  /// Completes [task], or reopens it when finished.
  Future<void> toggleDone(Task task) async {
    final l10n = context.l10n;
    final workflow = _context?.workflowOf(task);
    final done = isDone(task);
    final target = done ? workflow?.initial : workflow?.doneState?.id;
    if (target == null || target.isEmpty) {
      showTixToast(context, l10n.boardNoRoute(task.ref), tone: TixTone.danger);
      return;
    }
    final now = ref.read(clockProvider)();
    final change = _listing.change(
      task.copyWith(status: target, completedAt: done ? null : now),
      send: () => _listing.sendMove(task.ref, target),
      reverse: () => _listing.sendMove(task.ref, task.status),
    );
    await runOptimistic(
      context,
      apply: change.apply,
      rollback: change.rollback,
      commit: change.commit,
      describe: _describe,
      success: done
          ? l10n.boardReopened(task.ref)
          : l10n.boardCompleted(task.ref),
      undo: change.undo,
    );
  }

  /// Moves [task] to the state [to].
  Future<void> move(Task task, WorkflowState to) async {
    if (to.id == task.status) return;
    unawaited(TixHaptics.confirm());
    final change = _listing.change(
      task.copyWith(status: to.id),
      send: () => _listing.sendMove(task.ref, to.id),
      reverse: () => _listing.sendMove(task.ref, task.status),
    );
    await runOptimistic(
      context,
      apply: change.apply,
      rollback: change.rollback,
      commit: change.commit,
      describe: _describe,
      success: context.l10n.boardMoved(task.ref, to.name),
      undo: change.undo,
    );
  }

  /// Stars [task], or takes its star off.
  Future<void> toggleStar(Task task) async {
    final l10n = context.l10n;
    final starred = !task.starred;
    final change = _listing.change(
      task.copyWith(starred: starred),
      send: () => _listing.sendStar(task.ref, starred: starred),
      reverse: () => _listing.sendStar(task.ref, starred: !starred),
    );
    await runOptimistic(
      context,
      apply: change.apply,
      rollback: change.rollback,
      commit: change.commit,
      describe: _describe,
      success: starred
          ? l10n.boardStarred(task.ref)
          : l10n.boardUnstarred(task.ref),
      undo: change.undo,
    );
  }

  /// Asks until when, then snoozes [task]; or wakes it.
  Future<void> snooze(Task task) async {
    final now = ref.read(clockProvider)();
    final until = await pickSnooze(context, task, now);
    if (until == null || !context.mounted) return;
    final l10n = context.l10n;
    final wake = until == wakeNow;
    await runOptimistic(
      context,
      apply: () =>
          _listing.apply([task.copyWith(snoozedUntil: wake ? null : until)]),
      rollback: () => _listing.apply([task]),
      commit: () => _listing.sendSnooze(task.ref, wake ? null : until),
      describe: _describe,
      success: wake ? l10n.boardWoken(task.ref) : l10n.boardSnoozed(task.ref),
      undo: () => _listing.sendSnooze(task.ref, task.snoozedUntil),
    );
  }

  /// Assigns [task] to the reader.
  Future<void> assignToMe(Task task) async {
    final l10n = context.l10n;
    final String me;
    try {
      me = (await ref.read(meProvider.future)).id;
    } on Object catch (e) {
      if (context.mounted) {
        showTixToast(context, _describe(e), tone: TixTone.danger);
      }
      return;
    }
    if (!context.mounted || task.assigneeActorId == me) return;
    final change = _listing.change(
      task.copyWith(assigneeActorId: me),
      send: () => _listing.sendAssign(task.ref, me),
      reverse: () => _listing.sendAssign(task.ref, task.assigneeActorId),
    );
    await runOptimistic(
      context,
      apply: change.apply,
      rollback: change.rollback,
      commit: change.commit,
      describe: _describe,
      success: l10n.boardAssignedToMe(task.ref),
      undo: change.undo,
    );
  }

  /// Asks whom to give [task] to, anyone in the tenant or nobody.
  Future<void> pickAssignee(Task task) async {
    final l10n = context.l10n;
    final picked = await pickActor(
      context,
      current: task.assigneeActorId,
      title: l10n.assign,
    );
    if (picked == null ||
        picked.value == task.assigneeActorId ||
        !context.mounted) {
      return;
    }
    final to = picked.value;
    final change = _listing.change(
      task.copyWith(assigneeActorId: to),
      send: () => _listing.sendAssign(task.ref, to),
      reverse: () => _listing.sendAssign(task.ref, task.assigneeActorId),
    );
    await runOptimistic(
      context,
      apply: change.apply,
      rollback: change.rollback,
      commit: change.commit,
      describe: _describe,
      success: l10n.boardAssigned(task.ref),
      undo: change.undo,
    );
  }

  /// Asks which state to move [task] to, among those its workflow reaches.
  Future<void> pickMove(Task task) async {
    final workflow = _context?.workflowOf(task);
    if (workflow == null) return;
    final reach = workflow.reachableFrom(task.status);
    final to = await showActionSheet<WorkflowState>(
      context,
      title: context.l10n.boardMoveTitle(task.ref),
      actions: [
        for (final s in workflow.states)
          if (reach.contains(s.id))
            TixSheetAction(
              key: Key('move.${s.id}'),
              value: s,
              label: s.name,
              icon: Icons.arrow_forward,
            ),
      ],
    );
    if (to != null && context.mounted) await move(task, to);
  }
}

/// What [pickSnooze] answers to wake a snoozed task.
final wakeNow = DateTime.utc(1970);

/// Asks until when [task] should sleep, measured from [now]: later today,
/// tomorrow morning or next week; [wakeNow] when it is snoozed and should
/// wake.
Future<DateTime?> pickSnooze(BuildContext context, Task task, DateTime now) {
  final l10n = context.l10n;
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1, hours: 9));
  final monday = today.add(Duration(days: 8 - now.weekday, hours: 9));
  final snoozed = task.snoozedUntil?.isAfter(now) ?? false;
  return showActionSheet<DateTime>(
    context,
    title: l10n.boardSnoozeTitle(task.ref),
    actions: [
      TixSheetAction(
        key: const Key('snooze.later'),
        value: now.add(const Duration(hours: 3)),
        label: l10n.boardSnoozeLater,
        icon: Icons.schedule,
      ),
      TixSheetAction(
        key: const Key('snooze.tomorrow'),
        value: tomorrow,
        label: l10n.boardSnoozeTomorrow,
        icon: Icons.wb_twilight,
      ),
      TixSheetAction(
        key: const Key('snooze.week'),
        value: monday,
        label: l10n.boardSnoozeWeek,
        icon: Icons.date_range,
      ),
      if (snoozed)
        TixSheetAction(
          key: const Key('snooze.wake'),
          value: wakeNow,
          label: l10n.boardWake,
          icon: Icons.alarm_on,
        ),
    ],
  );
}

/// The things a row's or card's menu offers.
enum TaskMenuItem {
  /// Open the task.
  open,

  /// Complete or reopen.
  done,

  /// Move to a state.
  move,

  /// Star or unstar.
  star,

  /// Snooze or wake.
  snooze,

  /// Assign to the reader.
  assignMe,

  /// Assign to anyone.
  assign,

  /// Pick for a bulk action.
  select,
}

/// Opens [task]'s menu and runs what is picked; [onOpen] opens the task and
/// [onSelect] picks it, when the screen can.
Future<void> showTaskMenu(
  BuildContext context,
  TaskQuickActions actions,
  Task task, {
  required VoidCallback onOpen,
  VoidCallback? onSelect,
}) async {
  final l10n = context.l10n;
  final done = actions.isDone(task);
  final item = await showActionSheet<TaskMenuItem>(
    context,
    title: '${task.ref}  ${task.title}',
    actions: [
      TixSheetAction(
        key: const Key('menu.open'),
        value: TaskMenuItem.open,
        label: l10n.boardOpen,
        icon: Icons.open_in_new,
      ),
      TixSheetAction(
        key: const Key('menu.done'),
        value: TaskMenuItem.done,
        label: done ? l10n.reopen : l10n.complete,
        icon: done ? Icons.undo : Icons.check_circle_outline,
      ),
      TixSheetAction(
        key: const Key('menu.move'),
        value: TaskMenuItem.move,
        label: l10n.boardMoveTo,
        icon: Icons.arrow_forward,
      ),
      TixSheetAction(
        key: const Key('menu.star'),
        value: TaskMenuItem.star,
        label: task.starred ? l10n.unstar : l10n.star,
        icon: task.starred ? Icons.star_outline : Icons.star,
      ),
      TixSheetAction(
        key: const Key('menu.snooze'),
        value: TaskMenuItem.snooze,
        label: l10n.snooze,
        icon: Icons.snooze,
      ),
      TixSheetAction(
        key: const Key('menu.assignMe'),
        value: TaskMenuItem.assignMe,
        label: l10n.boardAssignMe,
        icon: Icons.person_add_alt,
      ),
      TixSheetAction(
        key: const Key('menu.assign'),
        value: TaskMenuItem.assign,
        label: l10n.boardAssignTo,
        icon: Icons.people_outline,
      ),
      if (onSelect != null)
        TixSheetAction(
          key: const Key('menu.select'),
          value: TaskMenuItem.select,
          label: l10n.bulkSelect,
          icon: Icons.check_box_outlined,
        ),
    ],
  );
  if (item == null || !context.mounted) return;
  switch (item) {
    case TaskMenuItem.open:
      onOpen();
    case TaskMenuItem.done:
      await actions.toggleDone(task);
    case TaskMenuItem.move:
      await actions.pickMove(task);
    case TaskMenuItem.star:
      await actions.toggleStar(task);
    case TaskMenuItem.snooze:
      await actions.snooze(task);
    case TaskMenuItem.assignMe:
      await actions.assignToMe(task);
    case TaskMenuItem.assign:
      await actions.pickAssignee(task);
    case TaskMenuItem.select:
      onSelect?.call();
  }
}
