// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:tix_mobile/src/core/errors/tix_exception.dart';
import 'package:tix_mobile/src/core/logging/log.dart';
import 'package:tix_mobile/src/data/events/event_poll.dart';
import 'package:tix_mobile/src/data/events/event_stream.dart';
import 'package:tix_mobile/src/data/events/live_diagnostics.dart';

export 'package:tix_mobile/src/data/events/event_poll.dart';
export 'package:tix_mobile/src/data/events/event_stream.dart';
export 'package:tix_mobile/src/data/events/live_diagnostics.dart';

/// How live updates reach the app right now.
enum LiveMode {
  /// Opening the WebSocket, or opening it again after a drop.
  connecting,

  /// Subscribed over the WebSocket.
  websocket,

  /// The WebSocket kept failing; following the log by long polling.
  polling,

  /// Neither works on this server (it has no poll endpoint), so what is on
  /// screen is read again on a timer.
  refreshing,

  /// The server cannot be reached; retrying.
  offline,

  /// The server refused this credential live updates. No retry is made.
  unavailable,

  /// Asleep with the local engine that serves them: nothing is attempted
  /// until [LiveEvents.wake].
  paused,

  /// [LiveEvents.close] was called.
  closed,
}

/// Where [LiveEvents] stands, and the last thing that went wrong.
@immutable
class LiveStatus {
  /// Reports [mode], keeping [lastError] for diagnostics.
  const LiveStatus(this.mode, {this.lastError});

  /// The mode.
  final LiveMode mode;

  /// The most recent failure, kept after recovering from it.
  final Object? lastError;

  @override
  bool operator ==(Object other) =>
      other is LiveStatus &&
      other.mode == mode &&
      identical(other.lastError, lastError);

  @override
  int get hashCode => Object.hash(mode, identityHashCode(lastError));

  @override
  String toString() => 'LiveStatus(${mode.name}, $lastError)';
}

/// The thresholds and timings of [LiveEvents].
@immutable
class LiveConfig {
  /// The defaults are the ones docs/architecture.md lists.
  const LiveConfig({
    this.failuresBeforeFallback = 3,
    this.failureWindow = const Duration(minutes: 2),
    this.socketBackoff = const Backoff(),
    this.probeEvery = const Duration(minutes: 2),
    this.probeJitter = 1.5,
    this.pollWait = const Duration(seconds: 25),
    this.pollLimit = 200,
    this.pollBackoff = const Backoff(),
    this.refreshEvery = const Duration(seconds: 45),
    this.historySize = 20,
  });

  /// WebSocket failures within [failureWindow] that switch to polling.
  final int failuresBeforeFallback;

  /// How long a WebSocket failure counts.
  final Duration failureWindow;

  /// The WebSocket's own reconnection delays.
  final Backoff socketBackoff;

  /// The shortest wait between background WebSocket attempts while polling
  /// or refreshing.
  final Duration probeEvery;

  /// The random share added to [probeEvery]: 1.5 makes 2 minutes 2 to 5.
  final double probeJitter;

  /// How long the server may hold a poll waiting for an event.
  final Duration pollWait;

  /// Events asked for per poll.
  final int pollLimit;

  /// Delays between polls that failed.
  final Backoff pollBackoff;

  /// How often what is on screen is read again without a poll endpoint.
  final Duration refreshEvery;

  /// How many mode changes and failures [LiveDiagnostics.history] keeps.
  final int historySize;
}

/// Live updates for one connection: the WebSocket first, long polling when
/// it keeps failing, periodic refresh on a server that cannot be polled,
/// and back to the WebSocket when it works again.
///
/// It owns the cursor, so every event is delivered once and in order
/// whichever transport carried it. [updates] carries the same
/// [EventReceived] and [EventsMissed] as [TixEventStream]; [statuses]
/// carries the mode.
class LiveEvents {
  /// Follows the server at the given base URL with the given headers over
  /// the WebSocket, and with the given poller over HTTP.
  LiveEvents({
    required this._baseUrl,
    required this._headers,
    required this._poller,
    this._connector = ioEventSocket,
    this.config = const LiveConfig(),
    this._types = const [],
    this.onRefresh,
    Random? random,
    this._now = DateTime.now,
  }) : _random = random ?? Random() {
    _updates = StreamController<EventStreamUpdate>.broadcast(onListen: _start);
    _statuses = StreamController<LiveStatus>.broadcast(onListen: _start);
    _diagnostics = StreamController<LiveDiagnostics>.broadcast(
      onListen: _start,
    );
    _modeSince = _now();
  }

  /// The thresholds and timings in use.
  final LiveConfig config;

  /// Called before each timed refresh reports its gap, so a local engine can
  /// tell the reads that follow from the person's own.
  final void Function()? onRefresh;
  final String _baseUrl;
  final Map<String, String> _headers;
  final EventPoller _poller;
  final EventSocketConnector _connector;
  final List<String> _types;
  final Random _random;
  final DateTime Function() _now;
  late final StreamController<EventStreamUpdate> _updates;
  late final StreamController<LiveStatus> _statuses;
  late final StreamController<LiveDiagnostics> _diagnostics;

  var _started = false;
  var _asleep = false;
  var _awake = true;
  var _hadLive = false;
  var _pollUnsupported = false;
  LiveTransport _transport = LiveTransport.none;
  LiveMode _mode = LiveMode.connecting;
  Object? _lastError;
  var _cursor = 0;

  late DateTime _modeSince;
  DateTime? _lastContactAt;
  DateTime? _lastEventAt;
  var _consecutiveFailures = 0;
  LiveError? _lastErrorInfo;
  DateTime? _nextRetryAt;
  DateTime? _nextProbeAt;
  final _history = <LiveLogEntry>[];

  TixEventStream? _socket;
  StreamSubscription<EventStreamUpdate>? _socketSub;
  final _failures = <Timer>[];

  TixEventStream? _probe;
  StreamSubscription<EventStreamUpdate>? _probeSub;
  Timer? _probeTimer;

  CancelToken? _pollCancel;
  Timer? _pollTimer;
  var _pollAttempt = 0;
  late Duration _pollWait = config.pollWait;
  var _pollFresh = false;

  Timer? _refreshTimer;

  /// Every event once in `seq` order, and every possible gap.
  Stream<EventStreamUpdate> get updates => _updates.stream;

  /// Each change of [status].
  Stream<LiveStatus> get statuses => _statuses.stream;

  /// The mode and the last error.
  LiveStatus get status => LiveStatus(_mode, lastError: _lastError);

  /// The highest `seq` seen, 0 before the first.
  int get cursor => _cursor;

  /// Each change of [diagnostics].
  Stream<LiveDiagnostics> get diagnosticsChanges => _diagnostics.stream;

  /// Why live updates are in their mode, without a credential.
  LiveDiagnostics get diagnostics => LiveDiagnostics(
    mode: _mode,
    transport: _transport,
    host: hostOf(_baseUrl),
    modeSince: _modeSince,
    lastContactAt: _lastContactAt,
    lastEventAt: _lastEventAt,
    consecutiveFailures: _consecutiveFailures,
    windowFailures: _failures.length,
    failuresBeforeFallback: config.failuresBeforeFallback,
    failureWindow: config.failureWindow,
    pollUnsupported: _pollUnsupported,
    lastError: _lastErrorInfo,
    nextRetryAt: _nextRetryAt,
    nextProbeAt: _nextProbeAt,
    cursor: _cursor,
    history: List.unmodifiable(_history),
  );

  /// Tries the WebSocket at once, whatever the mode, as when the person
  /// asks to reconnect: also after a refusal, which is otherwise final.
  /// Does nothing while asleep or closed.
  void retryNow() {
    if (!_started || _asleep || _mode == LiveMode.closed) return;
    if (_transport != LiveTransport.none) {
      reconnectNow();
      return;
    }
    _awake = true;
    _nextRetryAt = null;
    _set(LiveMode.connecting);
    if (_cursor == 0 && _hadLive) _gap();
    _transport = LiveTransport.websocket;
    _socket = _openStream(since: _cursor, probe: false);
  }

  /// Retries whatever is waiting at once, such as when the app returns to
  /// the foreground or the network comes back. Ends a [pause].
  void reconnectNow() {
    if (!_started || _transport == LiveTransport.none) return;
    final wasAsleep = !_awake;
    _awake = true;
    switch (_transport) {
      case LiveTransport.websocket:
        _socket?.reconnectNow();
      case LiveTransport.poll:
        if (wasAsleep || _pollTimer != null) _schedulePoll(Duration.zero);
        _probeNow();
      case LiveTransport.refresh:
        _gap();
        _scheduleRefresh();
        _probeNow();
      case LiveTransport.none:
        break;
    }
  }

  /// Stops polling, refreshing and probing until [reconnectNow], cancelling
  /// a poll in flight: a phone app in the background. The WebSocket is left
  /// to the platform, as before.
  void pause() {
    if (!_awake) return;
    _awake = false;
    _stopPolling();
    _stopRefreshing();
    _probeTimer?.cancel();
    _probeTimer = null;
    unawaited(_dropProbe());
  }

  /// Stops everything until [wake]: the WebSocket closes and nothing is
  /// polled, refreshed or retried. For a local engine that stopped, which
  /// any attempt would only fail against or start again.
  void sleep() {
    if (_asleep || _mode == LiveMode.closed || _mode == LiveMode.unavailable) {
      return;
    }
    _asleep = true;
    _set(LiveMode.paused);
    unawaited(_stopAll());
  }

  /// Ends a [sleep]: the WebSocket again, from the cursor.
  void wake() {
    if (!_asleep) return;
    _asleep = false;
    _awake = true;
    _set(LiveMode.connecting);
    if (!_started) return;
    if (_cursor == 0 && _hadLive) _gap();
    _transport = LiveTransport.websocket;
    _socket = _openStream(since: _cursor, probe: false);
  }

  /// Stops everything. Nothing reconnects after this.
  Future<void> close() async {
    if (_mode == LiveMode.closed) return;
    _set(LiveMode.closed);
    await _stopAll();
    await _updates.close();
    await _statuses.close();
    await _diagnostics.close();
  }

  void _start() {
    if (_started || _mode == LiveMode.closed) return;
    _started = true;
    if (_asleep) return;
    _transport = LiveTransport.websocket;
    _socket = _openStream(since: _cursor, probe: false);
  }

  TixEventStream _openStream({required int since, required bool probe}) {
    final stream = TixEventStream(
      baseUrl: _baseUrl,
      headers: _headers,
      connector: _connector,
      backoff: config.socketBackoff,
      types: _types,
      since: since,
      random: _random,
    );
    // Kept in _socketSub or _probeSub and cancelled in _closeSocket or
    // _dropProbe.
    // ignore: cancel_subscriptions
    final sub = stream.updates.listen((u) => _onSocket(stream, since, u));
    if (probe) {
      _probeSub = sub;
    } else {
      _socketSub = sub;
    }
    return stream;
  }

  void _onSocket(TixEventStream stream, int since, EventStreamUpdate update) {
    final isProbe = identical(stream, _probe);
    if (!isProbe && !identical(stream, _socket)) return;
    switch (update) {
      case EventReceived(:final event):
        _deliver(event);
      case EventsMissed():
        _gap();
      case EventStreamStatus(:final state, :final error, :final retryIn):
        switch (state) {
          case EventStreamState.live:
            if (isProbe) _adoptProbe(since);
            _hadLive = true;
            _succeeded();
            _set(LiveMode.websocket);
          case EventStreamState.retrying:
          case EventStreamState.unavailable when isProbe:
            if (isProbe) {
              _probeFailed(error);
            } else {
              _socketFailed(error, retryIn);
            }
          case EventStreamState.unavailable:
            _refused(error);
          case EventStreamState.connecting:
          case EventStreamState.closed:
            break;
        }
    }
  }

  void _socketFailed(Object? error, Duration? retryIn) {
    _consecutiveFailures++;
    _nextRetryAt = retryIn == null ? null : _now().add(retryIn);
    _record(error, LiveErrorSource.websocket);
    late final Timer expiry;
    expiry = Timer(config.failureWindow, () {
      _failures.remove(expiry);
      _changed();
    });
    _failures.add(expiry);
    if (_failures.length >= config.failuresBeforeFallback) {
      unawaited(_fallBack());
      return;
    }
    _set(_isNetwork(error) ? LiveMode.offline : LiveMode.connecting);
    _changed();
  }

  Future<void> _fallBack() async {
    log('live: the WebSocket failed ${_failures.length} times, falling back');
    _clearFailures();
    final socket = _closeSocket();
    _nextRetryAt = null;
    if (_pollUnsupported) {
      _startRefreshing();
    } else {
      _transport = LiveTransport.poll;
      _pollFresh = true;
      _pollAttempt = 0;
      _set(LiveMode.polling);
      _schedulePoll(Duration.zero);
    }
    _scheduleProbe();
    await socket;
  }

  void _schedulePoll(Duration wait) {
    _pollTimer?.cancel();
    _pollTimer = null;
    if (_transport != LiveTransport.poll || !_awake || _pollCancel != null) {
      return;
    }
    _pollTimer = Timer(wait, () {
      _pollTimer = null;
      unawaited(_poll());
    });
  }

  Future<void> _poll() async {
    if (_transport != LiveTransport.poll || !_awake || _pollCancel != null) {
      return;
    }
    final cancel = CancelToken();
    _pollCancel = cancel;
    final since = _cursor;
    try {
      final page = await _poller.poll(
        sinceSeq: since,
        types: _types,
        wait: _pollWait,
        limit: config.pollLimit,
        cancel: cancel,
      );
      if (cancel.isCancelled) return;
      _pollCancel = null;
      _polled(page, since);
    } on EventPollUnsupported {
      if (cancel.isCancelled) return;
      _pollCancel = null;
      log('live: the server cannot be polled, refreshing on a timer');
      _succeeded();
      _pollUnsupported = true;
      _startRefreshing();
    } on TixException catch (e) {
      if (cancel.isCancelled) return;
      _pollCancel = null;
      _pollFailed(e);
    }
  }

  void _polled(EventPollPage page, int since) {
    final recovered = _pollAttempt > 0;
    _pollAttempt = 0;
    _succeeded();
    if (_pollFresh && since == 0 && _hadLive) _gap();
    _pollFresh = false;
    _hadLive = true;
    final before = _cursor;
    page.events.forEach(_deliver);
    if (page.nextSeq > _cursor) _cursor = page.nextSeq;
    _set(LiveMode.polling);
    if (recovered) _probeNow();
    final idle = page.events.isEmpty && _cursor == before;
    _schedulePoll(idle ? _idlePause : Duration.zero);
  }

  void _pollFailed(TixException e) {
    if (e.kind == TixErrorKind.unauthenticated ||
        e.kind == TixErrorKind.forbidden) {
      _refused(e);
      return;
    }
    if (e.kind == TixErrorKind.invalid &&
        e.message.contains('no longer available')) {
      _cursor = 0;
      _pollFresh = false;
      _gap();
      _schedulePoll(Duration.zero);
      return;
    }
    if (e.kind == TixErrorKind.invalid &&
        e.message.contains('wait') &&
        _pollWait > _shorterWait) {
      _pollWait = _shorterWait;
      _schedulePoll(Duration.zero);
      return;
    }
    _pollAttempt++;
    _consecutiveFailures++;
    final wait = config.pollBackoff.delay(_pollAttempt, _random);
    _nextRetryAt = _now().add(wait);
    _record(e, LiveErrorSource.poll);
    _set(_isNetwork(e) ? LiveMode.offline : LiveMode.polling);
    _changed();
    _schedulePoll(wait);
  }

  void _startRefreshing() {
    _stopPolling();
    _transport = LiveTransport.refresh;
    _cursor = 0;
    _set(LiveMode.refreshing);
    _gap();
    _scheduleRefresh();
  }

  void _scheduleRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    if (_transport != LiveTransport.refresh || !_awake) return;
    _refreshTimer = Timer.periodic(config.refreshEvery, (_) {
      onRefresh?.call();
      _gap();
    });
  }

  void _scheduleProbe() {
    _probeTimer?.cancel();
    _probeTimer = null;
    if (!_awake) return;
    final wait = Backoff(
      first: config.probeEvery,
      max: config.probeEvery,
      jitter: config.probeJitter,
    ).delay(1, _random);
    _nextProbeAt = _now().add(wait);
    _probeTimer = Timer(wait, _probeNow);
    _changed();
  }

  void _probeNow() {
    _probeTimer?.cancel();
    _probeTimer = null;
    _nextProbeAt = null;
    final fallen =
        _transport == LiveTransport.poll || _transport == LiveTransport.refresh;
    if (!fallen || !_awake || _probe != null) return;
    _probe = _openStream(
      since: _transport == LiveTransport.poll ? _cursor : 0,
      probe: true,
    );
  }

  void _probeFailed(Object? error) {
    _record(error, LiveErrorSource.probe);
    unawaited(_dropProbe());
    _scheduleProbe();
  }

  void _adoptProbe(int since) {
    log('live: the WebSocket works again');
    _stopPolling();
    _stopRefreshing();
    _probeTimer?.cancel();
    _probeTimer = null;
    _socket = _probe;
    _socketSub = _probeSub;
    _probe = null;
    _probeSub = null;
    _transport = LiveTransport.websocket;
    _clearFailures();
    if (since == 0 && _hadLive) _gap();
  }

  void _refused(Object? error) {
    _nextRetryAt = null;
    _nextProbeAt = null;
    _record(
      error,
      _transport == LiveTransport.poll
          ? LiveErrorSource.poll
          : LiveErrorSource.websocket,
    );
    _set(LiveMode.unavailable);
    unawaited(_stopAll());
  }

  /// Reports [EventsMissed], so everything that refreshes on a gap reads the
  /// server again: after queued writes went out, for one.
  void reportGap() => _gap();

  void _deliver(TixEvent event) {
    if (event.seq <= _cursor || _updates.isClosed) return;
    _cursor = event.seq;
    _lastEventAt = _now();
    _updates.add(EventReceived(event));
    _changed();
  }

  void _gap() {
    if (!_updates.isClosed) _updates.add(const EventsMissed());
  }

  void _set(LiveMode mode) {
    final next = LiveStatus(mode, lastError: _lastError);
    if (next == status) return;
    if (mode != _mode) {
      _modeSince = _now();
      _mode = mode;
      _log(LiveLogEntry(at: _modeSince, mode: mode, transport: _transport));
    }
    if (!_statuses.isClosed) _statuses.add(next);
    _changed();
  }

  void _record(Object? error, LiveErrorSource source) {
    _lastError = error;
    final info = LiveError.from(
      error,
      at: _now(),
      source: source,
      secrets: _secrets,
    );
    _lastErrorInfo = info;
    _log(
      LiveLogEntry(
        at: info.at,
        mode: _mode,
        transport: _transport,
        error: info,
      ),
    );
    _changed();
  }

  void _succeeded() {
    _lastContactAt = _now();
    _consecutiveFailures = 0;
    _nextRetryAt = null;
  }

  void _log(LiveLogEntry entry) {
    _history.add(entry);
    final over = _history.length - config.historySize;
    if (over > 0) _history.removeRange(0, over);
  }

  void _changed() {
    if (_diagnostics.hasListener && !_diagnostics.isClosed) {
      _diagnostics.add(diagnostics);
    }
  }

  Iterable<String> get _secrets => [
    for (final v in _headers.values) ...[v, ...v.split(RegExp('[ =]')).skip(1)],
  ];

  // A server that answers an empty poll at once, ignoring the wait, is
  // not asked again in a tight loop.
  static const _idlePause = Duration(seconds: 1);

  // A server whose request timeout is below the default refuses a 25 s wait.
  static const _shorterWait = Duration(seconds: 10);

  static bool _isNetwork(Object? error) => switch (error) {
    SocketException() || TimeoutException() => true,
    TixException(:final kind) =>
      kind == TixErrorKind.network || kind == TixErrorKind.timeout,
    _ => false,
  };

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _pollCancel?.cancel();
    _pollCancel = null;
  }

  void _stopRefreshing() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  void _clearFailures() {
    for (final t in _failures) {
      t.cancel();
    }
    _failures.clear();
  }

  Future<void> _closeSocket() async {
    final socket = _socket;
    final sub = _socketSub;
    _socket = null;
    _socketSub = null;
    final closing = socket?.close();
    await sub?.cancel();
    await closing;
  }

  Future<void> _dropProbe() async {
    final probe = _probe;
    final sub = _probeSub;
    _probe = null;
    _probeSub = null;
    final closing = probe?.close();
    await sub?.cancel();
    await closing;
  }

  Future<void> _stopAll() async {
    _transport = LiveTransport.none;
    _stopPolling();
    _stopRefreshing();
    _clearFailures();
    _probeTimer?.cancel();
    _probeTimer = null;
    await _closeSocket();
    await _dropProbe();
  }
}
