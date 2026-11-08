// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/clock/clock.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/data/models/actor.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/features/tasks/application/task_detail.dart';
import 'package:tix_mobile/src/features/tasks/presentation/detail/mentions.dart';

/// A value chosen in a sheet that may itself be "nothing": a cleared due
/// date, an unassigned task. Null from a sheet means it was cancelled.
@immutable
class Choice<T> {
  /// Wraps [value].
  const Choice(this.value);

  /// What was chosen.
  final T value;
}

/// Asks for a priority, marking [current].
Future<int?> pickPriority(BuildContext context, int current) =>
    showTixSheet<int>(
      context,
      builder: (context) => TixSheetBody(
        title: context.l10n.taskDetailPriorityTitle,
        actions: [_cancel(context)],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var p = 1; p <= 5; p++)
              _ChoiceTile(
                key: Key('priority.$p'),
                selected: p == current,
                onTap: () => Navigator.of(context).pop(p),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: PriorityMark(priority: p, emphasizeNormal: true),
                ),
              ),
          ],
        ),
      ),
    );

/// Asks for one of the tenant's actors; `Choice('')` unassigns.
Future<Choice<String>?> pickActor(
  BuildContext context, {
  required String current,
  required String title,
}) => showTixSheet<Choice<String>>(
  context,
  builder: (context) => _ActorPicker(current: current, title: title),
);

class _ActorPicker extends ConsumerStatefulWidget {
  const _ActorPicker({required this.current, required this.title});

  final String current;
  final String title;

  @override
  ConsumerState<_ActorPicker> createState() => _ActorPickerState();
}

class _ActorPickerState extends ConsumerState<_ActorPicker> {
  var _query = '';

  bool _matches(Actor a) {
    final q = _query.trim().toLowerCase().replaceFirst('@', '');
    if (q.isEmpty) return true;
    return a.handle.toLowerCase().contains(q) ||
        a.displayName.toLowerCase().contains(q);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final actors = ref.watch(actorDirectoryProvider);
    return TixSheetBody(
      title: widget.title,
      actions: [_cancel(context)],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TixSearchField(
            fieldKey: const Key('actor.search'),
            hint: l10n.taskDetailActorSearch,
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: TixSpace.s2),
          if (widget.current.isNotEmpty)
            _ChoiceTile(
              key: const Key('actor.none'),
              onTap: () => Navigator.of(context).pop(const Choice('')),
              child: Text(
                l10n.taskDetailUnassign,
                style: TextStyle(color: context.tix.muted),
              ),
            ),
          switch (actors) {
            AsyncData(:final value) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final a in value.where(_matches))
                  _ChoiceTile(
                    key: Key('actor.${a.id}'),
                    selected: a.id == widget.current,
                    onTap: () => Navigator.of(context).pop(Choice(a.id)),
                    child: Row(
                      children: [
                        TixAvatar(
                          label: a.label,
                          seed: a.handle.isEmpty ? a.id : a.handle,
                          size: 28,
                          hued: true,
                          icon: a.kind == ActorKind.agent
                              ? Icons.smart_toy_outlined
                              : null,
                        ),
                        const SizedBox(width: TixSpace.s3),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(a.label),
                              if (a.handle.isNotEmpty && a.handle != a.label)
                                Text(
                                  '@${a.handle}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            AsyncError(:final error) => ErrorState(
              error: error,
              compact: true,
              onRetry: () => ref.invalidate(actorDirectoryProvider),
            ),
            _ => const SkeletonList(rows: 4, inline: true),
          },
        ],
      ),
    );
  }
}

/// Asks for a line or a block of text, prefilled with [initial].
Future<String?> askText(
  BuildContext context, {
  required String title,
  required String label,
  String initial = '',
  String? hint,
  String? help,
  String? info,
  bool multiline = false,
  bool mentions = false,
  bool allowEmpty = true,
  String? action,
}) => showTixSheet<String>(
  context,
  builder: (context) => _TextSheet(
    title: title,
    label: label,
    initial: initial,
    hint: hint,
    help: help,
    info: info,
    multiline: multiline,
    mentions: mentions,
    allowEmpty: allowEmpty,
    action: action,
  ),
);

class _TextSheet extends StatefulWidget {
  const _TextSheet({
    required this.title,
    required this.label,
    required this.initial,
    required this.multiline,
    required this.mentions,
    required this.allowEmpty,
    this.hint,
    this.help,
    this.info,
    this.action,
  });

  final String title;
  final String label;
  final String initial;
  final String? hint;
  final String? help;
  final String? info;
  final bool multiline;
  final bool mentions;
  final bool allowEmpty;
  final String? action;

  @override
  State<_TextSheet> createState() => _TextSheetState();
}

class _TextSheetState extends State<_TextSheet> {
  late final _controller = TextEditingController(text: widget.initial)
    ..addListener(() => setState(() {}));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (!widget.allowEmpty && _controller.text.trim().isEmpty) return;
    Navigator.of(context).pop(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final field = widget.mentions
        ? MentionTextField(
            controller: _controller,
            label: widget.label,
            hint: widget.hint,
            maxLines: widget.multiline ? 10 : 1,
            autofocus: true,
            onSubmit: _save,
          )
        : TixTextField(
            fieldKey: const Key('text.field'),
            controller: _controller,
            label: widget.label,
            hint: widget.hint,
            help: widget.help,
            info: widget.info,
            autofocus: true,
            maxLines: widget.multiline ? 10 : 1,
            keyboardType: widget.multiline ? TextInputType.multiline : null,
            textInputAction: widget.multiline
                ? TextInputAction.newline
                : TextInputAction.done,
            onSubmitted: widget.multiline ? null : (_) => _save(),
          );
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter, control: true): _save,
        const SingleActivator(LogicalKeyboardKey.enter, meta: true): _save,
      },
      child: TixSheetBody(
        title: widget.title,
        actions: [
          _cancel(context),
          TixButton.primary(
            key: const Key('text.save'),
            label: widget.action ?? l10n.taskDetailSave,
            onPressed: !widget.allowEmpty && _controller.text.trim().isEmpty
                ? null
                : _save,
          ),
        ],
        child: field,
      ),
    );
  }
}

/// Asks for a due date: today, tomorrow, next week, a picked day, or none.
Future<Choice<DateTime?>?> pickDue(
  BuildContext context,
  WidgetRef ref, {
  DateTime? current,
}) async {
  final l10n = context.l10n;
  final now = ref.read(clockProvider)().toLocal();
  DateTime day(int offset) => DateTime(now.year, now.month, now.day + offset);
  final choice = await showActionSheet<String>(
    context,
    title: l10n.taskDetailDueTitle,
    actions: [
      TixSheetAction(
        key: const Key('due.today'),
        value: 'today',
        label: l10n.taskDetailDueToday,
        icon: Icons.today_outlined,
      ),
      TixSheetAction(
        key: const Key('due.tomorrow'),
        value: 'tomorrow',
        label: l10n.taskDetailDueTomorrow,
        icon: Icons.wb_sunny_outlined,
      ),
      TixSheetAction(
        key: const Key('due.week'),
        value: 'week',
        label: l10n.taskDetailDueNextWeek,
        icon: Icons.date_range_outlined,
      ),
      TixSheetAction(
        key: const Key('due.pick'),
        value: 'pick',
        label: l10n.taskDetailPickDate,
        icon: Icons.edit_calendar_outlined,
      ),
      if (current != null)
        TixSheetAction(
          key: const Key('due.clear'),
          value: 'clear',
          label: l10n.taskDetailDueClear,
          icon: Icons.event_busy_outlined,
          destructive: true,
        ),
    ],
  );
  if (!context.mounted) return null;
  switch (choice) {
    case 'today':
      return Choice(day(0));
    case 'tomorrow':
      return Choice(day(1));
    case 'week':
      final d = (DateTime.monday - now.weekday + 7) % 7;
      return Choice(day(d == 0 ? 7 : d));
    case 'clear':
      return const Choice(null);
    case 'pick':
      final picked = await showDatePicker(
        context: context,
        initialDate: current?.toLocal() ?? now,
        firstDate: DateTime(now.year - 10),
        lastDate: DateTime(now.year + 10),
      );
      return picked == null ? null : Choice(picked);
  }
  return null;
}

/// Asks for a date and a time of day, starting at [initial].
Future<DateTime?> pickDateTime(BuildContext context, DateTime initial) async {
  final local = initial.toLocal();
  final date = await showDatePicker(
    context: context,
    initialDate: local,
    firstDate: DateTime(local.year - 10),
    lastDate: DateTime(local.year + 10),
  );
  if (date == null || !context.mounted) return null;
  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(local),
  );
  if (time == null) return null;
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}

/// Asks where to move a task in [status] under [workflow], and for a
/// comment when the move needs one.
Future<({String to, String? comment})?> pickMove(
  BuildContext context, {
  required String status,
  required Workflow workflow,
}) => showTixSheet<({String to, String? comment})>(
  context,
  builder: (context) => _MoveSheet(status: status, workflow: workflow),
);

class _MoveSheet extends StatefulWidget {
  const _MoveSheet({required this.status, required this.workflow});

  final String status;
  final Workflow workflow;

  @override
  State<_MoveSheet> createState() => _MoveSheetState();
}

class _MoveSheetState extends State<_MoveSheet> {
  WorkflowRoute? _needsComment;
  final _comment = TextEditingController();

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  StatusCategory _category(WorkflowState s) => statusCategoryOf(s);

  void _pick(WorkflowRoute r) {
    if (r.requiresComment) {
      setState(() => _needsComment = r);
      return;
    }
    Navigator.of(context).pop((to: r.to.id, comment: null));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final routes = widget.workflow.routesFrom(widget.status);
    final asking = _needsComment;
    if (asking != null) {
      return TixSheetBody(
        title: l10n.taskDetailMoveTo(_label(asking.to)),
        actions: [
          TixButton.quiet(
            label: l10n.back,
            onPressed: () => setState(() => _needsComment = null),
          ),
          TixButton.primary(
            key: const Key('move.confirm'),
            label: l10n.taskDetailMove,
            onPressed: () {
              if (_comment.text.trim().isEmpty) return;
              Navigator.of(context)
                  .pop((to: asking.to.id, comment: _comment.text.trim()));
            },
          ),
        ],
        child: TixTextField(
          fieldKey: const Key('move.comment'),
          controller: _comment,
          label: l10n.taskDetailMoveComment,
          help: l10n.taskDetailMoveCommentHelp,
          autofocus: true,
          maxLines: 4,
        ),
      );
    }
    final current = widget.workflow.state(widget.status);
    return TixSheetBody(
      title: l10n.taskDetailMoveTitle,
      actions: [_cancel(context)],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                l10n.taskDetailMoveFrom,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: TixSpace.s2),
              StatusPill(
                label: current == null ? widget.status : _label(current),
                category: current == null ? null : _category(current),
              ),
            ],
          ),
          const SizedBox(height: TixSpace.s2),
          if (routes.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: TixSpace.s4),
              child: Text(l10n.taskDetailNoMoves),
            ),
          for (final r in routes)
            _ChoiceTile(
              key: Key('move.${r.to.id}'),
              onTap: () => _pick(r),
              child: Wrap(
                spacing: TixSpace.s2,
                runSpacing: TixSpace.s1,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  StatusPill(label: _label(r.to), category: _category(r.to)),
                  if (r.via.isNotEmpty)
                    Text(
                      l10n.taskDetailMoveVia(r.via.map(_label).join(', ')),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  if (r.requiresComment)
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 14,
                      color: context.tix.muted,
                      semanticLabel: l10n.taskDetailMoveNeedsComment,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

String _label(WorkflowState s) => s.name;

/// The category of a workflow state, from what the workflow says or, when
/// it says nothing, from the state's name and whether it ends the work.
StatusCategory statusCategoryOf(WorkflowState? s, [String status = '']) {
  if (s == null) return StatusCategory.guess(status);
  return switch (s.category) {
    StateCategory.todo => StatusCategory.todo,
    StateCategory.inProgress => StatusCategory.inProgress,
    StateCategory.blocked => StatusCategory.blocked,
    StateCategory.waiting => StatusCategory.waiting,
    StateCategory.done => StatusCategory.done,
    StateCategory.cancelled => StatusCategory.cancelled,
    null =>
      (s.terminal ?? false) &&
              StatusCategory.guess(s.id) != StatusCategory.cancelled
          ? StatusCategory.done
          : StatusCategory.guess(s.id),
  };
}

/// Asks until when to snooze, from the presets or a picked time.
Future<DateTime?> pickSnooze(BuildContext context, DateTime now) async {
  final l10n = context.l10n;
  final locale = Localizations.localeOf(context).toLanguageTag();
  String when(DateTime t) => DateFormat.MMMEd(locale).add_Hm().format(t);
  final choice = await showActionSheet<Object>(
    context,
    title: l10n.taskDetailSnoozeTitle,
    actions: [
      for (final p in SnoozePreset.values)
        TixSheetAction(
          key: Key('snooze.${p.name}'),
          value: p,
          label:
              '${switch (p) {
                SnoozePreset.laterToday => l10n.taskDetailSnoozeLater,
                SnoozePreset.tomorrow => l10n.taskDetailSnoozeTomorrow,
                SnoozePreset.nextWeek => l10n.taskDetailSnoozeNextWeek,
              }} · ${when(p.from(now))}',
          icon: switch (p) {
            SnoozePreset.laterToday => Icons.schedule,
            SnoozePreset.tomorrow => Icons.wb_twilight,
            SnoozePreset.nextWeek => Icons.next_week_outlined,
          },
        ),
      TixSheetAction(
        key: const Key('snooze.pick'),
        value: 'pick',
        label: l10n.taskDetailPickDateTime,
        icon: Icons.edit_calendar_outlined,
      ),
    ],
  );
  if (!context.mounted || choice == null) return null;
  if (choice is SnoozePreset) return choice.from(now);
  return await pickDateTime(context, SnoozePreset.tomorrow.from(now));
}

/// Asks where to copy [task] and what travels with it.
Future<CopyTaskInput?> askCopy(BuildContext context, Task task) =>
    showTixSheet<CopyTaskInput>(
      context,
      builder: (context) => _CopySheet(task: task),
    );

class _CopySheet extends ConsumerStatefulWidget {
  const _CopySheet({required this.task});

  final Task task;

  @override
  ConsumerState<_CopySheet> createState() => _CopySheetState();
}

class _CopySheetState extends ConsumerState<_CopySheet> {
  late final _title = TextEditingController(text: widget.task.title);
  late String _project = projectKeyOf(widget.task.ref).toLowerCase();
  var _subtasks = false;
  var _comments = false;
  var _deps = false;
  var _keepStatus = false;
  var _link = true;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final projects = ref.watch(copyTargetsProvider);
    return TixSheetBody(
      title: l10n.taskDetailCopyTitle(widget.task.ref),
      actions: [
        _cancel(context),
        TixButton.primary(
          key: const Key('copy.confirm'),
          label: l10n.taskDetailCopyAction,
          icon: Icons.copy_all_outlined,
          onPressed: () => Navigator.of(context).pop(
            CopyTaskInput(
              projectRef: _project,
              title: _title.text.trim() == widget.task.title
                  ? null
                  : _title.text.trim(),
              withSubtasks: _subtasks,
              withComments: _comments,
              withDependencies: _deps,
              keepStatus: _keepStatus,
              link: _link,
            ),
          ),
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.taskDetailCopyProject,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: TixSpace.s1),
          switch (projects) {
            AsyncData(:final value) => DropdownButtonFormField<String>(
              key: const Key('copy.project'),
              initialValue: value.any((p) => p.key.toLowerCase() == _project)
                  ? _project
                  : null,
              isExpanded: true,
              items: [
                for (final p in value)
                  DropdownMenuItem(
                    value: p.key.toLowerCase(),
                    child: Text(
                      p.name.isEmpty ? p.key : '${p.name} (${p.key})',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (v) => setState(() => _project = v ?? _project),
            ),
            AsyncError(:final error) => ErrorState(
              error: error,
              compact: true,
              onRetry: () => ref.invalidate(copyTargetsProvider),
            ),
            _ => const SkeletonBox(height: TixSize.control),
          },
          const SizedBox(height: TixSpace.s3),
          TixTextField(
            fieldKey: const Key('copy.title'),
            controller: _title,
            label: l10n.taskDetailCopyNewTitle,
          ),
          TixSwitchRow(
            key: const Key('copy.subtasks'),
            title: l10n.taskDetailCopySubtasks,
            value: _subtasks,
            onChanged: (v) => setState(() => _subtasks = v),
          ),
          TixSwitchRow(
            key: const Key('copy.comments'),
            title: l10n.taskDetailCopyComments,
            value: _comments,
            onChanged: (v) => setState(() => _comments = v),
          ),
          TixSwitchRow(
            key: const Key('copy.deps'),
            title: l10n.taskDetailCopyDependencies,
            value: _deps,
            onChanged: (v) => setState(() => _deps = v),
          ),
          TixSwitchRow(
            key: const Key('copy.status'),
            title: l10n.taskDetailCopyKeepStatus,
            value: _keepStatus,
            onChanged: (v) => setState(() => _keepStatus = v),
          ),
          TixSwitchRow(
            key: const Key('copy.link'),
            title: l10n.taskDetailCopyLink,
            value: _link,
            onChanged: (v) => setState(() => _link = v),
          ),
        ],
      ),
    );
  }
}

/// Asks for a tag to add, offering the tenant's tags that [task] lacks.
Future<String?> pickTag(BuildContext context, Task task) =>
    showTixSheet<String>(context, builder: (context) => _TagSheet(task: task));

class _TagSheet extends ConsumerStatefulWidget {
  const _TagSheet({required this.task});

  final Task task;

  @override
  ConsumerState<_TagSheet> createState() => _TagSheetState();
}

class _TagSheetState extends ConsumerState<_TagSheet> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add([String? name]) {
    final tag = (name ?? _controller.text).trim().replaceFirst('#', '');
    if (tag.isEmpty) return;
    Navigator.of(context).pop(tag);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final q = _controller.text.trim().toLowerCase().replaceFirst('#', '');
    final have = widget.task.tags.map((t) => t.toLowerCase()).toSet();
    final known = ref.watch(tagDirectoryProvider).value ?? const [];
    final offered = [
      for (final t in known)
        if (!have.contains(t.name.toLowerCase()) &&
            t.name.toLowerCase().contains(q))
          t.name,
    ];
    return TixSheetBody(
      title: l10n.taskDetailAddTag,
      actions: [
        _cancel(context),
        TixButton.primary(
          key: const Key('tag.add'),
          label: l10n.taskDetailAdd,
          icon: Icons.add,
          onPressed: q.isEmpty ? null : _add,
        ),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TixTextField(
            fieldKey: const Key('tag.field'),
            controller: _controller,
            label: l10n.fieldTags,
            hint: l10n.taskDetailTagHint,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _add(),
          ),
          const SizedBox(height: TixSpace.s2),
          Wrap(
            spacing: TixSpace.s2,
            runSpacing: TixSpace.s2,
            children: [
              for (final name in offered.take(24))
                TagChip(
                  name,
                  key: Key('tag.offer.$name'),
                  onTap: () => _add(name),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Asks for a new value of the custom field [def], starting from
/// [current]; `Choice(null)` clears it.
Future<Choice<Object?>?> editField(
  BuildContext context,
  WidgetRef ref,
  FieldDef def,
  Object? current,
) async {
  final l10n = context.l10n;
  switch (def.typeName) {
    case 'bool':
      return Choice(!(current == true));
    case 'enum':
      final picked = await showActionSheet<String>(
        context,
        title: def.name,
        actions: [
          for (final o in def.enumOptions)
            TixSheetAction(
              key: Key('field.option.$o'),
              value: o,
              label: o,
              icon: o == current ? Icons.check : null,
            ),
          if (current != null)
            TixSheetAction(
              key: const Key('field.clear'),
              value: '\u0000',
              label: l10n.taskDetailClear,
              icon: Icons.backspace_outlined,
              destructive: true,
            ),
        ],
      );
      if (picked == null) return null;
      return Choice(picked == '\u0000' ? null : picked);
    case 'actor':
      final picked = await pickActor(
        context,
        current: current is String ? current : '',
        title: def.name,
      );
      if (picked == null) return null;
      return Choice(picked.value.isEmpty ? null : picked.value);
    case 'date':
    case 'datetime':
      final now = ref.read(clockProvider)();
      final start = current is String ? DateTime.tryParse(current) ?? now : now;
      final DateTime? picked;
      if (def.typeName == 'date') {
        picked = await showDatePicker(
          context: context,
          initialDate: start,
          firstDate: DateTime(start.year - 50),
          lastDate: DateTime(start.year + 50),
        );
      } else {
        picked = await pickDateTime(context, start);
      }
      if (picked == null) return null;
      return Choice(
        def.typeName == 'date'
            ? DateFormat('yyyy-MM-dd').format(picked)
            : picked.toUtc().toIso8601String(),
      );
  }
  if (!context.mounted) return null;
  final text = await askText(
    context,
    title: def.name,
    label: def.name,
    initial: current == null
        ? ''
        : def.typeName == 'json'
        ? const JsonEncoder.withIndent('  ').convert(current)
        : '$current',
    multiline: def.typeName == 'text' || def.typeName == 'json',
    help: def.typeName == 'json' ? l10n.taskDetailJsonHelp : null,
  );
  if (text == null) return null;
  if (text.trim().isEmpty) return const Choice(null);
  return Choice(switch (def.typeName) {
    'int' => int.tryParse(text.trim()) ?? text.trim(),
    'float' => double.tryParse(text.trim()) ?? text.trim(),
    'json' => _jsonOrText(text),
    _ => text,
  });
}

Object? _jsonOrText(String text) {
  try {
    return jsonDecode(text);
  } on FormatException {
    return text;
  }
}

/// How a custom field's value reads.
String fieldText(BuildContext context, FieldDef def, Object? value) {
  if (value == null) return '';
  final l10n = context.l10n;
  final locale = Localizations.localeOf(context).toLanguageTag();
  switch (def.typeName) {
    case 'bool':
      return value == true ? l10n.taskDetailYes : l10n.taskDetailNo;
    case 'date':
      final d = DateTime.tryParse('$value');
      return d == null ? '$value' : DateFormat.yMMMd(locale).format(d);
    case 'datetime':
      final d = DateTime.tryParse('$value');
      return d == null
          ? '$value'
          : DateFormat.yMMMd(locale).add_Hm().format(d.toLocal());
    case 'json':
      return jsonEncode(value);
  }
  return '$value';
}

TixButton _cancel(BuildContext context) => TixButton.quiet(
  key: const Key('sheet.cancel'),
  label: context.l10n.cancel,
  onPressed: () => Navigator.of(context).pop(),
);

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.child,
    required this.onTap,
    this.selected = false,
    super.key,
  });

  final Widget child;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    return InkWell(
      borderRadius: BorderRadius.circular(TixRadius.md),
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: TixSize.target),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: TixSpace.s2,
            vertical: TixSpace.s2,
          ),
          child: Row(
            children: [
              Expanded(child: child),
              if (selected)
                Icon(
                  Icons.check,
                  color: t.accent,
                  semanticLabel: context.l10n.taskDetailCurrent,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
