// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/platform/desktop.dart';
import 'package:tix_mobile/src/core/router/routes.dart';
import 'package:tix_mobile/src/core/update/updates.dart';
import 'package:tix_mobile/src/data/models/scopes.dart';

/// Where a setting is kept.
enum SettingsScope {
  /// In this device's preferences; nothing else sees it.
  device,

  /// On the server with the person's account; every device and the web
  /// follow it.
  account,

  /// On the server for the whole tenant; administrators only.
  tenant,
}

/// The headed groups of the Settings screen, in the order they are drawn.
enum SettingsSection {
  /// Theme, black, motion and touch feedback.
  appearance(SettingsScope.device),

  /// The app's language.
  language(SettingsScope.device),

  /// The screen the app opens on.
  start(SettingsScope.device),

  /// The tray, start at login and the global hotkey on a desktop.
  desktop(SettingsScope.device),

  /// Whether this device notifies.
  deviceNotifications(SettingsScope.device),

  /// The saved servers and connections.
  servers(SettingsScope.device),

  /// How long a local engine may sit idle.
  localEngine(SettingsScope.device),

  /// What home screen widgets show.
  widgets(SettingsScope.device),

  /// What the active context keeps on this device for offline use.
  offline(SettingsScope.device),

  /// Keyboard shortcuts and the keymap preset.
  keyboard(SettingsScope.device),

  /// Looking for and installing new releases.
  updates(SettingsScope.device),

  /// Developer controls: commands over ADB.
  advanced(SettingsScope.device),

  /// The app itself.
  about(SettingsScope.device),

  /// Who is signed in.
  profile(SettingsScope.account),

  /// Second factor, SSH keys, sessions and the caller's API tokens.
  security(SettingsScope.account),

  /// The personal calendar feed.
  calendar(SettingsScope.account),

  /// Date format and time zone.
  dates(SettingsScope.account),

  /// Inbox kinds and personal channels.
  inbox(SettingsScope.account),

  /// Saved filters.
  filters(SettingsScope.account),

  /// Board, lane and My work arrangements.
  arrangement(SettingsScope.account),

  /// The tenant's own settings, in the Manage hub.
  tenant(SettingsScope.tenant);

  SettingsSection(this.scope);

  /// Where its settings are kept.
  final SettingsScope scope;
}

/// One setting, as search and the command palette know it.
@immutable
class SettingsItem {
  /// The setting [id] in [section], called [label].
  const SettingsItem({
    required this.id,
    required this.section,
    required this.label,
    required this.icon,
    this.keywords = '',
    this.route,
  });

  /// A stable id, `<section>.<setting>`, for keys and commands.
  final String id;

  /// The group it is drawn in.
  final SettingsSection section;

  /// Its name.
  final String label;

  /// Its icon in the palette.
  final IconData icon;

  /// More words it is found by.
  final String keywords;

  /// The screen it opens, for a setting that lives on a screen of its own.
  final String? route;

  /// Whether [query] finds it, by its name, its keywords or its group's
  /// title [sectionTitle].
  bool matches(String query, String sectionTitle) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return '$label $keywords $sectionTitle'.toLowerCase().contains(q);
  }
}

/// The title of [section].
String settingsSectionTitle(AppLocalizations l10n, SettingsSection section) =>
    switch (section) {
      SettingsSection.appearance => l10n.appearanceLabel,
      SettingsSection.language => l10n.languageLabel,
      SettingsSection.start => l10n.settingsStartTitle,
      SettingsSection.keyboard => l10n.settingsKeyboard,
      SettingsSection.desktop => l10n.settingsDesktop,
      SettingsSection.deviceNotifications => l10n.settingsDeviceNotifTitle,
      SettingsSection.servers => l10n.instancesTitle,
      SettingsSection.localEngine => l10n.localInstanceIdleTitle,
      SettingsSection.widgets => l10n.settingsWidgets,
      SettingsSection.offline => l10n.offlineTitle,
      SettingsSection.updates => l10n.settingsUpdates,
      SettingsSection.advanced => l10n.settingsAdvanced,
      SettingsSection.about => l10n.aboutTitle,
      SettingsSection.profile => l10n.settingsProfileTitle,
      SettingsSection.security => l10n.securityTitle,
      SettingsSection.calendar => l10n.calendarTitle,
      SettingsSection.dates => l10n.settingsDatesTitle,
      SettingsSection.inbox => l10n.settingsInboxTitle,
      SettingsSection.filters => l10n.settingsFiltersTitle,
      SettingsSection.arrangement => l10n.settingsArrangementTitle,
      SettingsSection.tenant => l10n.settingsGroupTenant,
    };

/// The label that says where [scope]'s settings are kept.
String settingsScopeLabel(AppLocalizations l10n, SettingsScope scope) =>
    switch (scope) {
      SettingsScope.device => l10n.settingsScopeDevice,
      SettingsScope.account => l10n.settingsScopeAccount,
      SettingsScope.tenant => l10n.settingsScopeTenant,
    };

/// Every setting the screen offers right now: account settings only with
/// a session, tenant settings only for an administrator, the black switch
/// only under the system theme, the idle timeout only where local databases
/// are offered, widgets only where the platform has them, the desktop's
/// switches only where [desktop] offers them, updates only where [updates]
/// is not off and installing automatically only where the app installs
/// itself, ADB control only on Android.
List<SettingsItem> settingsCatalogue(
  AppLocalizations l10n, {
  required bool signedIn,
  required bool tenantAdmin,
  required bool systemTheme,
  bool Function(String scope)? can,
  bool localEngines = false,
  bool widgets = false,
  bool adb = false,
  DesktopCaps desktop = DesktopCaps.none,
  UpdateMode updates = UpdateMode.off,
  String tenant = '',
}) => [
  SettingsItem(
    id: 'appearance.theme',
    section: SettingsSection.appearance,
    label: l10n.themeLabel,
    icon: Icons.brightness_auto_outlined,
    keywords: [
      l10n.themeLight,
      l10n.themeDark,
      l10n.themeOled,
      l10n.themeSystem,
    ].join(' '),
  ),
  if (systemTheme)
    SettingsItem(
      id: 'appearance.systemBlack',
      section: SettingsSection.appearance,
      label: l10n.themeSystemBlack,
      icon: Icons.contrast,
      keywords: l10n.themeOled,
    ),
  SettingsItem(
    id: 'appearance.reduceMotion',
    section: SettingsSection.appearance,
    label: l10n.settingsReduceMotion,
    icon: Icons.motion_photos_off_outlined,
  ),
  SettingsItem(
    id: 'appearance.haptics',
    section: SettingsSection.appearance,
    label: l10n.settingsHaptics,
    icon: Icons.vibration,
  ),
  SettingsItem(
    id: 'language.app',
    section: SettingsSection.language,
    label: l10n.languageLabel,
    icon: Icons.translate,
    keywords: 'English Български Français Deutsch',
  ),
  SettingsItem(
    id: 'start.screen',
    section: SettingsSection.start,
    label: l10n.settingsStartTitle,
    icon: Icons.home_outlined,
    keywords: [
      l10n.projectsTitle,
      l10n.tasksTitle,
      l10n.myWorkTitle,
      l10n.inboxTitle,
    ].join(' '),
  ),
  if (desktop.any)
    SettingsItem(
      id: 'desktop.closeToTray',
      section: SettingsSection.desktop,
      label: l10n.settingsCloseToTray,
      icon: Icons.move_to_inbox_outlined,
      keywords: '${l10n.settingsDesktop} ${l10n.trayQuit}',
    ),
  if (desktop.autostart)
    SettingsItem(
      id: 'desktop.autostart',
      section: SettingsSection.desktop,
      label: l10n.settingsAutostart,
      icon: Icons.login,
      keywords: l10n.settingsDesktop,
    ),
  if (desktop.hotkey)
    SettingsItem(
      id: 'desktop.hotkey',
      section: SettingsSection.desktop,
      label: l10n.settingsHotkey,
      icon: Icons.keyboard_outlined,
      keywords: '${l10n.settingsDesktop} ${l10n.quickAddTitle}',
    ),
  SettingsItem(
    id: 'deviceNotifications.open',
    section: SettingsSection.deviceNotifications,
    label: l10n.settingsDeviceNotifTitle,
    icon: Icons.notifications_outlined,
    keywords: l10n.notifSettingsTitle,
    route: Routes.notificationSettings,
  ),
  SettingsItem(
    id: 'servers.instances',
    section: SettingsSection.servers,
    label: l10n.manageInstances,
    icon: Icons.dns_outlined,
    keywords: l10n.addInstance,
    route: Routes.instances,
  ),
  if (localEngines)
    SettingsItem(
      id: 'localEngine.idle',
      section: SettingsSection.localEngine,
      label: l10n.localInstanceIdleLabel,
      icon: Icons.timer_outlined,
      keywords: l10n.localInstanceIdleTitle,
    ),
  if (widgets)
    SettingsItem(
      id: 'widgets.lockCounts',
      section: SettingsSection.widgets,
      label: l10n.settingsWidgetLockCounts,
      icon: Icons.widgets_outlined,
      keywords: l10n.settingsWidgets,
    ),
  if (signedIn)
    SettingsItem(
      id: 'offline.open',
      section: SettingsSection.offline,
      label: l10n.offlineTitle,
      icon: Icons.cloud_off_outlined,
      keywords: '${l10n.offlineAvailableTitle} ${l10n.offlineSyncTitle}',
      route: Routes.offline,
    ),
  SettingsItem(
    id: 'keyboard.shortcuts',
    section: SettingsSection.keyboard,
    label: l10n.shortcutsTitle,
    icon: Icons.keyboard_outlined,
    keywords: 'shortcut keymap ${l10n.settingsKeyboard} ${l10n.settingsKeymap}',
  ),
  SettingsItem(
    id: 'keyboard.preset',
    section: SettingsSection.keyboard,
    label: l10n.settingsKeymap,
    icon: Icons.keyboard_command_key,
    keywords: [
      'keymap shortcut',
      l10n.settingsKeyboard,
      l10n.keymapDefault,
      l10n.keymapVim,
      l10n.keymapEmacs,
      l10n.keymapOff,
    ].join(' '),
  ),
  SettingsItem(
    id: 'keyboard.bindings',
    section: SettingsSection.keyboard,
    label: l10n.settingsKeyBindings,
    icon: Icons.list_alt,
    keywords: 'shortcut keymap ${l10n.settingsKeyboard}',
  ),
  if (updates != UpdateMode.off) ...[
    SettingsItem(
      id: 'updates.status',
      section: SettingsSection.updates,
      label: l10n.updateCheckNow,
      icon: Icons.system_update_outlined,
      keywords: '${l10n.settingsUpdates} ${l10n.updateWhatsNew}',
    ),
    SettingsItem(
      id: 'updates.check',
      section: SettingsSection.updates,
      label: l10n.settingsUpdateCheck,
      icon: Icons.update,
      keywords: l10n.settingsUpdates,
    ),
  ],
  if (updates == UpdateMode.install)
    SettingsItem(
      id: 'updates.auto',
      section: SettingsSection.updates,
      label: l10n.settingsUpdateAuto,
      icon: Icons.install_desktop_outlined,
      keywords: l10n.settingsUpdates,
    ),
  if (adb)
    SettingsItem(
      id: 'advanced.adb',
      section: SettingsSection.advanced,
      label: l10n.settingsAdbControl,
      icon: Icons.usb,
      keywords: 'ADB adb dumpsys tix://',
    ),
  SettingsItem(
    id: 'about.app',
    section: SettingsSection.about,
    label: l10n.aboutTitle,
    icon: Icons.info_outline,
    route: Routes.about,
  ),
  if (Routes.galleryEnabled)
    SettingsItem(
      id: 'about.gallery',
      section: SettingsSection.about,
      label: l10n.galleryTitle,
      icon: Icons.widgets_outlined,
      route: Routes.gallery,
    ),
  if (signedIn) ...[
    SettingsItem(
      id: 'profile.account',
      section: SettingsSection.profile,
      label: l10n.accountTitle,
      icon: Icons.person_outline,
      route: Routes.account,
    ),
    SettingsItem(
      id: 'profile.signOut',
      section: SettingsSection.profile,
      label: l10n.signOut,
      icon: Icons.logout,
      keywords: l10n.accountLabel,
    ),
    SettingsItem(
      id: 'security.open',
      section: SettingsSection.security,
      label: l10n.securityTitle,
      icon: Icons.shield_outlined,
      keywords: 'TOTP SSH',
      route: Routes.security,
    ),
    if (can?.call(Scopes.tokenAdmin) ?? false)
      SettingsItem(
        id: 'security.tokens',
        section: SettingsSection.security,
        label: l10n.tokensMine,
        icon: Icons.key_outlined,
        route: Routes.myTokens,
      ),
    SettingsItem(
      id: 'security.connectAgent',
      section: SettingsSection.security,
      label: l10n.connectAgentTitle,
      icon: Icons.cable_outlined,
      keywords: 'CLI MCP SSH API skill agent',
      route: Routes.connectAgent,
    ),
    if (can?.call(Scopes.taskRead) ?? true)
      SettingsItem(
        id: 'calendar.open',
        section: SettingsSection.calendar,
        label: l10n.calendarTitle,
        icon: Icons.event_outlined,
        keywords: 'iCalendar webcal',
        route: Routes.calendar,
      ),
    SettingsItem(
      id: 'dates.format',
      section: SettingsSection.dates,
      label: l10n.settingsDateFormat,
      icon: Icons.calendar_today_outlined,
      keywords: 'ISO RFC 3339 US',
    ),
    SettingsItem(
      id: 'dates.zone',
      section: SettingsSection.dates,
      label: l10n.settingsTimeZone,
      icon: Icons.public,
      keywords: 'UTC',
    ),
    SettingsItem(
      id: 'inbox.open',
      section: SettingsSection.inbox,
      label: l10n.settingsInboxTitle,
      icon: Icons.inbox_outlined,
      keywords: l10n.notifSettingsTitle,
      route: Routes.notificationSettings,
    ),
    SettingsItem(
      id: 'filters.open',
      section: SettingsSection.filters,
      label: l10n.settingsFiltersTitle,
      icon: Icons.filter_list,
      route: Routes.savedFilters,
    ),
    SettingsItem(
      id: 'arrangement.reset',
      section: SettingsSection.arrangement,
      label: l10n.settingsArrangementResetTitle,
      icon: Icons.view_column_outlined,
      keywords: l10n.myWorkTitle,
    ),
  ],
  if (signedIn && (can?.call(Scopes.tenantAdmin) ?? false)) ...[
    SettingsItem(
      id: 'tenant.settings',
      section: SettingsSection.tenant,
      label: l10n.tenantSettingsTitle,
      icon: Icons.tune,
      keywords: l10n.settingsDateFormat,
      route: Routes.manageTenant,
    ),
    SettingsItem(
      id: 'tenant.retention',
      section: SettingsSection.tenant,
      label: l10n.retentionTitle,
      icon: Icons.history,
      route: Routes.retention,
    ),
  ],
  if (signedIn && (can?.call(Scopes.webhookAdmin) ?? false))
    SettingsItem(
      id: 'tenant.webhooks',
      section: SettingsSection.tenant,
      label: l10n.webhooksTitle,
      icon: Icons.webhook_outlined,
      route: Routes.webhooks,
    ),
  if (signedIn && (can?.call(Scopes.syncAdmin) ?? false))
    SettingsItem(
      id: 'tenant.sync',
      section: SettingsSection.tenant,
      label: l10n.syncTitle,
      icon: Icons.sync_alt,
      route: Routes.sync,
    ),
  if (signedIn && tenantAdmin)
    SettingsItem(
      id: 'tenant.manage',
      section: SettingsSection.tenant,
      label: l10n.settingsTenantManage(tenant),
      icon: Icons.admin_panel_settings_outlined,
      keywords: l10n.manageTitle,
      route: Routes.manage,
    ),
];
