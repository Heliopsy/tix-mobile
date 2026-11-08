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

  /// Theme, language and instances.
  static const settings = '/settings';

  /// The saved instances and their connections.
  static const instances = '/settings/instances';

  /// The query parameters that open the connect screen beside a session.
  static const connectParams = {'add', 'instance', 'connection', 'url'};

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

  /// The tasks of the project [key].
  static String project(String key) => '/projects/${Uri.encodeComponent(key)}';

  /// The task [ref] in the project [key].
  static String task(String key, String ref) =>
      '${project(key)}/tasks/${Uri.encodeComponent(ref)}';
}
