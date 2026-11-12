// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/markdown/checklist.dart';
import 'package:tix_mobile/src/data/models/inbox.dart';
import 'package:tix_mobile/src/data/models/project.dart';
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
          const HeldMark(holder: 'atlas'),
          const ClaimExpiredMark(
            ago: Duration(hours: 3),
            holder: 'atlas',
            claims: 4,
          ),
          const WaitMark(['infra-12']),
          const WaitMark(['infra-12', 'infra-15']),
          const RepeatMark('every week'),
          const ChecklistMark(done: 3, total: 5),
          const ChecklistMark(done: 5, total: 5),
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
        TixPageHeader(
          key: const Key('gallery.tasks.header'),
          title: 'Infra',
          subtitle: l10n.boardCount(galleryTasks.length, ''),
          subtitleNote: l10n.tasksHeldByAgent(2),
          actions: [ScreenHelpButton(title: 'Infra', onPressed: () {})],
        ),
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
  final _server = TextEditingController(text: 'https://tix.example.com');
  bool _mine = true;
  bool _on = true;

  @override
  void dispose() {
    _line.dispose();
    _name.dispose();
    _hex.dispose();
    _server.dispose();
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
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: TixMeasure.field + TixSize.target,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TixTextField(
                  label: 'Server address',
                  controller: _server,
                ),
              ),
              const HelpButton(
                title: 'Server address',
                body:
                    'The address you open tix with in a browser, such as '
                    'https://tix.example.com.\n\nAsk whoever runs tix for '
                    'you.',
              ),
            ],
          ),
        ),
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
      Wrap(
        spacing: TixSpace.s1,
        children: [
          ReactionChip(
            emoji: '👍',
            count: 2,
            mine: true,
            semanticLabel: '👍 2',
            onTap: () {},
          ),
          ReactionChip(
            emoji: '🚀',
            count: 1,
            mine: false,
            semanticLabel: '🚀 1',
            onTap: () {},
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

/// Pick-one settings drawn as wrapping chips.
class GalleryChoices extends StatefulWidget {
  /// Creates the samples.
  const GalleryChoices({super.key});

  @override
  State<GalleryChoices> createState() => _GalleryChoicesState();
}

class _GalleryChoicesState extends State<GalleryChoices> {
  String _theme = 'oled';
  String _language = 'de';

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TixChoices<String>(
        choices: const [
          TixChoice('system', 'System', icon: Icons.brightness_auto),
          TixChoice('light', 'Light', icon: Icons.light_mode),
          TixChoice('dark', 'Dark', icon: Icons.dark_mode),
          TixChoice('oled', 'OLED black', icon: Icons.contrast),
        ],
        selected: _theme,
        onSelected: (v) => setState(() => _theme = v),
      ),
      const SizedBox(height: TixSpace.s3),
      TixChoices<String>(
        choices: const [
          TixChoice('', 'System'),
          TixChoice('en', 'English'),
          TixChoice('bg', 'Български'),
          TixChoice('fr', 'Français'),
          TixChoice('de', 'Deutsch'),
        ],
        selected: _language,
        onSelected: (v) => setState(() => _language = v),
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
        const Padding(
          padding: EdgeInsets.only(bottom: TixSpace.s3),
          child: OneTimeSecret(
            heading: 'Copy this signing secret now',
            note:
                'It is shown once and cannot be retrieved again. If you '
                'lose it, save the endpoint again with a new secret.',
            values: ['whsec_3f9c0a7d1b2e4f6a8c0d2e4f6a8b0c1d'],
          ),
        ),
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

/// Buttons that open each overlay: confirm, action sheet, project picker,
/// sheet, toast, palette and shortcut help.
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
        label: 'Project picker',
        onPressed: () => showProjectPicker(
          context,
          title: 'Switch project',
          keyPrefix: 'gallery.project',
          current: 'INFRA',
          projects: [
            const Project(
              key: 'INFRA',
              name: 'Infrastructure',
              color: 'teal',
              iconName: 'server',
            ),
            const Project(key: 'WEB', name: 'Web', color: '#7a3ef0', icon: 'W'),
            const Project(
              key: 'MOB',
              name: 'Mobile',
              color: 'amber',
              icon: '📱',
            ),
            Project(key: 'OLD', name: 'Legacy', archivedAt: DateTime(2026)),
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
      KeyBindingKeys(
        Keymap.of(KeymapPreset.vim).bindingsFor(KeyActions.taskDelete),
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

/// Inbox items of every kind, read and unread, as the inbox draws them.
final galleryInbox = [
  InboxItem(
    id: 'g1',
    kind: InboxKind.mention,
    actorHandle: 'raj',
    taskRef: 'infra-11',
    taskTitle: 'Shed load instead of falling over',
    excerpt: '@ana can you take the second half of this?',
    createdAt: galleryNow.subtract(const Duration(minutes: 12)),
  ),
  InboxItem(
    id: 'g2',
    kind: InboxKind.status,
    actorHandle: 'lee',
    taskRef: 'web-4',
    taskTitle: 'Full text search across titles, bodies and comments',
    fromStatus: 'todo',
    toStatus: 'doing',
    createdAt: galleryNow.subtract(const Duration(hours: 3)),
    readAt: galleryNow,
  ),
  InboxItem(
    id: 'g3',
    kind: InboxKind.assigned,
    actorHandle: 'kim',
    taskRef: 'ops-2',
    taskTitle: 'Move DNS to the new registrar',
    // Days back, not yesterday: yesterday shows a local clock time, which
    // would make the goldens depend on the host's time zone.
    createdAt: galleryNow.subtract(const Duration(days: 3)),
  ),
  InboxItem(
    id: 'g4',
    kind: InboxKind.comment,
    taskRef: 'ops-9',
    taskGone: true,
    excerpt: 'Closing this, the vendor fixed it.',
    createdAt: galleryNow.subtract(const Duration(days: 6)),
    readAt: galleryNow,
  ),
];

/// Inbox rows and the live-update marks.
class GalleryInbox extends StatelessWidget {
  /// Creates the samples.
  const GalleryInbox({super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final item in galleryInbox)
        InboxRow(item: item, now: galleryNow, onTap: () {}, onMenu: () {}),
      const SizedBox(height: TixSpace.s4),
      const Align(
        alignment: AlignmentDirectional.centerStart,
        child: UpdatedMark(visible: true),
      ),
      const SizedBox(height: TixSpace.s3),
      ChangedElsewhereBanner(by: 'raj', onReload: () {}, onDismiss: () {}),
    ],
  );
}

/// What managing projects and workflows is built from: a select, the
/// project colour and icon pickers, notices and project marks.
class GalleryManage extends StatefulWidget {
  /// Creates the samples.
  const GalleryManage({super.key});

  @override
  State<GalleryManage> createState() => _GalleryManageState();
}

class _GalleryManageState extends State<GalleryManage> {
  String _type = 'enum';
  String _colour = 'violet';
  ProjectIconValue _icon = const ProjectIconValue(
    kind: ProjectIconKind.builtin,
    name: 'rocket',
  );

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TixSelectField<String>(
        label: 'Type',
        value: _type,
        help: 'The kind of value every task holds.',
        options: const [
          TixOption('string', 'Text, one line'),
          TixOption('enum', 'Choice'),
          TixOption('date', 'Date'),
        ],
        onChanged: (v) => setState(() => _type = v ?? _type),
      ),
      const SizedBox(height: TixSpace.s3),
      const TixFieldLabel('Colour'),
      TixColourPicker(
        value: _colour,
        onChanged: (c) => setState(() => _colour = c),
      ),
      const SizedBox(height: TixSpace.s3),
      const TixFieldLabel('Icon'),
      ProjectIconPicker(
        value: _icon,
        names: const ['folder', 'rocket', 'bug', 'server', 'chart', 'bolt'],
        onChanged: (v) => setState(() => _icon = v),
        onUpload: () {},
      ),
      const SizedBox(height: TixSpace.s3),
      const Wrap(
        spacing: TixSpace.s2,
        children: [
          ProjectMark(name: 'Infrastructure', colour: 'teal'),
          ProjectMark(name: 'Web', colour: 'violet', iconName: 'rocket'),
          ProjectMark(name: 'Mobile', colour: 'amber', icon: '📱'),
        ],
      ),
      const SizedBox(height: TixSpace.s3),
      const TixNotice(
        'You can see these settings but not change them: that needs '
        'project:write.',
      ),
      const SizedBox(height: TixSpace.s2),
      const TixNotice(
        'Tasks still in a removed state need somewhere to go.',
        tone: TixNoticeTone.warn,
      ),
      const SizedBox(height: TixSpace.s2),
      const TixNotice(
        'state "review" still holds 2 tasks',
        title: 'tix refused the change',
        tone: TixNoticeTone.danger,
      ),
    ],
  );
}

/// The live indicator in every state, then as a corner badge.
class GalleryLive extends StatelessWidget {
  /// Creates the indicators.
  const GalleryLive({super.key});

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: TixSpace.s3,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      for (final s in LiveState.values) LiveIndicator(state: s),
      for (final s in LiveState.values) LiveIndicator(state: s, compact: true),
    ],
  );
}

/// The marks and banners that say a change has not synced yet.
class GallerySync extends StatelessWidget {
  /// Creates the samples.
  const GallerySync({super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Wrap(
        spacing: TixSpace.s2,
        runSpacing: TixSpace.s2,
        children: [for (final kind in SyncMarkKind.values) SyncMark(kind)],
      ),
      const SizedBox(height: TixSpace.s3),
      TaskRow(
        task: galleryTasks.first.copyWith(ref: 'ops-draft1'),
        facts: const TaskFacts(
          projectKey: 'ops',
          projectColour: 'amber',
          sync: SyncMarkKind.draft,
        ),
        onTap: () {},
        now: galleryNow,
      ),
      TaskRow(
        task: galleryTasks[1],
        facts: const TaskFacts(
          projectKey: 'infra',
          projectColour: 'slate',
          sync: SyncMarkKind.unsynced,
        ),
        onTap: () {},
        now: galleryNow,
      ),
      const SizedBox(height: TixSpace.s3),
      const SyncBanner(message: '2 changes wait to sync.'),
      const SizedBox(height: TixSpace.s2),
      SyncBanner(
        message: 'Your offline changes need a decision.',
        attention: true,
        actionLabel: 'Resolve',
        onAction: () {},
      ),
    ],
  );
}

/// A pane with a resize handle beside a filler, the handle working.
class GalleryPanes extends StatefulWidget {
  /// Creates the sample.
  const GalleryPanes({super.key});

  @override
  State<GalleryPanes> createState() => _GalleryPanesState();
}

class _GalleryPanesState extends State<GalleryPanes> {
  static const _min = 120.0;
  static const _max = 280.0;
  static const _default = 180.0;
  double _width = _default;

  @override
  Widget build(BuildContext context) {
    final t = context.tix;
    return SizedBox(
      height: 96,
      child: Row(
        children: [
          SizedBox(
            width: _width,
            child: ColoredBox(
              color: t.surface,
              child: Center(child: Text('${_width.round()}')),
            ),
          ),
          TixPaneResizer(
            label: 'Resize pane',
            width: _width,
            min: _min,
            max: _max,
            onResize: (w, {required done}) => setState(() => _width = w),
            onReset: () => setState(() => _width = _default),
          ),
          const Expanded(child: SizedBox.expand()),
        ],
      ),
    );
  }
}
