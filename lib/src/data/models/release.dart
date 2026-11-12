// SPDX-License-Identifier: AGPL-3.0-or-later

// The server's release check, as `GET /release` answers it. Written by hand
// until the pinned tix carries the route and the generated client has it.

import 'package:meta/meta.dart';

/// What the server knows about its own version and the newest release.
@immutable
class ServerRelease {
  /// The answer, field by field.
  const ServerRelease({
    required this.running,
    this.latest = '',
    this.status = '',
    this.newer = false,
    this.checked = false,
    this.failed = false,
    this.notes = '',
    this.methods = const [],
    this.changes = const ReleaseChanges(),
  });

  /// Reads the JSON object tix sends.
  factory ServerRelease.fromJson(Map<String, dynamic> json) => ServerRelease(
    running: json['running'] as String? ?? '',
    latest: json['latest'] as String? ?? '',
    status: json['status'] as String? ?? '',
    newer: json['newer'] as bool? ?? false,
    checked: json['checked'] as bool? ?? false,
    failed: json['failed'] as bool? ?? false,
    notes: json['notes'] as String? ?? '',
    methods: [
      for (final m in json['methods'] as List<dynamic>? ?? const [])
        UpgradeMethod.fromJson(m as Map<String, dynamic>),
    ],
    changes: json['changes'] is Map<String, dynamic>
        ? ReleaseChanges.fromJson(json['changes'] as Map<String, dynamic>)
        : const ReleaseChanges(),
  );

  /// This server's version, without a leading v.
  final String running;

  /// The newest published release, empty until a check succeeded.
  final String latest;

  /// newer, current, unknown, failed or pending.
  final String status;

  /// Whether [latest] is ahead of [running].
  final bool newer;

  /// Whether a check has finished.
  final bool checked;

  /// Whether the last check got no usable answer.
  final bool failed;

  /// The newest release's notes as Markdown, links taken out; empty unless
  /// [newer].
  final String notes;

  /// The commands that upgrade each install method; empty unless [newer].
  final List<UpgradeMethod> methods;

  /// What the changelog bundled with the server says.
  final ReleaseChanges changes;
}

/// One way tix is installed and the command that upgrades it.
@immutable
class UpgradeMethod {
  /// [id] upgraded by [command].
  const UpgradeMethod({
    required this.id,
    required this.command,
    this.name = '',
    this.help = '',
  });

  /// Reads the JSON object tix sends.
  factory UpgradeMethod.fromJson(Map<String, dynamic> json) => UpgradeMethod(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    help: json['help'] as String? ?? '',
    command: json['command'] as String? ?? '',
  );

  /// binary, container or go.
  final String id;

  /// What tix calls it, in English.
  final String name;

  /// When it applies, in English.
  final String help;

  /// The command.
  final String command;
}

/// The changelog around the running version.
@immutable
class ReleaseChanges {
  /// The entries.
  const ReleaseChanges({
    this.running,
    this.earlier = const [],
    this.untagged = false,
  });

  /// Reads the JSON object tix sends; a missing running entry is null.
  factory ReleaseChanges.fromJson(Map<String, dynamic> json) => ReleaseChanges(
    running: json['running'] is Map<String, dynamic>
        ? ReleaseEntry.fromJson(json['running'] as Map<String, dynamic>)
        : null,
    earlier: [
      for (final e in json['earlier'] as List<dynamic>? ?? const [])
        ReleaseEntry.fromJson(e as Map<String, dynamic>),
    ],
    untagged: json['untagged'] as bool? ?? false,
  );

  /// The running version's own entry, null for a build the changelog does
  /// not name.
  final ReleaseEntry? running;

  /// The entries before it, or the newest when [running] is null.
  final List<ReleaseEntry> earlier;

  /// Whether the running version is not a tagged release.
  final bool untagged;
}

/// One changelog entry.
@immutable
class ReleaseEntry {
  /// [version] released on [date].
  const ReleaseEntry({required this.version, this.date = '', this.notes = ''});

  /// Reads the JSON object tix sends.
  factory ReleaseEntry.fromJson(Map<String, dynamic> json) => ReleaseEntry(
    version: json['version'] as String? ?? '',
    date: json['date'] as String? ?? '',
    notes: json['notes'] as String? ?? '',
  );

  /// The release, without a leading v.
  final String version;

  /// YYYY-MM-DD, or empty.
  final String date;

  /// The entry as Markdown, links taken out.
  final String notes;
}
