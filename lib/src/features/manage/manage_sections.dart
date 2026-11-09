// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/router/routes.dart';
import 'package:tix_mobile/src/data/models/access.dart';

/// The groups the Manage screen lists, in order.
enum ManageGroup { projects, workflows, fields, people, access, tenant, server }

/// One management area on the Manage screen.
@immutable
class ManageEntry {
  /// An entry in [group] opening [route], shown when the credential holds
  /// [scope] (and passes [when], if given).
  const ManageEntry({
    required this.id,
    required this.group,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.route,
    this.scope,
    this.when,
  });

  /// A stable id, `<area>.<screen>`, for keys and tests.
  final String id;

  /// Where it is listed.
  final ManageGroup group;

  /// Its icon.
  final IconData icon;

  /// Its name.
  final String Function(AppLocalizations l10n) title;

  /// One line on what it manages.
  final String Function(AppLocalizations l10n) subtitle;

  /// The location it opens.
  final String route;

  /// The scope that shows it; null shows it to everyone [when] lets in.
  final Scope? scope;

  /// A further test, for entries a scope alone does not decide.
  final bool Function(Access access)? when;

  /// Whether [access] may use it.
  bool visibleTo(Access access) =>
      (scope == null || access.has(scope!)) && (when?.call(access) ?? true);
}

/// Every management area. Add an entry here for a new area; the Manage
/// screen groups and filters them, so nothing else needs to change.
final manageSections = <ManageEntry>[
  ManageEntry(
    id: 'projects.list',
    group: ManageGroup.projects,
    icon: Icons.folder_outlined,
    title: (l) => l.projectsTitle,
    subtitle: (l) => l.manageProjectsSubtitle,
    route: Routes.projects,
    scope: Scope.projectRead,
  ),
  ManageEntry(
    id: 'workflows.list',
    group: ManageGroup.workflows,
    icon: Icons.account_tree_outlined,
    title: (l) => l.workflowsTitle,
    subtitle: (l) => l.manageWorkflowsSubtitle,
    route: Routes.workflows,
    scope: Scope.workflowRead,
  ),
  ManageEntry(
    id: 'fields.projects',
    group: ManageGroup.fields,
    icon: Icons.tune,
    title: (l) => l.fieldsTitle,
    subtitle: (l) => l.manageFieldsSubtitle,
    route: Routes.fieldProjects,
    scope: Scope.projectRead,
  ),
  // The screens below are routed by the people and access feature.
  ManageEntry(
    id: 'people.users',
    group: ManageGroup.people,
    icon: Icons.group_outlined,
    title: (l) => l.manageUsersTitle,
    subtitle: (l) => l.manageUsersSubtitle,
    route: '/manage/users',
    scope: Scope.userAdmin,
  ),
  ManageEntry(
    id: 'access.tokens',
    group: ManageGroup.access,
    icon: Icons.key_outlined,
    title: (l) => l.manageTokensTitle,
    subtitle: (l) => l.manageTokensSubtitle,
    route: '/manage/tokens',
    scope: Scope.tokenAdmin,
  ),
  ManageEntry(
    id: 'tenant.transfer',
    group: ManageGroup.tenant,
    icon: Icons.import_export,
    title: (l) => l.manageTransferTitle,
    subtitle: (l) => l.manageTransferSubtitle,
    route: '/manage/transfer',
    when: (a) => a.hasValue('export') || a.hasValue('import'),
  ),
  // Tenant and server administration.
  ManageEntry(
    id: 'tenant.settings',
    group: ManageGroup.tenant,
    icon: Icons.settings_outlined,
    title: (l) => l.tenantSettingsTitle,
    subtitle: (l) => l.tenantSettingsSubtitle,
    route: Routes.manageTenant,
    scope: Scope.tenantAdmin,
  ),
  ManageEntry(
    id: 'tenant.domains',
    group: ManageGroup.tenant,
    icon: Icons.language,
    title: (l) => l.domainsTitle,
    subtitle: (l) => l.domainsSubtitle,
    route: Routes.manageDomains,
    scope: Scope.tenantAdmin,
  ),
  ManageEntry(
    id: 'tenant.server',
    group: ManageGroup.tenant,
    icon: Icons.dns_outlined,
    title: (l) => l.serverTitle,
    subtitle: (l) => l.serverSubtitle,
    route: Routes.manageServer,
    scope: Scope.tenantAdmin,
  ),
  ManageEntry(
    id: 'server.tenants',
    group: ManageGroup.server,
    icon: Icons.domain,
    title: (l) => l.tenantsTitle,
    subtitle: (l) => l.tenantsSubtitle,
    route: Routes.manageTenants,
    when: (a) => a.globalAdmin,
  ),
  ManageEntry(
    id: 'server.globalAdmins',
    group: ManageGroup.server,
    icon: Icons.admin_panel_settings_outlined,
    title: (l) => l.globalAdminsTitle,
    subtitle: (l) => l.globalAdminsSubtitle,
    route: Routes.manageGlobalAdmins,
    when: (a) => a.globalAdmin,
  ),
];
