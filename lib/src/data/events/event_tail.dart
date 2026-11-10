// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:meta/meta.dart';
import 'package:tix_mobile/src/data/events/tix_event.dart';

/// What an [EventTail] reports.
@immutable
sealed class TailUpdate {
  const TailUpdate();
}

/// An event matching the tail's filter, once and in `seq` order.
final class TailEvent extends TailUpdate {
  /// Wraps [event].
  const TailEvent(this.event);

  /// The event.
  final TixEvent event;
}

/// The server acknowledged the subscription, or answered a poll: events
/// arrive from here on.
final class TailLive extends TailUpdate {
  /// Reports the tail live.
  const TailLive();
}

/// The tail resubscribed without a cursor after having been live, so events
/// in between may be missing.
final class TailGap extends TailUpdate {
  /// Reports a possible gap.
  const TailGap();
}

/// The server no longer keeps the events after [since]; the tail carries on
/// from the newest event.
final class TailExpired extends TailUpdate {
  /// Reports that the cursor [since] was refused as too old.
  const TailExpired(this.since);

  /// The cursor the server refused.
  final int since;
}

/// The server refused the tail: its filter, or this credential. [code] is
/// tix's error code (`invalid`, `forbidden`, `unauthenticated`), [message]
/// its reason when it gave one.
final class TailRefused extends TailUpdate {
  /// Reports a refusal.
  const TailRefused({required this.code, this.message = ''});

  /// tix's error code.
  final String code;

  /// The server's reason.
  final String message;

  /// Whether the credential, not the filter, was refused.
  bool get credential => code == 'forbidden' || code == 'unauthenticated';
}

/// The server can only be refreshed on a timer, so no tail can be served
/// until the WebSocket or polling works again.
final class TailUnsupported extends TailUpdate {
  /// Reports that the tail cannot be served.
  const TailUnsupported();
}

/// One filtered view of the event log over the connection live updates
/// already hold, with its own cursor: what `tix watch` follows.
///
/// `LiveEvents` makes them and the transports feed them; whoever reads
/// [updates] calls [close] when done.
class EventTail {
  /// A tail named [id] for [types] and [projectIds], resuming after [since].
  EventTail({
    required this.id,
    this.types = const [],
    this.projectIds = const [],
    int since = 0,
    this._onClose,
  }) : _cursor = since;

  /// The subscription id on the socket.
  final String id;

  /// Event type patterns the server keeps; empty keeps every type.
  final List<String> types;

  /// Project ids the server keeps; empty keeps every project.
  final List<String> projectIds;

  final void Function(EventTail tail)? _onClose;
  // Single subscription, so what happens before the reader listens, such
  // as a refusal while subscribing, waits for it.
  final _updates = StreamController<TailUpdate>();
  int _cursor;
  var _wasLive = false;
  var _expired = false;
  var _stopped = false;
  int _subscribedFrom = 0;

  /// Events, acknowledgements, gaps and refusals, for one reader.
  Stream<TailUpdate> get updates => _updates.stream;

  /// The highest `seq` delivered or read past, 0 before any.
  int get cursor => _cursor;

  /// Whether the server refused it or it was closed: nothing feeds it again.
  bool get stopped => _stopped;

  /// The subscribe frame for it, resuming from its cursor.
  @internal
  Map<String, Object?> subscribeFrame() {
    _subscribedFrom = _cursor;
    return {
      'type': 'subscribe',
      'id': id,
      if (_cursor > 0) 'since_seq': _cursor,
      if (types.isNotEmpty || projectIds.isNotEmpty)
        'filter': {
          if (types.isNotEmpty) 'types': types,
          if (projectIds.isNotEmpty) 'project_ids': projectIds,
        },
    };
  }

  /// The server acknowledged the subscription sent by [subscribeFrame].
  @internal
  void subscribed() {
    if (_wasLive && _subscribedFrom == 0 && !_expired) _add(const TailGap());
    _expired = false;
    _wasLive = true;
    _add(const TailLive());
  }

  /// Hands [event] on unless it is at or before the cursor.
  @internal
  void deliver(TixEvent event) {
    if (event.seq <= _cursor) return;
    _cursor = event.seq;
    _add(TailEvent(event));
  }

  /// A poll answered [events] and read up to [nextSeq].
  @internal
  void polled(List<TixEvent> events, int nextSeq) {
    if (!_wasLive) {
      _wasLive = true;
      _add(const TailLive());
    }
    events.forEach(deliver);
    if (nextSeq > _cursor) _cursor = nextSeq;
  }

  /// The server refused the cursor as too old; the tail starts again from
  /// the newest event.
  @internal
  void expired() {
    final since = _cursor;
    _cursor = 0;
    _expired = true;
    _add(TailExpired(since));
  }

  /// The server refused the tail; nothing feeds it again.
  @internal
  void refused({required String code, String message = ''}) {
    _stopped = true;
    _add(TailRefused(code: code, message: message));
  }

  /// The whole connection was refused; the tail waits for it to come back.
  @internal
  void connectionRefused({required String code, String message = ''}) =>
      _add(TailRefused(code: code, message: message));

  /// The connection can only refresh on a timer.
  @internal
  void unsupported() => _add(const TailUnsupported());

  /// Ends the tail and its subscription.
  Future<void> close() async {
    if (_updates.isClosed) return;
    _stopped = true;
    _onClose?.call(this);
    // Completes only once a reader has seen it, which may be never.
    unawaited(_updates.close());
  }

  void _add(TailUpdate update) {
    if (!_updates.isClosed) _updates.add(update);
  }
}
