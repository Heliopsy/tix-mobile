// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/router/routes.dart';

part 'deep_links.g.dart';

/// The scheme of the app's own links.
const tixLinkScheme = 'tix';

/// Where a `tix://` link leads. Links only navigate; none changes data.
@immutable
class TixLink {
  /// A link to [route], in the context [context] names when given.
  const TixLink({
    this.route,
    this.context,
    this.quickAdd = false,
    this.project,
  });

  /// The route to go to; null for the connection details, which open over
  /// the screen on show, and for quick add.
  final String? route;

  /// The context to open it in, as the link names it; null for the active
  /// one.
  final String? context;

  /// Whether the link opens quick add over the screen on show.
  final bool quickAdd;

  /// The project quick add starts in, when the link names one.
  final String? project;

  @override
  bool operator ==(Object other) =>
      other is TixLink &&
      other.route == route &&
      other.context == context &&
      other.quickAdd == quickAdd &&
      other.project == project;

  @override
  int get hashCode => Object.hash(route, context, quickAdd, project);

  @override
  String toString() => 'TixLink($route, $context, $quickAdd, $project)';
}

final _name = RegExp(r'^[A-Za-z0-9][A-Za-z0-9_.-]*$');

/// [uri] as a [TixLink], null when it is not a link the app knows.
///
/// `tix://inbox`, `tix://mine`, `tix://tasks`, `tix://projects`,
/// `tix://projects/<KEY>`, `tix://projects/<KEY>/tasks/<ref>`,
/// `tix://settings`, `tix://about`, `tix://activity` (or the older
/// `tix://watch`), `tix://connection`,
/// `tix://tasks?filter=<name or id>` and `tix://quick-add?project=<KEY>`,
/// each with an optional `?context=<connection or name>`.
TixLink? parseTixLink(Uri uri) {
  if (uri.scheme.toLowerCase() != tixLinkScheme) return null;
  final List<String> segments;
  final String? context;
  final String filter;
  final String project;
  try {
    segments = [
      if (uri.host.isNotEmpty) uri.host.toLowerCase(),
      ...uri.pathSegments.where((s) => s.isNotEmpty),
    ];
    final q = uri.queryParameters;
    final named = q['context']?.trim() ?? '';
    context = named.isEmpty ? null : named;
    filter = q['filter']?.trim() ?? '';
    project = q['project']?.trim() ?? '';
  } on FormatException {
    return null;
  }
  bool ok(String s) => _name.hasMatch(s);
  if (segments case ['quick-add']) {
    if (project.isNotEmpty && !ok(project)) return null;
    return TixLink(
      context: context,
      quickAdd: true,
      project: project.isEmpty ? null : project,
    );
  }
  final route = switch (segments) {
    ['inbox'] => Routes.inbox,
    ['mine'] => Routes.myWork,
    ['tasks'] when filter.isNotEmpty => Routes.tasksFiltered(filter),
    ['tasks'] => Routes.tasks,
    ['projects'] => Routes.projects,
    ['projects', final key] when ok(key) => Routes.project(key),
    ['projects', final key, 'tasks', final ref] when ok(key) && ok(ref) =>
      Routes.task(key, ref),
    ['settings'] => Routes.settings,
    ['about'] => Routes.about,
    ['activity'] || ['watch'] => Routes.activity,
    ['connection'] => '',
    _ => null,
  };
  if (route == null) return null;
  return TixLink(route: route.isEmpty ? null : route, context: context);
}

/// The link that opens [path] (such as `projects/OPS`) in the context
/// [context], a `<connection>.<tenant>` key, with [query] added.
Uri tixLinkTo(
  String path, {
  String? context,
  Map<String, String> query = const {},
}) {
  final segments = path.split('/').where((s) => s.isNotEmpty).toList();
  final params = {
    ...query,
    if (context != null && context.isNotEmpty) 'context': context,
  };
  return Uri(
    scheme: tixLinkScheme,
    host: segments.first,
    pathSegments: segments.length > 1 ? segments.skip(1) : null,
    queryParameters: params.isEmpty ? null : params,
  );
}

/// `tix://` links the platform opened the app with. Android's
/// `MainActivity`, and the Linux, Windows and macOS runners, hold the latest
/// one until it is taken over the `tix/links` channel, and say `opened` when
/// one arrives while running.
class DeepLinkIntake {
  /// Listens on [channel].
  DeepLinkIntake([this.channel = const MethodChannel('tix/links')]) {
    channel.setMethodCallHandler((call) async {
      if (call.method == 'opened') await _pull();
    });
  }

  /// The channel to the platform.
  final MethodChannel channel;
  final _links = StreamController<Uri>.broadcast();
  Uri? _waiting;

  /// Links as they arrive, while someone listens.
  Stream<Uri> get links => _links.stream;

  /// Takes a link that arrived while nobody listened.
  Uri? take() {
    final waiting = _waiting;
    _waiting = null;
    return waiting;
  }

  /// Takes the link the platform holds, such as the one that started the
  /// app.
  Future<void> start() => _pull();

  Future<void> _pull() async {
    final String? taken;
    try {
      taken = await channel.invokeMethod<String>('take');
    } on MissingPluginException {
      return;
    }
    final uri = taken == null ? null : Uri.tryParse(taken);
    if (uri != null) deliver(uri);
  }

  /// Hands [uri] over as if the platform had opened it: the desktop tray and
  /// hotkey send their links this way.
  void deliver(Uri uri) {
    if (_links.hasListener) {
      _links.add(uri);
    } else {
      _waiting = uri;
    }
  }

  /// Stops listening.
  void dispose() {
    channel.setMethodCallHandler(null);
    unawaited(_links.close());
  }
}

/// The platform's link intake; tests swap in one on a mocked channel.
@Riverpod(keepAlive: true)
DeepLinkIntake deepLinkIntake(Ref ref) {
  final intake = DeepLinkIntake();
  ref.onDispose(intake.dispose);
  return intake;
}
