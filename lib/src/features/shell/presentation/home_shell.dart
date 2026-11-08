// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/quick/quick_add.dart';
import 'package:tix_mobile/src/core/router/router.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/theme/layout.dart';
import 'package:tix_mobile/src/features/shell/presentation/context_switcher.dart';

/// The frame around the signed-in screens: the context switcher above a
/// bottom navigation bar on phones, atop a navigation rail on anything wider.
class HomeShell extends StatelessWidget {
  /// Frames the branch navigators of [shell].
  const HomeShell({required this.shell, super.key});

  /// The shell route's navigation state.
  final StatefulNavigationShell shell;

  void _select(int index) =>
      shell.goBranch(index, initialLocation: index == shell.currentIndex);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TixShortcuts(
      child: CommandScope(
        commands: [
          TixCommand(
            id: 'go.projects',
            label: l10n.goProjects,
            group: l10n.commandsNavigate,
            icon: Icons.folder_outlined,
            run: () => _select(0),
          ),
          TixCommand(
            id: 'go.tasks',
            label: l10n.goTasks,
            group: l10n.commandsNavigate,
            icon: Icons.checklist,
            run: () => _select(1),
          ),
          TixCommand(
            id: 'go.myWork',
            label: l10n.goMyWork,
            group: l10n.commandsNavigate,
            icon: Icons.person_outline,
            run: () => _select(2),
          ),
          TixCommand(
            id: 'go.settings',
            label: l10n.goSettings,
            group: l10n.commandsNavigate,
            icon: Icons.settings_outlined,
            run: () => _select(3),
          ),
          TixCommand(
            id: 'go.instances',
            label: l10n.goInstances,
            group: l10n.commandsNavigate,
            icon: Icons.dns_outlined,
            run: () => context.go(Routes.instances),
          ),
          if (Routes.galleryEnabled)
            TixCommand(
              id: 'go.gallery',
              label: l10n.galleryTitle,
              group: l10n.commandsNavigate,
              icon: Icons.widgets_outlined,
              run: () => context.push(Routes.gallery),
            ),
        ],
        child: ContextCommands(child: _frame(context)),
      ),
    );
  }

  Widget _frame(BuildContext context) {
    final l10n = context.l10n;
    final width = MediaQuery.sizeOf(context).width;
    final destinations = [
      (Icons.folder_outlined, Icons.folder, l10n.projectsTitle),
      (Icons.checklist, Icons.checklist, l10n.tasksTitle),
      (Icons.person_outline, Icons.person, l10n.myWorkTitle),
      (Icons.settings_outlined, Icons.settings, l10n.settingsTitle),
    ];
    if (width < compactMaxWidth) {
      return Scaffold(
        body: shell,
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: context.tix.surface,
              child: const Row(
                children: [
                  Expanded(child: ContextSwitcherButton()),
                  Padding(
                    padding: EdgeInsets.only(right: TixSpace.s2),
                    child: QuickAddButton(),
                  ),
                ],
              ),
            ),
            const Divider(),
            NavigationBar(
              selectedIndex: shell.currentIndex,
              onDestinationSelected: _select,
              destinations: [
                for (final (icon, selected, label) in destinations)
                  NavigationDestination(
                    icon: Icon(icon),
                    selectedIcon: Icon(selected),
                    label: label,
                  ),
              ],
            ),
          ],
        ),
      );
    }
    final extended = width >= extendedRailMinWidth;
    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              extended: extended,
              leading: Column(
                children: [
                  ContextSwitcherButton(rail: true, extended: extended),
                  const SizedBox(height: TixSpace.s2),
                  QuickAddButton(extended: extended),
                ],
              ),
              labelType: extended
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              selectedIndex: shell.currentIndex,
              onDestinationSelected: _select,
              destinations: [
                for (final (icon, selected, label) in destinations)
                  NavigationRailDestination(
                    icon: Icon(icon),
                    selectedIcon: Icon(selected),
                    label: Text(label),
                  ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: shell),
        ],
      ),
    );
  }
}

/// Opens quick add from anywhere: a tinted button beside the context on a
/// phone, at the top of the rail wider.
class QuickAddButton extends ConsumerWidget {
  /// A button; [extended] gives it its label, for a rail with labels.
  const QuickAddButton({this.extended = false, super.key});

  /// Whether it shows its label.
  final bool extended;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    void open() => ref.read(quickAddDraftsProvider.notifier).open();
    if (extended) {
      return TixButton(
        key: const Key('shell.quickAdd'),
        label: l10n.quickAddTitle,
        icon: Icons.add_task,
        onPressed: open,
      );
    }
    return TixIconButton(
      key: const Key('shell.quickAdd'),
      icon: Icons.add_task,
      tooltip: l10n.quickAddTitle,
      selected: true,
      onPressed: open,
    );
  }
}

/// Registers a "Switch to" command for every saved context but the active
/// one.
class ContextCommands extends ConsumerWidget {
  /// Registers the commands around [child].
  const ContextCommands({required this.child, super.key});

  /// The screens.
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final directory = ref.watch(contextDirectoryProvider);
    final session = ref.watch(sessionControllerProvider).value;
    final entries = [
      for (final g in directory.groups)
        for (final e in g.entries)
          if (e.elsewhere.isEmpty && !isActiveEntry(e, session)) e,
    ];
    return CommandScope(
      commands: [
        for (final e in entries)
          TixCommand(
            id: 'context.${e.connection.id}.${e.tenantKey}',
            label: e.tenantName.isEmpty
                ? e.instance.name
                : '${e.instance.name} › ${e.tenantName}',
            keywords: '${e.connection.handle} ${e.tenantKey}',
            group: l10n.paletteGroupContexts,
            icon: Icons.swap_horiz,
            run: () => unawaited(activateEntry(context, ref, e)),
          ),
      ],
      child: child,
    );
  }
}
