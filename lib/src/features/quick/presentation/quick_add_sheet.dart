// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/quick/quick_add.dart';
import 'package:tix_mobile/src/core/time/times.dart';
import 'package:tix_mobile/src/data/models/actor.dart';
import 'package:tix_mobile/src/data/models/project.dart';
import 'package:tix_mobile/src/data/models/quick_preview.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/data/models/template.dart';
import 'package:tix_mobile/src/features/quick/application/quick.dart';

/// The project a reference such as `web-12` belongs to.
String projectOfRef(String ref) {
  final dash = ref.lastIndexOf('-');
  return dash <= 0 ? ref : ref.substring(0, dash);
}

/// Opens quick add holding [draft], in [project] unless the draft names
/// one, and returns the task it created when it closes on one.
Future<Task?> showGlobalQuickAdd(
  BuildContext context, {
  QuickAddDraft draft = const QuickAddDraft(),
  String? project,
  VoidCallback? onManageTemplates,
}) => showTixSheet<Task>(
  context,
  builder: (_) => GlobalQuickAddSheet(
    initialText: draft.text,
    initialProject: draft.project ?? project,
    onManageTemplates: onManageTemplates,
  ),
);

/// Quick add from anywhere: a project, one line the server parses, what the
/// server makes of it so far, completions for names, and the most used
/// templates.
class GlobalQuickAddSheet extends ConsumerStatefulWidget {
  /// Opens holding [initialText] for [initialProject].
  const GlobalQuickAddSheet({
    this.initialText = '',
    this.initialProject,
    this.onManageTemplates,
    super.key,
  });

  /// The line to start from: a share, the clipboard, or nothing.
  final String initialText;

  /// The project to start in, or null for the last one used.
  final String? initialProject;

  /// Opens the templates screen.
  final VoidCallback? onManageTemplates;

  @override
  ConsumerState<GlobalQuickAddSheet> createState() =>
      _GlobalQuickAddSheetState();
}

class _GlobalQuickAddSheetState extends ConsumerState<GlobalQuickAddSheet> {
  late final _line = TextEditingController(text: oneLine(widget.initialText));
  final _focus = FocusNode();
  String? _project;
  bool _busy = false;
  Object? _error;
  Task? _added;
  Completion? _completion;

  @override
  void initState() {
    super.initState();
    _project = widget.initialProject;
    _line.addListener(_changed);
    if (widget.initialText.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _changed());
    }
  }

  @override
  void dispose() {
    _line
      ..removeListener(_changed)
      ..dispose();
    _focus.dispose();
    super.dispose();
  }

  String? _resolvedProject(List<Project> projects, RecentValues recent) {
    final keys = {for (final p in projects) p.key};
    for (final k in [_project, ...recent.projects]) {
      if (k != null && (keys.isEmpty || keys.contains(k))) return k;
    }
    return projects.isEmpty ? _project : projects.first.key;
  }

  String? get _currentProject => _resolvedProject(
    ref.read(quickProjectsProvider).value ?? const [],
    ref.read(recentQuickValuesProvider),
  );

  void _changed() {
    if (!mounted) return;
    final completion = completionAt(_line.text, _line.selection.baseOffset);
    if (completion?.start != _completion?.start ||
        completion?.partial != _completion?.partial ||
        completion?.sigil != _completion?.sigil) {
      setState(() => _completion = completion);
    }
    _askPreview();
  }

  void _askPreview() => ref
      .read(quickPreviewerProvider.notifier)
      .request(_currentProject ?? '', _line.text.trim());

  void _pickProject(String key) {
    setState(() => _project = key);
    _askPreview();
  }

  void _complete(String value) {
    final c = _completion;
    if (c == null) return;
    final text = _line.text;
    if (c.sigil == '+') {
      var end = c.end;
      if (end < text.length && text[end] == ' ') end++;
      final next = text.replaceRange(c.start, end, '');
      _line.value = TextEditingValue(
        text: next,
        selection: TextSelection.collapsed(offset: c.start),
      );
      _pickProject(value);
    } else {
      final word = '${c.sigil}$value ';
      var end = c.end;
      if (end < text.length && text[end] == ' ') end++;
      final next = text.replaceRange(c.start, end, word);
      _line.value = TextEditingValue(
        text: next,
        selection: TextSelection.collapsed(offset: c.start + word.length),
      );
    }
    _focus.requestFocus();
  }

  Future<void> _submit() async {
    final line = _line.text.trim();
    final project = _currentProject;
    if (line.isEmpty || _busy || project == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final task = await ref
          .read(quickAdderProvider.notifier)
          .add(project, line);
      if (!mounted) return;
      if (ref.read(addAnotherProvider)) {
        _line.clear();
        ref.read(quickPreviewerProvider.notifier).request(project, '');
        setState(() {
          _busy = false;
          _added = task;
        });
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _focus.requestFocus(),
        );
      } else {
        Navigator.of(context).pop(task);
      }
    } on TixException catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = e;
        });
      }
    }
  }

  Future<void> _use(TaskTemplate template) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final task = await ref
          .read(quickAdderProvider.notifier)
          .use(template, project: template.tenantWide ? _currentProject : null);
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

  String? _errorText(BuildContext context) {
    final error = _error;
    if (error == null) return null;
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
    final projects = ref.watch(quickProjectsProvider);
    final recent = ref.watch(recentQuickValuesProvider);
    final preview = ref.watch(quickPreviewerProvider).value;
    final blocked = ref.watch(previewBlockedProvider);
    final templates =
        ref.watch(quickTemplatesProvider).value ?? const <TaskTemplate>[];
    final addAnother = ref.watch(addAnotherProvider);
    ref.watch(quickAdderProvider);
    final list = projects.value ?? const <Project>[];
    final project = _resolvedProject(list, recent);
    final noProjects = projects.hasValue && list.isEmpty;
    final added = _added;
    final refusal = preview?.refusal;
    return TixSheetBody(
      title: l10n.quickAddTitle,
      actions: [
        TixButton.quiet(
          key: const Key('quickAdd.cancel'),
          label: l10n.cancel,
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _ProjectPicker(
            projects: list,
            recent: recent.projects,
            selected: project,
            onPick: _busy ? null : _pickProject,
          ),
          const SizedBox(height: TixSpace.s3),
          CallbackShortcuts(
            bindings: {
              if (_completion != null)
                const SingleActivator(LogicalKeyboardKey.tab): () {
                  final first = _firstSuggestion();
                  if (first != null) _complete(first);
                },
            },
            child: QuickAddField(
              controller: _line,
              focusNode: _focus,
              autofocus: true,
              busy: _busy,
              help: blocked ? l10n.quickAddPreviewOff : l10n.quickAddHelp,
              error: noProjects ? l10n.quickAddNoProjects : _errorText(context),
              fieldKey: const Key('quickAdd.line'),
              submitKey: const Key('quickAdd.submit'),
              onSubmit: _submit,
              preview: preview == null || preview.refused
                  ? const []
                  : previewChips(context, preview, _line.text.trim()),
            ),
          ),
          if (_completion != null) _suggestions(context, recent),
          if (refusal != null) ...[
            const SizedBox(height: TixSpace.s2),
            Row(
              key: const Key('quickAdd.refusal'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 16, color: t.warn),
                const SizedBox(width: TixSpace.s2),
                Expanded(
                  child: Text(
                    l10n.quickAddPreviewRefused(refusal),
                    style: TextStyle(fontSize: TixText.sm, color: t.muted),
                  ),
                ),
              ],
            ),
          ],
          if (added != null) ...[
            const SizedBox(height: TixSpace.s2),
            Row(
              key: const Key('quickAdd.added'),
              children: [
                Icon(Icons.check_circle_outline, size: 16, color: t.ok),
                const SizedBox(width: TixSpace.s2),
                Text(
                  l10n.taskCreated(added.ref),
                  style: TextStyle(fontSize: TixText.sm, color: t.ok),
                ),
              ],
            ),
          ],
          if (templates.isNotEmpty) ...[
            const SizedBox(height: TixSpace.s4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.quickAddTemplates,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                if (widget.onManageTemplates != null)
                  TixButton.quiet(
                    key: const Key('quickAdd.manageTemplates'),
                    size: TixButtonSize.small,
                    label: l10n.quickAddManageTemplates,
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onManageTemplates!();
                    },
                  ),
              ],
            ),
            const SizedBox(height: TixSpace.s2),
            Wrap(
              spacing: TixSpace.s2,
              runSpacing: TixSpace.s2,
              children: [
                for (final tpl in templates)
                  ActionChip(
                    key: Key('quickAdd.template.${tpl.name}'),
                    avatar: const Icon(Icons.bolt, size: 16),
                    label: Text(tpl.name),
                    onPressed: _busy ? null : () => _use(tpl),
                  ),
              ],
            ),
          ],
          const SizedBox(height: TixSpace.s3),
          TixSwitchRow(
            key: const Key('quickAdd.another'),
            title: l10n.quickAddAnother,
            subtitle: l10n.quickAddAnotherHelp,
            value: addAnother,
            onChanged: (on) =>
                ref.read(addAnotherProvider.notifier).set(on: on),
          ),
        ],
      ),
    );
  }

  List<({String key, String label, String value})> _options(
    RecentValues recent,
  ) {
    final c = _completion;
    if (c == null) return const [];
    switch (c.sigil) {
      case '#':
        final tags = ref.read(quickTagsProvider).value ?? const <String>[];
        return [
          for (final tag in rankCompletions(
            {...recent.tags, ...tags},
            c.partial,
            names: (t) => [t],
            id: (t) => t,
            recent: recent.tags,
          ))
            (key: tag, label: '#$tag', value: tag),
        ];
      case '@':
        final actors = ref.read(quickActorsProvider).value ?? const <Actor>[];
        return [
          for (final a in rankCompletions(
            actors.where((a) => a.handle.isNotEmpty),
            c.partial,
            names: (a) => [a.handle, a.displayName],
            id: (a) => a.handle,
            recent: recent.handles,
          ))
            (
              key: a.handle,
              label: a.displayName.isEmpty
                  ? '@${a.handle}'
                  : '@${a.handle} · ${a.displayName}',
              value: a.handle,
            ),
        ];
      default:
        final projects =
            ref.read(quickProjectsProvider).value ?? const <Project>[];
        return [
          for (final p in rankCompletions(
            projects,
            c.partial,
            names: (p) => [p.key, p.name],
            id: (p) => p.key,
            recent: recent.projects,
          ))
            (
              key: p.key,
              label: p.name.isEmpty ? p.key : '${p.key} · ${p.name}',
              value: p.key,
            ),
        ];
    }
  }

  String? _firstSuggestion() {
    final options = _options(ref.read(recentQuickValuesProvider));
    return options.isEmpty ? null : options.first.value;
  }

  Widget _suggestions(BuildContext context, RecentValues recent) {
    ref
      ..watch(quickTagsProvider)
      ..watch(quickActorsProvider);
    final options = _options(recent);
    if (options.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: TixSpace.s2),
      child: Semantics(
        label: context.l10n.quickAddSuggestions,
        container: true,
        child: Wrap(
          key: const Key('quickAdd.suggestions'),
          spacing: TixSpace.s2,
          runSpacing: TixSpace.s2,
          children: [
            for (final o in options)
              ActionChip(
                key: Key('quickAdd.suggest.${o.key}'),
                label: Text(o.label),
                onPressed: () => _complete(o.value),
              ),
          ],
        ),
      ),
    );
  }
}

/// The chips for what the server made of [line]: the title left once the
/// tokens are out, then each attribute the line set.
List<QuickChip> previewChips(
  BuildContext context,
  QuickPreview preview,
  String line,
) {
  final l10n = context.l10n;
  final row = preview.line;
  final priority = preview.priority;
  final status = preview.status;
  final due = row.due;
  return [
    if (row.title.isNotEmpty && row.title != line)
      QuickChip(kind: l10n.quickAddChipTitle, value: row.title),
    if (priority != null)
      QuickChip(
        kind: l10n.quickAddChipPriority,
        value: l10n.priorityLabel('$priority').toLowerCase(),
      ),
    for (final tag in row.tags)
      QuickChip(kind: l10n.quickAddChipTag, value: tag),
    if (row.assignee.isNotEmpty)
      QuickChip(kind: l10n.quickAddChipAssignee, value: '@${row.assignee}'),
    if (due != null)
      QuickChip(
        kind: l10n.quickAddChipDue,
        value: context.times.style.plain.weekdayDate(due),
      ),
    if (status != null) QuickChip(kind: l10n.quickAddChipStatus, value: status),
    if (row.parent.isNotEmpty)
      QuickChip(kind: l10n.quickAddChipParent, value: row.parent),
  ];
}

class _ProjectPicker extends StatelessWidget {
  const _ProjectPicker({
    required this.projects,
    required this.recent,
    required this.selected,
    required this.onPick,
  });

  final List<Project> projects;
  final List<String> recent;
  final String? selected;
  final ValueChanged<String>? onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tix;
    final current = projects.where((p) => p.key == selected).firstOrNull;
    final ordered = [
      for (final k in recent) ...projects.where((p) => p.key == k),
      ...projects.where((p) => !recent.contains(p.key)),
    ];
    return Row(
      children: [
        Text(
          l10n.quickAddProject,
          style: TextStyle(fontSize: TixText.sm, color: t.muted),
        ),
        const SizedBox(width: TixSpace.s2),
        Flexible(
          child: PopupMenuButton<String>(
            key: const Key('quickAdd.project'),
            tooltip: l10n.quickAddPickProject,
            enabled: onPick != null && projects.isNotEmpty,
            onSelected: onPick,
            itemBuilder: (_) => [
              for (final p in ordered)
                PopupMenuItem(
                  key: Key('quickAdd.project.${p.key}'),
                  value: p.key,
                  child: Row(
                    children: [
                      ProjectMark(
                        name: p.name.isEmpty ? p.key : p.name,
                        colour: p.color,
                        icon: p.icon,
                      ),
                      const SizedBox(width: TixSpace.s3),
                      Flexible(
                        child: Text(
                          p.name.isEmpty ? p.key : p.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: TixSpace.s2),
                      Text(p.key, style: tixMono(context)),
                    ],
                  ),
                ),
            ],
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: TixSize.target),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selected == null)
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
