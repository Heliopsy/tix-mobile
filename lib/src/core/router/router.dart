// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/router/routes.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/theme/layout.dart';
import 'package:tix_mobile/src/features/about/presentation/about_screen.dart';
import 'package:tix_mobile/src/features/account/presentation/account_screen.dart';
import 'package:tix_mobile/src/features/account/presentation/calendar_screen.dart';
import 'package:tix_mobile/src/features/admin/presentation/account_log_screen.dart';
import 'package:tix_mobile/src/features/admin/presentation/domains_screen.dart';
import 'package:tix_mobile/src/features/admin/presentation/global_admins_screen.dart';
import 'package:tix_mobile/src/features/admin/presentation/server_screen.dart';
import 'package:tix_mobile/src/features/admin/presentation/tenant_detail.dart';
import 'package:tix_mobile/src/features/admin/presentation/tenant_settings_screen.dart';
import 'package:tix_mobile/src/features/admin/presentation/tenant_users_screen.dart';
import 'package:tix_mobile/src/features/admin/presentation/tenants_screen.dart';
import 'package:tix_mobile/src/features/audit/presentation/audit_screen.dart';
import 'package:tix_mobile/src/features/bundles/presentation/bundles_screen.dart';
import 'package:tix_mobile/src/features/bundles/presentation/snapshot_import_screen.dart';
import 'package:tix_mobile/src/features/connect/presentation/connect_screen.dart';
import 'package:tix_mobile/src/features/gallery/presentation/gallery_screen.dart';
import 'package:tix_mobile/src/features/inbox/presentation/channel_screen.dart';
import 'package:tix_mobile/src/features/inbox/presentation/inbox_screen.dart';
import 'package:tix_mobile/src/features/inbox/presentation/inbox_shell.dart';
import 'package:tix_mobile/src/features/inbox/presentation/notification_settings_screen.dart';
import 'package:tix_mobile/src/features/instances/presentation/instances_screen.dart';
import 'package:tix_mobile/src/features/integrations/presentation/sync_screen.dart';
import 'package:tix_mobile/src/features/integrations/presentation/webhooks_screen.dart';
import 'package:tix_mobile/src/features/maintenance/presentation/housekeeping_screen.dart';
import 'package:tix_mobile/src/features/maintenance/presentation/retention_screen.dart';
import 'package:tix_mobile/src/features/maintenance/presentation/trash_screen.dart';
import 'package:tix_mobile/src/features/manage/presentation/manage_screen.dart';
import 'package:tix_mobile/src/features/people/presentation/user_screen.dart';
import 'package:tix_mobile/src/features/people/presentation/users_screen.dart';
import 'package:tix_mobile/src/features/projects/presentation/fields_screen.dart';
import 'package:tix_mobile/src/features/projects/presentation/project_settings_screen.dart';
import 'package:tix_mobile/src/features/projects/presentation/projects_screen.dart';
import 'package:tix_mobile/src/features/quick/presentation/quick_actions_host.dart';
import 'package:tix_mobile/src/features/security/presentation/security_screen.dart';
import 'package:tix_mobile/src/features/settings/presentation/settings_screen.dart';
import 'package:tix_mobile/src/features/settings/presentation/time_settings_screen.dart';
import 'package:tix_mobile/src/features/shell/presentation/home_shell.dart';
import 'package:tix_mobile/src/features/shell/presentation/splash_screen.dart';
import 'package:tix_mobile/src/features/status/presentation/status_screen.dart';
import 'package:tix_mobile/src/features/tasks/presentation/task_detail_screen.dart';
import 'package:tix_mobile/src/features/tasks/presentation/task_list_screen.dart';
import 'package:tix_mobile/src/features/tasks/presentation/task_screen.dart';
import 'package:tix_mobile/src/features/templates/presentation/templates_commands.dart';
import 'package:tix_mobile/src/features/templates/presentation/templates_screen.dart';
import 'package:tix_mobile/src/features/tokens/presentation/tokens_screen.dart';
import 'package:tix_mobile/src/features/transfer/presentation/transfer_screen.dart';
import 'package:tix_mobile/src/features/widgets/presentation/home_widgets_scope.dart';
import 'package:tix_mobile/src/features/workflows/presentation/workflow_editor_screen.dart';
import 'package:tix_mobile/src/features/workflows/presentation/workflows_screen.dart';

export 'package:tix_mobile/src/core/router/routes.dart';

part 'router.g.dart';

/// Where [uri] should lead instead, given [session], or null to stay.
String? redirectFor(AsyncValue<Session?> session, Uri uri) {
  final path = uri.path;
  if (path == Routes.gallery && Routes.galleryEnabled) return null;
  if (session.isLoading && !session.hasValue) {
    return path == Routes.splash ? null : Routes.splash;
  }
  if (session.value == null) {
    return path == Routes.connect ? null : Routes.connect;
  }
  final adding = uri.queryParameters.keys.any(Routes.connectParams.contains);
  if (path == Routes.splash || (path == Routes.connect && !adding)) {
    return Routes.projects;
  }
  return null;
}

/// The app's router, which follows the session in and out of the connect
/// screen.
@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final session = ValueNotifier<AsyncValue<Session?>>(const AsyncLoading());
  ref
    ..listen(
      sessionControllerProvider,
      (_, next) => session.value = next,
      fireImmediately: true,
    )
    ..onDispose(session.dispose);
  final router = GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: session,
    redirect: (_, state) => redirectFor(session.value, state.uri),
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(
        path: Routes.connect,
        builder: (_, state) {
          final q = state.uri.queryParameters;
          return ConnectScreen(
            key: ValueKey(state.uri.toString()),
            adding: q.keys.any(Routes.connectParams.contains),
            instanceId: q['instance'],
            connectionId: q['connection'],
            url: q['url'] ?? '',
            email: q['email'] ?? '',
            invite: q['invite'] ?? '',
          );
        },
      ),
      if (Routes.galleryEnabled)
        GoRoute(path: Routes.gallery, builder: (_, _) => const GalleryScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => HomeWidgetsScope(
          child: InboxAlertsScope(
            child: QuickActionsHost(
              child: TemplatesCommands(
                child: SettingsCommands(
                  child: HomeShell(
                    shell: shell,
                    inboxIcon: (icon) => InboxNavIcon(icon: icon),
                  ),
                ),
              ),
            ),
          ),
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.projects,
                builder: (_, _) => const ProjectsScreen(),
                routes: [
                  GoRoute(
                    path: ':key',
                    builder: (_, state) => TaskListScreen(
                      projectKey: state.pathParameters['key']!,
                    ),
                    routes: [
                      GoRoute(path: 'tasks/:ref', pageBuilder: _taskPage),
                      GoRoute(
                        path: 'settings',
                        builder: (_, state) => ProjectSettingsScreen(
                          projectKey: state.pathParameters['key']!,
                        ),
                      ),
                      GoRoute(
                        path: 'fields',
                        builder: (_, state) => ProjectFieldsScreen(
                          projectKey: state.pathParameters['key']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              GoRoute(
                path: Routes.templates,
                builder: (_, _) => const TemplatesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.tasks,
                builder: (_, state) => TasksScreen(
                  filter: state.uri.queryParameters['filter'] ?? '',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.myWork,
                builder: (_, _) => const MyWorkScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.inbox,
                builder: (_, _) => const InboxScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.manage,
                builder: (_, _) => const ManageScreen(),
                routes: [
                  GoRoute(
                    path: 'workflows',
                    builder: (_, _) => const WorkflowsScreen(),
                    routes: [
                      GoRoute(
                        path: ':key',
                        builder: (_, state) => WorkflowEditorScreen(
                          workflowKey: state.pathParameters['key']!,
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'status',
                    builder: (_, _) => const StatusScreen(),
                  ),
                  GoRoute(
                    path: 'bundles',
                    builder: (_, _) => const BundlesScreen(),
                  ),
                  GoRoute(
                    path: 'import',
                    builder: (_, _) => const SnapshotImportScreen(),
                  ),
                  GoRoute(
                    path: 'fields',
                    builder: (_, _) => const FieldProjectsScreen(),
                    routes: [
                      GoRoute(
                        path: ':key',
                        builder: (_, state) => ProjectFieldsScreen(
                          projectKey: state.pathParameters['key']!,
                        ),
                      ),
                    ],
                  ),
                  ...manageRoutes,
                  ...adminRoutes,
                  ...upkeepRoutes,
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.settings,
                builder: (_, _) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'instances',
                    builder: (_, _) => const InstancesScreen(),
                  ),
                  GoRoute(
                    path: 'notifications',
                    builder: (_, _) => const NotificationSettingsScreen(),
                    routes: [
                      GoRoute(
                        path: 'channels/:id',
                        builder: (_, state) => ChannelScreen(
                          channelId: state.pathParameters['id']!,
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'time',
                    builder: (_, _) => const TimeSettingsScreen(),
                  ),
                  GoRoute(
                    path: 'about',
                    builder: (_, _) => const AboutScreen(),
                  ),
                  ...accountRoutes,
                  GoRoute(
                    path: 'security',
                    builder: (_, _) => const SecurityScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
}

Page<void> _taskPage(BuildContext context, GoRouterState state) {
  final key = state.pathParameters['key']!;
  final ref = state.pathParameters['ref']!;
  if (context.isTwoPane) {
    return NoTransitionPage(
      key: state.pageKey,
      child: TaskListScreen(projectKey: key, selectedRef: ref),
    );
  }
  return MaterialPage(
    key: state.pageKey,
    child: TaskDetailScreen(taskRef: ref),
  );
}

/// The caller's own account, under Settings.
final accountRoutes = [
  GoRoute(path: 'account', builder: (_, _) => const AccountScreen()),
  GoRoute(path: 'calendar', builder: (_, _) => const CalendarScreen()),
  GoRoute(
    path: 'tokens',
    builder: (_, _) => const TokensScreen(personal: true),
  ),
];

/// People, tokens and transfers of the tenant, under Manage.
final manageRoutes = [
  GoRoute(
    path: 'users',
    builder: (_, _) => const UsersScreen(),
    routes: [
      GoRoute(
        path: ':id',
        builder: (_, state) => UserScreen(userId: state.pathParameters['id']!),
      ),
    ],
  ),
  GoRoute(path: 'tokens', builder: (_, _) => const TokensScreen()),
  GoRoute(
    path: 'transfer',
    builder: (_, state) => TransferScreen(
      project: state.uri.queryParameters['project'] ?? '',
      query: state.uri.queryParameters['q'] ?? '',
    ),
  ),
];

/// Integrations and upkeep of the tenant (wave 3), under Manage.
final upkeepRoutes = <RouteBase>[
  GoRoute(path: 'webhooks', builder: (_, _) => const WebhooksScreen()),
  GoRoute(path: 'sync', builder: (_, _) => const SyncScreen()),
  GoRoute(path: 'retention', builder: (_, _) => const RetentionScreen()),
  GoRoute(path: 'housekeeping', builder: (_, _) => const HousekeepingScreen()),
  GoRoute(path: 'trash', builder: (_, _) => const TrashScreen()),
  GoRoute(path: 'audit', builder: (_, _) => const AuditScreen()),
];

/// Tenant and server administration (wave 3), under Manage.
final adminRoutes = <RouteBase>[
  GoRoute(path: 'tenant', builder: (_, _) => const TenantSettingsScreen()),
  GoRoute(path: 'domains', builder: (_, _) => const DomainsScreen()),
  GoRoute(path: 'server', builder: (_, _) => const ServerScreen()),
  GoRoute(path: 'global-admins', builder: (_, _) => const GlobalAdminsScreen()),
  GoRoute(
    path: 'accounts/:email/log',
    builder: (_, state) =>
        AccountLogScreen(email: state.pathParameters['email']!),
  ),
  GoRoute(
    path: 'tenants',
    builder: (_, _) => const TenantsScreen(),
    routes: [
      GoRoute(
        path: ':key',
        pageBuilder: _tenantPage,
        routes: [
          GoRoute(
            path: 'settings',
            builder: (_, state) =>
                TenantSettingsScreen(tenantRef: state.pathParameters['key']),
          ),
          GoRoute(
            path: 'users',
            builder: (_, state) =>
                TenantUsersScreen(tenantKey: state.pathParameters['key']!),
          ),
        ],
      ),
    ],
  ),
];

Page<void> _tenantPage(BuildContext context, GoRouterState state) {
  final key = state.pathParameters['key']!;
  if (context.isTwoPane) {
    return NoTransitionPage(
      key: state.pageKey,
      child: TenantsScreen(selectedKey: key),
    );
  }
  return MaterialPage(
    key: state.pageKey,
    child: TenantDetailScreen(tenantKey: key),
  );
}
