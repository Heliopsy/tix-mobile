// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ProviderListenableSelect;
import 'package:meta/meta.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/events/events.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/data/models/project.dart';

part 'watch.g.dart';

/// How many events Watch keeps, and how many it holds while paused.
const watchCap = 500;

/// How long Watch keeps following after its screen closes, so opening a
/// task from it and coming back loses nothing.
const watchCacheFor = Duration(minutes: 5);

/// What Watch follows: projects and event types for the server, the actor
/// for the device, and where to replay from.
@immutable
class WatchQuery {
  /// A query; the defaults follow everything from now on.
  const WatchQuery({
    this.projectIds = const [],
    this.types = const [],
    this.actors = const [],
    this.since,
  });

  /// Project ids the server keeps; empty keeps every project.
  final List<String> projectIds;

  /// Event type patterns the server keeps, `task.*` for a prefix.
  final List<String> types;

  /// Actor ids or handles kept on the device, as `tix watch --actor` does.
  final List<String> actors;

  /// Replay after this sequence number; null starts from now.
  final int? since;

  /// Whether nothing narrows or replays the tail.
  bool get isEmpty =>
      projectIds.isEmpty && types.isEmpty && actors.isEmpty && since == null;

  /// The half the server applies; a change to it resubscribes.
  WatchQuery get subscription =>
      WatchQuery(projectIds: projectIds, types: types, since: since);

  /// Whether [event] passes the actor filter.
  bool keeps(TixEvent event) {
    if (actors.isEmpty) return true;
    final handle = event.payload['actor_handle'];
    return actors.any((a) {
      final want = a.startsWith('@') ? a.substring(1) : a;
      return want == event.actorId ||
          (handle is String && handle.toLowerCase() == want.toLowerCase());
    });
  }

  /// A copy with the given parts replaced; [since] takes a function so it
  /// can be cleared.
  WatchQuery copyWith({
    List<String>? projectIds,
    List<String>? types,
    List<String>? actors,
    int? Function()? since,
  }) => WatchQuery(
    projectIds: projectIds ?? this.projectIds,
    types: types ?? this.types,
    actors: actors ?? this.actors,
    since: since == null ? this.since : since(),
  );

  @override
  bool operator ==(Object other) =>
      other is WatchQuery &&
      _same(other.projectIds, projectIds) &&
      _same(other.types, types) &&
      _same(other.actors, actors) &&
      other.since == since;

  @override
  int get hashCode => Object.hash(
    Object.hashAll(projectIds),
    Object.hashAll(types),
    Object.hashAll(actors),
    since,
  );

  static bool _same(List<String> a, List<String> b) =>
      a.length == b.length &&
      Iterable<int>.generate(a.length).every((i) => a[i] == b[i]);
}

/// What Watch is narrowed to.
@riverpod
class WatchFilter extends _$WatchFilter {
  @override
  WatchQuery build() => const WatchQuery();

  /// Narrows Watch to what [edit] makes of the current query.
  void change(WatchQuery Function(WatchQuery current) edit) =>
      state = edit(state);
}

/// Where Watch's subscription stands.
enum WatchPhase {
  /// No context is active.
  idle,

  /// Subscribing; nothing acknowledged yet.
  connecting,

  /// Events arrive.
  live,

  /// The server can only be refreshed on a timer, so nothing is streamed.
  unsupported,

  /// The server refused the filter or the credential.
  refused,
}

/// Watch's events and where its subscription stands.
@immutable
class WatchState {
  /// A state; the defaults are a tail still connecting.
  const WatchState({
    this.events = const [],
    this.held = const [],
    this.paused = false,
    this.phase = WatchPhase.connecting,
    this.refusal,
    this.expiredSince,
    this.missed = false,
  });

  /// The events shown, newest first, at most [watchCap].
  final List<TixEvent> events;

  /// Events that arrived while paused, newest first, at most [watchCap].
  final List<TixEvent> held;

  /// Whether the list is held still.
  final bool paused;

  /// Where the subscription stands.
  final WatchPhase phase;

  /// Why the server refused, while [phase] is [WatchPhase.refused].
  final TailRefused? refusal;

  /// The cursor the server no longer kept, when it refused one.
  final int? expiredSince;

  /// Whether events may be missing after a reconnect without a cursor.
  final bool missed;

  /// Whether the oldest events are being dropped.
  bool get full => events.length >= watchCap;

  /// A copy with the given parts replaced.
  WatchState copyWith({
    List<TixEvent>? events,
    List<TixEvent>? held,
    bool? paused,
    WatchPhase? phase,
    TailRefused? Function()? refusal,
    int? Function()? expiredSince,
    bool? missed,
  }) => WatchState(
    events: events ?? this.events,
    held: held ?? this.held,
    paused: paused ?? this.paused,
    phase: phase ?? this.phase,
    refusal: refusal == null ? this.refusal : refusal(),
    expiredSince: expiredSince == null ? this.expiredSince : expiredSince(),
    missed: missed ?? this.missed,
  );
}

/// The active context's events as they arrive, over the connection live
/// updates already hold. Changing the projects, types or replay point
/// subscribes again; the actor filter does not.
@riverpod
class WatchFeed extends _$WatchFeed {
  @override
  WatchState build() {
    final link = ref.keepAlive();
    Timer? timer;
    ref
      ..onCancel(() => timer = Timer(watchCacheFor, link.close))
      ..onResume(() => timer?.cancel())
      ..onDispose(() => timer?.cancel());
    final query = ref.watch(watchFilterProvider.select((q) => q.subscription));
    final live = ref.watch(tixEventStreamProvider);
    if (live == null) return const WatchState(phase: WatchPhase.idle);
    final tail = live.tail(
      types: query.types,
      projectIds: query.projectIds,
      since: query.since,
    );
    final sub = tail.updates.listen(_on);
    ref.onDispose(() {
      unawaited(sub.cancel());
      unawaited(tail.close());
    });
    return const WatchState();
  }

  void _on(TailUpdate update) {
    if (!ref.mounted) return;
    final s = state;
    state = switch (update) {
      TailEvent(:final event) when s.paused => s.copyWith(
        held: _capped([event, ...s.held]),
      ),
      TailEvent(:final event) => s.copyWith(
        events: _capped([event, ...s.events]),
      ),
      TailLive() => s.copyWith(phase: WatchPhase.live, refusal: () => null),
      TailGap() => s.copyWith(missed: true),
      TailExpired(:final since) => s.copyWith(expiredSince: () => since),
      TailRefused() => s.copyWith(
        phase: WatchPhase.refused,
        refusal: () => update,
      ),
      TailUnsupported() => s.copyWith(phase: WatchPhase.unsupported),
    };
  }

  static List<TixEvent> _capped(List<TixEvent> events) =>
      events.length <= watchCap ? events : events.sublist(0, watchCap);

  /// Holds the list still; new events wait in [WatchState.held].
  void pause() => state = state.copyWith(paused: true);

  /// Puts what arrived while paused on top and follows again.
  void resume() => state = state.copyWith(
    paused: false,
    held: const [],
    events: _capped([...state.held, ...state.events]),
  );

  /// Forgets the events shown and the notices.
  void clear() => state = state.copyWith(
    events: const [],
    held: const [],
    expiredSince: () => null,
    missed: false,
  );

  /// Hides the notice about an expired cursor.
  void dismissExpired() => state = state.copyWith(expiredSince: () => null);

  /// Hides the notice about missed events.
  void dismissMissed() => state = state.copyWith(missed: false);
}

/// The events Watch shows: the feed through the actor filter.
@riverpod
List<TixEvent> watchVisible(Ref ref) {
  final query = ref.watch(watchFilterProvider);
  return ref.watch(watchFeedProvider).events.where(query.keeps).toList();
}

/// How many events the actor filter keeps of those held while paused.
@riverpod
int watchHeldCount(Ref ref) {
  final query = ref.watch(watchFilterProvider);
  return ref.watch(watchFeedProvider).held.where(query.keeps).length;
}

/// The tenant's projects, for the filter and to name a project by its id.
@riverpod
Future<List<Project>> watchProjects(Ref ref) async {
  final repo = ref.watch(projectsRepositoryProvider);
  final out = <Project>[];
  String? cursor;
  do {
    final page = await repo.all(cursor: cursor);
    out.addAll(page.items);
    cursor = page.nextCursor;
  } while (cursor != null && cursor.isNotEmpty);
  return out;
}
