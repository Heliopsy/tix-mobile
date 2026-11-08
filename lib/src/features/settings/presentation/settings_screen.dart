// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/router/router.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/widgets/tix_mark.dart';
import 'package:tix_mobile/src/features/settings/application/settings.dart';

/// Language names as their own readers write them, as tix's web app does.
const languageNames = {'en': 'English', 'bg': 'Български'};

/// Theme, language and the saved instances.
class SettingsScreen extends ConsumerWidget {
  /// Creates the screen.
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final themeMode = ref.watch(themeModeSettingProvider);
    final locale = ref.watch(localeSettingProvider);
    final session = ref.watch(sessionControllerProvider).value;
    final count = ref.watch(contextDirectoryProvider).groups.length;
    Widget padded(Widget child) => Padding(
      padding: const EdgeInsets.all(TixSpace.s3),
      child: Align(alignment: AlignmentDirectional.centerStart, child: child),
    );
    return TixPage(
      title: l10n.settingsTitle,
      body: ListView(
        padding: const EdgeInsets.only(bottom: TixSpace.s6),
        children: [
          TixSection(
            title: l10n.appearanceLabel,
            children: [
              _Labelled(
                label: l10n.themeLabel,
                child: SegmentedButton<ThemeMode>(
                  key: const Key('settings.theme'),
                  segments: [
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text(l10n.themeSystem),
                      icon: const Icon(Icons.brightness_auto),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text(l10n.themeLight),
                      icon: const Icon(Icons.light_mode),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text(l10n.themeDark),
                      icon: const Icon(Icons.dark_mode),
                    ),
                  ],
                  showSelectedIcon: false,
                  selected: {themeMode},
                  onSelectionChanged: (s) =>
                      ref.read(themeModeSettingProvider.notifier).set(s.first),
                ),
              ),
              _Labelled(
                label: l10n.languageLabel,
                child: SegmentedButton<String>(
                  key: const Key('settings.language'),
                  segments: [
                    ButtonSegment(value: '', label: Text(l10n.languageSystem)),
                    for (final MapEntry(:key, :value) in languageNames.entries)
                      ButtonSegment(value: key, label: Text(value)),
                  ],
                  showSelectedIcon: false,
                  selected: {locale?.languageCode ?? ''},
                  onSelectionChanged: (s) => ref
                      .read(localeSettingProvider.notifier)
                      .set(s.first.isEmpty ? null : Locale(s.first)),
                ),
              ),
            ],
          ),
          TixSection(
            title: l10n.instancesTitle,
            trailing: TixButton.primary(
              key: const Key('settings.add'),
              label: l10n.addInstance,
              icon: Icons.add,
              size: TixButtonSize.small,
              onPressed: () => context.go(Routes.addServer),
            ),
            children: [
              ListTile(
                key: const Key('settings.instances'),
                leading: const Icon(Icons.dns_outlined),
                title: Text(l10n.manageInstances),
                subtitle: Text(
                  [
                    l10n.instanceCount(count),
                    if (session != null) session.instance.name,
                    if (session != null &&
                        session.connection.tenantKey.isNotEmpty)
                      session.connection.tenantLabel,
                  ].join(' · '),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go(Routes.instances),
              ),
            ],
          ),
          if (session != null)
            TixSection(
              title: l10n.accountLabel,
              children: [
                padded(
                  Wrap(
                    spacing: TixSpace.s3,
                    runSpacing: TixSpace.s2,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (session.connection.handle.isNotEmpty)
                        Text(l10n.signedInAs('@${session.connection.handle}')),
                      TixButton.danger(
                        key: const Key('settings.signOut'),
                        label: l10n.signOut,
                        icon: Icons.logout,
                        onPressed: () => _confirmSignOut(
                          context,
                          ref,
                          session.instance.name,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          TixSection(
            title: l10n.aboutTitle,
            children: [
              AboutListTile(
                key: const Key('settings.about'),
                icon: const TixMark(size: 24),
                applicationName: l10n.appTitle,
                applicationIcon: const TixMark(size: 48),
              ),
              if (Routes.galleryEnabled)
                ListTile(
                  key: const Key('settings.gallery'),
                  leading: const Icon(Icons.widgets_outlined),
                  title: Text(l10n.galleryTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(Routes.gallery),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(
    BuildContext context,
    WidgetRef ref,
    String server,
  ) async {
    final l10n = context.l10n;
    final ok = await confirmDestructive(
      context,
      title: l10n.signOut,
      body: l10n.signOutBody(server),
      action: l10n.signOut,
    );
    if (ok) await ref.read(sessionControllerProvider.notifier).signOut();
  }
}

class _Labelled extends StatelessWidget {
  const _Labelled({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(TixSpace.s3),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: TixText.xs,
            fontWeight: FontWeight.w500,
            color: context.tix.muted,
          ),
        ),
        const SizedBox(height: TixSpace.s2),
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: child),
      ],
    ),
  );
}

/// The settings anyone may want from the keyboard wherever they are: the
/// theme. Mounted around the signed-in screens by the router.
class SettingsCommands extends ConsumerWidget {
  /// Registers the commands around [child].
  const SettingsCommands({required this.child, super.key});

  /// The signed-in screens.
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = ref.read(themeModeSettingProvider.notifier);
    return CommandScope(
      commands: [
        for (final (mode, label, icon) in [
          (ThemeMode.light, l10n.paletteThemeLight, Icons.light_mode_outlined),
          (ThemeMode.dark, l10n.paletteThemeDark, Icons.dark_mode_outlined),
          (
            ThemeMode.system,
            l10n.paletteThemeSystem,
            Icons.brightness_auto_outlined,
          ),
        ])
          TixCommand(
            id: 'theme.${mode.name}',
            label: label,
            group: l10n.paletteGroupTheme,
            icon: icon,
            run: () => unawaited(theme.set(mode)),
          ),
      ],
      child: child,
    );
  }
}
