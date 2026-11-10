// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/offline/outbox.dart';
import 'package:tix_mobile/src/core/quick/quick_add.dart';
import 'package:tix_mobile/src/core/router/router.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/theme/layout.dart';
import 'package:tix_mobile/src/core/theme/panes.dart';
import 'package:tix_mobile/src/features/shell/presentation/context_switcher.dart';
import 'package:tix_mobile/src/features/shell/presentation/watch_shortcut.dart';

/// One top-level destination: the shell branch it opens, in branch order.
@immutable
class ShellDestination {
  /// A destination drawn with [icon], [selectedIcon] and [label].
  const ShellDestination({
    required this.id,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  /// A stable id, for keys and commands.
  final String id;

  /// The icon when not selected.
  final IconData icon;

  /// The icon when selected.
  final IconData selectedIcon;

  /// Its name.
  final String label;
}

/// The most destinations a phone's bottom bar shows; past that the last
/// slot is More, which lists the rest.
const maxBarDestinations = 5;

/// The frame around the signed-in screens: the context switcher above a
/// bottom navigation bar on phones, atop a navigation rail on anything wider.
class HomeShell extends StatelessWidget {
  /// Frames the branch navigators of [shell].
  const HomeShell({required this.shell, this.inboxIcon, super.key});

  /// The shell route's navigation state.
  final StatefulNavigationShell shell;

  /// Draws the Inbox destination's icon, such as with its unread badge.
  final Widget Function(Widget icon)? inboxIcon;

  /// Every destination, in the shell's branch order.
  static List<ShellDestination> destinations(AppLocalizations l10n) => [
    ShellDestination(
      id: 'projects',
      icon: Icons.folder_outlined,
      selectedIcon: Icons.folder,
      label: l10n.projectsTitle,
    ),
    ShellDestination(
      id: 'tasks',
      icon: Icons.checklist,
      selectedIcon: Icons.checklist,
      label: l10n.tasksTitle,
    ),
    ShellDestination(
      id: 'myWork',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: l10n.myWorkTitle,
    ),
    ShellDestination(
      id: 'inbox',
      icon: Icons.inbox_outlined,
      selectedIcon: Icons.inbox,
      label: l10n.inboxTitle,
    ),
    ShellDestination(
      id: 'manage',
      icon: Icons.admin_panel_settings_outlined,
      selectedIcon: Icons.admin_panel_settings,
      label: l10n.manageTitle,
    ),
    ShellDestination(
      id: 'settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: l10n.settingsTitle,
    ),
  ];

  Widget _decorate(ShellDestination d, Widget icon) {
    final decorate = inboxIcon;
    return d.id == 'inbox' && decorate != null ? decorate(icon) : icon;
  }

  void _select(int index) =>
      shell.goBranch(index, initialLocation: index == shell.currentIndex);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final all = destinations(l10n);
    int at(String id) => all.indexWhere((d) => d.id == id);
    return TixShortcuts(
      child: CommandScope(
        commands: [
          TixCommand(
            id: 'go.projects',
            action: KeyActions.navProjects,
            label: l10n.goProjects,
            group: l10n.commandsNavigate,
            icon: Icons.folder_outlined,
            run: () => _select(at('projects')),
          ),
          TixCommand(
            id: 'go.tasks',
            action: KeyActions.navTasks,
            label: l10n.goTasks,
            group: l10n.commandsNavigate,
            icon: Icons.checklist,
            run: () => _select(at('tasks')),
          ),
          TixCommand(
            id: 'go.myWork',
            action: KeyActions.navMyWork,
            label: l10n.goMyWork,
            group: l10n.commandsNavigate,
            icon: Icons.person_outline,
            run: () => _select(at('myWork')),
          ),
          TixCommand(
            id: 'go.inbox',
            action: KeyActions.navInbox,
            label: l10n.goInbox,
            group: l10n.commandsNavigate,
            icon: Icons.inbox_outlined,
            run: () => _select(at('inbox')),
          ),
          TixCommand(
            id: 'go.manage',
            action: KeyActions.navManage,
            label: l10n.goManage,
            group: l10n.commandsNavigate,
            icon: Icons.admin_panel_settings_outlined,
            run: () => _select(at('manage')),
          ),
          TixCommand(
            id: 'go.settings',
            action: KeyActions.navSettings,
            label: l10n.goSettings,
            group: l10n.commandsNavigate,
            icon: Icons.settings_outlined,
            run: () => _select(at('settings')),
          ),
          TixCommand(
            id: 'go.watch',
            action: KeyActions.navWatch,
            label: l10n.goWatch,
            group: l10n.commandsNavigate,
            icon: Icons.stream,
            run: () => context.go(Routes.watch),
          ),
          TixCommand(
            id: 'go.instances',
            label: l10n.goInstances,
            group: l10n.commandsNavigate,
            icon: Icons.dns_outlined,
            run: () => context.go(Routes.instances),
          ),
          TixCommand(
            id: 'go.about',
            label: l10n.goAbout,
            group: l10n.commandsNavigate,
            icon: Icons.info_outline,
            run: () => context.go(Routes.about),
          ),
          TixCommand(
            id: 'nav.back',
            action: KeyActions.navBack,
            label: l10n.keysBack,
            group: l10n.commandsNavigate,
            icon: Icons.arrow_back,
            inPalette: false,
            run: () =>
                unawaited(GoRouter.of(context).routerDelegate.popRoute()),
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
        child: ContextCommands(child: _frame(context, all)),
      ),
    );
  }

  Widget _frame(BuildContext context, List<ShellDestination> all) {
    if (MediaQuery.sizeOf(context).width < compactMaxWidth) {
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
                  WatchShortcutButton(),
                  SyncBadgeButton(),
                  Padding(
                    padding: EdgeInsets.only(right: TixSpace.s2),
                    child: QuickAddButton(),
                  ),
                ],
              ),
            ),
            const Divider(),
            ShellBottomBar(
              destinations: all,
              currentIndex: shell.currentIndex,
              onSelect: _select,
              decorate: _decorate,
              onAbout: () => context.go(Routes.about),
            ),
          ],
        ),
      );
    }
    return WideShellFrame(
      rail: (context, {required extended, required width}) => NavigationRail(
        extended: extended,
        minExtendedWidth: extended ? width : null,
        leading: Column(
          children: [
            if (extended)
              Row(
                children: [
                  Flexible(
                    child: ContextSwitcherButton(
                      rail: true,
                      extended: extended,
                    ),
                  ),
                  const SidebarToggle(),
                ],
              )
            else ...[
              const SidebarToggle(),
              ContextSwitcherButton(rail: true, extended: extended),
            ],
            const SyncBadgeButton(),
            const WatchShortcutButton(),
            const SizedBox(height: TixSpace.s2),
            QuickAddButton(extended: extended),
          ],
        ),
        trailing: Padding(
          padding: const EdgeInsets.only(top: TixSpace.s2),
          child: ShellAboutButton(extended: extended),
        ),
        labelType: extended
            ? NavigationRailLabelType.none
            : NavigationRailLabelType.all,
        selectedIndex: shell.currentIndex,
        onDestinationSelected: _select,
        destinations: [
          for (final d in all)
            NavigationRailDestination(
              icon: _decorate(d, Icon(d.icon)),
              selectedIcon: _decorate(d, Icon(d.selectedIcon)),
              label: Text(d.label),
            ),
        ],
      ),
      child: shell,
    );
  }
}

/// Draws [rail] beside [child] on anything wider than a phone, with a
/// handle on its edge that resizes and collapses it, as tix web's sidebar.
/// The width and the collapsed state are kept on the device.
class WideShellFrame extends ConsumerWidget {
  /// Frames [child] with the rail [rail] draws.
  const WideShellFrame({required this.rail, required this.child, super.key});

  /// Draws the rail, labelled beside its icons when `extended`, at `width`
  /// when it is.
  final Widget Function(
    BuildContext context, {
    required bool extended,
    required double width,
  })
  rail;

  /// The screens.
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final window = MediaQuery.sizeOf(context).width;
    final sizes = ref.watch(panesProvider);
    final panes = ref.read(panesProvider.notifier);
    final collapsed = sizes.collapsedIn(window);
    final width = sizes.sidebarIn(window);
    return CommandScope(
      commands: [
        TixCommand(
          id: 'shell.sidebar',
          label: collapsed ? l10n.sidebarExpand : l10n.sidebarCollapse,
          group: l10n.commandsNavigate,
          icon: collapsed
              ? Icons.keyboard_double_arrow_right
              : Icons.keyboard_double_arrow_left,
          run: () => unawaited(panes.collapseSidebar(collapsed: !collapsed)),
        ),
      ],
      child: Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: collapsed
                  ? rail(context, extended: false, width: width)
                  : SizedBox(
                      key: const Key('shell.sidebar'),
                      width: width,
                      child: rail(context, extended: true, width: width),
                    ),
            ),
            TixPaneResizer(
              key: const Key('shell.sidebar.resize'),
              label: l10n.sidebarResize,
              width: collapsed ? railWidth : width,
              min: sidebarMinWidth,
              max: sidebarMaxFor(window),
              collapsed: collapsed,
              collapseAt: sidebarCollapseAt,
              onResize: (w, {required done}) =>
                  unawaited(panes.resizeSidebar(w, save: done)),
              onReset: () => unawaited(panes.resizeSidebar(null)),
              onCollapse: () =>
                  unawaited(panes.collapseSidebar(collapsed: true)),
              onExpand: () =>
                  unawaited(panes.collapseSidebar(collapsed: false)),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

/// Collapses the rail to its icons and expands it again, at its top as
/// tix web has it beside its name.
class SidebarToggle extends ConsumerWidget {
  /// Creates the button.
  const SidebarToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final collapsed = ref
        .watch(panesProvider)
        .collapsedIn(MediaQuery.sizeOf(context).width);
    return Semantics(
      expanded: !collapsed,
      child: TixIconButton(
        key: const Key('shell.sidebar.toggle'),
        icon: collapsed
            ? Icons.keyboard_double_arrow_right
            : Icons.keyboard_double_arrow_left,
        tooltip: collapsed ? l10n.sidebarExpand : l10n.sidebarCollapse,
        onPressed: () => unawaited(
          ref
              .read(panesProvider.notifier)
              .collapseSidebar(collapsed: !collapsed),
        ),
      ),
    );
  }
}

/// Opens About from the foot of the rail, where a phone has it under More.
class ShellAboutButton extends StatelessWidget {
  /// A button; [extended] gives it its label, for a rail with labels.
  const ShellAboutButton({this.extended = false, super.key});

  /// Whether it shows its label.
  final bool extended;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    void open() => context.go(Routes.about);
    if (extended) {
      return TixButton.quiet(
        key: const Key('shell.about'),
        label: l10n.aboutTitle,
        icon: Icons.info_outline,
        onPressed: open,
      );
    }
    return TixIconButton(
      key: const Key('shell.about'),
      icon: Icons.info_outline,
      tooltip: l10n.aboutTitle,
      onPressed: open,
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

/// Says how many offline changes wait, or need a decision, and opens the
/// Conflicts screen. Drawn only while something waits; it also keeps the
/// outbox replay running for the active context.
class SyncBadgeButton extends ConsumerWidget {
  /// Creates the button.
  const SyncBadgeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(outboxSyncProvider);
    final l10n = context.l10n;
    final snap = ref.watch(syncStateProvider).value;
    if (snap == null || (snap.entries.isEmpty && !_open(snap))) {
      return const SizedBox.shrink();
    }
    final attention =
        snap.conflicts.where((r) => r.resolution == null).length +
        snap.entries
            .where(
              (e) =>
                  e.state == OutboxState.failed ||
                  e.state == OutboxState.needsCheck,
            )
            .length;
    final count = attention > 0 ? attention : snap.entries.length;
    return Badge(
      key: const Key('shell.sync'),
      label: Text('$count'),
      backgroundColor: attention > 0 ? context.tix.warn : context.tix.muted,
      offset: const Offset(-TixSpace.s1, TixSpace.s1),
      child: TixIconButton(
        icon: attention > 0 ? Icons.call_split : Icons.cloud_off_outlined,
        tooltip: attention > 0
            ? l10n.syncBadge(attention)
            : l10n.syncBannerWaiting(count),
        onPressed: () => context.go(Routes.conflicts),
      ),
    );
  }

  static bool _open(SyncSnapshot s) =>
      s.conflicts.any((r) => r.resolution == null);
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

/// A phone's bottom bar: every destination when they fit in
/// [maxBarDestinations], else the first four and More, which lists the
/// rest in a sheet and shows as selected while one of them is open. More
/// wears the decoration of a destination it hides, so an unread badge
/// stays in sight. With [onAbout], More is always there and ends with
/// About.
class ShellBottomBar extends StatelessWidget {
  /// A bar over [destinations], [currentIndex] selected.
  const ShellBottomBar({
    required this.destinations,
    required this.currentIndex,
    required this.onSelect,
    this.decorate,
    this.onAbout,
    super.key,
  });

  /// Every destination, in branch order.
  final List<ShellDestination> destinations;

  /// The open destination's index.
  final int currentIndex;

  /// Opens the destination at an index.
  final ValueChanged<int> onSelect;

  /// Draws a destination's icon, such as with a badge; null draws it plain.
  final Widget Function(ShellDestination d, Widget icon)? decorate;

  /// Opens About, listed last under More; null leaves it out.
  final VoidCallback? onAbout;

  static const _about = -1;

  Widget _icon(ShellDestination d, IconData data) =>
      decorate?.call(d, Icon(data)) ?? Icon(data);

  Future<void> _more(BuildContext context, int first) async {
    final l10n = context.l10n;
    final picked = await showActionSheet<int>(
      context,
      title: l10n.navMore,
      actions: [
        for (var i = first; i < destinations.length; i++)
          TixSheetAction(
            key: Key('nav.more.${destinations[i].id}'),
            value: i,
            label: destinations[i].label,
            icon: i == currentIndex
                ? destinations[i].selectedIcon
                : destinations[i].icon,
          ),
        if (onAbout != null)
          TixSheetAction(
            key: const Key('nav.more.about'),
            value: _about,
            label: l10n.aboutTitle,
            icon: Icons.info_outline,
          ),
      ],
    );
    if (picked == _about) {
      onAbout?.call();
    } else if (picked != null) {
      onSelect(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final overflow =
        destinations.length > maxBarDestinations || onAbout != null;
    final shown = overflow && destinations.length >= maxBarDestinations
        ? destinations.sublist(0, maxBarDestinations - 1)
        : destinations;
    Widget more = const Icon(Icons.more_horiz);
    if (overflow && decorate != null) {
      for (final d in destinations.sublist(shown.length)) {
        more = decorate!(d, more);
      }
    }
    return NavigationBar(
      selectedIndex: currentIndex < shown.length ? currentIndex : shown.length,
      onDestinationSelected: (i) =>
          i < shown.length ? onSelect(i) : _more(context, shown.length),
      destinations: [
        for (final d in shown)
          NavigationDestination(
            key: Key('nav.${d.id}'),
            icon: _icon(d, d.icon),
            selectedIcon: _icon(d, d.selectedIcon),
            label: d.label,
          ),
        if (overflow)
          NavigationDestination(
            key: const Key('nav.more'),
            icon: more,
            label: context.l10n.navMore,
          ),
      ],
    );
  }
}
