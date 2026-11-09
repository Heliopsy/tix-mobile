// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/events/events.dart';
import 'package:tix_mobile/src/core/logging/log.dart';
import 'package:tix_mobile/src/core/offline/outbox.dart';
import 'package:tix_mobile/src/core/offline/sync.dart';
import 'package:tix_mobile/src/core/platform/adb_commands.dart';
import 'package:tix_mobile/src/core/platform/adb_snapshot.dart';
import 'package:tix_mobile/src/core/platform/app_info.dart';
import 'package:tix_mobile/src/core/quick/quick_add.dart';
import 'package:tix_mobile/src/core/session/context_match.dart';
import 'package:tix_mobile/src/core/session/local.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/storage/providers.dart';
import 'package:tix_mobile/src/data/cache/cache_store.dart';
import 'package:tix_mobile/src/data/models/connection.dart';
import 'package:tix_mobile/src/data/models/instance.dart';
import 'package:tix_mobile/src/data/repositories/instances_repository.dart';
import 'package:tix_mobile/src/data/repositories/settings_repository.dart';

export 'package:tix_mobile/src/core/platform/adb_commands.dart';

part 'adb_bridge.g.dart';

/// Whether `am broadcast` commands run in a release build: off until a
/// person turns it on, and kept on this device only.
@Riverpod(keepAlive: true)
class AdbControlSetting extends _$AdbControlSetting {
  /// Where it is kept.
  static const key = 'settings.adbControl';

  @override
  bool build() => ref.watch(keyValueStoreProvider).read(key) == 'true';

  /// Turns it on or off and remembers it.
  Future<void> set({required bool on}) async {
    state = on;
    final store = ref.read(keyValueStoreProvider);
    await (on ? store.write(key, 'true') : store.delete(key));
  }
}

/// Whether this platform has ADB, so Settings offers the switch.
@Riverpod(keepAlive: true)
bool adbControlOffered(Ref ref) => Platform.isAndroid;

/// Whether this is a debug build, which runs every command.
@Riverpod(keepAlive: true)
bool adbDebugBuild(Ref ref) => kDebugMode;

/// Whether this is the engine Android starts to answer ADB while the app is
/// not open: no session, no live updates, no local engine.
@Riverpod(keepAlive: true)
bool adbHeadless(Ref ref) => false;

/// How `theme` and `locale` change the app.
abstract interface class AdbAppearance {
  /// Switches to the theme [name].
  Future<void> setTheme(String name);

  /// Switches to the language [code], or the system's with null.
  Future<void> setLocale(String? code);
}

/// [AdbAppearance] through the stored settings, for an engine with no
/// screen to redraw.
class StoredAppearance implements AdbAppearance {
  /// Writes to [_settings].
  StoredAppearance(this._settings);

  final SettingsRepository _settings;

  @override
  Future<void> setTheme(String name) => _settings.setThemeMode(name);

  @override
  Future<void> setLocale(String? code) => _settings.setLanguageCode(code);
}

/// How commands change theme and language. `main` swaps in the settings
/// feature's, which redraws the app at once.
@Riverpod(keepAlive: true)
AdbAppearance adbAppearance(Ref ref) =>
    StoredAppearance(SettingsRepository(ref.watch(keyValueStoreProvider)));

/// The answering end of Android's ADB hooks (docs/adb.md): `dumpsys` asks
/// for a snapshot and `am broadcast` sends commands, both over `tix/adb`.
class AdbBridge {
  /// Answers with [actions], allowing commands when [debugBuild] or when
  /// [enabled] says the setting is on.
  AdbBridge({
    required this.actions,
    required this.enabled,
    required this.debugBuild,
    this.headless = false,
    this.channel = const MethodChannel('tix/adb'),
  });

  /// What commands do.
  final AdbActions actions;

  /// Whether Allow control over ADB is on, read for every command.
  final bool Function() enabled;

  /// Whether this is a debug build.
  final bool debugBuild;

  /// Whether this engine has no session.
  final bool headless;

  /// The channel to the platform.
  final MethodChannel channel;

  /// Answers the platform and tells it this engine is ready.
  Future<void> listen() async {
    channel.setMethodCallHandler(_handle);
    try {
      await channel.invokeMethod<void>('ready');
    } on MissingPluginException {
      log('adb: no platform side');
    }
  }

  Future<Object?> _handle(MethodCall call) async {
    final args = switch (call.arguments) {
      final Map<Object?, Object?> m => m,
      _ => const <Object?, Object?>{},
    };
    switch (call.method) {
      case 'snapshot':
        return await snapshot(args['section'] as String? ?? '');
      case 'command':
        final extras = <String, String>{
          if (args['extras'] case final Map<Object?, Object?> m)
            for (final MapEntry(:key, :value) in m.entries)
              if (key is String && value is String) key: value,
        };
        return (await run(args['cmd'] as String?, extras)).toMap();
    }
    throw MissingPluginException('tix/adb has no ${call.method}');
  }

  /// The state report for the section called [section].
  Future<String> snapshot(String section) async =>
      (await run('dump', {'section': section})).text;

  /// Runs [cmd] with [extras].
  Future<AdbReply> run(String? cmd, Map<String, String> extras) =>
      runAdbCommand(
        cmd,
        extras,
        actions: actions,
        debugBuild: debugBuild,
        enabled: enabled(),
        headless: headless,
      );

  /// Stops answering.
  void dispose() => channel.setMethodCallHandler(null);
}

/// The bridge of this engine.
@Riverpod(keepAlive: true)
AdbBridge adbBridge(Ref ref) {
  final headless = ref.watch(adbHeadlessProvider);
  final bridge = AdbBridge(
    actions: ProviderAdbActions(ref, headless: headless),
    enabled: () => ref.read(adbControlSettingProvider),
    debugBuild: ref.watch(adbDebugBuildProvider),
    headless: headless,
  );
  ref.onDispose(bridge.dispose);
  return bridge;
}

/// [AdbActions] over the app's providers, the same code the screens use.
/// A [headless] engine only reads what is stored, and never builds the
/// session, live updates or a local engine.
class ProviderAdbActions implements AdbActions {
  /// Reads through [_ref].
  ProviderAdbActions(this._ref, {required this.headless});

  final Ref _ref;

  /// Whether this engine has no session.
  final bool headless;

  InstancesRepository get _repo => _ref.read(instancesRepositoryProvider);

  @override
  Future<String> snapshot(AdbSection section) async =>
      formatAdbSnapshot(await gather(), section, secrets: await _secrets());

  Future<List<String>> _secrets() async {
    final secrets = <String>[];
    for (final c in _repo.connections()) {
      final s = await _repo.secret(c);
      if (s != null && s.isNotEmpty) secrets.add(s);
    }
    return secrets;
  }

  /// The state as `dumpsys` prints it.
  Future<AdbSnapshot> gather() async {
    final repo = _repo;
    final active = repo.active();
    final entries = savedContexts(repo);
    final settings = SettingsRepository(_ref.read(keyValueStoreProvider));
    final info = await _info();
    final live = headless ? null : _ref.read(tixEventStreamProvider);
    return AdbSnapshot(
      version: info?.version ?? 'unknown',
      build: info?.build ?? '',
      buildMode: kDebugMode
          ? 'debug'
          : kProfileMode
          ? 'profile'
          : 'release',
      headless: headless,
      theme: settings.themeMode() ?? 'system',
      locale: settings.languageCode() ?? 'system',
      control: _ref.read(adbControlSettingProvider),
      contexts: [
        for (final e in entries)
          AdbContextLine(
            id: contextKey(e),
            instance: e.instance.name,
            host: e.instance.host,
            database: e.instance.kind == InstanceKind.local
                ? baseName(e.instance.dbPath)
                : '',
            tenant: e.tenantName,
            signIn: e.connection.kind == ConnectionKind.signIn,
            active: isActiveContext(e, active),
          ),
      ],
      liveMode: live?.status.mode.name,
      liveReport: live?.diagnostics.toReport(
        app: info == null ? '' : '${info.version} (${info.build})',
        platform: info == null ? '' : '${info.platform} ${info.osVersion}',
      ),
      outbox: await _outbox(entries),
      engines: headless ? const [] : _engines(repo),
    );
  }

  Future<AppInfo?> _info() async {
    try {
      return await _ref.read(appInfoProvider.future);
    } on PlatformException catch (e) {
      log('adb: no app info: ${e.code}');
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  Future<List<AdbOutboxLine>> _outbox(List<ContextEntry> entries) async {
    final cache = _ref.read(cacheStoreProvider);
    final activeScope = headless ? null : _ref.read(activeCacheScopeProvider);
    final lines = <AdbOutboxLine>[];
    for (final e in entries) {
      final scope = CacheScope(
        e.connection.id,
        e.connection.switchable ? e.tenantKey : '',
      );
      final snap = scope == activeScope
          ? await _ref.read(syncStoreProvider).load()
          : await SyncStore.peek(cache, scope);
      if (snap == null) continue;
      int count(OutboxState s) =>
          snap.entries.where((x) => x.state == s).length;
      final open = snap.conflicts.where((r) => r.resolution == null).length;
      if (snap.entries.isEmpty && open == 0) continue;
      lines.add(
        AdbOutboxLine(
          id: contextKey(e),
          pending: count(OutboxState.pending),
          failed: count(OutboxState.failed),
          conflict: count(OutboxState.conflict),
          needsCheck: count(OutboxState.needsCheck),
          openConflicts: open,
        ),
      );
    }
    return lines;
  }

  List<AdbEngineLine> _engines(InstancesRepository repo) => [
    for (final MapEntry(key: id, value: s)
        in _ref.read(localEnginesProvider).statuses.entries)
      AdbEngineLine(
        instance: repo.instance(id)?.name ?? id,
        state: s.state.name,
        database: baseName(s.dbPath),
      ),
  ];

  Future<Session> _session() async {
    final s = await _ref.read(sessionControllerProvider.future);
    if (s == null) throw const AdbError('no context is active: sign in first');
    return s;
  }

  Future<Instance> _localInstance() async {
    final i = (await _session()).instance;
    if (i.kind != InstanceKind.local) {
      throw const AdbError('the active context is not a local instance');
    }
    return i;
  }

  @override
  Future<String> reconnect() async {
    await _session();
    final live = _ref.read(tixEventStreamProvider);
    if (live == null) throw const AdbError('no live connection to retry');
    live.retryNow();
    return 'reconnecting, was ${live.status.mode.name}';
  }

  @override
  Future<String> syncNow() async {
    await _session();
    final report = await _ref.read(outboxSyncProvider.notifier).replayNow();
    if (report == null) {
      throw const AdbError('the outbox could not be sent: see dump outbox');
    }
    if (report.unreachable) return 'server unreachable: writes stay queued';
    return 'sent ${report.sent}, ${report.conflicts} conflicts, '
        '${report.failed} refused';
  }

  @override
  Future<String> switchTo(String name) async {
    final session = await _session();
    final match = matchContext(name, savedContexts(_repo), session.ref);
    if (match.kind == ContextMatchKind.unknown) {
      throw AdbError('no context is called "$name": see dump contexts');
    }
    if (match.kind == ContextMatchKind.stay) return 'already there';
    if (match.kind == ContextMatchKind.ambiguous) {
      throw AdbError(
        '"$name" names ${match.choices.length} contexts: '
        '${match.choices.map(contextKey).join(', ')}; switch by one of these',
      );
    }
    final target = match.choices.single;
    await _ref.read(sessionControllerProvider.notifier).activate(target.ref);
    return 'switched to ${contextLabel(target)} [${contextKey(target)}]';
  }

  @override
  Future<String> quickAdd(String line, {String? project}) async {
    await _session();
    final sub = _ref.listen(tasksRepositoryProvider, (_, _) {});
    try {
      final repo = sub.read();
      final key = project ?? (await repo.projects()).items.firstOrNull?.key;
      if (key == null) {
        throw const AdbError('no project to add to: pass --es project <KEY>');
      }
      final task = await repo.quickAdd(key, oneLine(line));
      _ref.read(tasksChangedProvider.notifier).touch();
      return 'added ${task.ref} in $key';
    } finally {
      sub.close();
    }
  }

  @override
  Future<String> engineStop() async {
    final i = await _localInstance();
    await _ref.read(localEnginesProvider).rest(i.id);
    return 'stopped the engine of ${i.name} (${baseName(i.dbPath)})';
  }

  @override
  Future<String> engineStart() async {
    final i = await _localInstance();
    final engines = _ref.read(localEnginesProvider);
    await engines.ensure(i);
    final state = engines.statuses[i.id]?.state.name ?? 'stopped';
    return 'engine of ${i.name} (${baseName(i.dbPath)}): $state';
  }

  @override
  Future<String> clearCache() async {
    final s = await _session();
    await _ref.read(offlineSyncProvider.notifier).clear();
    return 'forgot the saved copies of ${s.instance.name}';
  }

  @override
  Future<String> theme(String name) async {
    await _ref.read(adbAppearanceProvider).setTheme(name);
    return 'theme: $name';
  }

  @override
  Future<String> locale(String code) async {
    await _ref
        .read(adbAppearanceProvider)
        .setLocale(code == 'system' ? null : code);
    return 'locale: $code';
  }
}
