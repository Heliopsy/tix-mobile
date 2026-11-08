// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/platform/attachments.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/features/tasks/application/task_detail.dart';

/// Applies [change] to [task] at once and sends it, through
/// [runOptimistic]: a refusal rolls back with the reason, a success says
/// [success] and offers Undo, which sends [undo].
Future<bool> changeTask(
  BuildContext context,
  WidgetRef ref,
  Task task,
  TaskChange change, {
  TaskChange? undo,
  String? success,
}) {
  final controller = ref.read(taskDetailControllerProvider(task.ref).notifier);
  final l10n = context.l10n;
  var begun = false;
  var committed = false;
  return runOptimistic(
    context,
    apply: () {
      if (begun) return;
      begun = true;
      controller.begin(change);
    },
    rollback: () {
      if (committed && undo != null) controller.begin(undo);
    },
    commit: () async {
      await controller.commit(change);
      committed = true;
    },
    describe: (e) => errorMessage(l10n, e),
    success: success,
    undo: undo == null ? null : () => controller.commit(undo),
  );
}

/// Changes the attributes [patch] names on [task], with Undo.
Future<bool> patchTask(
  BuildContext context,
  WidgetRef ref,
  Task task,
  TaskPatch patch, {
  String? success,
  bool checkVersion = false,
}) => changeTask(
  context,
  ref,
  task,
  TaskChange.patch(patch, checkVersion: checkVersion),
  undo: TaskChange.patch(patch.inverseFor(task)),
  success: success ?? context.l10n.taskDetailSaved,
);

/// Sends [run], showing its failure in a danger toast; whether it worked.
Future<bool> tryAction(
  BuildContext context,
  Future<void> Function() run, {
  String? success,
}) async {
  final l10n = context.l10n;
  try {
    await run();
  } on Object catch (e) {
    unawaited(TixHaptics.refuse());
    if (context.mounted) {
      showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
    }
    return false;
  }
  if (success != null && context.mounted) showTixToast(context, success);
  return true;
}

/// Opens [uri] outside the app.
void openLink(WidgetRef ref, Uri uri) {
  unawaited(ref.read(attachmentsProvider).openLink(uri));
}
