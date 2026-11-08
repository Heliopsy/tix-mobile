// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/markdown/checklist.dart';
import 'package:tix_mobile/src/data/models/task.dart';

// Sample content in English only: the gallery is a debug tool for
// developers, never shown in a release build, so it is not localised.

/// The fixed time the samples are drawn at, so goldens never drift.
final galleryNow = DateTime.utc(2026, 11, 2, 9);

/// Tasks that exercise every marking a row can carry.
final galleryTasks = [
  Task(
    id: 't1',
    ref: 'ops-7',
    title: 'Shed load instead of falling over',
    status: 'doing',
    priority: 2,
    tags: const ['reliability', 'infra', 'sre', 'oncall'],
    starred: true,
    dueAt: DateTime.utc(2026, 11, 5),
  ),
  Task(
    id: 't2',
    ref: 'infra-11',
    title: 'Move DNS to the new registrar',
    status: 'blocked',
    priority: 3,
    tags: const ['dns', 'migration'],
    blocked: true,
    dueAt: DateTime.utc(2026, 10, 30),
  ),
  Task(
    id: 't3',
    ref: 'data-8',
    title:
        'Mask personal data in the analytics copies before the quarterly '
        'export goes out to the partner',
    status: 'todo',
    priority: 1,
    tags: const ['privacy'],
    snoozedUntil: DateTime.utc(2026, 11, 9),
  ),
  Task(
    id: 't4',
    ref: 'web-9',
    title: 'Full text search across titles, bodies and comments',
    status: 'done',
    priority: 4,
    completedAt: DateTime.utc(2026, 11, 1, 10),
  ),
  const Task(
    id: 't5',
    ref: 'docs-5',
    title: 'Explain how an agent claims work',
    status: 'waiting',
    priority: 5,
  ),
];

/// The facts for [galleryTasks], in order.
const galleryFacts = [
  TaskFacts(projectKey: 'ops', projectColour: 'amber', assigneeHandle: 'raj'),
  TaskFacts(projectKey: 'infra', projectColour: 'slate', assigneeHandle: 'raj'),
  TaskFacts(
    projectKey: 'data',
    projectColour: 'green',
    assigneeHandle: 'nadia',
  ),
  TaskFacts(projectKey: 'web', projectColour: 'blue'),
  TaskFacts(
    projectKey: 'docs',
    projectColour: '#0e7490',
    assigneeHandle: 'mint',
    statusCategory: StatusCategory.waiting,
  ),
];

/// A titled block of the gallery.
class GalleryBlock extends StatelessWidget {
  /// A block titled [title] holding [child].
  const GalleryBlock({required this.title, required this.child, super.key});

  /// The heading.
  final String title;

  /// The samples.
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      TixSpace.s4,
      TixSpace.s5,
      TixSpace.s4,
      0,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: TixSpace.s3),
        child,
      ],
    ),
  );
}

/// The colour tokens of the active theme as swatches.
class GalleryTokens extends StatelessWidget {
  /// Creates the swatches.
  const GalleryTokens({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    final theme = Theme.of(context);
    final swatches = {
      'bg': t.bg,
      'surface': t.surface,
      'ink': t.ink,
      'muted': t.muted,
      'line': t.line,
      'line-strong': t.lineStrong,
      'accent': t.accent,
      'accent-soft': t.accentSoft,
      'on-accent': t.onAccent,
      'danger': t.danger,
      'warn': t.warn,
      'ok': t.ok,
      for (final p in ProjectColour.values) 'proj-${p.name}': t.projects[p]!,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: TixSpace.s2,
          runSpacing: TixSpace.s2,
          children: [
            for (final MapEntry(:key, :value) in swatches.entries)
              SizedBox(
                width: 92,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 32,
                      decoration: BoxDecoration(
                        color: value,
                        border: Border.all(color: t.line),
                        borderRadius: BorderRadius.circular(TixRadius.sm),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(key, style: theme.textTheme.labelSmall),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: TixSpace.s4),
        for (final (name, style) in [
          ('Page heading 24', theme.textTheme.headlineSmall),
          ('Section heading 18', theme.textTheme.titleLarge),
          ('Sub-heading 15', theme.textTheme.titleMedium),
          (
            'Body 15, the size everything is read at',
            theme.textTheme.bodyMedium,
          ),
          ('Help and secondary text 13', theme.textTheme.bodySmall),
          ('Label 12', theme.textTheme.labelMedium),
        ])
          Text(name, style: style),
      ],
    );
  }
}

/// Every button intent and size.
class GalleryButtons extends StatelessWidget {
  /// Creates the buttons.
  const GalleryButtons({super.key});

  @override
  Widget build(BuildContext context) {
    void noop() {}
    return Wrap(
      spacing: TixSpace.s2,
      runSpacing: TixSpace.s2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        TixButton.primary(label: 'New task', icon: Icons.add, onPressed: noop),
        TixButton(label: 'Secondary', onPressed: noop),
        TixButton.quiet(label: 'Cancel', onPressed: noop),
        TixButton.danger(
          label: 'Delete',
          icon: Icons.delete_outline,
          onPressed: noop,
        ),
        TixButton.primary(label: 'Saving', busy: true, onPressed: noop),
        const TixButton.primary(label: 'Disabled', onPressed: null),
        TixButton(
          label: 'Small',
          size: TixButtonSize.small,
          icon: Icons.filter_list,
          onPressed: noop,
        ),
        TixIconButton(icon: Icons.more_horiz, tooltip: 'More', onPressed: noop),
        TixIconButton(
          icon: Icons.star,
          tooltip: 'Starred',
          selected: true,
          onPressed: noop,
        ),
      ],
    );
  }
}

/// Status pills, priority marks, tags, projects, people and badges.
class GalleryMarks extends StatelessWidget {
  /// Creates the marks.
  const GalleryMarks({super.key});

  @override
  Widget build(BuildContext context) {
    Widget row(List<Widget> children) => Padding(
      padding: const EdgeInsets.only(bottom: TixSpace.s3),
      child: Wrap(
        spacing: TixSpace.s2,
        runSpacing: TixSpace.s2,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: children,
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        row([
          for (final (s, c) in [
            ('todo', StatusCategory.todo),
            ('doing', StatusCategory.inProgress),
            ('blocked', StatusCategory.blocked),
            ('waiting', StatusCategory.waiting),
            ('done', StatusCategory.done),
            ('cancelled', StatusCategory.cancelled),
            ('triage', StatusCategory.unknown),
          ])
            StatusPill(label: s, category: c),
          const StatusPill(label: 'doing', framed: true),
        ]),
        row([
          for (var p = 1; p <= 5; p++) PriorityMark(priority: p),
          const PriorityMark(priority: 3, emphasizeNormal: true, framed: true),
        ]),
        row([
          const TagChip('reliability'),
          TagChip('security', onTap: () {}),
          const MoreMark(2),
          for (final c in ['amber', 'slate', 'green', 'blue', '#7a3ef0'])
            ProjectChip(projectKey: c.replaceAll('#', 'x'), colour: c),
          const ProjectChip(projectKey: 'ops', colour: 'red', icon: 'OP'),
        ]),
        row([
          const AssigneeRef('raj'),
          const AssigneeRef(''),
          const RefText('infra-14'),
          DueMark(due: DateTime.utc(2026, 10, 30), now: galleryNow),
          DueMark(due: DateTime.utc(2026, 11, 2, 18), now: galleryNow),
          DueMark(due: DateTime.utc(2026, 11, 5), now: galleryNow),
          DueMark(due: DateTime.utc(2026, 12, 24), now: galleryNow),
          SnoozeMark(until: DateTime.utc(2026, 11, 9)),
        ]),
        row([
          const TixAvatar(label: 'Nadia Petrova'),
          const TixAvatar(label: 'Atlas (build agent)', size: 28),
          const TixAvatar(label: 'raj', hued: true, size: 28),
          const TixAvatar(label: 'mint', hued: true, size: 28),
          const TixAvatar(label: 'cloud', icon: Icons.cloud_outlined),
          const TixBadge('admin'),
          const TixBadge('active', tone: TixTone.ok),
          const TixBadge('expired', tone: TixTone.warn),
          const TixBadge('failed', tone: TixTone.danger),
          const TixBadge('updated', tone: TixTone.accent),
          const TixCounter(7),
          const TixCounter(128),
          const Kbd('Ctrl K'),
          const Kbd('?'),
        ]),
      ],
    );
  }
}

/// Task rows and board cards with every marking.
class GalleryTasks extends StatelessWidget {
  /// Creates the samples.
  const GalleryTasks({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: t.surface,
            border: Border.all(color: t.line),
            borderRadius: BorderRadius.circular(TixRadius.base),
            boxShadow: t.shadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(TixRadius.base - 1),
            child: Column(
              children: [
                for (var i = 0; i < galleryTasks.length; i++)
                  TixSwipeActions(
                    id: galleryTasks[i].id,
                    start: TixSwipeAction.complete(l10n.complete, () {}),
                    end: TixSwipeAction.snooze(l10n.snooze, () {}),
                    child: TaskRow(
                      task: galleryTasks[i],
                      facts: galleryFacts[i],
                      selected: i == 2,
                      now: galleryNow,
                      onTap: () {},
                      onToggleDone: i == 4 ? null : () {},
                      onToggleStar: () {},
                      onStatusTap: () {},
                      onPriorityTap: () {},
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: TixSpace.s4),
        Wrap(
          spacing: TixSpace.s3,
          runSpacing: TixSpace.s3,
          children: [
            for (var i = 0; i < 3; i++)
              SizedBox(
                width: 260,
                child: TaskCard(
                  task: galleryTasks[i],
                  facts: galleryFacts[i],
                  selected: i == 1,
                  now: galleryNow,
                  onTap: () {},
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Fields, the filter bar and quick add.
class GalleryForms extends StatefulWidget {
  /// Creates the samples.
  const GalleryForms({super.key});

  @override
  State<GalleryForms> createState() => _GalleryFormsState();
}

class _GalleryFormsState extends State<GalleryForms> {
  final _line = TextEditingController(text: 'Fix login !high #auth @raj');
  final _name = TextEditingController(text: 'Acme');
  final _hex = TextEditingController(text: 'teal');
  bool _mine = true;
  bool _on = true;

  @override
  void dispose() {
    _line.dispose();
    _name.dispose();
    _hex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TixTextField(
        label: 'Tenant name',
        controller: _name,
        help: 'What people see in the switcher.',
        info: 'Shown on every surface, the terminal included.',
      ),
      const SizedBox(height: TixSpace.s3),
      TixTextField(
        label: 'Accent',
        controller: _hex,
        error: 'theme "teal" is not defined; use #rrggbb or a built-in name',
      ),
      const SizedBox(height: TixSpace.s3),
      TixFilterBar(
        onQuery: (_) {},
        chips: [
          TixFilterChip(
            label: 'Mine',
            selected: _mine,
            icon: Icons.person_outline,
            onSelected: (v) => setState(() => _mine = v),
          ),
          TixFilterChip(label: 'Overdue', selected: false, onSelected: (_) {}),
          TixFilterChip(
            label: 'Starred',
            selected: false,
            count: 3,
            onSelected: (_) {},
          ),
        ],
      ),
      QuickAddField(
        controller: _line,
        help: context.l10n.quickAddHelp,
        onSubmit: () {},
        preview: const [
          QuickChip(kind: 'priority', value: 'high'),
          QuickChip(kind: 'tag', value: 'auth'),
          QuickChip(kind: 'assignee', value: '@raj', unknown: true),
        ],
      ),
      const SizedBox(height: TixSpace.s3),
      TixSwitchRow(
        title: 'Keep deleted tasks in the trash',
        subtitle: 'Off makes deleting permanent.',
        value: _on,
        onChanged: (v) => setState(() => _on = v),
      ),
    ],
  );
}

/// Empty, error and loading states, and a settings section.
class GalleryStates extends StatelessWidget {
  /// Creates the samples.
  const GalleryStates({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    Widget framed(Widget child, double height) => Container(
      height: height,
      margin: const EdgeInsets.only(bottom: TixSpace.s3),
      decoration: BoxDecoration(
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(TixRadius.lg),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        framed(
          EmptyState(
            icon: Icons.task_alt,
            title: 'No tasks in this project.',
            body: 'Add a task with one line.',
            action: TixAction(
              label: 'New task',
              icon: Icons.add,
              onPressed: () {},
            ),
          ),
          240,
        ),
        framed(
          ErrorState(error: StateError('x'), onRetry: () {}, onBack: () {}),
          180,
        ),
        framed(const SkeletonList(rows: 3), 190),
        TixSection(
          title: 'Danger zone',
          subtitle: 'Settings are always drawn, never folded away.',
          danger: true,
          children: [
            ListTile(
              title: const Text('Delete this project'),
              subtitle: const Text('Its tasks go to the trash.'),
              trailing: TixButton.danger(
                label: 'Delete',
                size: TixButtonSize.small,
                onPressed: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Buttons that open each overlay: confirm, action sheet, sheet, toast,
/// palette and shortcut help.
class GalleryOverlays extends StatelessWidget {
  /// Creates the launchers.
  const GalleryOverlays({required this.registry, super.key});

  /// The registry the palette lists.
  final CommandRegistry registry;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: TixSpace.s2,
    runSpacing: TixSpace.s2,
    children: [
      TixButton.danger(
        label: 'Confirm',
        onPressed: () => confirmDestructive(
          context,
          title: 'Delete infra-11?',
          body: 'It goes to the trash, where it can be restored for 30 days.',
          action: 'Delete',
        ),
      ),
      TixButton(
        label: 'Action sheet',
        onPressed: () => showActionSheet<int>(
          context,
          title: 'infra-11',
          actions: const [
            TixSheetAction(value: 1, label: 'Complete', icon: Icons.check),
            TixSheetAction(value: 2, label: 'Snooze', icon: Icons.snooze),
            TixSheetAction(
              value: 3,
              label: 'Delete',
              icon: Icons.delete_outline,
              destructive: true,
            ),
          ],
        ),
      ),
      TixButton(
        label: 'Sheet or dialog',
        onPressed: () => showTixSheet<void>(
          context,
          builder: (context) => TixSheetBody(
            title: 'New project',
            actions: [
              TixButton.quiet(
                label: 'Cancel',
                onPressed: () => Navigator.of(context).pop(),
              ),
              TixButton.primary(
                label: 'Create',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
            child: const TixTextField(label: 'Key', hint: 'infra'),
          ),
        ),
      ),
      TixButton(
        label: 'Toast with undo',
        onPressed: () =>
            showTixToast(context, 'Completed ops-7', onUndo: () {}),
      ),
      TixButton(
        label: 'Error toast',
        onPressed: () => showTixToast(
          context,
          'Someone changed it first.',
          tone: TixTone.danger,
        ),
      ),
      TixButton(
        label: 'Command palette',
        onPressed: () => showCommandPalette(context, registry),
      ),
      TixButton(
        label: 'Shortcut help',
        onPressed: () => showShortcutHelp(context, registry.commands),
      ),
    ],
  );
}

/// A record's properties and a Markdown description with its checklist.
class GalleryRecord extends StatefulWidget {
  /// Creates the samples.
  const GalleryRecord({super.key});

  @override
  State<GalleryRecord> createState() => _GalleryRecordState();
}

class _GalleryRecordState extends State<GalleryRecord> {
  var _body = '''
Rotate the **edge** certificates before they expire. See [the runbook](https://example.com).

- [x] Issue the new certificates
- [ ] Roll them out
  - [ ] staging
  - [ ] production

```
openssl x509 -enddate -noout
```
''';

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: TixPropertyList(
          children: [
            TixPropertyRow(
              label: 'Status',
              onTap: () {},
              child: const Align(
                alignment: AlignmentDirectional.centerStart,
                child: StatusPill(label: 'doing'),
              ),
            ),
            TixPropertyRow(
              label: 'Priority',
              onTap: () {},
              child: const Align(
                alignment: AlignmentDirectional.centerStart,
                child: PriorityMark(priority: 2, emphasizeNormal: true),
              ),
            ),
            TixPropertyRow(
              label: 'Repeats',
              info: 'Finishing it creates the next one.',
              onTap: () {},
              child: const Text('every week'),
            ),
            const TixPropertyRow(
              label: 'Project',
              child: Text('Infrastructure'),
            ),
          ],
        ),
      ),
      const SizedBox(height: TixSpace.s4),
      TixMarkdown(
        data: _body,
        onToggle: (item, {required done}) =>
            setState(() => _body = setChecklistItem(_body, item, done: done)),
      ),
    ],
  );
}
