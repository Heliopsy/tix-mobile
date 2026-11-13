// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/config/server_url.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/platform/attachments.dart';
import 'package:tix_mobile/src/core/session/local.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/models/instance.dart';

/// A section of tix's documentation: a page under docs/ and the GitHub
/// anchor of a heading in it.
@immutable
class DocSection {
  /// The heading [anchor] of [page].
  const DocSection(this.page, this.anchor);

  /// A file under tix's docs/, such as `web-ui.md`.
  final String page;

  /// The heading's GitHub anchor, such as `the-task-list`.
  final String anchor;
}

/// The section that explains each routed screen, by its route pattern, with
/// the web's sections (internal/web/help.go) where the screens match. Null
/// for a screen tix's docs do not describe, which draws no (?).
const Map<String, DocSection?> screenDocs = {
  '/projects': DocSection('web-ui.md', 'projects'),
  '/projects/:key': DocSection('web-ui.md', 'the-project-page'),
  '/projects/:key/tasks/:ref': DocSection('web-ui.md', 'the-task-screen'),
  '/projects/:key/settings': DocSection('web-ui.md', 'project-settings'),
  '/projects/:key/fields': DocSection('workflows.md', 'custom-fields'),
  '/projects/:key/transfer': DocSection(
    'import-export.md',
    'project-import-and-export',
  ),
  '/templates': DocSection('web-ui.md', 'task-templates'),
  '/tasks': DocSection('web-ui.md', 'the-task-list'),
  '/mine': DocSection('web-ui.md', 'my-work-saved-filters-and-recently-viewed'),
  '/inbox': DocSection('web-ui.md', 'the-inbox'),
  '/activity': DocSection('web-ui.md', 'activity'),
  '/actors/:id': DocSection('web-ui.md', 'the-actor-screen'),
  '/stats': DocSection('web-ui.md', 'statistics'),
  '/events': DocSection('api.md', 'the-event-stream'),
  '/manage': DocSection('web-ui.md', 'server-administration'),
  '/manage/workflows': DocSection('workflows.md', 'defining-a-workflow'),
  '/manage/workflows/:key': DocSection('workflows.md', 'defining-a-workflow'),
  '/manage/status': DocSection('web-ui.md', 'server-administration'),
  '/manage/bundles': DocSection(
    'migrating.md',
    'sharing-configuration-between-installations',
  ),
  '/manage/import': DocSection('migrating.md', 'moving-a-whole-tenant'),
  '/manage/fields': DocSection('workflows.md', 'custom-fields'),
  '/manage/fields/:key': DocSection('workflows.md', 'custom-fields'),
  '/manage/users': DocSection('tenancy.md', 'members-and-roles'),
  '/manage/users/:id': DocSection('tenancy.md', 'members-and-roles'),
  '/manage/tokens': DocSection('agents.md', 'tokens-and-scopes'),
  '/manage/transfer': DocSection(
    'import-export.md',
    'project-import-and-export',
  ),
  '/manage/webhooks': DocSection('api.md', 'webhooks'),
  '/manage/sync': DocSection(
    'migrating.md',
    'importing-from-an-external-tracker',
  ),
  '/manage/retention': DocSection('configuration.md', 'retention'),
  '/manage/housekeeping': DocSection('web-ui.md', 'housekeeping'),
  '/manage/trash': DocSection('tenancy.md', 'the-trash'),
  '/manage/tenant': DocSection('tenancy.md', 'tenants'),
  '/manage/domains': DocSection('tenancy.md', 'domains'),
  '/manage/server': DocSection('web-ui.md', 'server-administration'),
  '/manage/global-admins': DocSection('tenancy.md', 'global-admins'),
  '/manage/accounts/:email/log': DocSection('tenancy.md', 'account-history'),
  '/manage/tenants': DocSection('tenancy.md', 'global-admins'),
  '/manage/tenants/:key': DocSection('tenancy.md', 'global-admins'),
  '/manage/tenants/:key/settings': DocSection('tenancy.md', 'global-admins'),
  '/manage/tenants/:key/users': DocSection('tenancy.md', 'global-admins'),
  '/settings': DocSection('web-ui.md', 'the-settings-screen'),
  '/settings/filters': DocSection(
    'web-ui.md',
    'my-work-saved-filters-and-recently-viewed',
  ),
  '/settings/instances': DocSection('tenancy.md', 'switching-tenant'),
  '/settings/notifications': DocSection('web-ui.md', 'notification-channels'),
  '/settings/notifications/channels/:id': DocSection(
    'web-ui.md',
    'notification-channels',
  ),
  '/settings/about': DocSection('README.md', 'documentation'),
  '/settings/account': DocSection('tenancy.md', 'account-history'),
  '/settings/calendar': DocSection('calendar.md', 'getting-the-address'),
  '/settings/tokens': DocSection('agents.md', 'tokens-and-scopes'),
  '/settings/connect-agent': DocSection('web-ui.md', 'connect-an-agent'),
  '/settings/security': DocSection('web-ui.md', 'the-second-factor'),
  '/settings/offline': null,
  '/settings/conflicts': null,
};

/// Where tix's docs are read on GitHub.
const tixDocsRepo = 'https://github.com/heliopsy/tix/blob/';

/// [doc] through the documentation redirect of the server at [baseUrl],
/// which lands on the docs of the release that server runs.
Uri serverDocsUri(String baseUrl, DocSection doc) =>
    Uri.parse('${withoutTrailingSlash(baseUrl)}/docs/${doc.page}')
        .replace(queryParameters: {'section': doc.anchor});

/// [doc] on GitHub at the tag of [release], or at main when it is not a
/// release version.
Uri githubDocsUri(DocSection doc, {String? release}) {
  final v = RegExp(r'^v?(\d+\.\d+\.\d+)$').firstMatch(release ?? '');
  final ref = v == null ? 'main' : 'v${v.group(1)}';
  return Uri.parse('$tixDocsRepo$ref/docs/${doc.page}#${doc.anchor}');
}

/// Opens [doc] in the browser: through the active remote server, or on
/// GitHub at the embedded engine's release for a local instance.
Future<void> openDocs(WidgetRef ref, DocSection doc) async {
  final session = ref.read(sessionControllerProvider).value;
  final uri = session != null && session.instance.kind == InstanceKind.remote
      ? serverDocsUri(session.baseUrl, doc)
      : githubDocsUri(doc, release: await _engineRelease(ref));
  await ref.read(attachmentsProvider).openLink(uri);
}

Future<String?> _engineRelease(WidgetRef ref) async {
  try {
    return await ref.read(localTixEngineProvider).version();
  } on TixException catch (e) {
    if (e.kind == TixErrorKind.engineUnavailable) return null;
    rethrow;
  }
}

/// Gives every page in [child] the (?) of its route's [screenDocs] entry.
class ScreenHelpScope extends ConsumerWidget {
  /// Help for the routes in [child].
  const ScreenHelpScope({required this.child, super.key});

  /// The routes.
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) => TixPageHelp(
    open: (context) {
      final doc = screenDocs[_routeOf(context)];
      if (doc == null) return null;
      return () => unawaited(openDocs(ref, doc));
    },
    child: child,
  );
}

/// The route pattern of the page in [context], or null for a widget no
/// route built.
String? _routeOf(BuildContext context) {
  try {
    return GoRouterState.of(context).fullPath;
    // go_router has no maybeOf; it throws for a route it did not build.
    // ignore: avoid_catching_errors
  } on GoError {
    return null;
  }
}
