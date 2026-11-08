// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:tix_mobile/l10n/generated/app_localizations.dart';
import 'package:tix_mobile/src/core/design/accent.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/logging/log.dart';
import 'package:tix_mobile/src/core/platform/widget_bridge.dart';
import 'package:tix_mobile/src/core/session/session.dart' show entriesOf;
import 'package:tix_mobile/src/core/storage/stores.dart';
import 'package:tix_mobile/src/data/api/tix_api.dart';
import 'package:tix_mobile/src/data/cache/response_cache.dart';
import 'package:tix_mobile/src/data/models/connection.dart';
import 'package:tix_mobile/src/data/models/instance.dart';
import 'package:tix_mobile/src/data/models/widget_snapshot.dart';
import 'package:tix_mobile/src/data/repositories/inbox_repository.dart';
import 'package:tix_mobile/src/data/repositories/instances_repository.dart';
import 'package:tix_mobile/src/data/repositories/settings_repository.dart';
import 'package:tix_mobile/src/data/repositories/task_list_repository.dart';
import 'package:tix_mobile/src/data/repositories/tasks_repository.dart';
import 'package:tix_mobile/src/data/repositories/tenant_repository.dart';
import 'package:tix_mobile/src/features/widgets/application/feed.dart';
import 'package:tix_mobile/src/features/widgets/application/snapshots.dart';

/// How long a widget's request stands without being renewed.
const wantedFor = Duration(days: 14);

/// A context widgets can show, and what reaches it.
@immutable
class WidgetTarget {
  /// [ctx] on [instance] through [connection].
  const WidgetTarget({
    required this.ctx,
    required this.instance,
    required this.connection,
    required this.tenantKey,
  });

  /// How widgets name it.
  final WidgetContext ctx;

  /// The instance.
  final Instance instance;

  /// The connection.
  final Connection connection;

  /// The tenant.
  final String tenantKey;

  /// Whether it is a database served on this device.
  bool get local => instance.kind == InstanceKind.local;
}

/// The widget key of the context [ref].
String widgetContextId(ContextRef ref) =>
    '${ref.connectionId}.${ref.tenantKey}';

/// Opens the repositories of [target], or answers null when it cannot be
/// reached now.
typedef FeedOpener = Future<WidgetFeed?> Function(WidgetTarget target);

/// Opens a feed for a remote [target] with its saved credential, never for
/// a local one: a widget must not start an engine. Null as well for a
/// switchable sign-in whose session sits in another tenant, and when the
/// credential cannot be read (a locked iPhone's keychain).
Future<WidgetFeed?> openStoredFeed(
  WidgetTarget target, {
  required InstancesRepository instances,
  required TixApiFactory factory,
  required CacheStore cache,
}) async {
  if (target.local) return null;
  final c = target.connection;
  if (c.switchable && target.tenantKey != c.tenantKey) return null;
  final String? secret;
  try {
    secret = await instances.secret(c);
  } on Exception catch (e) {
    log('widgets: credential unreadable: ${e.runtimeType}');
    return null;
  }
  if (secret == null || secret.isEmpty) return null;
  final credential = switch (c.kind) {
    ConnectionKind.token => BearerCredential(secret) as Credential,
    ConnectionKind.signIn => SessionCredential(secret),
  };
  final api = factory(target.instance.baseUrl, credential);
  final responses = ResponseCache(
    cache,
    CacheScope(c.id, c.switchable ? c.tenantKey : ''),
  );
  return WidgetFeed(
    tasks: TasksRepository(api, responses),
    lists: TaskListRepository(api, responses),
    inbox: InboxRepository(api, responses),
  );
}

/// Writes the widgets' snapshots and runs their queue. The foreground app
/// and the headless runner both use it; they differ in which contexts they
/// can reach.
class WidgetWriter {
  /// Writes through [bridge], reading contexts from [instances].
  WidgetWriter({
    required this.bridge,
    required this.instances,
    required this.store,
    required this.l10n,
    required this.now,
    required this.open,
  });

  /// Widget storage.
  final WidgetBridge bridge;

  /// The saved instances and connections.
  final InstancesRepository instances;

  /// Preferences: theme, privacy, remembered accents.
  final KeyValueStore store;

  /// The app's language.
  final AppLocalizations l10n;

  /// The clock.
  final DateTime Function() now;

  /// Opens a context's repositories.
  final FeedOpener open;

  /// Every saved context.
  List<WidgetTarget> targets() => [
    for (final i in instances.instances())
      for (final c in instances.connectionsOf(i.id))
        for (final e in entriesOf(i, c))
          if (e.elsewhere.isEmpty)
            WidgetTarget(
              ctx: WidgetContext(
                id: widgetContextId(e.ref),
                instance: i.name,
                tenant: e.tenantName,
                local: i.kind == InstanceKind.local,
              ),
              instance: i,
              connection: c,
              tenantKey: e.tenantKey,
            ),
  ];

  /// The active context's widget key, null when signed out.
  String? activeId() {
    final a = instances.active();
    return a == null ? null : widgetContextId(a);
  }

  Future<Object?> _json(String key) async {
    final text = await bridge.read(key);
    if (text == null || text.isEmpty) return null;
    try {
      return jsonDecode(text);
    } on FormatException {
      return null;
    }
  }

  /// What configured widgets asked for, without requests gone stale.
  Future<List<WidgetWant>> wanted() async {
    final json = await _json(WidgetKeys.wanted);
    if (json is! Map<String, dynamic>) return const [];
    final cutoff = now().subtract(wantedFor).millisecondsSinceEpoch;
    final wants = <WidgetWant>[];
    for (final v in json.values) {
      if (v is! Map<String, dynamic>) continue;
      final w = WidgetWant.fromJson(v);
      if (w.at == 0 || w.at >= cutoff) wants.add(w);
    }
    return wants;
  }

  /// The actions widgets queued.
  Future<List<WidgetAction>> queue() async {
    final json = await _json(WidgetKeys.queue);
    if (json is! List) return const [];
    return [
      for (final e in json)
        if (e is Map<String, dynamic>) WidgetAction.fromJson(e),
    ];
  }

  Future<WidgetIndex?> _index() async {
    final json = await _json(WidgetKeys.index);
    if (json is! Map<String, dynamic>) return null;
    try {
      return WidgetIndex.fromJson(json);
    } on Object catch (e) {
      log('widgets: old index unreadable: ${e.runtimeType}');
      return null;
    }
  }

  Future<void> _save(String key, Map<String, dynamic> json) =>
      bridge.save(key, jsonEncode(json));

  /// Rewrites every snapshot that [reachable] contexts allow, the index and
  /// the catalog, removes what belonged to contexts that are gone, and
  /// asks widgets to draw.
  Future<void> refresh({
    required bool Function(WidgetTarget t) reachable,
  }) async {
    if (!bridge.supported) return;
    final active = activeId();
    final all = targets();
    final wants = await wanted();
    final old = await _index();
    final projects = <String, Set<String>>{};
    void want(String ctx, [String? project]) {
      final set = projects.putIfAbsent(ctx, () => <String>{});
      if (project != null && project.isNotEmpty) set.add(project);
    }

    if (active != null) want(active);
    for (final w in wants) {
      final ctx = w.ctx == WidgetKeys.active ? active : w.ctx;
      if (ctx != null) want(ctx, w.project);
    }
    final catalog = <String, List<WidgetProject>>{
      for (final e in (old?.projects ?? const {}).entries)
        if (all.any((t) => t.ctx.id == e.key)) e.key: e.value,
    };
    for (final MapEntry(key: ctx, value: keys) in projects.entries) {
      final target = all.where((t) => t.ctx.id == ctx).firstOrNull;
      if (target == null || !reachable(target)) continue;
      final written = await _writeContext(target, keys);
      if (written != null) catalog[ctx] = written;
    }
    await _forgetGone(old, all);
    await _save(
      WidgetKeys.index,
      WidgetIndex(
        at: now().millisecondsSinceEpoch,
        active: active,
        contexts: [for (final t in all) t.ctx],
        projects: catalog,
        theme: widgetTheme(SettingsRepository(store).themeMode()),
        systemBlack: SettingsRepository(store).systemBlack(),
        lockCounts: SettingsRepository(store).widgetLockCounts(),
        strings: widgetStrings(l10n),
      ).toJson(),
    );
    await bridge.redraw();
  }

  Future<List<WidgetProject>?> _writeContext(
    WidgetTarget target,
    Set<String> keys,
  ) async {
    final feed = await open(target);
    if (feed == null) return null;
    final ctx = target.ctx.id;
    try {
      final data = await feed.load(
        ctx: target.ctx,
        accent: TixAccent.resolve(TenantRepository.rememberedIn(store, ctx)),
        projects: keys,
      );
      final snaps = WidgetSnapshots(data, l10n, now());
      await _save(WidgetKeys.myWork(ctx), snaps.myWork().toJson());
      await _save(WidgetKeys.inbox(ctx), snaps.inbox().toJson());
      for (final key in keys) {
        final project = snaps.project(key);
        if (project != null) {
          await _save(WidgetKeys.project(ctx, key), project.toJson());
        }
      }
      return snaps.catalog();
    } on TixException catch (e) {
      log('widgets: $ctx not refreshed: ${e.kind.name}');
      return null;
    }
  }

  Future<void> _forgetGone(WidgetIndex? old, List<WidgetTarget> all) async {
    if (old == null) return;
    for (final c in old.contexts) {
      if (all.any((t) => t.ctx.id == c.id)) continue;
      await bridge.save(WidgetKeys.myWork(c.id), null);
      await bridge.save(WidgetKeys.inbox(c.id), null);
      for (final p in old.projects[c.id] ?? const <WidgetProject>[]) {
        await bridge.save(WidgetKeys.project(c.id, p.key), null);
      }
    }
  }

  /// Runs the queued actions [reachable] contexts allow. Each one the
  /// server took or refused for good leaves the queue; the rest wait.
  /// Answers how many left it.
  Future<int> drain({required bool Function(WidgetTarget t) reachable}) async {
    if (!bridge.supported) return 0;
    final actions = await queue();
    if (actions.isEmpty) return 0;
    final all = targets();
    final settled = <String>{};
    final feeds = <String, WidgetFeed?>{};
    for (final a in actions) {
      final target = all.where((t) => t.ctx.id == a.ctx).firstOrNull;
      if (target == null || a.op != WidgetAction.complete) {
        settled.add(a.id);
        continue;
      }
      if (!reachable(target)) continue;
      final feed = feeds.containsKey(a.ctx)
          ? feeds[a.ctx]
          : feeds[a.ctx] = await open(target);
      if (feed == null) continue;
      final outcome = await feed.complete(a.ref);
      if (outcome != ActionOutcome.later) settled.add(a.id);
    }
    if (settled.isEmpty) return 0;
    final now = await queue();
    final left = [
      for (final a in now)
        if (!settled.contains(a.id)) a.toJson(),
    ];
    await bridge.save(WidgetKeys.queue, left.isEmpty ? null : jsonEncode(left));
    return settled.length;
  }
}
