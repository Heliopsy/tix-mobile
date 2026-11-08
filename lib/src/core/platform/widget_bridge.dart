// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/logging/log.dart';

part 'widget_bridge.g.dart';

/// The App Group iOS shares with its widget extension.
const iosAppGroup = 'group.red.tix.tixMobile';

/// The native widgets, by the name each platform knows them under.
const widgetKinds = <({String ios, String android})>[
  (ios: 'TixMyWork', android: 'red.tix.tix_mobile.widgets.MyWorkReceiver'),
  (ios: 'TixInbox', android: 'red.tix.tix_mobile.widgets.InboxReceiver'),
  (ios: 'TixQuickAdd', android: 'red.tix.tix_mobile.widgets.QuickAddReceiver'),
  (ios: 'TixProject', android: 'red.tix.tix_mobile.widgets.ProjectReceiver'),
];

/// Runs in a headless engine when a widget wakes the app's code.
typedef WidgetBackgroundCallback = Future<void> Function(Uri? uri);

/// Widget storage and the taps that come back from widgets. Only strings
/// go in, and only snapshots: never a credential.
abstract interface class WidgetBridge {
  /// Whether this platform has widgets at all.
  bool get supported;

  /// Links tapped in a widget while the app runs.
  Stream<Uri> get opened;

  /// Fires when a widget queued an action while the app runs and nothing
  /// else will run it.
  Stream<void> get queued;

  /// Prepares the platform side; safe to call more than once.
  Future<void> init();

  /// The link that started the app, if a widget did.
  Future<Uri?> launched();

  /// The value under [key].
  Future<String?> read(String key);

  /// Stores [value] under [key], or removes it when null.
  Future<void> save(String key, String? value);

  /// Asks every widget to draw again.
  Future<void> redraw();
}

/// [WidgetBridge] through `home_widget`, on Android and iOS.
class PluginWidgetBridge implements WidgetBridge {
  /// Registers [background] for Android's interactive widgets.
  PluginWidgetBridge({this.background});

  /// What a widget's background tap runs on Android.
  final WidgetBackgroundCallback? background;

  Future<void>? _ready;

  @override
  bool get supported => true;

  @override
  Stream<Uri> get opened =>
      HomeWidget.widgetClicked.where((u) => u != null).cast<Uri>();

  @override
  Stream<void> get queued => const Stream.empty();

  @override
  Future<void> init() => _ready ??= _init();

  Future<void> _init() async {
    try {
      if (Platform.isIOS) await HomeWidget.setAppGroupId(iosAppGroup);
      final callback = background;
      if (Platform.isAndroid && callback != null) {
        await HomeWidget.registerInteractivityCallback(callback);
      }
    } on PlatformException catch (e) {
      log('widgets: init failed: ${e.code}');
    }
  }

  @override
  Future<Uri?> launched() async {
    await init();
    try {
      return await HomeWidget.initiallyLaunchedFromHomeWidget();
    } on PlatformException catch (e) {
      log('widgets: launch read failed: ${e.code}');
      return null;
    }
  }

  @override
  Future<String?> read(String key) async {
    await init();
    try {
      return await HomeWidget.getWidgetData<String>(key);
    } on PlatformException catch (e) {
      log('widgets: read failed: ${e.code}');
      return null;
    }
  }

  @override
  Future<void> save(String key, String? value) async {
    await init();
    try {
      await HomeWidget.saveWidgetData<String>(key, value);
    } on PlatformException catch (e) {
      log('widgets: save failed: ${e.code}');
    }
  }

  @override
  Future<void> redraw() async {
    await init();
    for (final kind in widgetKinds) {
      try {
        await HomeWidget.updateWidget(
          iOSName: kind.ios,
          qualifiedAndroidName: kind.android,
        );
      } on PlatformException catch (e) {
        log('widgets: redraw failed: ${e.code}');
      }
    }
  }
}

/// [WidgetBridge] over the macOS runner's `tix/widgets` channel, since
/// `home_widget` has no macOS side.
class ChannelWidgetBridge implements WidgetBridge {
  /// Talks over [channel].
  ChannelWidgetBridge([this.channel = const MethodChannel('tix/widgets')]) {
    channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'opened':
          final url = Uri.tryParse(call.arguments as String? ?? '');
          if (url != null) _opened.add(url);
        case 'queued':
          _queued.add(null);
      }
    });
  }

  /// The channel to the runner.
  final MethodChannel channel;
  final _opened = StreamController<Uri>.broadcast();
  final _queued = StreamController<void>.broadcast();

  @override
  bool get supported => true;

  @override
  Stream<Uri> get opened => _opened.stream;

  @override
  Stream<void> get queued => _queued.stream;

  @override
  Future<void> init() async {}

  Future<T?> _call<T>(String method, [Object? args]) async {
    try {
      return await channel.invokeMethod<T>(method, args);
    } on MissingPluginException {
      return null;
    } on PlatformException catch (e) {
      log('widgets: $method failed: ${e.code}');
      return null;
    }
  }

  @override
  Future<Uri?> launched() async {
    final url = await _call<String>('launch');
    return url == null ? null : Uri.tryParse(url);
  }

  @override
  Future<String?> read(String key) => _call<String>('read', {'key': key});

  @override
  Future<void> save(String key, String? value) =>
      _call<void>('save', {'key': key, 'value': value});

  @override
  Future<void> redraw() => _call<void>('reload');

  /// Stops listening.
  void dispose() {
    channel.setMethodCallHandler(null);
    unawaited(_opened.close());
    unawaited(_queued.close());
  }
}

/// [WidgetBridge] for platforms without widgets: stores nothing.
class NoWidgetBridge implements WidgetBridge {
  /// Creates it.
  const NoWidgetBridge();

  @override
  bool get supported => false;

  @override
  Stream<Uri> get opened => const Stream.empty();

  @override
  Stream<void> get queued => const Stream.empty();

  @override
  Future<void> init() async {}

  @override
  Future<Uri?> launched() async => null;

  @override
  Future<String?> read(String key) async => null;

  @override
  Future<void> save(String key, String? value) async {}

  @override
  Future<void> redraw() async {}
}

/// The bridge this platform has: `home_widget` on Android and iOS, the
/// runner's channel on macOS, none elsewhere.
WidgetBridge platformWidgetBridge({WidgetBackgroundCallback? background}) {
  if (kIsWeb) return const NoWidgetBridge();
  if (Platform.isAndroid || Platform.isIOS) {
    return PluginWidgetBridge(background: background);
  }
  if (Platform.isMacOS) return ChannelWidgetBridge();
  return const NoWidgetBridge();
}

/// The platform's widget bridge. `main` hands it the background callback;
/// tests swap in a fake.
@Riverpod(keepAlive: true)
WidgetBridge widgetBridge(Ref ref) => platformWidgetBridge();

/// Ticks when something the widgets draw changed outside any event, such
/// as the theme, the language or the privacy setting, so they are written
/// again.
@Riverpod(keepAlive: true)
class WidgetsStale extends _$WidgetsStale {
  @override
  int build() => 0;

  /// Says the widgets need writing.
  void touch() => state++;
}
