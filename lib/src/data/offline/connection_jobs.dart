// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

/// Thrown inside a [ConnectionJob] once its connection is being forgotten.
class JobCancelled implements Exception {
  /// The one cancellation.
  const JobCancelled();

  @override
  String toString() => 'JobCancelled';
}

/// One piece of background work bound to a connection, such as a prefetch
/// or a replay of the outbox.
class ConnectionJob {
  ConnectionJob._(this.connectionId);

  /// The connection the work reads from and writes for.
  final String connectionId;

  final _done = Completer<void>();
  var _cancelled = false;

  /// Whether the connection is being forgotten and the work must stop.
  bool get cancelled => _cancelled;

  /// Throws [JobCancelled] when [cancelled].
  void check() {
    if (_cancelled) throw const JobCancelled();
  }
}

/// The background work running per connection, so forgetting a connection
/// can stop it before deleting its files: work still running afterwards
/// would write them back under an id nothing refers to any more.
class ConnectionJobs {
  /// Waits at most [grace] for cancelled work to end.
  ConnectionJobs({this.grace = const Duration(seconds: 5)});

  /// How long [stop] waits for work that ignores cancellation, such as a
  /// request already sent.
  final Duration grace;

  final _running = <ConnectionJob>{};
  final _stopped = <String>{};

  /// Whether any work runs for [connectionId].
  bool busy(String connectionId) =>
      _running.any((j) => j.connectionId == connectionId);

  /// Runs [body] as a job of [connectionId]. Throws [JobCancelled] without
  /// running it when the connection was stopped.
  Future<T> run<T>(
    String connectionId,
    Future<T> Function(ConnectionJob job) body,
  ) async {
    if (_stopped.contains(connectionId)) throw const JobCancelled();
    final job = ConnectionJob._(connectionId);
    _running.add(job);
    try {
      return await body(job);
    } finally {
      _running.remove(job);
      job._done.complete();
    }
  }

  /// Cancels the work of [connectionId], refuses new work for it, and waits
  /// up to [grace] for what runs to end. Connection ids are never reused.
  Future<void> stop(String connectionId) async {
    _stopped.add(connectionId);
    final jobs = [
      for (final j in _running)
        if (j.connectionId == connectionId) j,
    ];
    for (final j in jobs) {
      j._cancelled = true;
    }
    await Future.wait([for (final j in jobs) j._done.future])
        .timeout(grace, onTimeout: () => const []);
  }
}
