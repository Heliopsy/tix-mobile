// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/widgets/form_sheet.dart';
import 'package:tix_mobile/src/features/tasks/application/task_detail.dart';

/// Ends the claim another actor holds on a task, with an optional reason
/// for the audit trail: what an administrator does when a worker died.
class ReclaimForm extends ConsumerStatefulWidget {
  /// Reclaims [taskRef].
  const ReclaimForm({required this.taskRef, super.key});

  /// The task.
  final String taskRef;

  @override
  ConsumerState<ReclaimForm> createState() => _ReclaimFormState();
}

class _ReclaimFormState extends ConsumerState<ReclaimForm> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FormSheet(
      title: l10n.taskReclaim,
      submitLabel: l10n.taskReclaimSubmit,
      danger: true,
      onSubmit: () => ref
          .read(taskDetailControllerProvider(widget.taskRef).notifier)
          .reclaim(reason: _reason.text.trim()),
      children: [
        Text(l10n.taskReclaimBody),
        formGap,
        TixTextField(
          fieldKey: const Key('reclaim.reason'),
          label: l10n.taskReclaimReason,
          help: l10n.taskReclaimReasonHelp,
          controller: _reason,
        ),
      ],
    );
  }
}
