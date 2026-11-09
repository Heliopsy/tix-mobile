// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart';
import 'package:tix_mobile/src/core/logging/log.dart';

/// Runs one notification action from the channel's arguments and answers
/// what became of it.
typedef NoteActionHandler = Future<String> Function(Object? args);

/// This engine's end of Android's `NoteActionHub`: a pressed notification
/// button arrives as `run`, in the app's engine while it is up and in a
/// headless one otherwise (`noteActionHeadlessMain`). The handler decides
/// everything; the platform only carries the press.
class NoteActionBridge {
  /// Hands every action to [_handler] over [channel].
  NoteActionBridge(
    this._handler, [
    this.channel = const MethodChannel('tix/note-actions'),
  ]);

  final NoteActionHandler _handler;

  /// The channel to the platform.
  final MethodChannel channel;

  /// Answers the platform and tells it this engine is ready. [owned] is
  /// called once no headless engine of this app can still hold an outbox:
  /// at once when none runs, or when the platform says it has stopped it.
  Future<void> listen({void Function()? owned}) async {
    channel.setMethodCallHandler((call) async {
      if (call.method == 'run') return await _handler(call.arguments);
      if (call.method == 'headlessGone') {
        owned?.call();
        return null;
      }
      throw MissingPluginException(call.method);
    });
    try {
      final busy = await channel.invokeMethod<bool>('ready');
      if (busy != true) owned?.call();
    } on MissingPluginException {
      log('note actions: no platform side');
      owned?.call();
    }
  }

  /// Stops answering.
  void dispose() => channel.setMethodCallHandler(null);
}
