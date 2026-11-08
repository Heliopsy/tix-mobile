// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:meta/meta.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/platform/app_info.dart';
import 'package:tix_mobile/src/core/session/local.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/models/instance.dart';

part 'about.g.dart';

/// Where the project lives.
abstract final class AboutLinks {
  /// The tix website.
  static final Uri website = Uri.parse('https://tix.red');

  /// This app's source, which is also the AGPL's offer of it.
  static final Uri source = Uri.parse('https://github.com/heliopsy/tix-mobile');

  /// What is planned.
  static final Uri roadmap = Uri.parse(
    'https://github.com/heliopsy/tix-mobile/blob/main/ROADMAP.md',
  );

  /// What changed in each release.
  static final Uri changelog = Uri.parse(
    'https://github.com/heliopsy/tix-mobile/blob/main/CHANGELOG.md',
  );

  /// The tix server.
  static final Uri server = Uri.parse('https://github.com/heliopsy/tix');

  /// How to report a vulnerability.
  static final Uri security = Uri.parse(
    'https://github.com/heliopsy/tix-mobile/blob/main/SECURITY.md',
  );

  /// A new issue from the bug report form.
  static const newIssue = 'https://github.com/heliopsy/tix-mobile/issues/new';
}

/// The facts a bug report needs. Built from version strings and the
/// server's address only: never a token, a session or a password.
@immutable
class Diagnostics {
  /// The facts.
  const Diagnostics({
    required this.app,
    required this.engine,
    required this.server,
    required this.serverAddress,
    required this.locale,
  });

  /// This build and the system it runs on.
  final AppInfo app;

  /// The embedded engine's tix version, null when the build has none.
  final String? engine;

  /// The active server's tix version, null when unknown.
  final String? server;

  /// The active remote server's address, empty for a local instance.
  final String serverAddress;

  /// The language the app shows.
  final String locale;

  /// The app's version and build, as `0.4.0 (12)`.
  String get appVersion =>
      app.build.isEmpty ? app.version : '${app.version} (${app.build})';

  /// The facts as plain text, one per line. The server's address is left
  /// out unless [withServerAddress].
  String toText({bool withServerAddress = false}) => [
    'tix-mobile $appVersion',
    'Platform: ${app.platform} ${app.osVersion}',
    'Engine: ${engine ?? 'none'}',
    'Server: ${server ?? 'unknown'}',
    if (withServerAddress && serverAddress.isNotEmpty)
      'Server address: $serverAddress',
    'Locale: $locale',
  ].join('\n');

  /// The bug report form on GitHub with what is known filled in.
  Uri bugReport() => Uri.parse(AboutLinks.newIssue).replace(
    queryParameters: {
      'template': 'bug_report.yml',
      'platform': app.platform,
      'os-version': '${app.platform} ${app.osVersion}',
      'app-version': appVersion,
      'server-version': ?server,
      'logs': toText(),
    },
  );
}

/// The embedded engine's tix version, null when this build has none.
@riverpod
Future<String?> engineVersion(Ref ref) async {
  try {
    return await ref.watch(localTixEngineProvider).version();
  } on TixException catch (e) {
    if (e.kind == TixErrorKind.engineUnavailable) return null;
    rethrow;
  }
}

/// The tix version of the active context's server, null when signed out.
@riverpod
Future<String?> serverVersion(Ref ref) async {
  final session = ref.watch(sessionControllerProvider).value;
  if (session == null) return null;
  return await ref.watch(authRepositoryProvider).serverVersion(session.baseUrl);
}

/// The address of the active remote server, empty for a local instance or
/// when signed out.
@riverpod
String serverAddress(Ref ref) {
  final session = ref.watch(sessionControllerProvider).value;
  if (session == null) return '';
  final i = session.instance;
  return i.kind == InstanceKind.remote ? i.baseUrl : '';
}
