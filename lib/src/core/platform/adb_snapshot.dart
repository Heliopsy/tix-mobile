// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/foundation.dart';
import 'package:tix_mobile/src/core/platform/adb_commands.dart';
import 'package:tix_mobile/src/data/events/live_diagnostics.dart';

/// One saved context, as the dump lists it: names and hosts only.
@immutable
class AdbContextLine {
  /// A context.
  const AdbContextLine({
    required this.id,
    required this.instance,
    this.host = '',
    this.database = '',
    this.tenant = '',
    this.signIn = false,
    this.active = false,
  });

  /// `<connection>.<tenant>`.
  final String id;

  /// The instance's name.
  final String instance;

  /// A remote instance's host, without scheme, path or query.
  final String host;

  /// A local instance's file name, without its folder.
  final String database;

  /// The tenant's name or key.
  final String tenant;

  /// Whether the connection is a sign-in rather than an API token.
  final bool signIn;

  /// Whether it is the active context.
  final bool active;
}

/// What waits to be sent in one context.
@immutable
class AdbOutboxLine {
  /// The counts for context [id].
  const AdbOutboxLine({
    required this.id,
    this.pending = 0,
    this.failed = 0,
    this.conflict = 0,
    this.needsCheck = 0,
    this.openConflicts = 0,
  });

  /// `<connection>.<tenant>`.
  final String id;

  /// Writes waiting for the server.
  final int pending;

  /// Writes the server refused.
  final int failed;

  /// Writes waiting for the person to settle a conflict.
  final int conflict;

  /// Creates whose answer was lost.
  final int needsCheck;

  /// Conflicts nobody has settled.
  final int openConflicts;
}

/// One local instance's engine.
@immutable
class AdbEngineLine {
  /// The engine of [instance] on [database], in [state].
  const AdbEngineLine({
    required this.instance,
    required this.state,
    this.database = '',
  });

  /// The instance's name.
  final String instance;

  /// running, starting, resting or stopped.
  final String state;

  /// The file name, without its folder.
  final String database;
}

/// Everything `dumpsys` prints, gathered from the app's providers.
@immutable
class AdbSnapshot {
  /// The state.
  const AdbSnapshot({
    required this.version,
    this.build = '',
    this.buildMode = 'release',
    this.headless = false,
    this.theme = 'system',
    this.locale = 'system',
    this.control = false,
    this.contexts = const [],
    this.liveMode,
    this.liveReport,
    this.outbox = const [],
    this.engines = const [],
  });

  /// The version name.
  final String version;

  /// The build number.
  final String build;

  /// debug, profile or release.
  final String buildMode;

  /// Whether a headless engine answered because the app is not open.
  final bool headless;

  /// The theme setting.
  final String theme;

  /// The language setting.
  final String locale;

  /// Whether Allow control over ADB is on.
  final bool control;

  /// The saved contexts.
  final List<AdbContextLine> contexts;

  /// The live mode, null with no live connection.
  final String? liveMode;

  /// The connection details report, null with no live connection.
  final String? liveReport;

  /// Contexts with anything waiting.
  final List<AdbOutboxLine> outbox;

  /// Every engine that ran since the app started.
  final List<AdbEngineLine> engines;
}

/// The last part of [path], whichever separator it uses.
String baseName(String path) => path.split(RegExp(r'[/\\]')).last;

/// [s] as plain text for [section], with [secrets] and anything shaped like
/// a credential or a URL's query redacted.
String formatAdbSnapshot(
  AdbSnapshot s,
  AdbSection section, {
  Iterable<String> secrets = const [],
}) {
  bool shows(AdbSection x) => section == AdbSection.all || section == x;
  final build = s.build.isEmpty ? s.version : '${s.version} (${s.build})';
  final engine = s.headless
      ? 'background engine: the app is not open'
      : 'app engine';
  final lines = <String>[
    'tix-mobile $build, ${s.buildMode} build, $engine',
    'Theme: ${s.theme}',
    'Language: ${s.locale}',
    'ADB control: ${s.control ? 'on' : 'off'}',
  ];
  if (shows(AdbSection.contexts)) lines.addAll(_contexts(s));
  if (shows(AdbSection.connection)) lines.addAll(_connection(s));
  if (shows(AdbSection.outbox)) lines.addAll(_outbox(s));
  if (shows(AdbSection.engine)) lines.addAll(_engine(s));
  return '${redactSecrets(lines.join('\n'), secrets)}\n';
}

String _where(AdbContextLine c) {
  final at = c.database.isNotEmpty ? 'local ${c.database}' : c.host;
  final name = at.isEmpty ? c.instance : '${c.instance} ($at)';
  return c.tenant.isEmpty ? name : '$name · ${c.tenant}';
}

String _engineLine(AdbEngineLine e) => e.database.isEmpty
    ? '  ${e.instance}: ${e.state}'
    : '  ${e.instance}: ${e.state} (${e.database})';

String _kind(AdbContextLine c) => c.signIn ? 'sign-in' : 'token';

String _counts(AdbOutboxLine o) =>
    '${o.id}: ${o.pending} pending, ${o.failed} refused, '
    '${o.conflict} in conflict, ${o.needsCheck} to check; '
    '${o.openConflicts} open conflicts';

List<String> _contexts(AdbSnapshot s) {
  final active = s.contexts.where((c) => c.active).firstOrNull;
  return [
    '',
    '[contexts]',
    'Active: ${active == null ? 'none' : '${_where(active)} [${active.id}]'}',
    if (s.contexts.isEmpty) 'No saved contexts.',
    for (final c in s.contexts)
      '  ${c.active ? '*' : ' '} ${c.id}  ${_where(c)}, ${_kind(c)}',
  ];
}

List<String> _connection(AdbSnapshot s) => [
  '',
  '[connection]',
  if (s.headless)
    'Live updates run only while the app is open.'
  else if (s.liveReport == null)
    'No live connection: no context is active.'
  else ...[
    'Live: ${s.liveMode}',
    s.liveReport!,
  ],
];

List<String> _outbox(AdbSnapshot s) => [
  '',
  '[outbox]',
  if (s.outbox.isEmpty) 'Nothing waiting.',
  for (final o in s.outbox) _counts(o),
];

List<String> _engine(AdbSnapshot s) {
  final active = s.contexts.where((c) => c.active).firstOrNull;
  return [
    '',
    '[engine]',
    if (active == null || active.database.isEmpty)
      'The active context is not a local instance.'
    else
      'Active local instance: ${active.instance} (${active.database})',
    if (s.headless)
      'Engines run only in the app; a background engine never starts one.'
    else if (s.engines.isEmpty)
      'No engine has run since the app started.'
    else
      for (final e in s.engines) _engineLine(e),
  ];
}
