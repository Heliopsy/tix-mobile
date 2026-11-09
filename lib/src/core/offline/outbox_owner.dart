// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/logging/log.dart';

part 'outbox_owner.g.dart';

/// Whether this engine may read the outboxes yet. On Android a headless
/// engine may still hold a context's outbox in memory when the app opens
/// (it ran a notification action); two engines each keeping their own copy
/// would overwrite each other's writes. The app's engine waits until the
/// platform says the headless one is gone.
class OutboxOwnership {
  /// Owned from the start: no other engine can hold an outbox.
  OutboxOwnership.owned() {
    _owned.complete();
  }

  /// Owned once [take] is called, or after [timeout] at the latest, so a
  /// platform that never answers cannot keep the outbox shut.
  OutboxOwnership.pending({Duration timeout = const Duration(seconds: 30)}) {
    _deadline = Timer(timeout, () {
      if (_owned.isCompleted) return;
      log('outbox: no word that the background engine is gone; taking over');
      take();
    });
  }

  final _owned = Completer<void>();
  Timer? _deadline;

  /// Completes once this engine owns the outboxes.
  Future<void> get owned => _owned.future;

  /// Whether this engine owns the outboxes now.
  bool get isOwned => _owned.isCompleted;

  /// Takes the outboxes over; safe to call more than once.
  void take() {
    _deadline?.cancel();
    if (!_owned.isCompleted) _owned.complete();
  }
}

/// This engine's ownership of the outboxes: owned at once unless `main`
/// says another engine may hold them.
@Riverpod(keepAlive: true)
OutboxOwnership outboxOwnership(Ref ref) => OutboxOwnership.owned();
