// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:convert';

import 'package:tix_mobile/src/core/platform/widget_bridge.dart';

/// Widget storage in memory, recording every value written.
class FakeWidgetBridge implements WidgetBridge {
  FakeWidgetBridge({this.supported = true});

  @override
  final bool supported;

  /// What storage holds now.
  final values = <String, String>{};

  /// Every value ever written, removals left out.
  final written = <String>[];

  /// How many times widgets were asked to draw.
  var redraws = 0;

  /// The link that started the app.
  Uri? launch;

  final _opened = StreamController<Uri>.broadcast();
  final _queued = StreamController<void>.broadcast();

  /// Taps a link, as a widget would while the app runs.
  void tap(Uri uri) => _opened.add(uri);

  /// Says a widget queued something.
  void queuedNow() => _queued.add(null);

  /// The JSON under [key].
  Object? json(String key) {
    final v = values[key];
    return v == null ? null : jsonDecode(v);
  }

  @override
  Stream<Uri> get opened => _opened.stream;

  @override
  Stream<void> get queued => _queued.stream;

  @override
  Future<void> init() async {}

  @override
  Future<Uri?> launched() async => launch;

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> save(String key, String? value) async {
    if (value == null) {
      values.remove(key);
    } else {
      values[key] = value;
      written.add(value);
    }
  }

  @override
  Future<void> redraw() async => redraws++;
}
