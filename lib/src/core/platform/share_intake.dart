// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'share_intake.g.dart';

/// Text another app shared into this one.
typedef SharedText = ({String text, String subject});

/// Text shared to the app through the platform's share sheet. Android's
/// `MainActivity` holds the latest share until it is taken over the
/// `tix/share` channel and says `shared` when one arrives while running.
class ShareIntake {
  /// Listens on [channel].
  ShareIntake([this.channel = const MethodChannel('tix/share')]) {
    channel.setMethodCallHandler((call) async {
      if (call.method == 'shared') await _pull();
    });
  }

  /// The channel to the platform.
  final MethodChannel channel;
  final _shares = StreamController<SharedText>.broadcast();

  /// Shares as they arrive.
  Stream<SharedText> get shares => _shares.stream;

  /// Takes a share made before anyone listened, such as the one that
  /// started the app, and sends it to [shares].
  Future<void> start() => _pull();

  Future<void> _pull() async {
    final Map<Object?, Object?>? taken;
    try {
      taken = await channel.invokeMapMethod<Object?, Object?>('take');
    } on MissingPluginException {
      return;
    }
    if (taken == null) return;
    final text = (taken['text'] as String?)?.trim() ?? '';
    final subject = (taken['subject'] as String?)?.trim() ?? '';
    if (text.isEmpty && subject.isEmpty) return;
    _shares.add((text: text, subject: subject));
  }

  /// Stops listening.
  void dispose() {
    channel.setMethodCallHandler(null);
    unawaited(_shares.close());
  }
}

/// One line from a share: the subject, then the text unless the text already
/// starts with it.
String sharedLine(SharedText share) {
  final text = share.text;
  final subject = share.subject;
  if (subject.isEmpty || text.startsWith(subject)) return text;
  if (text.isEmpty) return subject;
  return '$subject $text';
}

/// The platform's share intake; tests swap in one on a mocked channel.
@Riverpod(keepAlive: true)
ShareIntake shareIntake(Ref ref) {
  final intake = ShareIntake();
  ref.onDispose(intake.dispose);
  return intake;
}
