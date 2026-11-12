// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/clock/clock.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/time/times.dart';
import 'package:tix_mobile/src/data/models/project.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/features/quick/application/quick.dart';

/// Opens Add with details holding [title], in [project] when given, and
/// returns the task it created when it closes on one.
Future<Task?> showTaskCreateForm(
  BuildContext context, {
  String title = '',
  String? project,
}) => showTixSheet<Task>(
  context,
  builder: (_) => TaskCreateForm(initialTitle: title, initialProject: project),
);

/// Add with details: a field per attribute of a new task, sent as written,
/// as tix's web form of the same name sends it. The title is stored as
/// typed and never read as a quick-add line.
class TaskCreateForm extends ConsumerStatefulWidget {
  /// Opens holding [initialTitle], in [initialProject] when given.
  const TaskCreateForm({
    this.initialTitle = '',
    this.initialProject,
    super.key,
  });

  /// The title to start from, such as the line typed in quick add.
  final String initialTitle;

  /// The project to start in, or null for the last one used.
  final String? initialProject;

  @override
  ConsumerState<TaskCreateForm> createState() => _TaskCreateFormState();
}

/// The fields a refusal can name, by the request field the server names.
const _fields = {
  'title',
  'body',
  'project_ref',
  'priority',
  'due_at',
  'assignee_actor_id',
  'tags',
  'recurrence',
  'parent_ref',
  'depends_on',
  'lease',
};

class _TaskCreateFormState extends ConsumerState<TaskCreateForm> {
  late final _title = TextEditingController(text: widget.initialTitle);
  final _body = TextEditingController();
  final _assignee = TextEditingController();
  final _tags = TextEditingController();
  final _repeat = TextEditingController();
  final _parent = TextEditingController();
  final _dependsOn = TextEditingController();
  final _lease = TextEditingController();
  late String? _project = widget.initialProject;
  int _priority = 3;
  DateTime? _due;
  bool _busy = false;
  bool _untitled = false;
  Object? _error;

  @override
  void dispose() {
    for (final c in [
      _title,
      _body,
      _assignee,
      _tags,
      _repeat,
      _parent,
      _dependsOn,
      _lease,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _resolvedProject(List<Project> projects, RecentValues recent) {
    final asked = _project;
    if (asked != null && asked.isNotEmpty) return asked;
    final keys = {for (final p in projects) p.key};
    for (final k in recent.projects) {
      if (keys.isEmpty || keys.contains(k)) return k;
    }
    return projects.firstOrNull?.key;
  }

  Future<void> _pickDue() async {
    final style = context.times.style;
    final now = style.pickable(ref.read(clockProvider)());
    final current = _due;
    final picked = await showDatePicker(
      context: context,
      initialDate: current == null ? now : style.pickable(current),
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null && mounted) {
      setState(() => _due = style.fromWall(picked));
    }
  }

  Future<void> _submit() async {
    final project = _resolvedProject(
      ref.read(quickProjectsProvider).value ?? const [],
      ref.read(recentQuickValuesProvider),
    );
    if (_busy || project == null) return;
    if (_title.text.trim().isEmpty) {
      setState(() => _untitled = true);
      return;
    }
    setState(() {
      _busy = true;
      _untitled = false;
      _error = null;
    });
    try {
      final task = await ref
          .read(quickAdderProvider.notifier)
          .addDetailed(
            TaskDetails(
              project: project,
              title: _title.text,
              body: _body.text,
              priority: _priority,
              due: _due,
              assignee: _assignee.text,
              tags: _tags.text,
              repeat: _repeat.text,
              parent: _parent.text,
              dependsOn: _dependsOn.text,
              lease: _lease.text,
            ),
          );
      if (mounted) Navigator.of(context).pop(task);
    } on TixException catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = e;
        });
      }
    }
  }

  String? get _errorField {
    final e = _error;
    if (e is! TixException) return null;
    final field = e.details['field'];
    return field is String && _fields.contains(field) ? field : null;
  }

  String? _on(String field) {
    final e = _error;
    return e is TixException && _errorField == field ? e.message : null;
  }

  String? _general(BuildContext context) {
    final error = _error;
    if (error == null || _errorField != null) return null;
    final l10n = context.l10n;
    if (error is TixException &&
        (error.kind == TixErrorKind.network ||
            error.kind == TixErrorKind.timeout)) {
      return l10n.quickAddOffline;
    }
    return errorMessage(l10n, error);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tix;
    final projects = ref.watch(quickProjectsProvider).value ?? const [];
    final recent = ref.watch(recentQuickValuesProvider);
    ref.watch(quickAdderProvider);
    final project = _resolvedProject(projects, recent);
    final options = project == null || projects.any((p) => p.key == project)
        ? projects
        : [Project(key: project), ...projects];
    final due = _due;
    final general = _general(context);
    const gap = SizedBox(height: TixSpace.s3);
    return TixSheetBody(
      title: l10n.addDetailsTitle,
      actions: [
        TixButton.quiet(
          key: const Key('addDetails.cancel'),
          label: l10n.cancel,
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
        ),
        TixButton.primary(
          key: const Key('addDetails.create'),
          label: l10n.addDetailsCreate,
          busy: _busy,
          onPressed: project == null ? null : _submit,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (general != null) ...[
            TixNotice(
              general,
              key: const Key('addDetails.error'),
              tone: TixNoticeTone.danger,
            ),
            gap,
          ],
          TixTextField(
            fieldKey: const Key('addDetails.title'),
            label: l10n.addDetailsTitleLabel,
            controller: _title,
            hint: l10n.addDetailsTitleHint,
            autofocus: true,
            error: _untitled ? l10n.addDetailsTitleRequired : _on('title'),
            textInputAction: TextInputAction.next,
          ),
          gap,
          TixTextField(
            fieldKey: const Key('addDetails.body'),
            label: l10n.addDetailsBody,
            controller: _body,
            hint: l10n.addDetailsBodyHint,
            maxLines: 6,
            keyboardType: TextInputType.multiline,
            error: _on('body'),
          ),
          gap,
          TixSelectField<String>(
            key: ValueKey(project),
            fieldKey: const Key('addDetails.project'),
            label: l10n.quickAddProject,
            value: project,
            error: _on('project_ref'),
            options: [
              for (final p in options)
                TixOption(
                  p.key,
                  p.name.isEmpty ? p.key : '${p.name} (${p.key})',
                ),
            ],
            onChanged: _busy
                ? null
                : (key) => setState(() => _project = key ?? _project),
          ),
          gap,
          TixSelectField<int>(
            fieldKey: const Key('addDetails.priority'),
            label: l10n.addDetailsPriority,
            value: _priority,
            error: _on('priority'),
            options: [
              for (var p = 1; p <= 5; p++)
                TixOption(p, l10n.priorityLabel('$p')),
            ],
            onChanged: _busy
                ? null
                : (p) => setState(() => _priority = p ?? _priority),
          ),
          gap,
          TixFieldLabel(l10n.addDetailsDue),
          const SizedBox(height: TixSpace.s1),
          Row(
            children: [
              Flexible(
                child: TixButton(
                  key: const Key('addDetails.due'),
                  icon: Icons.event_outlined,
                  label: due == null
                      ? l10n.addDetailsDuePick
                      : context.times.style.plain.weekdayDate(due),
                  onPressed: _busy ? null : _pickDue,
                ),
              ),
              if (due != null)
                TixIconButton(
                  key: const Key('addDetails.dueClear'),
                  icon: Icons.close,
                  tooltip: l10n.addDetailsDueClear,
                  onPressed: _busy ? null : () => setState(() => _due = null),
                ),
            ],
          ),
          if (_on('due_at') case final message?)
            Padding(
              padding: const EdgeInsets.only(top: TixSpace.s1),
              child: Text(
                message,
                style: TextStyle(fontSize: TixText.xs, color: t.danger),
              ),
            ),
          gap,
          TixTextField(
            fieldKey: const Key('addDetails.assignee'),
            label: l10n.addDetailsAssignee,
            controller: _assignee,
            hint: l10n.addDetailsAssigneeHint,
            info: l10n.addDetailsAssigneeInfo,
            error: _on('assignee_actor_id'),
          ),
          gap,
          TixTextField(
            fieldKey: const Key('addDetails.tags'),
            label: l10n.addDetailsTags,
            controller: _tags,
            hint: l10n.addDetailsTagsHint,
            error: _on('tags'),
          ),
          const SizedBox(height: TixSpace.s5),
          Text(
            l10n.addDetailsMoreOptions,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Text(
            l10n.addDetailsMoreOptionsHint,
            style: TextStyle(fontSize: TixText.sm, color: t.muted),
          ),
          gap,
          TixTextField(
            fieldKey: const Key('addDetails.repeat'),
            label: l10n.addDetailsRepeat,
            controller: _repeat,
            hint: l10n.addDetailsRepeatHint,
            info: l10n.addDetailsRepeatInfo,
            error: _on('recurrence'),
          ),
          gap,
          TixTextField(
            fieldKey: const Key('addDetails.parent'),
            label: l10n.addDetailsParent,
            controller: _parent,
            hint: 'proj-42',
            info: l10n.addDetailsParentInfo,
            error: _on('parent_ref'),
          ),
          gap,
          TixTextField(
            fieldKey: const Key('addDetails.dependsOn'),
            label: l10n.addDetailsDependsOn,
            controller: _dependsOn,
            hint: 'proj-42, proj-7',
            info: l10n.addDetailsDependsOnInfo,
            error: _on('depends_on'),
          ),
          gap,
          TixTextField(
            fieldKey: const Key('addDetails.lease'),
            label: l10n.addDetailsLease,
            controller: _lease,
            hint: l10n.addDetailsLeaseHint,
            info: l10n.addDetailsLeaseInfo,
            error: _on('lease'),
          ),
        ],
      ),
    );
  }
}
