// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/router/router.dart';
import 'package:tix_mobile/src/core/session/local.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/widgets/tix_mark.dart';
import 'package:tix_mobile/src/features/settings/application/settings.dart';

/// Language names as their own readers write them, as tix's web app does.
const languageNames = {
  'en': 'English',
  'bg': 'Български',
  'fr': 'Français',
  'de': 'Deutsch',
};

/// Theme, language and the saved instances.
class SettingsScreen extends ConsumerWidget {
  /// Creates the screen.
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = ref.watch(themeSettingProvider);
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
                child: TixChoices<ThemeChoice>(
                  key: const Key('settings.theme'),
                  choices: [
                    TixChoice(
                      ThemeChoice.system,
                      l10n.themeSystem,
                      icon: Icons.brightness_auto,
                    ),
                    TixChoice(
                      ThemeChoice.light,
                      l10n.themeLight,
                      icon: Icons.light_mode,
                    ),
                    TixChoice(
                      ThemeChoice.dark,
                      l10n.themeDark,
                      icon: Icons.dark_mode,
                    ),
                    TixChoice(
                      ThemeChoice.oled,
                      l10n.themeOled,
                      icon: Icons.contrast,
                    ),
                  ],
                  selected: theme,
                  onSelected: (c) =>
                      ref.read(themeSettingProvider.notifier).set(c),
                ),
              ),
              if (theme == ThemeChoice.system)
                TixSwitchRow(
                  key: const Key('settings.systemBlack'),
                  title: l10n.themeSystemBlack,
                  subtitle: l10n.themeSystemBlackHelp,
                  value: ref.watch(systemBlackSettingProvider),
                  onChanged: (on) =>
                      ref.read(systemBlackSettingProvider.notifier).set(on: on),
                ),
              _Labelled(
                label: l10n.languageLabel,
                child: TixChoices<String>(
                  key: const Key('settings.language'),
                  choices: [
                    TixChoice('', l10n.languageSystem),
                    for (final MapEntry(:key, :value) in languageNames.entries)
                      TixChoice(key, value),
                  ],
                  selected: locale?.languageCode ?? '',
                  onSelected: (c) => ref
                      .read(localeSettingProvider.notifier)
                      .set(c.isEmpty ? null : Locale(c)),
                ),
              ),
            ],
          ),
          TixSection(
            title: l10n.notifSettingsTitle,
            children: [
              ListTile(
                key: const Key('settings.notifications'),
                leading: const Icon(Icons.notifications_outlined),
                title: Text(l10n.notifSettingsTitle),
                subtitle: Text(l10n.notifSettingsSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go(Routes.notificationSettings),
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
          if (ref.watch(localInstancesEnabledProvider))
            const LocalIdleSection(),
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
              ListTile(
                key: const Key('settings.about'),
                leading: const TixMark(size: TixSpace.s5),
                title: Text(l10n.aboutTitle),
                subtitle: Text(l10n.aboutTagline),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go(Routes.about),
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

/// How long a local engine may sit idle before it stops.
class LocalIdleSection extends ConsumerWidget {
  /// Creates the section.
  const LocalIdleSection({super.key});

  /// The choices offered, in minutes; 0 is never.
  static const choices = [5, 10, 30, 0];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final minutes = ref.watch(localIdleTimeoutProvider)?.inMinutes ?? 0;
    return TixSection(
      title: l10n.localInstanceIdleTitle,
      info: l10n.localInstanceIdleHelp,
      children: [
        _Labelled(
          label: l10n.localInstanceIdleLabel,
          child: SegmentedButton<int>(
            key: const Key('settings.localIdle'),
            segments: [
              for (final m in {...choices, minutes})
                ButtonSegment(
                  value: m,
                  label: Text(
                    m == 0
                        ? l10n.localInstanceIdleNever
                        : l10n.localInstanceIdleMinutes(m),
                  ),
                ),
            ],
            showSelectedIcon: false,
            selected: {minutes},
            onSelectionChanged: (s) => ref
                .read(localIdleTimeoutProvider.notifier)
                .set(s.first == 0 ? null : Duration(minutes: s.first)),
          ),
        ),
      ],
    );
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
        child,
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
    final theme = ref.read(themeSettingProvider.notifier);
    return CommandScope(
      commands: [
        for (final (mode, label, icon) in [
          (
            ThemeChoice.light,
            l10n.paletteThemeLight,
            Icons.light_mode_outlined,
          ),
          (ThemeChoice.dark, l10n.paletteThemeDark, Icons.dark_mode_outlined),
          (ThemeChoice.oled, l10n.paletteThemeOled, Icons.contrast),
          (
            ThemeChoice.system,
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
