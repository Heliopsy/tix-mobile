// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/theme/layout.dart';

/// The frame around the signed-in screens: a bottom navigation bar on
/// phones, a navigation rail on anything wider.
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
    final width = MediaQuery.sizeOf(context).width;
    final destinations = [
      (Icons.folder_outlined, Icons.folder, l10n.projectsTitle),
      (Icons.settings_outlined, Icons.settings, l10n.settingsTitle),
    ];
    if (width < compactMaxWidth) {
      return Scaffold(
        body: shell,
        bottomNavigationBar: NavigationBar(
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
      );
    }
    final extended = width >= extendedRailMinWidth;
    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              extended: extended,
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
