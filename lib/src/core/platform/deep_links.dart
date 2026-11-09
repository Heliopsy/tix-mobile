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
  const TixLink({this.route, this.context});

  /// The route to go to; null for the connection details, which open over
  /// the screen on show.
  final String? route;

  /// The context to open it in, as the link names it; null for the active
  /// one.
  final String? context;

  @override
  bool operator ==(Object other) =>
      other is TixLink && other.route == route && other.context == context;

  @override
  int get hashCode => Object.hash(route, context);

  @override
  String toString() => 'TixLink($route, $context)';
}

final _name = RegExp(r'^[A-Za-z0-9][A-Za-z0-9_.-]*$');

/// [uri] as a [TixLink], null when it is not a link the app knows.
///
/// `tix://inbox`, `tix://mine`, `tix://tasks`, `tix://projects`,
/// `tix://projects/<KEY>`, `tix://projects/<KEY>/tasks/<ref>`,
/// `tix://settings`, `tix://about` and `tix://connection`, each with an
/// optional `?context=<connection or name>`.
TixLink? parseTixLink(Uri uri) {
  if (uri.scheme.toLowerCase() != tixLinkScheme) return null;
  final List<String> segments;
  final String? context;
  try {
    segments = [
      if (uri.host.isNotEmpty) uri.host.toLowerCase(),
      ...uri.pathSegments.where((s) => s.isNotEmpty),
    ];
    final named = uri.queryParameters['context']?.trim() ?? '';
    context = named.isEmpty ? null : named;
  } on FormatException {
    return null;
  }
  bool ok(String s) => _name.hasMatch(s);
  final route = switch (segments) {
    ['inbox'] => Routes.inbox,
    ['mine'] => Routes.myWork,
    ['tasks'] => Routes.tasks,
    ['projects'] => Routes.projects,
    ['projects', final key] when ok(key) => Routes.project(key),
    ['projects', final key, 'tasks', final ref] when ok(key) && ok(ref) =>
      Routes.task(key, ref),
    ['settings'] => Routes.settings,
    ['about'] => Routes.about,
    ['connection'] => '',
    _ => null,
  };
  if (route == null) return null;
  return TixLink(route: route.isEmpty ? null : route, context: context);
}

/// `tix://` links the platform opened the app with. Android's
/// `MainActivity` holds the latest one until it is taken over the
/// `tix/links` channel, and says `opened` when one arrives while running.
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
    if (uri == null) return;
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
