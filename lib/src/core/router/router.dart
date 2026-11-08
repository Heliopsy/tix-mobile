// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/theme/layout.dart';
import 'package:tix_mobile/src/features/connect/presentation/connect_screen.dart';
import 'package:tix_mobile/src/features/projects/presentation/projects_screen.dart';
import 'package:tix_mobile/src/features/settings/presentation/settings_screen.dart';
import 'package:tix_mobile/src/features/shell/presentation/home_shell.dart';
import 'package:tix_mobile/src/features/shell/presentation/splash_screen.dart';
import 'package:tix_mobile/src/features/tasks/presentation/task_detail_screen.dart';
import 'package:tix_mobile/src/features/tasks/presentation/task_list_screen.dart';

part 'router.g.dart';

/// App locations.
abstract final class Routes {
  /// Shown while the saved session loads.
  static const splash = '/';

  /// Sign in to a server.
  static const connect = '/connect';

  /// Sign in to one more server while signed in to another.
  static const addServer = '/connect?add=1';

  /// Every project.
  static const projects = '/projects';

  /// Theme, language and servers.
  static const settings = '/settings';

  /// The tasks of the project [key].
  static String project(String key) => '/projects/${Uri.encodeComponent(key)}';

  /// The task [ref] in the project [key].
  static String task(String key, String ref) =>
      '${project(key)}/tasks/${Uri.encodeComponent(ref)}';
}

/// Where [uri] should lead instead, given [session], or null to stay.
String? redirectFor(AsyncValue<Session?> session, Uri uri) {
  final path = uri.path;
  if (session.isLoading && !session.hasValue) {
    return path == Routes.splash ? null : Routes.splash;
  }
  if (session.value == null) {
    return path == Routes.connect ? null : Routes.connect;
  }
  final adding = uri.queryParameters.containsKey('add');
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
        builder: (_, state) =>
            ConnectScreen(adding: state.uri.queryParameters.containsKey('add')),
      ),
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
