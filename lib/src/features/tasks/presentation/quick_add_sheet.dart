// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/features/tasks/application/tasks.dart';

/// Opens the quick-add sheet for [projectKey] and confirms what it created.
Future<void> showQuickAdd(BuildContext context, String projectKey) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final task = await showModalBottomSheet<Task>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => QuickAddSheet(projectKey: projectKey),
  );
  if (task != null) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.taskCreated(task.ref))));
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
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.quickAddTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          TextField(
            key: const Key('quickAdd.line'),
            controller: _line,
            autofocus: true,
            enabled: !_busy,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              hintText: l10n.quickAddHint,
              helperText: l10n.quickAddHelp,
              errorText: error == null ? null : errorMessage(l10n, error),
              errorMaxLines: 3,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _busy ? null : () => Navigator.of(context).pop(),
                child: Text(l10n.cancel),
              ),
              const SizedBox(width: 8),
              FilledButton(
                key: const Key('quickAdd.submit'),
                onPressed: _busy ? null : _submit,
                child: Text(l10n.quickAddButton),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
