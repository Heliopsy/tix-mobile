// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/platform/app_shortcuts.dart';
import 'package:tix_mobile/src/core/platform/share_intake.dart';
import 'package:tix_mobile/src/core/quick/quick_add.dart';
import 'package:tix_mobile/src/core/router/routes.dart';
import 'package:tix_mobile/src/data/models/project.dart';
import 'package:tix_mobile/src/data/models/task.dart';
import 'package:tix_mobile/src/data/models/template.dart';
import 'package:tix_mobile/src/features/quick/application/quick.dart';
import 'package:tix_mobile/src/features/quick/presentation/quick_add_sheet.dart';

/// The launcher shortcut types.
abstract final class AppShortcutTypes {
  /// Opens quick add.
  static const quickAdd = 'quick_add';

  /// Opens the inbox.
  static const inbox = 'inbox';

  /// Opens my work.
  static const myWork = 'my_work';
}

/// A query shaped like a task reference: `web-12`.
final taskRefPattern = RegExp(
  r'^\s*([a-z][a-z0-9_]*(?:-[a-z0-9_]+)*-\d+)\s*$',
  caseSensitive: false,
);

/// [key] then a primary modifier: Cmd on Apple platforms, Ctrl elsewhere.
SingleActivator primaryKey(LogicalKeyboardKey key, {bool shift = false}) {
  final apple =
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.iOS;
  return SingleActivator(key, control: !apple, meta: apple, shift: shift);
}

/// Mounted around the signed-in screens by the router: opens quick add for
/// every draft (the shell's button, Ctrl+N, shares, launcher shortcuts),
/// registers the global commands and palette searches, and remembers the
/// tasks opened for the palette.
class QuickActionsHost extends ConsumerStatefulWidget {
  /// Hosts quick actions around [child].
  const QuickActionsHost({required this.child, super.key});

  /// The signed-in screens.
  final Widget child;

  @override
  ConsumerState<QuickActionsHost> createState() => _QuickActionsHostState();
}

class _QuickActionsHostState extends ConsumerState<QuickActionsHost> {
  StreamSubscription<SharedText>? _shares;
  GoRouter? _router;
  bool _sheetOpen = false;

  @override
  void initState() {
    super.initState();
    final intake = ref.read(shareIntakeProvider);
    _shares = intake.shares.listen(
      (share) => ref
          .read(quickAddDraftsProvider.notifier)
          .open(text: sharedLine(share)),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _router = GoRouter.maybeOf(context));
      _router?.routerDelegate.addListener(_routed);
      _routed();
      unawaited(intake.start());
      unawaited(_installShortcuts());
      unawaited(_drain());
    });
  }

  @override
  void dispose() {
    unawaited(_shares?.cancel());
    _router?.routerDelegate.removeListener(_routed);
    super.dispose();
  }

  String get _path =>
      _router?.routerDelegate.currentConfiguration.uri.path ?? '';

  bool _routes(String path) =>
      _router?.configuration.findMatch(Uri.parse(path)).isNotEmpty ?? false;

  String? get _projectOnShow {
    final segments = Uri.parse(_path).pathSegments;
    return segments.length >= 2 && segments.first == 'projects'
        ? segments[1]
        : null;
  }

  void _routed() {
    final segments = Uri.parse(_path).pathSegments;
    if (segments.length == 4 &&
        segments[0] == 'projects' &&
        segments[2] == 'tasks') {
      unawaited(
        ref.read(recentTasksProvider.notifier).visit(segments[3], segments[1]),
      );
    }
  }

  Future<void> _installShortcuts() async {
    final l10n = context.l10n;
    await ref.read(appShortcutsProvider).install([
      (type: AppShortcutTypes.quickAdd, label: l10n.quickAddTitle),
      (type: AppShortcutTypes.inbox, label: l10n.appShortcutInbox),
      (type: AppShortcutTypes.myWork, label: l10n.appShortcutMyWork),
    ], _shortcut);
  }

  void _shortcut(String type) {
    if (!mounted) return;
    switch (type) {
      case AppShortcutTypes.quickAdd:
        ref.read(quickAddDraftsProvider.notifier).open();
      case AppShortcutTypes.inbox:
        _goIfRouted(Routes.inbox);
      case AppShortcutTypes.myWork:
        _goIfRouted(Routes.myWork);
    }
  }

  void _goIfRouted(String path) =>
      _router?.go(_routes(path) ? path : Routes.projects);

  Future<void> _drain() async {
    if (_sheetOpen || !mounted) return;
    final draft = ref.read(quickAddDraftsProvider.notifier).take();
    if (draft == null) return;
    _sheetOpen = true;
    final task = await showGlobalQuickAdd(
      context,
      draft: draft,
      project: _projectOnShow,
      onManageTemplates: () => _router?.go(Routes.templates),
    );
    _sheetOpen = false;
    if (!mounted) return;
    if (task != null) _created(task);
    unawaited(_drain());
  }

  void _created(Task task) {
    showTixToast(
      context,
      context.l10n.taskCreated(task.ref),
      actionLabel: context.l10n.openButton,
      onAction: () =>
          _router?.go(Routes.task(projectOfRef(task.ref), task.ref)),
    );
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;
    final text = data?.text?.trim() ?? '';
    if (text.isEmpty) {
      showTixToast(context, context.l10n.quickAddClipboardEmpty);
      return;
    }
    ref.read(quickAddDraftsProvider.notifier).open(text: text);
  }

  Future<void> _use(TaskTemplate template) async {
    final l10n = context.l10n;
    try {
      final task = await ref
          .read(quickAdderProvider.notifier)
          .use(template, project: template.tenantWide ? _projectOnShow : null);
      if (mounted) _created(task);
    } on Object catch (e) {
      if (mounted) {
        showTixToast(context, errorMessage(l10n, e), tone: TixTone.danger);
      }
    }
  }

  List<TixCommand> _projects(String query) {
    final l10n = context.l10n;
    final projects = ref.read(quickProjectsProvider).value ?? const <Project>[];
    return [
      for (final p in projects)
        TixCommand(
          id: 'project.${p.key}',
          label: p.name.isEmpty ? p.key : p.name,
          keywords: p.key,
          group: l10n.paletteGroupProjects,
          icon: Icons.folder_outlined,
          run: () => _router?.go(Routes.project(p.key)),
        ),
    ];
  }

  List<TixCommand> _recentTasks(String query) {
    final l10n = context.l10n;
    return [
      for (final t in ref.read(recentTasksProvider))
        TixCommand(
          id: 'recent.${t.ref}',
          label: t.title.isEmpty ? t.ref : t.title,
          keywords: t.ref,
          group: l10n.paletteGroupRecent,
          icon: Icons.history,
          run: () => _router?.go(Routes.task(t.projectKey, t.ref)),
        ),
    ];
  }

  List<TixCommand> _taskByRef(String query) {
    final match = taskRefPattern.firstMatch(query);
    if (match == null) return const [];
    final taskRef = match.group(1)!.toLowerCase();
    return [
      TixCommand(
        id: 'open.$taskRef',
        label: context.l10n.paletteOpenTask(taskRef),
        keywords: taskRef,
        group: context.l10n.commandsTasks,
        icon: Icons.open_in_new,
        run: () => _router?.go(Routes.task(projectOfRef(taskRef), taskRef)),
      ),
    ];
  }

  List<TixCommand> _templates(String query) {
    final l10n = context.l10n;
    final templates =
        ref.read(quickTemplatesProvider).value ?? const <TaskTemplate>[];
    return [
      for (final t in templates)
        TixCommand(
          id: 'template.use.${t.id}',
          label: l10n.paletteUseTemplate(t.name),
          keywords: t.shape.title,
          group: l10n.paletteGroupTemplates,
          icon: Icons.bolt,
          run: () => unawaited(_use(t)),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    ref
      ..listen(quickAddDraftsProvider, (_, next) {
        if (next != null) unawaited(_drain());
      })
      ..watch(quickProjectsProvider)
      ..watch(quickTemplatesProvider)
      ..watch(recentTasksProvider)
      ..watch(quickAdderProvider);
    final drafts = ref.read(quickAddDraftsProvider.notifier);
    return CommandScope(
      commands: [
        TixCommand(
          id: 'quick.add',
          label: l10n.quickAddTitle,
          group: l10n.commandsTasks,
          icon: Icons.add_task,
          shortcut: primaryKey(LogicalKeyboardKey.keyN),
          run: drafts.open,
        ),
        TixCommand(
          id: 'quick.paste',
          label: l10n.quickAddPaste,
          group: l10n.commandsTasks,
          icon: Icons.content_paste,
          shortcut: primaryKey(LogicalKeyboardKey.keyV, shift: true),
          run: () => unawaited(_paste()),
        ),
        TixCommand(
          id: 'go.templates',
          label: l10n.paletteGoTemplates,
          group: l10n.commandsNavigate,
          icon: Icons.bolt,
          run: () => _router?.go(Routes.templates),
        ),
        if (_routes(Routes.inbox))
          TixCommand(
            id: 'go.inbox',
            label: l10n.paletteGoInbox,
            group: l10n.commandsNavigate,
            icon: Icons.inbox_outlined,
            run: () => _router?.go(Routes.inbox),
          ),
        if (_routes(Routes.myWork))
          TixCommand(
            id: 'go.mine',
            label: l10n.paletteGoMyWork,
            group: l10n.commandsNavigate,
            icon: Icons.person_outline,
            run: () => _router?.go(Routes.myWork),
          ),
      ],
      sources: [_taskByRef, _recentTasks, _projects, _templates],
      child: widget.child,
    );
  }
}
