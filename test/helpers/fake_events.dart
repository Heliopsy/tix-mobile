// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:tix_mobile/src/data/events/event_stream.dart';

/// A connector that refuses every socket as tix refuses a credential without
/// `event:subscribe`: the stream goes unavailable and never retries. The
/// default in widget tests, which have no live updates.
Future<EventSocket> refusingEventSocket(
  Uri url,
  Map<String, String> headers,
) async => throw const WebSocketException('not upgraded', 403);

/// One fake socket: what the client sent, and a way to answer it.
class FakeSocket implements EventSocket {
  FakeSocket(this.url, this.headers);

  final Uri url;
  final Map<String, String> headers;
  final sent = <Map<String, Object?>>[];
  final _incoming = StreamController<Object?>();
  bool closed = false;

  @override
  int? closeCode;

  @override
  String? closeReason;

  @override
  Stream<Object?> get messages => _incoming.stream;

  @override
  void send(String text) => sent.add(jsonDecode(text) as Map<String, Object?>);

  @override
  Future<void> close() async {
    closed = true;
    if (!_incoming.isClosed) await _incoming.close();
  }

  /// Sends the server frame [msg].
  void push(Map<String, Object?> msg) => _incoming.add(jsonEncode(msg));

  /// Acknowledges the last subscription, or the last one named [id],
  /// echoing its `since_seq`.
  void ack([String? id]) {
    final sub = sent.lastWhere(
      (m) => m['type'] == 'subscribe' && (id == null || m['id'] == id),
    );
    push({
      'type': 'subscribed',
      'id': sub['id'],
      if (sub['since_seq'] != null) 'since_seq': sub['since_seq'],
    });
  }

  /// Delivers an event with [seq] and [type] to the subscription [id].
  void event(
    int seq,
    String type, {
    String id = 's1',
    String subjectId = 'id-infra-1',
    String projectId = 'p1',
    String actorId = '',
    Map<String, Object?> payload = const {},
  }) => push({
    'type': 'event',
    'id': id,
    'event': {
      'seq': seq,
      'type': type,
      'subject_type': type.split('.').first,
      'subject_id': subjectId,
      'project_id': projectId,
      'actor_id': actorId,
      'payload': payload,
      'occurred_at': '2026-11-08T10:00:00Z',
    },
  });

  /// The subscribe frames sent for [id], in order.
  List<Map<String, Object?>> subscribes(String id) => [
    for (final m in sent)
      if (m['type'] == 'subscribe' && m['id'] == id) m,
  ];

  /// Drops the connection as a network failure would, or closes it with
  /// [code] and [reason] as a server or proxy would.
  Future<void> drop({int? code, String? reason}) {
    closeCode = code;
    closeReason = reason;
    return _incoming.close();
  }

  /// Fails the connection with [error], as a socket error would.
  void fail(Object error) => _incoming.addError(error);
}

/// Hands out [FakeSocket]s and records them; [refuse] makes the next
/// connection fail with that HTTP status, [fail] with a network error and
/// [error] with whatever it holds.
class FakeEventSockets {
  final sockets = <FakeSocket>[];
  int? refuse;
  bool fail = false;
  Exception? error;
  int attempts = 0;
  final _opened = StreamController<FakeSocket>.broadcast();

  /// Each socket as it opens.
  Stream<FakeSocket> get opened => _opened.stream;

  /// The newest socket.
  FakeSocket get last => sockets.last;

  Future<EventSocket> connect(Uri url, Map<String, String> headers) async {
    attempts++;
    final thrown = error;
    if (thrown != null) throw thrown;
    final status = refuse;
    if (status != null) throw WebSocketException('not upgraded', status);
    if (fail) throw const SocketException('refused');
    final s = FakeSocket(url, headers);
    sockets.add(s);
    _opened.add(s);
    return s;
  }
}
