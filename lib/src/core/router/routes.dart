// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/foundation.dart';

/// App locations.
abstract final class Routes {
  /// The component gallery, routed only in debug and profile builds or
  /// with `--dart-define=TIX_GALLERY=true`.
  static const gallery = '/gallery';

  /// Whether [gallery] is routed in this build.
  static const bool galleryEnabled =
      kDebugMode || kProfileMode || bool.fromEnvironment('TIX_GALLERY');

  /// Shown while the saved session loads.
  static const splash = '/';

  /// Add the first instance.
  static const connect = '/connect';

  /// Add one more instance while signed in to another.
  static const addServer = '/connect?add=1';

  /// Every project.
  static const projects = '/projects';

  /// Every task, as a list, a board or lanes.
  static const tasks = '/tasks';

  /// The task screen opened on the saved filter [nameOrId].
  static String tasksFiltered(String nameOrId) =>
      Uri(path: tasks, queryParameters: {'filter': nameOrId}).toString();

  /// Task templates.
  static const templates = '/templates';

  /// The reader's open assigned work by deadline.
  static const myWork = '/mine';

  /// The caller's inbox.
  static const inbox = '/inbox';

  /// Notifications on this device, inbox kinds and personal channels.
  static const notificationSettings = '/settings/notifications';

  /// The personal notification channel [id].
  static String channel(String id) =>
      '$notificationSettings/channels/${Uri.encodeComponent(id)}';

  /// Every management area the credential can use.
  static const manage = '/manage';

  /// The tenant's workflows.
  static const workflows = '/manage/workflows';

  /// The installation's status report.
  static const manageStatus = '/manage/status';

  /// Bundles out of and into the tenant.
  static const manageBundles = '/manage/bundles';

  /// A snapshot imported into the tenant.
  static const manageSnapshot = '/manage/import';

  /// The projects whose custom fields can be managed.
  static const fieldProjects = '/manage/fields';

  /// Everything a person can set, on this device and on the server.
  static const settings = '/settings';

  /// The saved instances and their connections.
  static const instances = '/settings/instances';

  /// The reader's saved filters, kept with their account.
  static const savedFilters = '/settings/filters';

  /// What the app is, its versions, links and the bug report.
  static const about = '/settings/about';

  /// The tenant's webhook endpoints and delivery log.
  static const webhooks = '/manage/webhooks';

  /// The tenant's external sync sources and runs.
  static const sync = '/manage/sync';

  /// How long the tenant keeps its logs.
  static const retention = '/manage/retention';

  /// The tenant's housekeeping rules.
  static const housekeeping = '/manage/housekeeping';

  /// The tenant's trash.
  static const trash = '/manage/trash';

  /// The tenant's audit log.
  static const audit = '/manage/audit';

  /// What stays available offline, its storage and sync.
  static const offline = '/settings/offline';

  /// The query parameters that open the connect screen beside a session.
  static const connectParams = {
    'add',
    'instance',
    'connection',
    'url',
    'invite',
  };

  /// Add a connection to the saved instance [id].
  static String addConnection(String id) =>
      Uri(path: connect, queryParameters: {'instance': id}).toString();

  /// Sign in again for the connection [id], keeping it.
  static String reconnect(String id) =>
      Uri(path: connect, queryParameters: {'connection': id}).toString();

  /// Add the remote instance at [url], with a sign-in for [email].
  static String addInstanceAt(String url, {String email = ''}) => Uri(
    path: connect,
    queryParameters: {'url': url, if (email.isNotEmpty) 'email': email},
  ).toString();

  /// The caller's profile, tenants and account history.
  static const account = '/settings/account';

  /// The caller's calendar feed.
  static const calendar = '/settings/calendar';

  /// The caller's own API tokens.
  static const myTokens = '/settings/tokens';

  /// The tenant's users, roles and invites.
  static const users = '/manage/users';

  /// The account [id] of the tenant.
  static String user(String id) => '$users/${Uri.encodeComponent(id)}';

  /// Every API token of the tenant.
  static const tokens = '/manage/tokens';

  /// Exports and imports.
  static const transfer = '/manage/transfer';

  /// The export screen opened on [project], filtered by [query].
  static String exportTasks(String project, {String query = ''}) => Uri(
    path: transfer,
    queryParameters: {'project': project, if (query.isNotEmpty) 'q': query},
  ).toString();

  /// Accept the invite [link], adding its server when it is new.
  static String acceptInvite(String link) =>
      Uri(path: connect, queryParameters: {'invite': link}).toString();

  /// The tasks of the project [key].
  static String project(String key) => '/projects/${Uri.encodeComponent(key)}';

  /// The settings of the project [key].
  static String projectSettings(String key) => '${project(key)}/settings';

  /// The custom fields of the project [key].
  static String projectFields(String key) => '${project(key)}/fields';

  /// The workflow [key], in its editor.
  static String workflow(String key) =>
      '$workflows/${Uri.encodeComponent(key)}';

  /// The task [ref] in the project [key].
  static String task(String key, String ref) =>
      '${project(key)}/tasks/${Uri.encodeComponent(ref)}';

  // Wave 3: tenant and server administration, and the person's security.

  /// The signed-in person's second factor and SSH keys.
  static const security = '/settings/security';

  /// The active tenant's settings.
  static const manageTenant = '/manage/tenant';

  /// The hostnames of the active tenant.
  static const manageDomains = '/manage/domains';

  /// The server's version and the tenant's live connections.
  static const manageServer = '/manage/server';

  /// Every tenant, for a global admin.
  static const manageTenants = '/manage/tenants';

  /// The global admins.
  static const manageGlobalAdmins = '/manage/global-admins';

  /// The tenant [key], for a global admin.
  static String manageTenantDetail(String key) =>
      '$manageTenants/${Uri.encodeComponent(key)}';

  /// The settings of tenant [key].
  static String manageTenantSettings(String key) =>
      '${manageTenantDetail(key)}/settings';

  /// The users of tenant [key].
  static String manageTenantUsers(String key) =>
      '${manageTenantDetail(key)}/users';

  /// The log of the account [email].
  static String accountLog(String email) =>
      '/manage/accounts/${Uri.encodeComponent(email)}/log';
}

/// The screens the app can open on.
enum StartScreen {
  /// Every project, the default.
  projects(Routes.projects),

  /// Every task.
  tasks(Routes.tasks),

  /// The reader's assigned work.
  myWork(Routes.myWork),

  /// The inbox.
  inbox(Routes.inbox);

  StartScreen(this.route);

  /// Where it is.
  final String route;

  /// The screen named [name], or [projects] for none or an unknown name.
  static StartScreen named(String? name) =>
      values.firstWhere((s) => s.name == name, orElse: () => projects);
}
