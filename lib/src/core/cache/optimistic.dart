// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/foundation.dart';

/// One optimistic change to a provider's state, in the shape the design
/// system's `runOptimistic` (core/design/components/toast.dart) takes:
///
/// ```dart
/// final change = ref.read(projectTasksProvider(key).notifier).star(task);
/// await runOptimistic(
///   context,
///   apply: change.apply,
///   rollback: change.rollback,
///   commit: change.commit,
///   undo: change.undo,
///   success: l10n.starred,
///   describe: (e) => describeError(context, e),
/// );
/// ```
///
/// The notifier builds it, since only the notifier may touch its state;
/// the widget runs it, since only the widget can show the toast.
class OptimisticChange<S> {
  /// Changes the state `read` returns, through `write`, with `change`, and
  /// sends it with `send`. [reverse], when given, undoes it on the server.
  OptimisticChange({
    required this._read,
    required this._write,
    required this._change,
    required this._send,
    Future<void> Function()? reverse,
  }) : undo = reverse;

  final S? Function() _read;
  final void Function(S state) _write;
  final S Function(S state) _change;
  final Future<void> Function() _send;
  S? _before;

  /// Undoes the change on the server, null when it cannot be undone.
  final Future<void> Function()? undo;

  /// Shows the change at once, remembering the state it replaced. Nothing
  /// happens while no state is loaded.
  void apply() {
    final now = _read();
    if (now == null) return;
    _before = now;
    _write(_change(now));
  }

  /// Puts back the state [apply] replaced.
  void rollback() {
    final before = _before;
    if (before != null) _write(before);
  }

  /// Sends the change to the server.
  Future<void> commit() => _send();

  /// The state [apply] replaced, for tests.
  @visibleForTesting
  S? get before => _before;
}
