// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/events/events.dart';

/// Which event types touch which data: the table a provider picks from when
/// it calls [refreshOn]. A provider names what it reads, not who writes it.
abstract final class EventTopics {
  /// A task's own fields, state, star, snooze or claim changed, or it was
  /// created or deleted.
  static const tasks = {'task.*'};

  /// A task's claim began or ended, which changes the lease a new claim
  /// would get.
  static const claims = {
    'task.claimed',
    'task.released',
    'task.lease_expired',
    'task.reclaimed',
  };

  /// Anything shown on a task's page: the task and what hangs off it.
  static const taskDetail = {
    'task.*',
    'comment.added',
    'comment.reacted',
    'comment.unreacted',
    'artifact.added',
    'dependency.added',
    'tag.added',
  };

  /// Comments on a task.
  static const comments = {
    'comment.added',
    'comment.reacted',
    'comment.unreacted',
  };

  /// Artifacts on a task.
  static const artifacts = {'artifact.added'};

  /// Dependencies between tasks.
  static const dependencies = {'dependency.added'};

  /// Tags, which also change task rows.
  static const tags = {'tag.added'};

  /// Projects.
  static const projects = {'project.*'};

  /// Workflows and the states tasks move through.
  static const workflows = {'workflow.updated'};

  /// Custom field definitions.
  static const fields = {'field.updated'};

  /// Saved filters.
  static const filters = {'filter.*'};

  /// How views are grouped and ordered.
  static const views = {'view.arranged'};

  /// The inbox and its unread count.
  static const inbox = {'inbox.updated'};

  /// Task templates.
  static const templates = {'template.updated'};

  /// A finished import, which can change anything.
  static const imports = {'import.completed'};

  /// Webhook deliveries.
  static const webhooks = {'webhook.delivered'};

  /// Users, memberships and invites.
  static const people = {'user.*', 'member.*', 'user_invite.*'};

  /// API tokens.
  static const tokens = {'token.*'};

  /// The caller's calendar feed.
  static const calendar = {'calendar_feed.*'};
}

/// Refreshes the provider building with [ref] when an event matching one of
/// [patterns] (and [where], if given) arrives on the active context's
/// stream, and whenever the stream reports it may have missed events.
///
/// Call it in `build`. Events arriving within [debounce] of each other cause
/// one refresh, so a bulk action of fifty tasks reloads a list once. The
/// listener ends with the build that registered it.
void refreshOn(
  Ref ref,
  Set<String> patterns, {
  bool Function(TixEvent event)? where,
  Duration debounce = const Duration(milliseconds: 300),
}) {
  onEvents(
    ref,
    patterns,
    where: where,
    debounce: debounce,
    (_) => ref.invalidateSelf(),
  );
}

/// Calls [handle] with the events matching [patterns] (and [where]) that
/// arrived within [debounce] of each other, for a provider that patches its
/// state instead of reloading. A possible gap calls [handle] with an empty
/// list: read everything again then.
void onEvents(
  Ref ref,
  Set<String> patterns,
  void Function(List<TixEvent> events) handle, {
  bool Function(TixEvent event)? where,
  Duration debounce = const Duration(milliseconds: 300),
}) {
  final stream = ref.read(tixEventStreamProvider);
  if (stream == null) return;
  final pending = <TixEvent>[];
  var gap = false;
  Timer? timer;
  void flush() {
    timer = null;
    if (!ref.mounted) return;
    final batch = gap ? const <TixEvent>[] : List<TixEvent>.of(pending);
    pending.clear();
    gap = false;
    handle(batch);
  }

  final sub = stream.updates.listen((update) {
    switch (update) {
      case EventReceived(:final event):
        if (!patterns.any((p) => TixEventTypes.matches(p, event.type))) return;
        if (where != null && !where(event)) return;
        pending.add(event);
      case EventsMissed():
        gap = true;
      case EventStreamStatus():
        return;
    }
    timer ??= Timer(debounce, flush);
  });
  ref.onDispose(() {
    timer?.cancel();
    unawaited(sub.cancel());
  });
}
