// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/features/tasks/application/tasks.dart';

/// Opens quick add for [projectKey], a sheet on a phone and a dialog on
/// anything wider, and confirms what it created.
Future<void> showQuickAdd(BuildContext context, String projectKey) async {
  final l10n = context.l10n;
  final task = await showTixSheet<Task>(
    context,
    builder: (_) => QuickAddSheet(projectKey: projectKey),
  );
  if (task != null && context.mounted) {
    showTixToast(context, l10n.taskCreated(task.ref));
  }
}

/// One line that becomes a task, in tix's quick-add syntax, which the server
/// parses: `Fix login !high #auth @raj due:fri`.
class QuickAddSheet extends ConsumerStatefulWidget {
  /// Adds to [projectKey].
  const QuickAddSheet({required this.projectKey, super.key});

  /// The project the task goes in unless the line names another.
  final String projectKey;

  @override
  ConsumerState<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<QuickAddSheet> {
  final _line = TextEditingController();
  bool _busy = false;
  Object? _error;

  @override
  void dispose() {
    _line.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final line = _line.text.trim();
    if (line.isEmpty || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final task = await ref
          .read(projectTasksProvider(widget.projectKey).notifier)
          .quickAdd(line);
      if (mounted) Navigator.of(context).pop(task);
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
      title: l10n.quickAddTitle,
      actions: [
        TixButton.quiet(
          label: l10n.cancel,
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.only(top: TixSpace.s1),
        child: QuickAddField(
          controller: _line,
          autofocus: true,
          busy: _busy,
          help: l10n.quickAddHelp,
          error: error == null ? null : errorMessage(l10n, error),
          fieldKey: const Key('quickAdd.line'),
          submitKey: const Key('quickAdd.submit'),
          onSubmit: _submit,
        ),
      ),
    );
  }
}
