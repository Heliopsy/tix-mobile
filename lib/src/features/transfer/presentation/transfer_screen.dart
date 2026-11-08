// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/platform/attachments.dart';
import 'package:tix_mobile/src/core/session/people.dart';
import 'package:tix_mobile/src/core/widgets/async_body.dart';
import 'package:tix_mobile/src/data/models/project.dart';
import 'package:tix_mobile/src/data/repositories/transfer_repository.dart';
import 'package:tix_mobile/src/features/transfer/application/transfer.dart';

/// Tasks out of tix as a file, a snapshot of the whole tenant, and a file of
/// tasks in, as the web's export and import screens do.
class TransferScreen extends ConsumerWidget {
  /// Opens on [project] with [query] filled in, when given.
  const TransferScreen({this.project = '', this.query = '', super.key});

  /// The project to export first.
  final String project;

  /// The filter to export by first.
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final access = ref.watch(currentAccessProvider).value;
    return TixPage(
      title: l10n.transferTitle,
      body: AsyncBody(
        value: ref.watch(transferProjectsProvider),
        onRetry: () => ref.invalidate(transferProjectsProvider),
        data: (projects) => ListView(
          padding: const EdgeInsets.only(bottom: TixSpace.s7),
          children: [
            if (projects.isEmpty)
              EmptyState(
                icon: Icons.folder_outlined,
                title: l10n.projectsEmpty,
                body: l10n.transferNoProjects,
              )
            else ...[
              if (access?.can(Scopes.export) ?? false)
                _ExportSection(
                  projects: projects,
                  initialProject: project,
                  initialQuery: query,
                ),
              if (access?.can(Scopes.import) ?? false)
                _ImportSection(projects: projects, initialProject: project),
            ],
            if (access?.can(Scopes.export) ?? false) const _SnapshotSection(),
          ],
        ),
      ),
    );
  }
}

class _ExportSection extends ConsumerStatefulWidget {
  const _ExportSection({
    required this.projects,
    required this.initialProject,
    required this.initialQuery,
  });

  final List<Project> projects;
  final String initialProject;
  final String initialQuery;

  @override
  ConsumerState<_ExportSection> createState() => _ExportSectionState();
}

class _ExportSectionState extends ConsumerState<_ExportSection> {
  late String _project = widget.projects
      .map((p) => p.key)
      .firstWhere(
        (k) => k == widget.initialProject,
        orElse: () => widget.projects.first.key,
      );
  late final _query = TextEditingController(text: widget.initialQuery);
  ExportFormat _format = ExportFormat.csv;
  final _columns = <String>{...defaultExportColumns};
  final _custom = <String>{};
  final _customOff = <String>{};
  var _finished = true;
  var _subtasks = true;
  var _trashed = false;
  var _dates = 'iso';
  var _delimiter = ',';
  var _busy = false;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _export() async {
    final l10n = context.l10n;
    final files = ref.read(attachmentsProvider);
    final box = context.findRenderObject() as RenderBox?;
    setState(() => _busy = true);
    try {
      final file = await ref
          .read(transferProvider.notifier)
          .exportTasks(
            project: _project,
            format: _format,
            columns: [
              for (final c in exportColumns)
                if (_columns.contains(c)) c,
              for (final c in _custom)
                if (!_customOff.contains(c)) c,
            ],
            query: _query.text,
            finished: _finished,
            subtasks: _subtasks,
            trashed: _trashed,
            dates: _dates,
            delimiter: _delimiter,
          );
      final saved = await files.saveBytes(
        file.name,
        file.bytes,
        file.mimeType,
        origin: box == null ? null : box.localToGlobal(Offset.zero) & box.size,
      );
      if (saved && mounted) {
        showTixToast(context, l10n.transferExported(file.name));
      }
    } on TixException catch (e) {
      if (mounted) {
        showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final fields = ref.watch(transferFieldsProvider(_project)).value ?? [];
    _custom
      ..clear()
      ..addAll([for (final f in fields) 'custom:${f.key}']);
    return TixSection(
      key: const Key('transfer.export'),
      title: l10n.transferExportTitle,
      subtitle: l10n.transferExportHelp,
      children: [
        Padding(
          padding: const EdgeInsets.all(TixSpace.s4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProjectPicker(
                key: const Key('transfer.project'),
                projects: widget.projects,
                value: _project,
                onChanged: (p) => setState(() => _project = p),
              ),
              const SizedBox(height: TixSpace.s3),
              TixTextField(
                label: l10n.transferQuery,
                controller: _query,
                fieldKey: const Key('transfer.query'),
                hint: l10n.calendarFilterHint,
                help: l10n.transferQueryHelp,
              ),
              const SizedBox(height: TixSpace.s3),
              Text(l10n.transferFormat, style: theme.textTheme.labelLarge),
              const SizedBox(height: TixSpace.s2),
              Wrap(
                spacing: TixSpace.s2,
                runSpacing: TixSpace.s2,
                children: [
                  for (final f in ExportFormat.values)
                    ChoiceChip(
                      key: Key('transfer.format.${f.name}'),
                      label: Text(_formatLabel(l10n, f)),
                      selected: _format == f,
                      onSelected: (_) => setState(() => _format = f),
                    ),
                ],
              ),
              const SizedBox(height: TixSpace.s3),
              Text(l10n.transferColumns, style: theme.textTheme.labelLarge),
              const SizedBox(height: TixSpace.s2),
              Wrap(
                spacing: TixSpace.s2,
                runSpacing: TixSpace.s2,
                children: [
                  for (final c in exportColumns)
                    FilterChip(
                      key: Key('transfer.column.$c'),
                      label: Text(_columnLabel(l10n, c)),
                      selected: _columns.contains(c),
                      onSelected: (on) => setState(
                        () => on ? _columns.add(c) : _columns.remove(c),
                      ),
                    ),
                  for (final f in fields)
                    FilterChip(
                      key: Key('transfer.column.custom:${f.key}'),
                      label: Text(f.label.isEmpty ? f.key : f.label),
                      selected: !_customOff.contains('custom:${f.key}'),
                      onSelected: (on) => setState(
                        () => on
                            ? _customOff.remove('custom:${f.key}')
                            : _customOff.add('custom:${f.key}'),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: TixSpace.s3),
              Text(l10n.transferDates, style: theme.textTheme.labelLarge),
              const SizedBox(height: TixSpace.s2),
              SegmentedButton<String>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: 'iso',
                    label: Text(l10n.transferDatesIso),
                  ),
                  ButtonSegment(
                    value: 'date',
                    label: Text(l10n.transferDatesDay),
                  ),
                ],
                selected: {_dates},
                onSelectionChanged: (s) => setState(() => _dates = s.first),
              ),
              if (_format == ExportFormat.csv) ...[
                const SizedBox(height: TixSpace.s3),
                Text(l10n.transferDelimiter, style: theme.textTheme.labelLarge),
                const SizedBox(height: TixSpace.s2),
                Wrap(
                  spacing: TixSpace.s2,
                  runSpacing: TixSpace.s2,
                  children: [
                    for (final d in exportDelimiters)
                      ChoiceChip(
                        key: Key('transfer.delimiter.$d'),
                        label: Text(_delimiterLabel(l10n, d)),
                        selected: _delimiter == d,
                        onSelected: (_) => setState(() => _delimiter = d),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
        TixSwitchRow(
          key: const Key('transfer.finished'),
          title: l10n.transferFinished,
          value: _finished,
          onChanged: (v) => setState(() => _finished = v),
        ),
        TixSwitchRow(
          key: const Key('transfer.subtasks'),
          title: l10n.transferSubtasks,
          value: _subtasks,
          onChanged: (v) => setState(() => _subtasks = v),
        ),
        TixSwitchRow(
          key: const Key('transfer.trashed'),
          title: l10n.transferTrashed,
          value: _trashed,
          onChanged: (v) => setState(() => _trashed = v),
        ),
        Padding(
          padding: const EdgeInsets.all(TixSpace.s4),
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TixButton.primary(
              key: const Key('transfer.exportButton'),
              label: l10n.transferExportButton,
              icon: Icons.download,
              busy: _busy,
              onPressed: _columns.isEmpty && _custom.isEmpty ? null : _export,
            ),
          ),
        ),
      ],
    );
  }

  static String _formatLabel(AppLocalizations l10n, ExportFormat f) =>
      switch (f) {
        ExportFormat.csv => l10n.transferFormatCsv,
        ExportFormat.json => 'JSON',
        ExportFormat.ndjson => l10n.transferFormatNdjson,
        ExportFormat.markdown => l10n.transferFormatMarkdown,
      };

  static String _delimiterLabel(AppLocalizations l10n, String d) => switch (d) {
    ',' => l10n.transferDelimiterComma,
    ';' => l10n.transferDelimiterSemicolon,
    'tab' => l10n.transferDelimiterTab,
    _ => l10n.transferDelimiterBar,
  };

  static String _columnLabel(AppLocalizations l10n, String c) => switch (c) {
    'ref' => l10n.columnRef,
    'title' => l10n.columnTitle,
    'status' => l10n.fieldStatus,
    'priority' => l10n.fieldPriority,
    'assignee' => l10n.fieldAssignee,
    'tags' => l10n.fieldTags,
    'due' => l10n.fieldDue,
    'parent' => l10n.columnParent,
    'depends_on' => l10n.columnDependsOn,
    'recurrence' => l10n.columnRepeat,
    'body' => l10n.fieldDescription,
    'created_at' => l10n.columnCreated,
    'updated_at' => l10n.columnUpdated,
    'started_at' => l10n.columnStarted,
    'completed_at' => l10n.columnCompleted,
    'deleted_at' => l10n.columnDeleted,
    'creator' => l10n.columnCreator,
    'project' => l10n.columnProject,
    'id' => l10n.columnId,
    'comments' => l10n.columnComments,
    'history' => l10n.columnHistory,
    _ => c,
  };
}

class _ProjectPicker extends StatelessWidget {
  const _ProjectPicker({
    required this.projects,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final List<Project> projects;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: TixMeasure.field),
    child: DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: context.l10n.columnProject),
      items: [
        for (final p in projects)
          DropdownMenuItem(
            value: p.key,
            child: Text(p.name.isEmpty ? p.key : '${p.name} (${p.key})'),
          ),
      ],
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    ),
  );
}

class _SnapshotSection extends ConsumerStatefulWidget {
  const _SnapshotSection();

  @override
  ConsumerState<_SnapshotSection> createState() => _SnapshotSectionState();
}

class _SnapshotSectionState extends ConsumerState<_SnapshotSection> {
  var _comments = true;
  var _busy = false;

  Future<void> _export() async {
    final l10n = context.l10n;
    final files = ref.read(attachmentsProvider);
    setState(() => _busy = true);
    try {
      final file = await ref
          .read(transferProvider.notifier)
          .exportSnapshot(comments: _comments);
      final saved = await files.saveBytes(file.name, file.bytes, file.mimeType);
      if (saved && mounted) {
        showTixToast(context, l10n.transferExported(file.name));
      }
    } on TixException catch (e) {
      if (mounted) {
        showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TixSection(
      key: const Key('transfer.snapshot'),
      title: l10n.transferSnapshotTitle,
      subtitle: l10n.transferSnapshotHelp,
      children: [
        TixSwitchRow(
          title: l10n.transferSnapshotComments,
          value: _comments,
          onChanged: (v) => setState(() => _comments = v),
        ),
        Padding(
          padding: const EdgeInsets.all(TixSpace.s4),
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TixButton(
              key: const Key('transfer.snapshotButton'),
              label: l10n.transferSnapshotButton,
              icon: Icons.download,
              busy: _busy,
              onPressed: _export,
            ),
          ),
        ),
      ],
    );
  }
}

class _ImportSection extends ConsumerStatefulWidget {
  const _ImportSection({required this.projects, required this.initialProject});

  final List<Project> projects;
  final String initialProject;

  @override
  ConsumerState<_ImportSection> createState() => _ImportSectionState();
}

class _ImportSectionState extends ConsumerState<_ImportSection> {
  late String _project = widget.projects
      .map((p) => p.key)
      .firstWhere(
        (k) => k == widget.initialProject,
        orElse: () => widget.projects.first.key,
      );
  PickedFile? _file;
  TaskImportResult? _preview;
  var _busy = false;
  String? _error;

  Future<void> _pick() async {
    final picked = await ref.read(attachmentsProvider).pickFile();
    if (picked == null) return;
    setState(() {
      _file = picked;
      _preview = null;
    });
    await _run(commit: false);
  }

  Future<void> _run({required bool commit}) async {
    final file = _file;
    if (file == null) return;
    final l10n = context.l10n;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await ref
          .read(transferProvider.notifier)
          .importTasks(
            project: _project,
            content: utf8.decode(file.bytes, allowMalformed: true),
            filename: file.name,
            commit: commit,
          );
      if (!mounted) return;
      if (commit) {
        showTixToast(
          context,
          l10n.transferImported(result.created, result.updated),
        );
        setState(() {
          _file = null;
          _preview = null;
        });
      } else {
        setState(() => _preview = result);
      }
    } on TixException catch (e) {
      if (mounted) setState(() => _error = errorMessage(l10n, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final preview = _preview;
    final file = _file;
    return TixSection(
      key: const Key('transfer.import'),
      title: l10n.transferImportTitle,
      subtitle: l10n.transferImportHelp,
      children: [
        Padding(
          padding: const EdgeInsets.all(TixSpace.s4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ProjectPicker(
                key: const Key('transfer.importProject'),
                projects: widget.projects,
                value: _project,
                onChanged: (p) => setState(() {
                  _project = p;
                  _preview = null;
                }),
              ),
              const SizedBox(height: TixSpace.s3),
              Wrap(
                spacing: TixSpace.s2,
                runSpacing: TixSpace.s2,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  TixButton(
                    key: const Key('transfer.pick'),
                    label: l10n.transferPick,
                    icon: Icons.upload_file,
                    busy: _busy && preview == null,
                    onPressed: _pick,
                  ),
                  if (file != null) Text(file.name, style: tixMono(context)),
                ],
              ),
              if (preview != null) ...[
                const SizedBox(height: TixSpace.s3),
                Text(
                  l10n.transferDryRun(
                    preview.rows,
                    preview.created,
                    preview.updated,
                    preview.skipped,
                    preview.failed,
                  ),
                  key: const Key('transfer.dryRun'),
                ),
                for (final e in preview.errors.take(5))
                  Text(
                    l10n.transferImportError(e.line, e.message),
                    style: TextStyle(color: context.tix.danger),
                  ),
                const SizedBox(height: TixSpace.s3),
                TixButton(
                  key: const Key('transfer.commit'),
                  label: l10n.transferImportButton(
                    preview.created + preview.updated,
                  ),
                  icon: Icons.check,
                  busy: _busy,
                  onPressed: preview.created + preview.updated == 0
                      ? null
                      : () => _run(commit: true),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: TixSpace.s3),
                Text(_error!, style: TextStyle(color: context.tix.danger)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
