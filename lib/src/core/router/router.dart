// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/router/routes.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/theme/layout.dart';
import 'package:tix_mobile/src/features/connect/presentation/connect_screen.dart';
import 'package:tix_mobile/src/features/gallery/presentation/gallery_screen.dart';
import 'package:tix_mobile/src/features/instances/presentation/instances_screen.dart';
import 'package:tix_mobile/src/features/projects/presentation/projects_screen.dart';
import 'package:tix_mobile/src/features/settings/presentation/settings_screen.dart';
import 'package:tix_mobile/src/features/shell/presentation/home_shell.dart';
import 'package:tix_mobile/src/features/shell/presentation/splash_screen.dart';
import 'package:tix_mobile/src/features/tasks/presentation/task_detail_screen.dart';
import 'package:tix_mobile/src/features/tasks/presentation/task_list_screen.dart';

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
          );
        },
      ),
      if (Routes.galleryEnabled)
        GoRoute(path: Routes.gallery, builder: (_, _) => const GalleryScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => HomeShell(shell: shell),
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
                    ],
                  ),
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
