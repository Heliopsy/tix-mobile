// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/desktop/desktop_state.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/offline/outbox.dart';
import 'package:tix_mobile/src/core/offline/unsent_warning.dart';
import 'package:tix_mobile/src/core/platform/adb_bridge.dart';
import 'package:tix_mobile/src/core/platform/desktop.dart';
import 'package:tix_mobile/src/core/platform/widget_bridge.dart';
import 'package:tix_mobile/src/core/router/router.dart';
import 'package:tix_mobile/src/core/session/local.dart';
import 'package:tix_mobile/src/core/session/people.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/time/reader_time.dart';
import 'package:tix_mobile/src/core/update/updates.dart';
import 'package:tix_mobile/src/core/widgets/tix_mark.dart';
import 'package:tix_mobile/src/core/widgets/update_panel.dart';
import 'package:tix_mobile/src/features/settings/application/settings.dart';
import 'package:tix_mobile/src/features/settings/presentation/date_settings.dart';
import 'package:tix_mobile/src/features/settings/presentation/keyboard_settings.dart';
import 'package:tix_mobile/src/features/settings/presentation/settings_catalogue.dart';

export 'package:tix_mobile/src/features/settings/presentation/settings_catalogue.dart';

/// Language names as their own readers write them, as tix's web app does.
const languageNames = {
  'en': 'English',
  'bg': 'Български',
  'fr': 'Français',
  'de': 'Deutsch',
};

/// Whether [access] administers its tenant in any way the Manage hub
/// offers.
bool administers(Access access) => [
  Scope.tenantAdmin,
  Scope.userAdmin,
  Scope.tokenAdmin,
  Scope.webhookAdmin,
  Scope.projectWrite,
  Scope.workflowWrite,
].any(access.has);

/// The settings on offer for the active session, as search and the palette
/// see them.
List<SettingsItem> currentSettings(WidgetRef ref, AppLocalizations l10n) {
  final session = ref.watch(sessionControllerProvider).value;
  final access = session == null
      ? null
      : ref.watch(currentAccessProvider).value;
  return settingsCatalogue(
    l10n,
    signedIn: session != null,
    tenantAdmin: access != null && administers(access),
    can: access?.can,
    localEngines: ref.watch(localInstancesEnabledProvider),
    widgets: ref.watch(widgetBridgeProvider).supported,
    adb: ref.watch(adbControlOfferedProvider),
    desktop: ref.watch(desktopCapsProvider).value ?? DesktopCaps.none,
    updates: ref.watch(updateModeProvider).value ?? UpdateMode.off,
    tenant: session?.connection.tenantLabel ?? '',
  );
}

/// Everything a person can set, grouped by where it is kept: this device,
/// their account on the server, or the whole tenant.
class SettingsScreen extends ConsumerStatefulWidget {
  /// Creates the screen, filtered to [initialQuery].
  const SettingsScreen({this.initialQuery = '', super.key});

  /// What the search starts with, from the palette.
  final String initialQuery;

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final _search = TextEditingController(text: widget.initialQuery);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(ref.read(readerTimeProvider.notifier).refresh());
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final session = ref.watch(sessionControllerProvider).value;
    final time = session == null
        ? null
        : ref.watch(readerTimeProvider).settings;
    final query = _search.text;
    final visible = [
      for (final item in currentSettings(ref, l10n))
        if (item.matches(query, settingsSectionTitle(l10n, item.section)) &&
            (item.id != 'dates.zone' || time != null))
          item,
    ];
    final tenant = session == null
        ? ''
        : session.connection.tenantLabel.isNotEmpty
        ? session.connection.tenantLabel
        : session.instance.name;
    return TixPage(
      title: l10n.settingsTitle,
      body: ListView(
        padding: const EdgeInsets.only(bottom: TixSpace.s6),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              TixSpace.s4,
              TixSpace.s3,
              TixSpace.s4,
              0,
            ),
            child: TixSearchField(
              controller: _search,
              fieldKey: const Key('settings.search'),
              hint: l10n.settingsSearchHint,
              onChanged: (_) => setState(() {}),
            ),
          ),
          if (visible.isEmpty)
            EmptyState(
              icon: Icons.search_off,
              title: l10n.settingsNoMatch(query.trim()),
              body: l10n.settingsNoMatchBody,
            ),
          for (final scope in SettingsScope.values)
            if (visible.any((i) => i.section.scope == scope)) ...[
              _GroupHeader(scope: scope, tenant: tenant),
              for (final section in SettingsSection.values)
                if (section.scope == scope &&
                    visible.any((i) => i.section == section))
                  _Section(
                    section: section,
                    items: [
                      for (final i in visible)
                        if (i.section == section) i,
                    ],
                  ),
            ],
        ],
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.scope, required this.tenant});

  final SettingsScope scope;
  final String tenant;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final (title, help) = switch (scope) {
      SettingsScope.device => (
        l10n.settingsGroupDevice,
        l10n.settingsGroupDeviceHelp,
      ),
      SettingsScope.account => (
        l10n.settingsGroupAccount(tenant),
        l10n.settingsGroupAccountHelp,
      ),
      SettingsScope.tenant => (
        l10n.settingsGroupTenant,
        l10n.settingsGroupTenantHelp(tenant),
      ),
    };
    return Padding(
      key: Key('settings.group.${scope.name}'),
      padding: const EdgeInsets.fromLTRB(
        TixSpace.s4,
        TixSpace.s6,
        TixSpace.s4,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(title, style: theme.textTheme.headlineSmall),
          ),
          const SizedBox(height: TixSpace.headSub),
          Text(help, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

/// The mark that says where a section's settings are kept.
class _ScopeBadge extends StatelessWidget {
  const _ScopeBadge(this.scope);

  final SettingsScope scope;

  @override
  Widget build(BuildContext context) => TixBadge(
    settingsScopeLabel(context.l10n, scope),
    tone: switch (scope) {
      SettingsScope.device => TixTone.neutral,
      SettingsScope.account => TixTone.accent,
      SettingsScope.tenant => TixTone.warn,
    },
  );
}

class _Section extends StatelessWidget {
  const _Section({required this.section, required this.items});

  final SettingsSection section;
  final List<SettingsItem> items;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return TixSection(
      key: Key('settings.section.${section.name}'),
      title: settingsSectionTitle(l10n, section),
      badge: _ScopeBadge(section.scope),
      info: switch (section) {
        SettingsSection.language => l10n.settingsLanguageHelp,
        SettingsSection.start => l10n.settingsStartHelp,
        SettingsSection.keyboard => l10n.settingsKeyboardHelp,
        SettingsSection.dates => l10n.settingsDatesHelp,
        SettingsSection.arrangement => l10n.settingsArrangementHelp,
        SettingsSection.localEngine => l10n.localInstanceIdleHelp,
        SettingsSection.widgets => l10n.settingsWidgetsHelp,
        SettingsSection.desktop => l10n.settingsDesktopHelp,
        SettingsSection.updates => l10n.settingsUpdatesHelp,
        _ => null,
      },
      children: [
        for (final item in items) _Entry(item),
        // The add button sits in the body rather than beside the heading,
        // where a long label at large text would squeeze the title out.
        if (section == SettingsSection.servers)
          Padding(
            padding: const EdgeInsets.all(TixSpace.s3),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: TixButton.primary(
                key: const Key('settings.add'),
                label: l10n.addInstance,
                icon: Icons.add,
                size: TixButtonSize.small,
                onPressed: () => context.go(Routes.addServer),
              ),
            ),
          ),
      ],
    );
  }
}

class _Entry extends StatelessWidget {
  const _Entry(this.item);

  final SettingsItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return switch (item.id) {
      'appearance.theme' => const _ThemeEntry(),
      'appearance.reduceMotion' => const _ReduceMotionEntry(),
      'appearance.haptics' => const _HapticsEntry(),
      'language.app' => const _LanguageEntry(),
      'start.screen' => const _StartEntry(),
      'keyboard.shortcuts' => const KeyboardShortcutsEntry(),
      'keyboard.preset' => const KeymapEntry(),
      'keyboard.bindings' => const KeyBindingsEntry(),
      'desktop.closeToTray' => const _CloseToTrayEntry(),
      'desktop.autostart' => const _AutostartEntry(),
      'desktop.hotkey' => const _HotkeyEntry(),
      'updates.status' => const UpdatePanel(),
      'updates.check' => const _UpdateCheckEntry(),
      'updates.auto' => const _AutoInstallEntry(),
      'deviceNotifications.open' => _LinkEntry(
        item: item,
        subtitle: l10n.settingsDeviceNotifSubtitle,
      ),
      'servers.instances' => const _InstancesEntry(),
      'localEngine.idle' => const LocalIdleEntry(),
      'widgets.lockCounts' => const _WidgetLockCountsEntry(),
      'advanced.adb' => const _AdbControlEntry(),
      'offline.open' => _LinkEntry(item: item, subtitle: l10n.offlineSubtitle),
      'about.app' => _LinkEntry(
        item: item,
        subtitle: l10n.aboutTagline,
        leading: const TixMark(size: TixSpace.s5),
      ),
      'about.gallery' => _LinkEntry(item: item, push: true),
      'about.release' => _LinkEntry(
        item: item,
        subtitle: l10n.releaseSubtitle,
        push: true,
      ),
      'profile.account' => _LinkEntry(
        item: item,
        subtitle: l10n.settingsAccountHelp,
        push: true,
      ),
      'profile.signOut' => const _ProfileEntry(),
      'security.open' => _LinkEntry(
        item: item,
        subtitle: l10n.securitySubtitle,
        push: true,
      ),
      'security.tokens' => _LinkEntry(
        item: item,
        subtitle: l10n.settingsTokensHelp,
        push: true,
      ),
      'security.connectAgent' => _LinkEntry(
        item: item,
        subtitle: l10n.connectAgentSubtitle,
        push: true,
      ),
      'calendar.open' => _LinkEntry(
        item: item,
        subtitle: l10n.settingsCalendarHelp,
        push: true,
      ),
      'tenant.settings' => _LinkEntry(
        item: item,
        subtitle: l10n.tenantSettingsSubtitle,
        push: true,
      ),
      'tenant.retention' => _LinkEntry(
        item: item,
        subtitle: l10n.retentionSubtitle,
        push: true,
      ),
      'tenant.webhooks' => _LinkEntry(
        item: item,
        subtitle: l10n.webhooksSubtitle,
        push: true,
      ),
      'tenant.sync' => _LinkEntry(
        item: item,
        subtitle: l10n.syncSubtitle,
        push: true,
      ),
      'dates.format' => const DateFormatSetting(),
      'dates.zone' => const TimeZoneSetting(),
      'inbox.open' => _LinkEntry(
        item: item,
        subtitle: l10n.settingsInboxSubtitle,
      ),
      'filters.open' => _LinkEntry(
        item: item,
        subtitle: l10n.settingsFiltersSubtitle,
      ),
      'arrangement.reset' => const _ArrangementEntry(),
      'tenant.manage' => _LinkEntry(
        item: item,
        subtitle: l10n.settingsTenantManageSubtitle,
      ),
      _ => const SizedBox.shrink(),
    };
  }
}

class _LinkEntry extends StatelessWidget {
  const _LinkEntry({
    required this.item,
    this.subtitle,
    this.leading,
    this.push = false,
  });

  final SettingsItem item;
  final String? subtitle;
  final Widget? leading;
  final bool push;

  @override
  Widget build(BuildContext context) => ListTile(
    key: Key('settings.${item.id}'),
    leading: leading ?? Icon(item.icon),
    title: Text(item.label),
    subtitle: subtitle == null ? null : Text(subtitle!),
    trailing: const Icon(Icons.chevron_right),
    onTap: () => push ? context.push(item.route!) : context.go(item.route!),
  );
}

class _ThemeEntry extends ConsumerWidget {
  const _ThemeEntry();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return _Labelled(
      label: l10n.themeLabel,
      child: TixChoices<ThemeChoice>(
        key: const Key('settings.theme'),
        choices: [
          TixChoice(
            ThemeChoice.system,
            l10n.themeSystem,
            icon: Icons.brightness_auto,
          ),
          TixChoice(ThemeChoice.light, l10n.themeLight, icon: Icons.light_mode),
          TixChoice(ThemeChoice.dark, l10n.themeDark, icon: Icons.dark_mode),
          TixChoice(ThemeChoice.oled, l10n.themeOled, icon: Icons.contrast),
          TixChoice(ThemeChoice.dim, l10n.themeDim, icon: Icons.tonality),
          TixChoice(
            ThemeChoice.systemOled,
            l10n.themeSystemOled,
            icon: Icons.brightness_4_outlined,
          ),
        ],
        selected: ref.watch(themeSettingProvider),
        onSelected: (c) => ref.read(themeSettingProvider.notifier).set(c),
      ),
    );
  }
}

class _ReduceMotionEntry extends ConsumerWidget {
  const _ReduceMotionEntry();

  @override
  Widget build(BuildContext context, WidgetRef ref) => TixSwitchRow(
    key: const Key('settings.reduceMotion'),
    title: context.l10n.settingsReduceMotion,
    subtitle: context.l10n.settingsReduceMotionHelp,
    value: ref.watch(reduceMotionSettingProvider),
    onChanged: (on) =>
        ref.read(reduceMotionSettingProvider.notifier).set(on: on),
  );
}

class _HapticsEntry extends ConsumerWidget {
  const _HapticsEntry();

  @override
  Widget build(BuildContext context, WidgetRef ref) => TixSwitchRow(
    key: const Key('settings.haptics'),
    title: context.l10n.settingsHaptics,
    subtitle: context.l10n.settingsHapticsHelp,
    value: ref.watch(hapticsSettingProvider),
    onChanged: (on) => ref.read(hapticsSettingProvider.notifier).set(on: on),
  );
}

class _LanguageEntry extends ConsumerWidget {
  const _LanguageEntry();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return _Labelled(
      label: l10n.languageLabel,
      child: TixChoices<String>(
        key: const Key('settings.language'),
        choices: [
          TixChoice('', l10n.languageSystem),
          for (final MapEntry(:key, :value) in languageNames.entries)
            TixChoice(key, value),
        ],
        selected: ref.watch(localeSettingProvider)?.languageCode ?? '',
        onSelected: (c) => ref
            .read(localeSettingProvider.notifier)
            .set(c.isEmpty ? null : Locale(c)),
      ),
    );
  }
}

class _StartEntry extends ConsumerWidget {
  const _StartEntry();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return _Labelled(
      label: l10n.settingsStartTitle,
      child: TixChoices<StartScreen>(
        key: const Key('settings.start'),
        choices: [
          TixChoice(
            StartScreen.projects,
            l10n.projectsTitle,
            icon: Icons.folder_outlined,
          ),
          TixChoice(StartScreen.tasks, l10n.tasksTitle, icon: Icons.checklist),
          TixChoice(
            StartScreen.myWork,
            l10n.myWorkTitle,
            icon: Icons.person_outline,
          ),
          TixChoice(
            StartScreen.inbox,
            l10n.inboxTitle,
            icon: Icons.inbox_outlined,
          ),
        ],
        selected: ref.watch(startScreenSettingProvider),
        onSelected: (s) => ref.read(startScreenSettingProvider.notifier).set(s),
      ),
    );
  }
}

class _CloseToTrayEntry extends ConsumerWidget {
  const _CloseToTrayEntry();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tray = ref.watch(desktopCapsProvider).value?.tray ?? false;
    return TixSwitchRow(
      key: const Key('settings.closeToTray'),
      title: l10n.settingsCloseToTray,
      subtitle: tray
          ? l10n.settingsCloseToTrayHelp
          : l10n.settingsCloseToTrayNone,
      value: ref.watch(closeToTraySettingProvider),
      onChanged: tray
          ? (on) => ref.read(closeToTraySettingProvider.notifier).set(on: on)
          : null,
    );
  }
}

class _AutostartEntry extends ConsumerWidget {
  const _AutostartEntry();

  Future<void> _set(BuildContext context, WidgetRef ref, bool on) async {
    final l10n = context.l10n;
    final ok = await ref.read(autostartSettingProvider.notifier).set(on: on);
    if (!ok && context.mounted) {
      showTixToast(context, l10n.settingsAutostartFailed, tone: TixTone.danger);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(autostartSettingProvider);
    return TixSwitchRow(
      key: const Key('settings.autostart'),
      title: context.l10n.settingsAutostart,
      subtitle: context.l10n.settingsAutostartHelp,
      value: state.value ?? false,
      onChanged: state.hasValue
          ? (on) => unawaited(_set(context, ref, on))
          : null,
    );
  }
}

class _HotkeyEntry extends ConsumerWidget {
  const _HotkeyEntry();

  Future<void> _set(BuildContext context, WidgetRef ref, bool on) async {
    final l10n = context.l10n;
    final keys = quickAddHotkeyLabel(Theme.of(context).platform);
    final ok = await ref
        .read(quickAddHotkeySettingProvider.notifier)
        .set(on: on);
    if (!ok && context.mounted) {
      showTixToast(
        context,
        l10n.settingsHotkeyTaken(keys),
        tone: TixTone.danger,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => TixSwitchRow(
    key: const Key('settings.hotkey'),
    title: context.l10n.settingsHotkey,
    subtitle: context.l10n.settingsHotkeyHelp(
      quickAddHotkeyLabel(Theme.of(context).platform),
    ),
    value: ref.watch(quickAddHotkeySettingProvider),
    onChanged: (on) => unawaited(_set(context, ref, on)),
  );
}

class _UpdateCheckEntry extends ConsumerWidget {
  const _UpdateCheckEntry();

  @override
  Widget build(BuildContext context, WidgetRef ref) => TixSwitchRow(
    key: const Key('settings.updateCheck'),
    title: context.l10n.settingsUpdateCheck,
    subtitle: context.l10n.settingsUpdateCheckHelp,
    value: ref.watch(updateCheckSettingProvider),
    onChanged: (on) =>
        ref.read(updateCheckSettingProvider.notifier).set(on: on),
  );
}

class _AutoInstallEntry extends ConsumerWidget {
  const _AutoInstallEntry();

  @override
  Widget build(BuildContext context, WidgetRef ref) => TixSwitchRow(
    key: const Key('settings.updateAuto'),
    title: context.l10n.settingsUpdateAuto,
    subtitle: context.l10n.settingsUpdateAutoHelp,
    value: ref.watch(autoInstallSettingProvider),
    onChanged: (on) =>
        ref.read(autoInstallSettingProvider.notifier).set(on: on),
  );
}

class _InstancesEntry extends ConsumerWidget {
  const _InstancesEntry();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final session = ref.watch(sessionControllerProvider).value;
    final count = ref.watch(contextDirectoryProvider).groups.length;
    return ListTile(
      key: const Key('settings.instances'),
      leading: const Icon(Icons.dns_outlined),
      title: Text(l10n.manageInstances),
      subtitle: Text(
        [
          l10n.instanceCount(count),
          if (session != null) session.instance.name,
          if (session != null && session.connection.tenantKey.isNotEmpty)
            session.connection.tenantLabel,
        ].join(' · '),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.go(Routes.instances),
    );
  }
}

/// How long a local engine may sit idle before it stops.
class LocalIdleEntry extends ConsumerWidget {
  /// Creates the control.
  const LocalIdleEntry({super.key});

  /// The choices offered, in minutes; 0 is never.
  static const choices = [5, 10, 30, 0];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final minutes = ref.watch(localIdleTimeoutProvider)?.inMinutes ?? 0;
    return _Labelled(
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
    );
  }
}

class _WidgetLockCountsEntry extends ConsumerWidget {
  const _WidgetLockCountsEntry();

  @override
  Widget build(BuildContext context, WidgetRef ref) => TixSwitchRow(
    key: const Key('settings.widgetLockCounts'),
    title: context.l10n.settingsWidgetLockCounts,
    subtitle: context.l10n.settingsWidgetLockCountsHelp,
    value: ref.watch(widgetLockCountsSettingProvider),
    onChanged: (on) =>
        ref.read(widgetLockCountsSettingProvider.notifier).set(on: on),
  );
}

class _AdbControlEntry extends ConsumerWidget {
  const _AdbControlEntry();

  @override
  Widget build(BuildContext context, WidgetRef ref) => TixSwitchRow(
    key: const Key('settings.adbControl'),
    title: context.l10n.settingsAdbControl,
    subtitle: context.l10n.settingsAdbControlHelp,
    value: ref.watch(adbControlSettingProvider),
    onChanged: (on) => ref.read(adbControlSettingProvider.notifier).set(on: on),
  );
}

class _ProfileEntry extends ConsumerWidget {
  const _ProfileEntry();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final session = ref.watch(sessionControllerProvider).value;
    if (session == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(TixSpace.s3),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Wrap(
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
              onPressed: () async {
                final unsent = await ref
                    .read(outboxSyncProvider.notifier)
                    .unsentForConnection(session.connection.id);
                if (!context.mounted) return;
                final ok = await confirmDestructive(
                  context,
                  title: l10n.signOut,
                  body: withUnsentWarning(
                    l10n,
                    l10n.signOutBody(session.instance.name),
                    unsent,
                  ),
                  action: l10n.signOut,
                );
                if (ok) {
                  await ref.read(sessionControllerProvider.notifier).signOut();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ArrangementEntry extends ConsumerWidget {
  const _ArrangementEntry();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.all(TixSpace.s3),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: TixButton.danger(
          key: const Key('settings.resetArrangement'),
          label: l10n.settingsArrangementReset,
          icon: Icons.restart_alt,
          onPressed: () async {
            final ok = await confirmDestructive(
              context,
              title: l10n.settingsArrangementResetTitle,
              body: l10n.settingsArrangementResetBody,
              action: l10n.settingsArrangementReset,
            );
            if (!ok || !context.mounted) return;
            try {
              await ref.read(arrangementSettingsProvider.notifier).reset();
              if (context.mounted) {
                showTixToast(context, l10n.settingsArrangementDone);
              }
            } on Object catch (e) {
              if (context.mounted) {
                showTixToast(
                  context,
                  errorMessage(l10n, e),
                  tone: TixTone.danger,
                );
              }
            }
          },
        ),
      ),
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
/// theme, and "Settings: …" for every setting, which opens the screen it is
/// on. Mounted around the signed-in screens by the router.
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
            ThemeChoice.system,
            l10n.paletteThemeSystem,
            Icons.brightness_auto_outlined,
          ),
          (
            ThemeChoice.light,
            l10n.paletteThemeLight,
            Icons.light_mode_outlined,
          ),
          (ThemeChoice.dark, l10n.paletteThemeDark, Icons.dark_mode_outlined),
          (ThemeChoice.oled, l10n.paletteThemeOled, Icons.contrast),
          (ThemeChoice.dim, l10n.paletteThemeDim, Icons.tonality),
          (
            ThemeChoice.systemOled,
            l10n.paletteThemeSystemOled,
            Icons.brightness_4_outlined,
          ),
        ])
          TixCommand(
            id: 'theme.${mode.name}',
            label: label,
            group: l10n.paletteGroupTheme,
            icon: icon,
            run: () => unawaited(theme.set(mode)),
          ),
        for (final item in currentSettings(ref, l10n))
          TixCommand(
            id: 'settings.${item.id}',
            label: l10n.paletteSettingsItem(item.label),
            group: l10n.settingsTitle,
            icon: item.icon,
            keywords: [
              settingsSectionTitle(l10n, item.section),
              settingsScopeLabel(l10n, item.section.scope),
              item.keywords,
            ].join(' '),
            run: () => context.go(
              item.route ??
                  Uri(
                    path: Routes.settings,
                    queryParameters: {'q': item.label},
                  ).toString(),
            ),
          ),
      ],
      child: child,
    );
  }
}
