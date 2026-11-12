// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/platform/attachments.dart';
import 'package:tix_mobile/src/core/router/routes.dart';
import 'package:tix_mobile/src/core/time/times.dart';
import 'package:tix_mobile/src/core/widgets/async_body.dart';
import 'package:tix_mobile/src/data/models/project.dart';
import 'package:tix_mobile/src/data/repositories/transfer_repository.dart';
import 'package:tix_mobile/src/features/transfer/application/import_wizard.dart';
import 'package:tix_mobile/src/features/transfer/application/transfer.dart';

/// Tasks into a project in five steps, as the web's import: a file or a
/// pasted list, the columns, the values, a preview and the result. Every
/// step has Back, which keeps what was chosen, and Cancel.
class ImportScreen extends ConsumerWidget {
  /// The import, on [project] when given, else the first project.
  const ImportScreen({this.project = '', super.key});

  /// The project to import into first.
  final String project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return AsyncBody(
      value: ref.watch(transferProjectsProvider),
      onRetry: () => ref.invalidate(transferProjectsProvider),
      loading: TixPage(
        title: l10n.transferImportTitle,
        body: const SkeletonList(),
      ),
      data: (projects) {
        if (projects.isEmpty) {
          return TixPage(
            title: l10n.transferImportTitle,
            body: EmptyState(
              icon: Icons.folder_outlined,
              title: l10n.projectsEmpty,
              body: l10n.transferNoProjects,
            ),
          );
        }
        final start = projects
            .map((p) => p.key)
            .firstWhere((k) => k == project, orElse: () => projects.first.key);
        return _Wizard(projects: projects, start: start);
      },
    );
  }
}

void _leave(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(Routes.transfer);
  }
}

class _Wizard extends ConsumerWidget {
  const _Wizard({required this.projects, required this.start});

  final List<Project> projects;
  final String start;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final draft = ref.watch(importWizardProvider(start));
    final wizard = ref.read(importWizardProvider(start).notifier);
    final error = draft.error;
    final name = projects
        .where((p) => p.key == draft.project)
        .map((p) => p.name)
        .firstOrNull;
    return TixPage(
      title: l10n.transferImportTitle,
      subtitle: l10n.importStepOf(
        draft.step.index + 1,
        l10n.importStep(draft.step.name),
      ),
      subtitleNote: name,
      body: ListView(
        key: ValueKey('import.step.${draft.step.name}'),
        padding: const EdgeInsets.only(bottom: TixSpace.s7),
        children: [
          Align(
            alignment: AlignmentDirectional.topStart,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: TixMeasure.form),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (error != null)
                    _Padded(
                      TixNotice(
                        errorDetail(l10n, error),
                        key: const Key('import.error'),
                        tone: TixNoticeTone.danger,
                      ),
                    ),
                  ...switch (draft.step) {
                    ImportStep.source => [
                      _SourceStep(
                        projects: projects,
                        draft: draft,
                        wizard: wizard,
                      ),
                    ],
                    ImportStep.columns => [
                      _ColumnsStep(draft: draft, wizard: wizard),
                    ],
                    ImportStep.valueMap => [
                      _ValuesStep(draft: draft, wizard: wizard),
                    ],
                    ImportStep.preview => [
                      _PreviewStep(draft: draft, wizard: wizard),
                    ],
                    ImportStep.result => [
                      _ResultStep(draft: draft, wizard: wizard),
                    ],
                  },
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Padded extends StatelessWidget {
  const _Padded(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      TixSpace.s4,
      TixSpace.s3,
      TixSpace.s4,
      0,
    ),
    child: child,
  );
}

/// The buttons every step ends with: Back, Cancel, and the step's own.
class _Foot extends StatelessWidget {
  const _Foot({required this.back, required this.children, this.cancel = true});

  final VoidCallback back;
  final bool cancel;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.all(TixSpace.s4),
      child: Wrap(
        alignment: WrapAlignment.end,
        spacing: TixSpace.s2,
        runSpacing: TixSpace.s2,
        children: [
          TixButton(
            key: const Key('import.back'),
            label: l10n.back,
            icon: Icons.arrow_back,
            onPressed: back,
          ),
          if (cancel)
            TixButton.quiet(
              key: const Key('import.cancel'),
              label: l10n.cancel,
              onPressed: () => _leave(context),
            ),
          ...children,
        ],
      ),
    );
  }
}

class _SourceStep extends ConsumerStatefulWidget {
  const _SourceStep({
    required this.projects,
    required this.draft,
    required this.wizard,
  });

  final List<Project> projects;
  final ImportDraft draft;
  final ImportWizard wizard;

  @override
  ConsumerState<_SourceStep> createState() => _SourceStepState();
}

class _SourceStepState extends ConsumerState<_SourceStep> {
  late final _lines = TextEditingController(text: widget.draft.lines);

  @override
  void dispose() {
    _lines.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final picked = await ref.read(attachmentsProvider).pickFile();
    if (picked == null) return;
    widget.wizard.chooseFile(
      picked.name,
      utf8.decode(picked.bytes, allowMalformed: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final d = widget.draft;
    final w = widget.wizard;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Padded(
          TixNotice(
            l10n.importFewBody,
            key: const Key('import.note'),
            title: l10n.importFewTitle,
          ),
        ),
        _Padded(
          TixSelectField<String>(
            fieldKey: const Key('import.project'),
            label: l10n.columnProject,
            value: d.project,
            options: [
              for (final p in widget.projects) TixOption(p.key, p.name),
            ],
            onChanged: d.busy
                ? null
                : (p) {
                    if (p != null) w.setProject(p);
                  },
          ),
        ),
        TixSection(
          title: l10n.importFileTitle,
          subtitle: l10n.importFileHelp,
          children: [
            Padding(
              padding: const EdgeInsets.all(TixSpace.s3),
              child: Wrap(
                spacing: TixSpace.s2,
                runSpacing: TixSpace.s2,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  TixButton(
                    key: const Key('import.pick'),
                    label: l10n.transferPick,
                    icon: Icons.upload_file,
                    onPressed: d.busy ? null : _pick,
                  ),
                  Text(
                    d.pasted ? l10n.importFileNone : d.filename,
                    key: const Key('import.filename'),
                    style: d.pasted ? null : tixMono(context),
                  ),
                  if (!d.pasted)
                    TixIconButton(
                      key: const Key('import.clearFile'),
                      icon: Icons.close,
                      tooltip: l10n.importFileRemove,
                      onPressed: d.busy ? null : w.clearFile,
                    ),
                ],
              ),
            ),
          ],
        ),
        TixSection(
          title: l10n.importPasteTitle,
          subtitle: l10n.importPasteHelp,
          children: [
            Padding(
              padding: const EdgeInsets.all(TixSpace.s3),
              child: TixTextField(
                fieldKey: const Key('import.lines'),
                label: l10n.importPasteLabel,
                controller: _lines,
                hint: l10n.importPasteHint,
                maxLines: 6,
                width: TixMeasure.form,
                onChanged: w.setLines,
              ),
            ),
          ],
        ),
        _Foot(
          back: () => _leave(context),
          children: [
            if (!d.pasted)
              TixButton(
                key: const Key('import.skip'),
                label: l10n.importSkipToPreview,
                onPressed: d.busy || !d.ready ? null : w.skipToPreview,
              ),
            TixButton.primary(
              key: const Key('import.next'),
              label: d.pasted ? l10n.importNextPreview : l10n.importNextColumns,
              icon: Icons.arrow_forward,
              busy: d.busy,
              onPressed: d.ready ? w.next : null,
            ),
          ],
        ),
      ],
    );
  }
}

class _ColumnsStep extends ConsumerWidget {
  const _ColumnsStep({required this.draft, required this.wizard});

  final ImportDraft draft;
  final ImportWizard wizard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final r = draft.result!;
    final fields =
        ref.watch(transferFieldsProvider(draft.project)).value ?? const [];
    final targets = <TixOption<String>>[
      for (final t in importTargets) TixOption(t, l10n.importTarget(t)),
      for (final f in fields)
        TixOption('custom:${f.key}', f.label.isEmpty ? f.key : f.label),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (r.confident)
          _Padded(
            TixNotice(
              l10n.importConfidentBody,
              key: const Key('import.confident'),
              title: l10n.importConfidentTitle,
            ),
          ),
        _Padded(
          Text(
            [
              l10n.importRows(r.rows),
              if (r.source.isNotEmpty) l10n.importLooksLike(r.source),
              l10n.importColumnsHelp,
            ].join(' · '),
            style: TextStyle(color: context.tix.muted),
          ),
        ),
        TixSection(
          title: l10n.importStep(ImportStep.columns.name),
          children: [
            for (final c in r.columns)
              _ColumnRow(
                key: ValueKey('import.column.${c.header}'),
                column: c,
                target: draft.target(c),
                options: [
                  ...targets,
                  if (!targets.any((o) => o.value == draft.target(c)))
                    TixOption(draft.target(c), draft.target(c)),
                ],
                onChanged: draft.busy
                    ? null
                    : (t) {
                        if (t != null) wizard.setColumn(c.header, t);
                      },
              ),
          ],
        ),
        _Foot(
          back: wizard.back,
          children: [
            TixButton(
              key: const Key('import.skip'),
              label: l10n.importSkipToPreview,
              onPressed: draft.busy ? null : wizard.skipToPreview,
            ),
            TixButton.primary(
              key: const Key('import.next'),
              label: l10n.importNextValues,
              icon: Icons.arrow_forward,
              busy: draft.busy,
              onPressed: wizard.next,
            ),
          ],
        ),
      ],
    );
  }
}

/// A label and its sample beside its control when there is room, above it
/// when there is not.
class _Pair extends StatelessWidget {
  const _Pair({required this.label, required this.control});

  final Widget label;
  final Widget control;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(TixSpace.s3),
    child: LayoutBuilder(
      builder: (context, box) => box.maxWidth >= 560
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: label),
                const SizedBox(width: TixSpace.s4),
                Expanded(child: control),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                label,
                const SizedBox(height: TixSpace.s2),
                control,
              ],
            ),
    ),
  );
}

class _ColumnRow extends StatelessWidget {
  const _ColumnRow({
    required this.column,
    required this.target,
    required this.options,
    required this.onChanged,
    super.key,
  });

  final TaskImportColumn column;
  final String target;
  final List<TixOption<String>> options;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return _Pair(
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: TixSpace.s2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(column.header, style: tixMono(context)),
              if (column.suggested) TixBadge(l10n.importSuggested),
            ],
          ),
          if (column.sample.isNotEmpty)
            Text(
              column.sample.join(', '),
              style: TextStyle(color: context.tix.muted),
            ),
        ],
      ),
      control: TixSelectField<String>(
        fieldKey: Key('import.target.${column.header}'),
        label: l10n.importColumnField(column.header),
        value: target,
        options: options,
        onChanged: onChanged,
      ),
    );
  }
}

class _ValuesStep extends ConsumerWidget {
  const _ValuesStep({required this.draft, required this.wizard});

  final ImportDraft draft;
  final ImportWizard wizard;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final r = draft.result!;
    final states =
        ref.watch(importStatesProvider(draft.project)).value ?? const [];
    final choices = <String, List<TixOption<String>>>{
      'status': [
        TixOption('', l10n.importNoMapping),
        for (final s in states) TixOption(s.key, s.label),
      ],
      'priority': [
        TixOption('', l10n.importNoMapping),
        for (var i = 0; i < importPriorities.length; i++)
          TixOption(importPriorities[i], l10n.priorityLabel('${i + 1}')),
      ],
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Padded(
          Text(
            l10n.importValuesHelp,
            style: TextStyle(color: context.tix.muted),
          ),
        ),
        for (final field in importValueFields)
          TixSection(
            key: Key('import.values.$field'),
            title: l10n.importTarget(field),
            children: [
              if ((r.values[field] ?? const []).isEmpty)
                Padding(
                  padding: const EdgeInsets.all(TixSpace.s3),
                  child: Text(
                    l10n.importValuesNone,
                    style: TextStyle(color: context.tix.muted),
                  ),
                ),
              for (final v in r.values[field] ?? const <TaskImportValue>[])
                _ValueRow(
                  key: ValueKey('import.value.$field.${v.value}'),
                  field: field,
                  value: v,
                  mapped: draft.valueOf(field, v),
                  options: choices[field],
                  onChanged: draft.busy
                      ? null
                      : (to) => wizard.setValue(field, v.value, to ?? ''),
                ),
              Padding(
                padding: const EdgeInsets.all(TixSpace.s3),
                child: TixSelectField<String>(
                  fieldKey: Key('import.policy.$field'),
                  label: l10n.importUnknown,
                  value: draft.policy(field),
                  options: [
                    for (final p in importPolicies[field]!)
                      TixOption(p, l10n.importPolicy(p)),
                  ],
                  onChanged: draft.busy
                      ? null
                      : (p) {
                          if (p != null) wizard.setPolicy(field, p);
                        },
                ),
              ),
            ],
          ),
        _Foot(
          back: wizard.back,
          children: [
            TixButton.primary(
              key: const Key('import.next'),
              label: l10n.importNextPreview,
              icon: Icons.arrow_forward,
              busy: draft.busy,
              onPressed: wizard.next,
            ),
          ],
        ),
      ],
    );
  }
}

class _ValueRow extends StatefulWidget {
  const _ValueRow({
    required this.field,
    required this.value,
    required this.mapped,
    required this.options,
    required this.onChanged,
    super.key,
  });

  final String field;
  final TaskImportValue value;
  final String mapped;

  /// The choices; null takes a handle as text.
  final List<TixOption<String>>? options;
  final ValueChanged<String?>? onChanged;

  @override
  State<_ValueRow> createState() => _ValueRowState();
}

class _ValueRowState extends State<_ValueRow> {
  late final _text = TextEditingController(text: widget.mapped);

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final v = widget.value;
    final options = widget.options;
    final key = Key('import.becomes.${widget.field}.${v.value}');
    return _Pair(
      label: Wrap(
        spacing: TixSpace.s2,
        runSpacing: TixSpace.s1,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(v.value, style: tixMono(context)),
          if (v.suggested) TixBadge(l10n.importSuggested),
          Text(
            l10n.importRows(v.count),
            style: TextStyle(color: context.tix.muted),
          ),
        ],
      ),
      control: options == null
          ? TixTextField(
              fieldKey: key,
              label: l10n.importValueBecomes(v.value),
              controller: _text,
              hint: l10n.importHandleHint,
              enabled: widget.onChanged != null,
              onChanged: widget.onChanged,
            )
          : TixSelectField<String>(
              fieldKey: key,
              label: l10n.importValueBecomes(v.value),
              value: widget.mapped,
              options: [
                ...options,
                if (!options.any((o) => o.value == widget.mapped))
                  TixOption(widget.mapped, widget.mapped),
              ],
              onChanged: widget.onChanged,
            ),
    );
  }
}

/// The counts of a dry run or an import.
class _Counts extends StatelessWidget {
  const _Counts(this.result);

  final TaskImportResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Wrap(
      key: const Key('import.counts'),
      spacing: TixSpace.s2,
      runSpacing: TixSpace.s2,
      children: [
        TixBadge(l10n.importToCreate(result.created)),
        TixBadge(l10n.importToUpdate(result.updated)),
        TixBadge(l10n.importToSkip(result.skipped)),
        TixBadge(
          l10n.importInError(result.failed),
          tone: result.failed > 0 ? TixTone.danger : TixTone.neutral,
        ),
      ],
    );
  }
}

/// Every row in error, the first fifty listed, and the report to save.
class _Errors extends ConsumerWidget {
  const _Errors({required this.project, required this.result});

  final String project;
  final TaskImportResult result;

  Future<void> _download(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final name = '$project-import-errors.csv';
    final saved = await ref
        .read(attachmentsProvider)
        .saveBytes(name, utf8.encode(importErrorsCsv(result)), 'text/csv');
    if (saved && context.mounted) {
      showTixToast(context, l10n.transferExported(name));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tix;
    return TixSection(
      key: const Key('import.errors'),
      title: l10n.importErrorsTitle,
      children: [
        for (final e in result.errors.take(50))
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: TixSpace.s3,
              vertical: TixSpace.s2,
            ),
            child: Text(
              l10n.transferImportError(e.line, e.message),
              style: TextStyle(color: t.danger),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(TixSpace.s3),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: TixButton(
              key: const Key('import.errorsCsv'),
              label: l10n.importErrorsDownload,
              icon: Icons.download,
              onPressed: () => _download(context, ref),
            ),
          ),
        ),
      ],
    );
  }
}

class _PreviewStep extends StatelessWidget {
  const _PreviewStep({required this.draft, required this.wizard});

  final ImportDraft draft;
  final ImportWizard wizard;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final r = draft.result!;
    final writes = r.created + r.updated;
    final canImport = r.failed == 0 && r.rows > r.skipped;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Padded(_Counts(r)),
        if (r.failed > 0)
          _Padded(
            TixNotice(
              l10n.importFailedNote,
              key: const Key('import.failed'),
              tone: TixNoticeTone.danger,
            ),
          ),
        if (r.errors.isNotEmpty) _Errors(project: draft.project, result: r),
        TixSection(
          title: l10n.importModeTitle,
          subtitle: l10n.importModeHelp,
          children: [
            Padding(
              padding: const EdgeInsets.all(TixSpace.s3),
              child: TixChoices<ImportMode>(
                key: const Key('import.mode'),
                choices: [
                  for (final m in ImportMode.values)
                    TixChoice(m, l10n.importMode(m.name)),
                ],
                selected: draft.mode,
                onSelected: (m) {
                  if (!draft.busy) unawaited(wizard.setMode(m));
                },
              ),
            ),
          ],
        ),
        TixSection(
          title: l10n.importPreviewTitle,
          children: [
            if (r.preview.isEmpty)
              Padding(
                padding: const EdgeInsets.all(TixSpace.s3),
                child: Text(l10n.importPreviewNone),
              ),
            for (final row in r.preview)
              _PreviewRow(key: Key('import.row.${row.line}'), row: row),
          ],
        ),
        _Foot(
          back: wizard.back,
          children: [
            TixButton.primary(
              key: const Key('import.commit'),
              label: canImport
                  ? l10n.transferImportButton(writes)
                  : r.failed > 0
                  ? l10n.importFixFirst
                  : l10n.importNothing,
              icon: Icons.check,
              busy: draft.busy,
              onPressed: canImport ? wizard.commit : null,
            ),
          ],
        ),
      ],
    );
  }
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({required this.row, super.key});

  final TaskImportRow row;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tix;
    final failed = row.action == 'error';
    final due = row.due;
    final facts = [
      if (row.status.isNotEmpty) row.status,
      if (row.priority >= 1 && row.priority <= 5)
        l10n.priorityLabel('${row.priority}'),
      if (row.assignee.isNotEmpty) '@${row.assignee}',
      ...row.tags.map((tag) => '#$tag'),
      if (due != null) context.times.style.date(due),
      if (row.parent.isNotEmpty) '^${row.parent}',
    ];
    return ColoredBox(
      color: failed ? t.dangerSoft : Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(TixSpace.s3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: TixSpace.s2,
              runSpacing: TixSpace.s1,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  l10n.importLine(row.line),
                  style: TextStyle(color: t.muted),
                ),
                TixBadge(
                  l10n.importAction(row.action),
                  tone: switch (row.action) {
                    'error' => TixTone.danger,
                    'create' => TixTone.ok,
                    'update' => TixTone.accent,
                    _ => TixTone.neutral,
                  },
                ),
                if (row.ref.isNotEmpty) Text(row.ref, style: tixMono(context)),
                Text(
                  row.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            if (facts.isNotEmpty)
              Text(facts.join(' · '), style: TextStyle(color: t.muted)),
            if (row.reason.isNotEmpty)
              Text(row.reason, style: TextStyle(color: t.muted)),
            for (final e in row.errors)
              Text(
                e,
                key: Key('import.row.${row.line}.error'),
                style: TextStyle(color: t.danger),
              ),
          ],
        ),
      ),
    );
  }
}

class _ResultStep extends StatelessWidget {
  const _ResultStep({required this.draft, required this.wizard});

  final ImportDraft draft;
  final ImportWizard wizard;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final r = draft.committed!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (r.committed)
          _Padded(
            TixNotice(
              l10n.importDoneBody(r.created, r.updated, r.skipped),
              key: const Key('import.done'),
              title: l10n.importDoneTitle,
            ),
          )
        else ...[
          _Padded(
            TixNotice(
              l10n.importRolledBackBody,
              key: const Key('import.rolledBack'),
              title: l10n.importRolledBackTitle,
              tone: TixNoticeTone.danger,
            ),
          ),
          _Padded(_Counts(r)),
          if (r.errors.isNotEmpty) _Errors(project: draft.project, result: r),
        ],
        _Foot(
          back: wizard.back,
          cancel: false,
          children: [
            TixButton(
              key: const Key('import.another'),
              label: l10n.importAnother,
              icon: Icons.upload_file,
              onPressed: wizard.restart,
            ),
            TixButton.primary(
              key: const Key('import.openProject'),
              label: l10n.importOpenProject,
              icon: Icons.arrow_forward,
              onPressed: () => context.go(Routes.project(draft.project)),
            ),
          ],
        ),
      ],
    );
  }
}
