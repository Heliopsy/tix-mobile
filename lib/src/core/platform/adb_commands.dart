// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/foundation.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/platform/deep_links.dart';
import 'package:tix_mobile/src/data/events/live_diagnostics.dart';

/// What `dumpsys` can be asked for.
enum AdbSection {
  /// Everything.
  all,

  /// Live updates and the connection details report.
  connection,

  /// Writes waiting and conflicts, per context.
  outbox,

  /// The local engine.
  engine,

  /// The saved contexts.
  contexts,
}

/// The section called [name], [AdbSection.all] when it is empty; null for
/// a name that is not one.
AdbSection? adbSectionNamed(String name) {
  final n = name.trim().toLowerCase();
  if (n.isEmpty) return AdbSection.all;
  return AdbSection.values.where((s) => s.name == n).firstOrNull;
}

/// One command `am broadcast` can send.
@immutable
class AdbCommandSpec {
  /// The command [name], used as [usage].
  const AdbCommandSpec(
    this.name,
    this.usage, {
    this.arg,
    this.readOnly = false,
    this.needsApp = true,
  });

  /// What `--es cmd` says.
  final String name;

  /// How it is called, for help and errors.
  final String usage;

  /// The extra holding its argument, null when it takes none.
  final String? arg;

  /// Whether it only reads, so a release build runs it with the setting off.
  final bool readOnly;

  /// Whether it needs the app's own engine, with its session, rather than
  /// a headless one.
  final bool needsApp;
}

/// Every command, in the order help lists them.
const adbCommands = <AdbCommandSpec>[
  AdbCommandSpec('help', 'help', readOnly: true, needsApp: false),
  AdbCommandSpec(
    'dump',
    'dump [--es section all|connection|outbox|engine|contexts]',
    arg: 'section',
    readOnly: true,
    needsApp: false,
  ),
  AdbCommandSpec('reconnect', 'reconnect'),
  AdbCommandSpec('sync-now', 'sync-now'),
  AdbCommandSpec('switch', 'switch --es context <id|name>', arg: 'context'),
  AdbCommandSpec(
    'quick-add',
    'quick-add --es line <text> [--es project <KEY>]',
    arg: 'line',
  ),
  AdbCommandSpec(
    'open',
    'open --es link <tix:// link>',
    arg: 'link',
    needsApp: false,
  ),
  AdbCommandSpec('engine-stop', 'engine-stop'),
  AdbCommandSpec('engine-start', 'engine-start'),
  AdbCommandSpec('clear-cache', 'clear-cache'),
  AdbCommandSpec(
    'theme',
    'theme --es value system|light|dark|oled',
    arg: 'value',
    needsApp: false,
  ),
  AdbCommandSpec(
    'locale',
    'locale --es value system|en|fr|de|bg',
    arg: 'value',
    needsApp: false,
  ),
];

/// The themes `theme` takes.
const adbThemes = ['system', 'light', 'dark', 'oled'];

/// The languages `locale` takes.
const adbLocales = ['system', 'en', 'fr', 'de', 'bg'];

/// What `help` prints.
final String adbHelp = [
  'tix adb commands, sent as --es cmd <command>:',
  for (final c in adbCommands) '  ${c.usage}',
  'An argument can also follow the name: --es cmd "theme dark".',
  'Release builds run only help and dump until',
  'Settings > Advanced > Allow control over ADB is on.',
].join('\n');

/// What a release build answers until the setting is on.
const adbDisabled =
    'disabled: enable Settings > Advanced > Allow control over ADB';

/// Extras no command takes: credentials never travel through the shell.
const _secretExtras = {
  'token',
  'password',
  'passwd',
  'secret',
  'cookie',
  'session',
  'credential',
  'authorization',
  'auth',
  'apikey',
  'api_key',
};

/// A command that cannot run, with the reason to print.
class AdbError implements Exception {
  /// Fails with [message].
  const AdbError(this.message);

  /// What `am broadcast` prints.
  final String message;

  @override
  String toString() => message;
}

/// A parsed command.
@immutable
class AdbCommand {
  /// [spec] with its [arg] and every extra sent.
  const AdbCommand(this.spec, {this.arg = '', this.extras = const {}});

  /// Which command.
  final AdbCommandSpec spec;

  /// Its argument, empty when it takes none.
  final String arg;

  /// Every extra sent with it.
  final Map<String, String> extras;

  /// Its name.
  String get name => spec.name;
}

/// [cmd] and [extras] as a command. The argument comes from the command's
/// extra, or else from what follows the name in [cmd]. Throws [AdbError]
/// for an unknown command, a missing argument, or an extra shaped like a
/// credential.
AdbCommand parseAdbCommand(String? cmd, Map<String, String> extras) {
  if (extras.keys.any((k) => _secretExtras.contains(k.toLowerCase()))) {
    throw const AdbError('refused: commands never take credentials');
  }
  final words = (cmd ?? '').trim();
  final space = words.indexOf(RegExp(r'\s'));
  final name = (space < 0 ? words : words.substring(0, space)).toLowerCase();
  final rest = space < 0 ? '' : words.substring(space).trim();
  if (name.isEmpty) return AdbCommand(adbCommands.first, extras: extras);
  final spec = adbCommands.where((c) => c.name == name).firstOrNull;
  if (spec == null) {
    final shown = name.length > 40 ? '${name.substring(0, 40)}…' : name;
    throw AdbError('unknown command "$shown": try help');
  }
  final key = spec.arg;
  final given = key == null ? '' : extras[key]?.trim() ?? '';
  final arg = given.isNotEmpty ? given : rest;
  if (key != null && arg.isEmpty && spec.name != 'dump') {
    throw AdbError('${spec.name} needs an argument: ${spec.usage}');
  }
  return AdbCommand(spec, arg: arg, extras: extras);
}

/// Whether [command] may run: read-only commands always, the rest in a
/// debug build or with the setting [enabled].
bool adbAllowed(
  AdbCommand command, {
  required bool debugBuild,
  required bool enabled,
}) => command.spec.readOnly || debugBuild || enabled;

/// What a command answers.
@immutable
class AdbReply {
  /// A reply printing [text].
  const AdbReply(
    this.text, {
    this.ok = true,
    this.needsApp = false,
    this.launch,
  });

  /// A failure printing [text].
  const AdbReply.error(this.text) : ok = false, needsApp = false, launch = null;

  /// A reply asking the platform to bring the app up and send again.
  const AdbReply.inApp()
    : text = 'needs the app',
      ok = false,
      needsApp = true,
      launch = null;

  /// What `am broadcast` prints.
  final String text;

  /// Whether it worked.
  final bool ok;

  /// Whether it has to run in the app's own engine.
  final bool needsApp;

  /// A `tix://` link the platform should open, null for none.
  final String? launch;

  /// The form the platform channel carries.
  Map<String, Object?> toMap() => {
    'ok': ok,
    'text': text,
    'needsApp': needsApp,
    'launch': ?launch,
  };
}

/// What commands change, over the app's providers.
abstract interface class AdbActions {
  /// The state report for [section].
  Future<String> snapshot(AdbSection section);

  /// Tries live updates again at once.
  Future<String> reconnect();

  /// Sends the outbox now.
  Future<String> syncNow();

  /// Switches to the context [name] names.
  Future<String> switchTo(String name);

  /// Adds a task from [line] in [project], or the first project.
  Future<String> quickAdd(String line, {String? project});

  /// Stops the active local instance's engine.
  Future<String> engineStop();

  /// Starts the active local instance's engine.
  Future<String> engineStart();

  /// Forgets the saved copies of the active context.
  Future<String> clearCache();

  /// Switches to the theme [name].
  Future<String> theme(String name);

  /// Switches to the language [code], `system` to follow the device.
  Future<String> locale(String code);
}

/// Runs [cmd] with [extras] on [actions] and answers in plain text that
/// never holds a credential: [secrets] and anything shaped like one are
/// redacted. [headless] says this engine has no session, so commands that
/// need one answer [AdbReply.inApp].
Future<AdbReply> runAdbCommand(
  String? cmd,
  Map<String, String> extras, {
  required AdbActions actions,
  required bool debugBuild,
  required bool enabled,
  bool headless = false,
  Iterable<String> secrets = const [],
}) async {
  String clean(String s) => redactSecrets(s, secrets);
  final AdbCommand command;
  try {
    command = parseAdbCommand(cmd, extras);
  } on AdbError catch (e) {
    return AdbReply.error(clean(e.message));
  }
  if (!adbAllowed(command, debugBuild: debugBuild, enabled: enabled)) {
    return const AdbReply.error(adbDisabled);
  }
  if (headless && command.spec.needsApp) return const AdbReply.inApp();
  try {
    final reply = await _dispatch(command, actions);
    return AdbReply(clean(reply.text), ok: reply.ok, launch: reply.launch);
  } on AdbError catch (e) {
    return AdbReply.error(clean(e.message));
  } on TixException catch (e) {
    return AdbReply.error(clean('failed: ${e.kind.name}: ${e.message}'));
  }
}

Future<AdbReply> _dispatch(AdbCommand c, AdbActions actions) async {
  switch (c.name) {
    case 'help':
      return AdbReply(adbHelp);
    case 'dump':
      final section = adbSectionNamed(c.arg);
      if (section == null) throw AdbError(_badSection(c.arg));
      return AdbReply(await actions.snapshot(section));
    case 'reconnect':
      return AdbReply(await actions.reconnect());
    case 'sync-now':
      return AdbReply(await actions.syncNow());
    case 'switch':
      return AdbReply(await actions.switchTo(c.arg));
    case 'quick-add':
      final project = c.extras['project']?.trim() ?? '';
      return AdbReply(
        await actions.quickAdd(
          c.arg,
          project: project.isEmpty ? null : project,
        ),
      );
    case 'open':
      return _open(c.arg);
    case 'engine-stop':
      return AdbReply(await actions.engineStop());
    case 'engine-start':
      return AdbReply(await actions.engineStart());
    case 'clear-cache':
      return AdbReply(await actions.clearCache());
    case 'theme':
      final theme = c.arg.toLowerCase();
      if (!adbThemes.contains(theme)) {
        throw AdbError('theme is one of ${adbThemes.join(', ')}');
      }
      return AdbReply(await actions.theme(theme));
    case 'locale':
      final code = c.arg.toLowerCase();
      if (!adbLocales.contains(code)) {
        throw AdbError('locale is one of ${adbLocales.join(', ')}');
      }
      return AdbReply(await actions.locale(code));
  }
  throw AdbError('unknown command "${c.name}": try help');
}

AdbReply _open(String link) {
  final uri = Uri.tryParse(link);
  if (uri == null || uri.scheme.toLowerCase() != tixLinkScheme) {
    throw const AdbError('open takes a tix:// link, such as tix://inbox');
  }
  final known = parseTixLink(uri) != null;
  return AdbReply(
    known
        ? 'opening $uri'
        : 'not a link tix knows: it says so and goes home. $uri',
    launch: uri.toString(),
  );
}

String _badSection(String name) =>
    'unknown section "$name": use '
    '${AdbSection.values.map((s) => s.name).join(', ')}';
