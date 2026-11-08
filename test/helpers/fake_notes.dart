// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:tix_mobile/src/core/notifications/local_notifier.dart';

/// Local notifications recorded instead of shown.
class FakeNotes implements LocalNotifier {
  /// Answers permission requests with [grant].
  FakeNotes({this.grant = true, this.launch});

  /// What a permission request answers.
  bool grant;

  /// The payload that launched the app.
  String? launch;

  final shown = <LocalNote>[];
  final cancelled = <int>[];
  int cancelledAll = 0;
  int asked = 0;
  int inits = 0;
  final _taps = StreamController<String>.broadcast();

  /// Taps the notification carrying [payload].
  void tap(String payload) => _taps.add(payload);

  @override
  Stream<String> get taps => _taps.stream;

  @override
  Future<void> init() async => inits++;

  @override
  Future<String?> launchPayload() async => launch;

  @override
  Future<bool> requestPermission() async {
    asked++;
    return grant;
  }

  @override
  Future<void> show(LocalNote note) async => shown.add(note);

  @override
  Future<void> cancel(int id) async => cancelled.add(id);

  @override
  Future<void> cancelAll() async => cancelledAll++;
}
