// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/data/models/project.dart';
import 'package:tix_mobile/src/data/models/template.dart';
import 'package:tix_mobile/src/features/templates/application/templates.dart';

/// Opens New template, starting from the task [taskRef] when given, and
/// confirms what it saved.
Future<void> showNewTemplate(BuildContext context, {String? taskRef}) async {
  final l10n = context.l10n;
  final saved = await showTixSheet<TaskTemplate>(
    context,
    builder: (_) => NewTemplateSheet(taskRef: taskRef),
  );
  if (saved != null && context.mounted) {
    showTixToast(context, l10n.templateSaved(saved.name));
  }
}

/// Opens [template]'s editor, and confirms a save or a delete.
Future<void> showEditTemplate(
  BuildContext context,
  TaskTemplate template,
) async {
  final l10n = context.l10n;
  final current = await ProviderScope.containerOf(
    context,
    listen: false,
  ).read(templatesProvider.notifier).current(template);
  if (!context.mounted) return;
  final result = await showTixSheet<Object>(
    context,
    builder: (_) => EditTemplateSheet(template: current),
  );
  if (!context.mounted) return;
  if (result is TaskTemplate) {
    showTixToast(context, l10n.templateSaved(result.name));
  } else if (result == EditTemplateSheet.deleted) {
    showTixToast(context, l10n.templateDeleted(template.name));
  }
}

/// Where a new template starts.
enum TemplateSource {
  /// An existing task, by reference.
  task,

  /// A new task, from a quick-add line.
  scratch,
}

/// Saves a task as a template, or creates the task from a line first.
class NewTemplateSheet extends ConsumerStatefulWidget {
  /// Starts from [taskRef] when given.
  const NewTemplateSheet({this.taskRef, super.key});

  /// The task to keep.
  final String? taskRef;

  @override
  ConsumerState<NewTemplateSheet> createState() => _NewTemplateSheetState();
}

class _NewTemplateSheetState extends ConsumerState<NewTemplateSheet> {
  late final _task = TextEditingController(text: widget.taskRef ?? '');
  final _name = TextEditingController();
  final _line = TextEditingController();
  final _due = TextEditingController();
  TemplateSource _source = TemplateSource.task;
  var _subtasks = true;
  var _tenantWide = false;
  String? _project;
  bool _busy = false;
  TixException? _error;

  @override
  void dispose() {
    for (final c in [_task, _name, _line, _due]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final due = _due.text.trim();
    final project = _project;
    final ready =
        name.isNotEmpty &&
        switch (_source) {
          TemplateSource.task => _task.text.trim().isNotEmpty,
          TemplateSource.scratch =>
            _line.text.trim().isNotEmpty && project != null,
        };
    if (!ready || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final notifier = ref.read(templatesProvider.notifier);
    try {
      final saved = switch (_source) {
        TemplateSource.task => await notifier.save(
          SaveTemplateInput(
            taskRef: _task.text.trim(),
            name: name,
            withSubtasks: _subtasks,
            tenantWide: _tenantWide,
            dueIn: due.isEmpty ? null : due,
          ),
        ),
        TemplateSource.scratch => await notifier.saveFromLine(
          project: project!,
          line: _line.text.trim(),
          name: name,
          dueIn: due.isEmpty ? null : due,
        ),
      };
      if (mounted) Navigator.of(context).pop(saved);
    } on TixException catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = e;
        });
      }
    }
  }

  String? _errorFor(String field) {
    final e = _error;
    if (e == null) return null;
    final l10n = context.l10n;
    final named = switch (e.kind) {
      TixErrorKind.conflict => 'name',
      TixErrorKind.notFound => 'task',
      _ => (e.details['field'] as String?) ?? '',
    };
    final mapped = switch (named) {
      'name' => 'name',
      'task_ref' || 'task' || 'title' => 'task',
      'due_in' => 'due',
      _ => 'general',
    };
    if (mapped != field) return null;
    if (e.kind == TixErrorKind.conflict && e.message.isNotEmpty) {
      return e.message;
    }
    return field == 'general'
        ? l10n.templateGeneralError(errorMessage(l10n, e))
        : errorMessage(l10n, e);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tix;
    final projects =
        ref.watch(templateProjectsProvider).value ?? const <Project>[];
    _project ??= projects.isEmpty ? null : projects.first.key;
    final general = _errorFor('general');
    return TixSheetBody(
      title: l10n.templateNew,
      actions: [
        TixButton.quiet(
          label: l10n.cancel,
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
        ),
        TixButton.primary(
          key: const Key('template.save'),
          label: l10n.templateCreate,
          busy: _busy,
          onPressed: _save,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SegmentedButton<TemplateSource>(
            key: const Key('template.source'),
            segments: [
              ButtonSegment(
                value: TemplateSource.task,
                label: Text(l10n.templateFromTask),
              ),
              ButtonSegment(
                value: TemplateSource.scratch,
                label: Text(l10n.templateFromScratch),
              ),
            ],
            selected: {_source},
            onSelectionChanged: _busy
                ? null
                : (s) => setState(() {
                    _source = s.first;
                    _error = null;
                  }),
          ),
          const SizedBox(height: TixSpace.s4),
          TixTextField(
            label: l10n.templateName,
            controller: _name,
            help: l10n.templateNameHelp,
            error: _errorFor('name'),
            autofocus: true,
            enabled: !_busy,
            fieldKey: const Key('template.name'),
          ),
          const SizedBox(height: TixSpace.s3),
          if (_source == TemplateSource.task) ...[
            TixTextField(
              label: l10n.templateTaskRef,
              controller: _task,
              help: l10n.templateTaskRefHelp,
              error: _errorFor('task'),
              enabled: !_busy,
              fieldKey: const Key('template.task'),
            ),
            TixSwitchRow(
              key: const Key('template.subtasks'),
              title: l10n.templateWithSubtasks,
              value: _subtasks,
              onChanged: _busy ? null : (v) => setState(() => _subtasks = v),
            ),
            TixSwitchRow(
              key: const Key('template.tenantWide'),
              title: l10n.templateTenantWide,
              value: _tenantWide,
              onChanged: _busy ? null : (v) => setState(() => _tenantWide = v),
            ),
          ] else ...[
            TemplateProjectPicker(
              projects: projects,
              selected: _project,
              onPick: _busy ? null : (k) => setState(() => _project = k),
            ),
            const SizedBox(height: TixSpace.s2),
            TixTextField(
              label: l10n.templateTaskRef,
              controller: _line,
              hint: l10n.quickAddHint,
              help: l10n.templateScratchNote,
              error: _errorFor('task'),
              enabled: !_busy,
              fieldKey: const Key('template.line'),
            ),
          ],
          const SizedBox(height: TixSpace.s3),
          TixTextField(
            label: l10n.templateDueIn,
            controller: _due,
            help: l10n.templateDueInHelp,
            error: _errorFor('due'),
            enabled: !_busy,
            fieldKey: const Key('template.due'),
          ),
          if (general != null) ...[
            const SizedBox(height: TixSpace.s2),
            Text(
              general,
              key: const Key('template.error'),
              style: TextStyle(color: t.danger, fontSize: TixText.sm),
            ),
          ],
        ],
      ),
    );
  }
}

/// A project menu for the template forms, with "Every project" when
/// [allowEvery] is set.
class TemplateProjectPicker extends StatelessWidget {
  /// Picks among [projects]; null [selected] with [allowEvery] means every
  /// project.
  const TemplateProjectPicker({
    required this.projects,
    required this.selected,
    required this.onPick,
    this.allowEvery = false,
    super.key,
  });

  /// The projects.
  final List<Project> projects;

  /// The project's key, or empty for every project.
  final String? selected;

  /// Picks a key, empty for every project.
  final ValueChanged<String>? onPick;

  /// Whether "Every project" is offered.
  final bool allowEvery;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tix;
    final current = projects.where((p) => p.key == selected).firstOrNull;
    final every = selected == null || selected!.isEmpty;
    return Row(
      children: [
        Text(
          l10n.quickAddProject,
          style: TextStyle(fontSize: TixText.sm, color: t.muted),
        ),
        const SizedBox(width: TixSpace.s2),
        Flexible(
          child: PopupMenuButton<String>(
            key: const Key('template.project'),
            tooltip: l10n.quickAddPickProject,
            enabled: onPick != null,
            onSelected: onPick,
            itemBuilder: (_) => [
              if (allowEvery)
                PopupMenuItem(
                  key: const Key('template.project.every'),
                  value: '',
                  child: Text(l10n.templateEveryProject),
                ),
              for (final p in projects)
                PopupMenuItem(
                  key: Key('template.project.${p.key}'),
                  value: p.key,
                  child: Text(p.name.isEmpty ? p.key : '${p.name} (${p.key})'),
                ),
            ],
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: TixSize.target),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (every && allowEvery)
                    TixBadge(l10n.templateEveryProject)
                  else if (selected == null)
                    Flexible(
                      child: Text(
                        l10n.quickAddPickProject,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  else
                    ProjectChip(
                      projectKey: selected!,
                      colour: current?.color ?? '',
                      icon: current?.icon ?? '',
                    ),
                  Icon(Icons.expand_more, size: 18, color: t.muted),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Edits a template, sending only what changed, or deletes it.
class EditTemplateSheet extends ConsumerStatefulWidget {
  /// Edits [template].
  const EditTemplateSheet({required this.template, super.key});

  /// The template.
  final TaskTemplate template;

  /// What the sheet closes with after a delete.
  static const deleted = #deleted;

  @override
  ConsumerState<EditTemplateSheet> createState() => _EditTemplateSheetState();
}

class _EditTemplateSheetState extends ConsumerState<EditTemplateSheet> {
  late final TaskTemplate _t = widget.template;
  late final _name = TextEditingController(text: _t.name);
  late final _title = TextEditingController(text: _t.shape.title);
  late final _body = TextEditingController(text: _t.shape.body);
  late final _tags = TextEditingController(text: _t.shape.tags.join(' '));
  late final _recurrence = TextEditingController(text: _t.shape.recurrence);
  late final _due = TextEditingController(text: readableDueIn(_t.dueIn));
  late int _priority = _t.shape.priority == 0 ? 3 : _t.shape.priority;
  late String _project = _t.projectKey;
  bool _busy = false;
  TixException? _error;

  @override
  void dispose() {
    for (final c in [_name, _title, _body, _tags, _recurrence, _due]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy) return;
    final changes = templateChanges(
      _t,
      name: _name.text.trim(),
      title: _title.text.trim(),
      body: _body.text,
      priority: _priority == 3 && _t.shape.priority == 0 ? 0 : _priority,
      tags: splitTags(_tags.text),
      recurrence: _recurrence.text.trim(),
      dueIn: _due.text.trim(),
      projectKey: _project,
    );
    if (isEmptyUpdate(changes)) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final saved = await ref
          .read(templatesProvider.notifier)
          .edit(_t, changes);
      if (mounted) Navigator.of(context).pop(saved);
    } on TixException catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = e;
        });
      }
    }
  }

  Future<void> _delete() async {
    final l10n = context.l10n;
    final ok = await confirmDestructive(
      context,
      title: l10n.templateDeleteTitle(_t.name),
      body: l10n.templateDeleteBody,
      action: l10n.templateDeleteAction,
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref.read(templatesProvider.notifier).delete(_t);
      if (mounted) Navigator.of(context).pop(EditTemplateSheet.deleted);
    } on TixException catch (e) {
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
    final t = context.tix;
    final projects =
        ref.watch(templateProjectsProvider).value ?? const <Project>[];
    final error = _error;
    return TixSheetBody(
      title: l10n.templateEdit,
      actions: [
        TixButton.danger(
          key: const Key('template.delete'),
          label: l10n.templateDelete,
          onPressed: _busy ? null : _delete,
        ),
        TixButton.quiet(
          label: l10n.cancel,
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
        ),
        TixButton.primary(
          key: const Key('template.save'),
          label: l10n.templateSave,
          busy: _busy,
          onPressed: _save,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          TixTextField(
            label: l10n.templateName,
            controller: _name,
            help: l10n.templateNameHelp,
            enabled: !_busy,
            fieldKey: const Key('template.name'),
          ),
          const SizedBox(height: TixSpace.s3),
          TixTextField(
            label: l10n.templateTitle,
            controller: _title,
            help: l10n.templateTitleHelp('{date}', '{n}', '{project}'),
            enabled: !_busy,
            fieldKey: const Key('template.title'),
          ),
          const SizedBox(height: TixSpace.s3),
          TixTextField(
            label: l10n.templateBody,
            controller: _body,
            maxLines: 4,
            enabled: !_busy,
            fieldKey: const Key('template.body'),
          ),
          const SizedBox(height: TixSpace.s3),
          Text(
            l10n.templatePriority,
            style: TextStyle(fontSize: TixText.sm, color: t.muted),
          ),
          const SizedBox(height: TixSpace.s1),
          Wrap(
            spacing: TixSpace.s1,
            runSpacing: TixSpace.s1,
            children: [
              for (var p = 1; p <= 5; p++)
                ChoiceChip(
                  key: Key('template.priority.$p'),
                  label: Text(l10n.priorityLabel('$p')),
                  selected: _priority == p,
                  onSelected: _busy
                      ? null
                      : (_) => setState(() => _priority = p),
                ),
            ],
          ),
          const SizedBox(height: TixSpace.s3),
          TixTextField(
            label: l10n.templateTags,
            controller: _tags,
            help: l10n.templateTagsHelp,
            enabled: !_busy,
            fieldKey: const Key('template.tags'),
          ),
          const SizedBox(height: TixSpace.s3),
          TixTextField(
            label: l10n.templateRecurrence,
            controller: _recurrence,
            help: l10n.templateRecurrenceHelp,
            enabled: !_busy,
            fieldKey: const Key('template.recurrence'),
          ),
          const SizedBox(height: TixSpace.s3),
          TixTextField(
            label: l10n.templateDueIn,
            controller: _due,
            help: l10n.templateDueInHelp,
            enabled: !_busy,
            fieldKey: const Key('template.due'),
          ),
          const SizedBox(height: TixSpace.s2),
          TemplateProjectPicker(
            projects: projects,
            selected: _project,
            allowEvery: true,
            onPick: _busy ? null : (k) => setState(() => _project = k),
          ),
          if (error != null) ...[
            const SizedBox(height: TixSpace.s2),
            Text(
              l10n.templateGeneralError(errorMessage(l10n, error)),
              key: const Key('template.error'),
              style: TextStyle(color: t.danger, fontSize: TixText.sm),
            ),
          ],
        ],
      ),
    );
  }
}
