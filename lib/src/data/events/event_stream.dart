// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:meta/meta.dart';
import 'package:tix_mobile/src/core/config/server_url.dart';
import 'package:tix_mobile/src/core/logging/log.dart';
import 'package:tix_mobile/src/data/events/event_tail.dart';
import 'package:tix_mobile/src/data/events/tix_event.dart';

export 'package:tix_mobile/src/data/events/event_tail.dart';
export 'package:tix_mobile/src/data/events/tix_event.dart';

/// One open WebSocket: text frames in, text frames out.
abstract interface class EventSocket {
  /// Frames from the server; done when the connection closes.
  Stream<Object?> get messages;

  /// Sends one text frame.
  void send(String text);

  /// Closes the connection.
  Future<void> close();

  /// The close code the other end sent, null while open or when none came.
  int? get closeCode;

  /// The close reason the other end sent, null when none came.
  String? get closeReason;
}

/// The WebSocket ended, with the close [code] and [reason] the other end
/// sent; both null when the connection simply dropped.
final class EventSocketClosed implements Exception {
  /// Reports a closed socket.
  const EventSocketClosed([this.code, this.reason]);

  /// The close code, such as 1001 or 1006.
  final int? code;

  /// The close reason.
  final String? reason;

  @override
  String toString() =>
      'the WebSocket closed${code == null ? '' : ' with $code'}'
      '${reason == null || reason!.isEmpty ? '' : ': $reason'}';
}

/// Opens a socket to [url] presenting [headers]. A refusal before the
/// upgrade throws a [WebSocketException] carrying the HTTP status.
typedef EventSocketConnector = Future<EventSocket> Function(
  Uri url,
  Map<String, String> headers,
);

/// The real connector, over `dart:io`. It pings every 25 seconds, so a
/// connection that died without a close (a phone changing networks) is
/// noticed and replaced.
Future<EventSocket> ioEventSocket(Uri url, Map<String, String> headers) async {
  final ws = await WebSocket.connect(url.toString(), headers: headers);
  ws.pingInterval = const Duration(seconds: 25);
  return _IoSocket(ws);
}

class _IoSocket implements EventSocket {
  _IoSocket(this._ws);

  final WebSocket _ws;

  @override
  Stream<Object?> get messages => _ws;

  @override
  void send(String text) => _ws.add(text);

  @override
  Future<void> close() => _ws.close();

  @override
  int? get closeCode => _ws.closeCode;

  @override
  String? get closeReason => _ws.closeReason;
}

/// How long to wait before each reconnection attempt.
@immutable
class Backoff {
  /// Doubles from [first] up to [max], plus up to [jitter] of the delay at
  /// random so a fleet of phones does not reconnect in step.
  const Backoff({
    this.first = const Duration(seconds: 1),
    this.max = const Duration(seconds: 60),
    this.jitter = 0.2,
  });

  /// The first delay.
  final Duration first;

  /// The longest delay.
  final Duration max;

  /// The random share added to each delay, from 0 to 1.
  final double jitter;

  /// The delay before attempt [attempt], counting from 1.
  Duration delay(int attempt, Random random) {
    final base = first * pow(2, min(attempt - 1, 20));
    final capped = base > max ? max : base;
    return capped * (1 + jitter * random.nextDouble());
  }
}

/// Where a [TixEventStream] stands.
enum EventStreamState {
  /// Opening the socket or waiting for the subscription to be acknowledged.
  connecting,

  /// Subscribed; events arrive as they happen.
  live,

  /// The connection dropped; another attempt is scheduled.
  retrying,

  /// The server refused this credential the stream (it lacks
  /// `event:subscribe`, or is no longer valid). No retry is made.
  unavailable,

  /// [TixEventStream.close] was called.
  closed,
}

/// What a [TixEventStream] reports.
@immutable
sealed class EventStreamUpdate {
  const EventStreamUpdate();
}

/// An event arrived, in order and once.
final class EventReceived extends EventStreamUpdate {
  /// Wraps [event].
  const EventReceived(this.event);

  /// The event.
  final TixEvent event;
}

/// Events may have been missed: the cursor was older than the server keeps,
/// or the stream reconnected without one. Anything shown should be read
/// again.
final class EventsMissed extends EventStreamUpdate {
  /// Reports a gap.
  const EventsMissed();
}

/// The stream moved to [state].
final class EventStreamStatus extends EventStreamUpdate {
  /// Reports [state], with the retry [attempt] and [retryIn] while retrying
  /// and the [error] behind it, if any.
  const EventStreamStatus(
    this.state, {
    this.attempt = 0,
    this.retryIn,
    this.error,
  });

  /// The new state.
  final EventStreamState state;

  /// Which reconnection attempt comes next, while retrying.
  final int attempt;

  /// How long until it, while retrying.
  final Duration? retryIn;

  /// What caused the move, when something did.
  final Object? error;
}

/// tix's event stream for one connection: subscribes, follows the `seq`
/// cursor, and reconnects with backoff, resuming exactly where it stopped.
///
/// Connecting starts with the first listener to [updates] and stops at
/// [close]. The cursor lives as long as this object: a fresh one starts
/// live-only, since whatever reads the events loads current data anyway.
class TixEventStream {
  /// Streams events from the server at [baseUrl], presenting the given
  /// headers, resuming after [since] when it is above 0.
  TixEventStream({
    required String baseUrl,
    required this._headers,
    this._connector = ioEventSocket,
    this._backoff = const Backoff(),
    this._types = const [],
    int since = 0,
    Random? random,
  }) : url = eventsUrl(baseUrl),
       _cursor = since,
       _random = random ?? Random() {
    _updates = StreamController<EventStreamUpdate>.broadcast(
      onListen: () {
        if (_state == EventStreamState.closed) return;
        if (_socket == null && _retry == null) unawaited(_connect());
      },
    );
  }

  /// The WebSocket address of the event stream under [baseUrl].
  static Uri eventsUrl(String baseUrl) {
    final base = Uri.parse(baseUrl);
    return base.replace(
      scheme: base.scheme == 'https' ? 'wss' : 'ws',
      path: '${withoutTrailingSlash(base.path)}/api/v1/events',
    );
  }

  /// Where the stream connects.
  final Uri url;
  final Map<String, String> _headers;
  final EventSocketConnector _connector;
  final Backoff _backoff;
  final List<String> _types;
  final Random _random;
  late final StreamController<EventStreamUpdate> _updates;

  static const _subscription = 's1';

  EventSocket? _socket;
  // Cancelled in _drop, which every path out of a connection goes through.
  // ignore: cancel_subscriptions
  StreamSubscription<Object?>? _listening;
  Timer? _retry;
  int _attempt = 0;
  int _cursor;
  bool _wasLive = false;
  bool _expired = false;
  EventStreamState _state = EventStreamState.connecting;
  final _tails = <String, EventTail>{};

  /// Every update: events, gaps and state changes.
  Stream<EventStreamUpdate> get updates => _updates.stream;

  /// The highest `seq` delivered so far, 0 before the first.
  int get cursor => _cursor;

  /// Where the stream stands.
  EventStreamState get state => _state;

  /// Skips the wait before the next attempt, such as when the app returns
  /// to the foreground. Does nothing unless a retry is pending.
  void reconnectNow() {
    if (_retry == null) return;
    _retry!.cancel();
    _retry = null;
    unawaited(_connect());
  }

  /// Subscribes [tail] on this connection as well, now if it is open and
  /// again from its cursor after every reconnect.
  void attach(EventTail tail) {
    if (tail.stopped) return;
    _tails[tail.id] = tail;
    _socket?.send(jsonEncode(tail.subscribeFrame()));
  }

  /// Ends [tail]'s subscription on this connection.
  void detach(EventTail tail) {
    if (_tails.remove(tail.id) == null) return;
    _socket?.send(jsonEncode({'type': 'unsubscribe', 'id': tail.id}));
  }

  /// Closes the socket and the stream. Nothing reconnects after this.
  Future<void> close() async {
    _set(EventStreamState.closed);
    _retry?.cancel();
    _retry = null;
    await _drop();
    await _updates.close();
  }

  void _set(EventStreamState state, {Object? error, Duration? retryIn}) {
    _state = state;
    if (_updates.isClosed) return;
    _updates.add(
      EventStreamStatus(
        state,
        attempt: _attempt,
        retryIn: retryIn,
        error: error,
      ),
    );
  }

  Future<void> _connect() async {
    _set(EventStreamState.connecting);
    final EventSocket socket;
    try {
      socket = await _connector(url, _headers);
    } on WebSocketException catch (e) {
      final status = e.httpStatusCode;
      if (status == 401 || status == 403) {
        _set(EventStreamState.unavailable, error: e);
        return;
      }
      _scheduleRetry(e);
      return;
    } on IOException catch (e) {
      _scheduleRetry(e);
      return;
    } on TimeoutException catch (e) {
      _scheduleRetry(e);
      return;
    }
    if (_state == EventStreamState.closed) {
      await socket.close();
      return;
    }
    _socket = socket;
    _listening = socket.messages.listen(
      _onMessage,
      onError: _lost,
      onDone: () =>
          _lost(EventSocketClosed(socket.closeCode, socket.closeReason)),
    );
    _subscribe(resume: true);
    for (final tail in _tails.values) {
      socket.send(jsonEncode(tail.subscribeFrame()));
    }
  }

  void _subscribe({required bool resume}) {
    _socket?.send(
      jsonEncode({
        'type': 'subscribe',
        'id': _subscription,
        if (resume && _cursor > 0) 'since_seq': _cursor,
        if (_types.isNotEmpty) 'filter': {'types': _types},
      }),
    );
  }

  void _onMessage(Object? frame) {
    if (frame is! String) return;
    final Map<String, Object?> msg;
    try {
      msg = jsonDecode(frame) as Map<String, Object?>;
    } on FormatException {
      log('event stream: unreadable frame');
      return;
    }
    final id = msg['id'];
    if (id is String && id != _subscription) {
      final tail = _tails[id];
      if (tail != null) _onTail(tail, msg);
      return;
    }
    switch (msg['type']) {
      case 'subscribed':
        final resumed = msg['since_seq'] != null || _cursor > 0;
        if ((_wasLive && !resumed) || _expired) {
          _updates.add(const EventsMissed());
        }
        _expired = false;
        _wasLive = true;
        _attempt = 0;
        _set(EventStreamState.live);
      case 'event':
        final raw = msg['event'];
        if (raw is! Map<String, Object?>) return;
        final event = TixEvent.fromJson(raw);
        if (event.seq <= _cursor) return;
        _cursor = event.seq;
        _updates.add(EventReceived(event));
      case 'error':
        _onError(msg['error']);
    }
  }

  void _onTail(EventTail tail, Map<String, Object?> msg) {
    switch (msg['type']) {
      case 'subscribed':
        tail.subscribed();
      case 'event':
        final raw = msg['event'];
        if (raw is Map<String, Object?>) tail.deliver(TixEvent.fromJson(raw));
      case 'error':
        final body = msg['error'] is Map
            ? msg['error']! as Map
            : const <String, Object?>{};
        final code = body['code'] is String ? body['code'] as String : '';
        final message = body['message'] is String
            ? body['message'] as String
            : '';
        if (code == 'invalid' && message.contains('no longer available')) {
          tail.expired();
          _socket?.send(jsonEncode(tail.subscribeFrame()));
          return;
        }
        _tails.remove(tail.id);
        tail.refused(code: code, message: message);
    }
  }

  void _onError(Object? error) {
    final body = error is Map ? error : const <String, Object?>{};
    final code = body['code'];
    final message = body['message'] is String ? body['message'] as String : '';
    if (code == 'invalid' && message.contains('no longer available')) {
      // The acknowledgement of this live-only subscription reports the gap.
      _cursor = 0;
      _expired = true;
      _subscribe(resume: false);
      return;
    }
    log('event stream refused: $code $message');
    _set(EventStreamState.unavailable, error: error);
    unawaited(_drop());
  }

  void _lost(Object? error) {
    if (_state == EventStreamState.closed ||
        _state == EventStreamState.unavailable) {
      return;
    }
    unawaited(_drop());
    _scheduleRetry(error);
  }

  void _scheduleRetry(Object? error) {
    if (_state == EventStreamState.closed) return;
    _attempt++;
    final wait = _backoff.delay(_attempt, _random);
    _set(EventStreamState.retrying, error: error, retryIn: wait);
    _retry = Timer(wait, () {
      _retry = null;
      unawaited(_connect());
    });
  }

  Future<void> _drop() async {
    final listening = _listening;
    final socket = _socket;
    _listening = null;
    _socket = null;
    await listening?.cancel();
    await socket?.close();
  }
}
