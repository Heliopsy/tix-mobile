// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/desktop/desktop_state.dart';
import 'package:tix_mobile/src/core/events/events.dart';
import 'package:tix_mobile/src/core/offline/outbox.dart';
import 'package:tix_mobile/src/core/offline/sync.dart';
import 'package:tix_mobile/src/core/platform/desktop.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/time/times.dart';
import 'package:tix_mobile/src/data/cache/cache_store.dart';
import 'package:tix_mobile/src/data/models/connection.dart';
import 'package:tix_mobile/src/data/models/instance.dart';

part 'tray_status.g.dart';

/// How long the tray waits between two hover text updates.
const trayStatusThrottle = Duration(seconds: 2);

/// How often the hover text is rebuilt so relative times move on.
const trayStatusRefresh = Duration(minutes: 1);

/// The most instances the hover text lists before it counts the rest.
const trayStatusMaxInstances = 3;

/// How the active instance reaches its server, as the tray says it.
enum TrayLink {
  /// Following live updates.
  live,

  /// Opening live updates.
  connecting,

  /// An offline sync is running.
  syncing,

  /// The server cannot be reached.
  offline,

  /// Nothing worth saying.
  idle,
}

/// One instance as the tray reports it.
@immutable
class TrayInstance {
  /// An instance called [name], at [host] or local.
  const TrayInstance({
    required this.name,
    this.host = '',
    this.local = false,
    this.link,
    this.syncedAt,
    this.queued = 0,
  });

  /// Its name.
  final String name;

  /// Its host, empty for a local instance.
  final String host;

  /// Whether it is a database on this device.
  final bool local;

  /// How it is connected; null for an instance that is not active.
  final TrayLink? link;

  /// When its saved copy last synced, null when it never has.
  final DateTime? syncedAt;

  /// Changes waiting in its outbox.
  final int queued;

  @override
  bool operator ==(Object other) =>
      other is TrayInstance &&
      other.name == name &&
      other.host == host &&
      other.local == local &&
      other.link == link &&
      other.syncedAt == syncedAt &&
      other.queued == queued;

  @override
  int get hashCode => Object.hash(name, host, local, link, syncedAt, queued);
}

/// Everything the tray's hover text says, before it is put into words.
@immutable
class TrayStatus {
  /// A status for [instances], the active one first.
  const TrayStatus({
    this.signedIn = false,
    this.instances = const [],
    this.unread,
  });

  /// Whether a context is active.
  final bool signedIn;

  /// The instances, the active one first.
  final List<TrayInstance> instances;

  /// The active context's unread inbox count, null before it is known.
  final int? unread;

  @override
  bool operator ==(Object other) =>
      other is TrayStatus &&
      other.signedIn == signedIn &&
      listEquals(other.instances, instances) &&
      other.unread == unread;

  @override
  int get hashCode => Object.hash(signedIn, Object.hashAll(instances), unread);
}

/// The tray's hover text for [status] at [now], in the words of [times].
TrayTooltip trayTooltip(TixTimes times, TrayStatus status, DateTime now) {
  final l10n = times.l10n;
  if (!status.signedIn) return TrayTooltip(l10n.trayStatusSignedOut);
  final shown = status.instances.take(trayStatusMaxInstances);
  final more = status.instances.length - shown.length;
  final unread = status.unread ?? 0;
  return TrayTooltip(
    l10n.trayStatusHeadline(status.instances.length),
    details: [
      for (final i in shown) _line(times, i, now),
      if (more > 0) l10n.trayStatusMore(more),
    ],
    footer: unread > 0 ? l10n.trayStatusUnread(unread) : null,
  );
}

String _line(TixTimes times, TrayInstance i, DateTime now) {
  final l10n = times.l10n;
  final place = i.local ? l10n.trayStatusLocal : i.host;
  final syncedAt = i.syncedAt;
  final state = [
    ?switch (i.link) {
      TrayLink.offline => l10n.trayStatusOffline,
      TrayLink.syncing => l10n.trayStatusSyncing,
      _ when syncedAt != null => l10n.trayStatusSynced(
        times.ago(syncedAt, now: now),
      ),
      TrayLink.live => l10n.trayStatusLive,
      TrayLink.connecting => l10n.trayStatusConnecting,
      TrayLink.idle || null => null,
    },
    if (i.queued > 0) l10n.trayStatusQueued(i.queued),
  ].join(', ');
  if (place.isEmpty && state.isEmpty) return i.name;
  if (state.isEmpty) return l10n.trayStatusInstanceQuiet(i.name, place);
  return l10n.trayStatusInstance(i.name, place, state);
}

/// [mode] of the active instance as the tray says it.
TrayLink trayLink(
  LiveMode? mode, {
  required bool syncing,
  required bool offline,
}) {
  if (offline || mode == LiveMode.offline) return TrayLink.offline;
  if (syncing) return TrayLink.syncing;
  return switch (mode) {
    LiveMode.websocket ||
    LiveMode.polling ||
    LiveMode.refreshing => TrayLink.live,
    LiveMode.connecting => TrayLink.connecting,
    _ => TrayLink.idle,
  };
}

CacheScope _scopeOf(Connection c) =>
    CacheScope(c.id, c.switchable ? c.tenantKey : '');

/// What the tray's hover text says about the saved instances, the active
/// context's connection, sync and outbox, and its unread count; null while
/// the session loads.
@riverpod
TrayStatus? trayStatus(Ref ref) {
  final loaded = ref.watch(sessionControllerProvider);
  if (!loaded.hasValue) return null;
  final session = loaded.value;
  if (session == null) return const TrayStatus();
  final groups = ref.watch(contextDirectoryProvider).groups;
  final prefs = ref.watch(offlinePrefsRepositoryProvider);
  final sync = ref.watch(offlineSyncProvider);
  final active = TrayInstance(
    name: session.instance.name,
    host: session.instance.host,
    local: session.instance.kind == InstanceKind.local,
    link: trayLink(
      ref.watch(liveStatusProvider).value?.mode,
      syncing: sync.running,
      offline: ref.watch(serverOfflineProvider),
    ),
    syncedAt: sync.lastSyncedAt,
    queued: ref.watch(syncStateProvider).value?.entries.length ?? 0,
  );
  DateTime? lastSynced(InstanceGroup g) {
    DateTime? last;
    for (final c in g.connections) {
      final at = prefs.syncedAt(_scopeOf(c));
      if (at != null && (last == null || at.isAfter(last))) last = at;
    }
    return last;
  }

  return TrayStatus(
    signedIn: true,
    instances: [
      active,
      for (final g in groups)
        if (g.instance.id != session.instance.id)
          TrayInstance(
            name: g.instance.name,
            host: g.instance.host,
            local: g.instance.kind == InstanceKind.local,
            syncedAt: lastSynced(g),
          ),
    ],
    unread: ref.watch(trayUnreadProvider),
  );
}
