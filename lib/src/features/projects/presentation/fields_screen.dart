// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/router/routes.dart';
import 'package:tix_mobile/src/core/session/access.dart';
import 'package:tix_mobile/src/core/widgets/async_body.dart';
import 'package:tix_mobile/src/data/models/project_admin.dart';
import 'package:tix_mobile/src/features/projects/application/project_admin.dart';
import 'package:tix_mobile/src/features/projects/application/projects.dart';

/// The name a person reads for the field type [t].
String fieldTypeName(AppLocalizations l10n, FieldType? t) => switch (t) {
  FieldType.string => l10n.fieldTypeString,
  FieldType.text => l10n.fieldTypeText,
  FieldType.int => l10n.fieldTypeInt,
  FieldType.float => l10n.fieldTypeFloat,
  FieldType.bool => l10n.fieldTypeBool,
  FieldType.date => l10n.fieldTypeDate,
  FieldType.datetime => l10n.fieldTypeDatetime,
  FieldType.enumValue => l10n.fieldTypeEnum,
  FieldType.actor => l10n.fieldTypeActor,
  FieldType.json => l10n.fieldTypeJson,
  null => l10n.fieldTypeUnknown,
};

/// The projects whose custom fields can be managed: the way in from the
/// Manage screen, since tix defines fields per project.
class FieldProjectsScreen extends ConsumerWidget {
  /// Creates the screen.
  const FieldProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final t = context.tix;
    return TixPage(
      title: l10n.fieldsTitle,
      subtitle: l10n.fieldProjectsSubtitle,
      body: AsyncBody(
        value: ref.watch(projectsProvider),
        onRetry: () => ref.invalidate(projectsProvider),
        data: (paged) => paged.items.isEmpty
            ? EmptyState(icon: Icons.folder_outlined, title: l10n.projectsEmpty)
            : ListView(
                children: [
                  for (final p in paged.items)
                    ListTile(
                      key: Key('fields.project.${p.key}'),
                      leading: ProjectMark(
                        name: p.name.isEmpty ? p.key : p.name,
                        colour: p.color,
                        icon: p.icon,
                        iconName: p.iconName,
                      ),
                      title: Text(p.name.isEmpty ? p.key : p.name),
                      subtitle: Text(p.key, style: tixMono(context)),
                      trailing: Icon(Icons.chevron_right, color: t.lineStrong),
                      onTap: () => context.go(
                        '${Routes.fieldProjects}/${Uri.encodeComponent(p.key)}',
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

/// A project's custom fields in display order: define, edit, reorder and
/// delete them.
class ProjectFieldsScreen extends ConsumerWidget {
  /// The fields of project [projectKey].
  const ProjectFieldsScreen({required this.projectKey, super.key});

  /// The project's key.
  final String projectKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final access = ref.watch(currentAccessProvider).value ?? Access.none;
    final write = access.has(Scope.projectWrite);
    final fields = ref.watch(projectFieldsProvider(projectKey));
    final project = ref.watch(projectSettingsProvider(projectKey)).value;
    void add() => showFieldSheet(context, projectKey, fields.value ?? const []);
    final action = write
        ? TixAction(
            key: const Key('field.new'),
            label: l10n.fieldNew,
            icon: Icons.add,
            onPressed: add,
          )
        : null;
    return TixPage(
      title: l10n.fieldsTitle,
      subtitle: project == null
          ? projectKey
          : (project.name.isEmpty ? project.key : project.name),
      primaryAction: action,
      body: AsyncBody(
        value: fields,
        onRetry: () => ref.invalidate(projectFieldsProvider(projectKey)),
        data: (list) {
          if (list.isEmpty) {
            return EmptyState(
              icon: Icons.tune,
              title: l10n.fieldsEmpty,
              body: l10n.fieldsEmptyBody,
              action: action,
            );
          }
          final tiles = [
            for (final (i, f) in list.indexed)
              _FieldTile(
                key: ValueKey(f.key),
                field: f,
                index: i,
                reorderable: write,
                onTap: write
                    ? () => showFieldSheet(context, projectKey, list, field: f)
                    : null,
              ),
          ];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!write)
                Padding(
                  padding: const EdgeInsets.all(TixSpace.s4),
                  child: TixNotice(l10n.fieldsReadOnly),
                ),
              Expanded(
                child: write
                    ? ReorderableListView(
                        buildDefaultDragHandles: false,
                        padding: const EdgeInsets.only(bottom: TixSpace.s7 * 2),
                        onReorderItem: (from, to) async {
                          try {
                            await ref
                                .read(
                                  projectFieldsProvider(projectKey).notifier,
                                )
                                .move(from, to);
                          } on Object catch (e) {
                            if (context.mounted) {
                              showTixToast(
                                context,
                                errorDetail(l10n, e),
                                tone: TixTone.danger,
                              );
                            }
                          }
                        },
                        children: tiles,
                      )
                    : ListView(children: tiles),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FieldTile extends StatelessWidget {
  const _FieldTile({
    required this.field,
    required this.index,
    required this.reorderable,
    required this.onTap,
    super.key,
  });

  final FieldDef field;
  final int index;
  final bool reorderable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = context.tix;
    final d = field.defaultValue;
    return Material(
      color: t.bg,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(
            horizontal: TixSpace.s4,
            vertical: TixSpace.s3,
          ),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: t.line)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: TixSpace.s2,
                      runSpacing: TixSpace.s1,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          field.label.isEmpty ? field.key : field.label,
                          style: const TextStyle(
                            fontSize: TixText.md,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(field.key, style: tixMono(context)),
                        TixBadge(fieldTypeName(l10n, field.type)),
                        if (field.required)
                          TixBadge(l10n.fieldRequired, tone: TixTone.accent),
                      ],
                    ),
                    if (field.type == FieldType.enumValue || d != null) ...[
                      const SizedBox(height: TixSpace.s1),
                      Text(
                        [
                          if (field.type == FieldType.enumValue)
                            field.enumOptions.join(', '),
                          if (d != null) l10n.fieldDefaultIs(_shown(d)),
                        ].join(' · '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              if (reorderable)
                ReorderableDragStartListener(
                  index: index,
                  child: Tooltip(
                    message: l10n.manageDragToReorder,
                    child: SizedBox.square(
                      dimension: TixSize.target,
                      child: Icon(Icons.drag_handle, color: t.muted),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static String _shown(Object d) =>
      d is String ? d : const JsonEncoder().convert(d);
}

/// Opens the form that defines a field on [project], or edits [field].
Future<void> showFieldSheet(
  BuildContext context,
  String project,
  List<FieldDef> existing, {
  FieldDef? field,
}) => showTixSheet<void>(
  context,
  builder: (_) =>
      _FieldSheet(project: project, existing: existing, field: field),
);

class _FieldSheet extends ConsumerStatefulWidget {
  const _FieldSheet({
    required this.project,
    required this.existing,
    this.field,
  });

  final String project;
  final List<FieldDef> existing;
  final FieldDef? field;

  @override
  ConsumerState<_FieldSheet> createState() => _FieldSheetState();
}

class _FieldSheetState extends ConsumerState<_FieldSheet> {
  late final FieldDef? _f = widget.field;
  late final _key = TextEditingController(text: _f?.key ?? '');
  late final _label = TextEditingController(text: _f?.label ?? '');
  late final _options = TextEditingController(
    text: _f?.enumOptions.join(', ') ?? '',
  );
  late final _defaultText = TextEditingController(
    text: switch (_f?.defaultValue) {
      null => '',
      final String s => s,
      final num n => '$n',
      final Object o => const JsonEncoder.withIndent('  ').convert(o),
    },
  );
  late FieldType _type = _f?.type ?? FieldType.string;
  late Object? _choice = _f?.defaultValue;
  late bool _required = _f?.required ?? false;
  String? _localError;
  Object? _error;
  var _busy = false;

  bool get _editing => _f != null;

  @override
  void dispose() {
    _key.dispose();
    _label.dispose();
    _options.dispose();
    _defaultText.dispose();
    super.dispose();
  }

  List<String> get _optionList => [
    for (final o in _options.text.split(','))
      if (o.trim().isNotEmpty) o.trim(),
  ];

  /// The default as the type holds it, or throws [FormatException] for
  /// text that cannot be read as one.
  Object? get _default {
    final text = _defaultText.text.trim();
    return switch (_type) {
      FieldType.bool || FieldType.enumValue => _choice,
      FieldType.date || FieldType.datetime => _choice,
      FieldType.int => text.isEmpty ? null : int.parse(text),
      FieldType.float => text.isEmpty ? null : double.parse(text),
      FieldType.json => text.isEmpty ? null : jsonDecode(text),
      _ => text.isEmpty ? null : text,
    };
  }

  int get _position {
    final f = _f;
    if (f != null) return f.position;
    var top = 0;
    for (final e in widget.existing) {
      if (e.position > top) top = e.position;
    }
    return top + 10;
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final Object? value;
    try {
      value = _default;
    } on FormatException {
      setState(() => _localError = l10n.fieldDefaultUnreadable);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _localError = null;
    });
    final input = FieldDefInput(
      key: _key.text.trim(),
      label: _label.text.trim(),
      type: _type,
      enumOptions: _type == FieldType.enumValue ? _optionList : null,
      defaultValue: value,
      position: _position,
      required: _required,
    );
    try {
      await ref.read(projectFieldsProvider(widget.project).notifier).put(input);
      if (!mounted) return;
      showTixToast(context, l10n.fieldSaved(input.key ?? ''));
      Navigator.of(context).pop();
    } on Object catch (e) {
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
    final f = _f!;
    final ok = await confirmDestructive(
      context,
      title: l10n.fieldDeleteTitle(f.key),
      body: l10n.fieldDeleteBody,
      action: l10n.manageDelete,
    );
    if (!ok || !mounted) return;
    try {
      await ref
          .read(projectFieldsProvider(widget.project).notifier)
          .delete(f.key);
      if (!mounted) return;
      showTixToast(context, l10n.fieldDeleted(f.key));
      Navigator.of(context).pop();
    } on Object catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final error = _error;
    return TixSheetBody(
      title: _editing ? l10n.fieldEdit(_f!.key) : l10n.fieldNew,
      actions: [
        if (_editing)
          TixButton.danger(
            key: const Key('field.delete'),
            label: l10n.manageDelete,
            onPressed: _busy ? null : _delete,
          ),
        TixButton.quiet(
          label: l10n.cancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
        TixButton.primary(
          key: const Key('field.save'),
          label: l10n.manageSave,
          busy: _busy,
          onPressed: _save,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (error != null) ...[
            TixNotice(
              errorDetail(l10n, error),
              key: const Key('field.error'),
              tone: TixNoticeTone.danger,
            ),
            const SizedBox(height: TixSpace.s3),
          ],
          TixTextField(
            fieldKey: const Key('field.key'),
            label: l10n.fieldKey,
            controller: _key,
            enabled: !_editing,
            autofocus: !_editing,
            help: _editing ? l10n.fieldKeyFixed : l10n.fieldKeyHelp,
          ),
          const SizedBox(height: TixSpace.s3),
          TixTextField(
            fieldKey: const Key('field.label'),
            label: l10n.fieldLabel,
            controller: _label,
            help: l10n.fieldLabelHelp,
          ),
          const SizedBox(height: TixSpace.s3),
          TixSelectField<FieldType>(
            fieldKey: const Key('field.type'),
            label: l10n.fieldType,
            value: _type,
            options: [
              for (final t in FieldType.values)
                TixOption(t, fieldTypeName(l10n, t)),
            ],
            onChanged: (t) => setState(() {
              _type = t ?? _type;
              _choice = null;
              _defaultText.clear();
            }),
          ),
          if (_type == FieldType.enumValue) ...[
            const SizedBox(height: TixSpace.s3),
            TixTextField(
              fieldKey: const Key('field.options'),
              label: l10n.fieldOptions,
              controller: _options,
              help: l10n.fieldOptionsHelp,
              onChanged: (_) => setState(() {}),
            ),
          ],
          const SizedBox(height: TixSpace.s3),
          _defaultInput(context),
          if (_localError != null)
            Padding(
              padding: const EdgeInsets.only(top: TixSpace.s1),
              child: Text(
                _localError!,
                key: const Key('field.defaultError'),
                style: TextStyle(
                  color: context.tix.danger,
                  fontSize: TixText.xs,
                ),
              ),
            ),
          const SizedBox(height: TixSpace.s2),
          TixSwitchRow(
            key: const Key('field.required'),
            title: l10n.fieldRequired,
            subtitle: l10n.fieldRequiredHelp,
            value: _required,
            onChanged: (v) => setState(() => _required = v),
          ),
        ],
      ),
    );
  }

  Widget _defaultInput(BuildContext context) {
    final l10n = context.l10n;
    final label = l10n.fieldDefault;
    switch (_type) {
      case FieldType.bool:
        return TixSelectField<String>(
          fieldKey: const Key('field.default'),
          label: label,
          value: switch (_choice) {
            true => 'yes',
            false => 'no',
            _ => 'none',
          },
          options: [
            TixOption('none', l10n.fieldNoDefault),
            TixOption('yes', l10n.manageYes),
            TixOption('no', l10n.manageNo),
          ],
          onChanged: (v) => setState(
            () => _choice = switch (v) {
              'yes' => true,
              'no' => false,
              _ => null,
            },
          ),
        );
      case FieldType.enumValue:
        final options = _optionList;
        return TixSelectField<String>(
          key: ValueKey(options.join('\n')),
          fieldKey: const Key('field.default'),
          label: label,
          value: _choice is String && options.contains(_choice)
              ? _choice! as String
              : '',
          options: [
            TixOption('', l10n.fieldNoDefault),
            for (final o in options) TixOption(o, o),
          ],
          onChanged: (v) =>
              setState(() => _choice = (v ?? '').isEmpty ? null : v),
        );
      case FieldType.date:
      case FieldType.datetime:
        final value = _choice as String?;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TixFieldLabel(label),
            Wrap(
              spacing: TixSpace.s2,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                TixButton(
                  key: const Key('field.default'),
                  label: value == null
                      ? l10n.fieldPickDefault
                      : _dateLabel(value),
                  icon: Icons.event,
                  onPressed: _pickDate,
                ),
                if (value != null)
                  TixButton.quiet(
                    key: const Key('field.default.clear'),
                    label: l10n.manageClear,
                    onPressed: () => setState(() => _choice = null),
                  ),
              ],
            ),
          ],
        );
      case FieldType.int:
      case FieldType.float:
        return TixTextField(
          fieldKey: const Key('field.default'),
          label: label,
          controller: _defaultText,
          keyboardType: TextInputType.numberWithOptions(
            signed: true,
            decimal: _type == FieldType.float,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp(_type == FieldType.float ? '[-0-9.eE]' : '[-0-9]'),
            ),
          ],
          hint: l10n.fieldNoDefault,
        );
      case FieldType.actor:
        return TixTextField(
          fieldKey: const Key('field.default'),
          label: label,
          controller: _defaultText,
          hint: l10n.fieldActorHint,
        );
      case FieldType.text:
      case FieldType.json:
        return TixTextField(
          fieldKey: const Key('field.default'),
          label: label,
          controller: _defaultText,
          maxLines: 4,
          hint: _type == FieldType.json ? '{"key": "value"}' : null,
        );
      case FieldType.string:
        return TixTextField(
          fieldKey: const Key('field.default'),
          label: label,
          controller: _defaultText,
          hint: l10n.fieldNoDefault,
        );
    }
  }

  String _dateLabel(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    final locale = Localizations.localeOf(context).toLanguageTag();
    return _type == FieldType.date
        ? DateFormat.yMMMd(locale).format(parsed)
        : DateFormat.yMMMd(locale).add_Hm().format(parsed.toLocal());
  }

  Future<void> _pickDate() async {
    final current = DateTime.tryParse((_choice as String?) ?? '');
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: current?.toLocal() ?? now,
      firstDate: DateTime(1970),
      lastDate: DateTime(now.year + 50),
    );
    if (date == null || !mounted) return;
    if (_type == FieldType.date) {
      setState(() => _choice = DateFormat('yyyy-MM-dd').format(date));
      return;
    }
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current?.toLocal() ?? now),
    );
    if (time == null || !mounted) return;
    final at = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    setState(() => _choice = at.toUtc().toIso8601String());
  }
}
