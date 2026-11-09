// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tix_mobile/src/core/logging/log.dart';

part 'local_notifier.g.dart';

/// What a button on a notification does.
enum NoteActionKind {
  /// Completes the task.
  done,

  /// Snoozes the task until tomorrow morning.
  snooze,

  /// Posts the typed text as a comment.
  reply,
}

/// A button on a notification, run in the background when pressed.
@immutable
class LocalNoteAction {
  /// A button for [kind] reading [label].
  const LocalNoteAction(this.kind, this.label);

  /// What it does.
  final NoteActionKind kind;

  /// What it reads.
  final String label;
}

/// One notification to show.
@immutable
class LocalNote {
  /// A note titled [title] that opens [payload] when tapped.
  const LocalNote({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
    this.badge,
    this.publicTitle,
    this.publicBody,
    this.actions = const [],
    this.replyLabel = '',
    this.unlockForActions = false,
  });

  /// Stable per item, so showing it again replaces it.
  final int id;

  /// The first line.
  final String title;

  /// The rest.
  final String body;

  /// What a tap hands back.
  final String payload;

  /// The app icon's badge, where the platform draws one from a notification.
  final int? badge;

  /// What a locked screen shows in place of [title], where the platform
  /// takes a public version (Android).
  final String? publicTitle;

  /// What a locked screen shows in place of [body].
  final String? publicBody;

  /// The buttons, where the platform runs them in the background (Android).
  final List<LocalNoteAction> actions;

  /// The hint in the field a reply is typed into.
  final String replyLabel;

  /// Whether the buttons ask for the device to be unlocked first, where the
  /// platform can (Android 12 and later).
  final bool unlockForActions;
}

/// The platform's local notifications, behind an interface tests fake.
abstract interface class LocalNotifier {
  /// Payloads of tapped notifications, while the app runs.
  Stream<String> get taps;

  /// Prepares the plugin; safe to call more than once.
  Future<void> init();

  /// The payload of the notification that launched the app, if one did.
  Future<String?> launchPayload();

  /// Asks the platform for permission; true when notifications may show.
  Future<bool> requestPermission();

  /// Shows [note].
  Future<void> show(LocalNote note);

  /// Removes the notification [id].
  Future<void> cancel(int id);

  /// Removes every notification this app shows.
  Future<void> cancelAll();
}

/// [LocalNotifier] over `flutter_local_notifications`.
class PluginLocalNotifier implements LocalNotifier {
  /// Wraps [plugin].
  PluginLocalNotifier([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  // flutter_local_notifications cannot set a public version, so
  // MainActivity adds one to the posted notification, and with it the
  // actions, whose intents go to the app's own receiver (PublicNotes.kt).
  static const _public = MethodChannel('tix/notes');
  final _taps = StreamController<String>.broadcast();
  Future<void>? _ready;

  static const _channel = AndroidNotificationChannel(
    'inbox',
    'Inbox',
    description: 'Mentions, assignments, comments and status changes',
  );

  @override
  Stream<String> get taps => _taps.stream;

  @override
  Future<void> init() => _ready ??= _init();

  Future<void> _init() async {
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('ic_stat_tix'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
          macOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
          linux: LinuxInitializationSettings(defaultActionName: 'Open'),
          windows: WindowsInitializationSettings(
            appName: 'tix',
            appUserModelId: 'red.tix.tix_mobile',
            guid: '5b0b7d1e-4f0e-4c38-9a77-2f1c8c2f3a61',
          ),
        ),
        onDidReceiveNotificationResponse: (r) {
          final payload = r.payload;
          if (payload != null && payload.isNotEmpty) _taps.add(payload);
        },
      );
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_channel);
    } on Object catch (e) {
      log('notifications: init failed: ${e.runtimeType}');
    }
  }

  @override
  Future<String?> launchPayload() async {
    await init();
    try {
      final details = await _plugin.getNotificationAppLaunchDetails();
      if (details == null || !details.didNotificationLaunchApp) return null;
      return details.notificationResponse?.payload;
    } on Object catch (e) {
      log('notifications: launch details failed: ${e.runtimeType}');
      return null;
    }
  }

  @override
  Future<bool> requestPermission() async {
    await init();
    try {
      if (Platform.isAndroid) {
        return await _plugin
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >()
                ?.requestNotificationsPermission() ??
            false;
      }
      if (Platform.isIOS) {
        return await _plugin
                .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin
                >()
                ?.requestPermissions(alert: true, badge: true, sound: true) ??
            false;
      }
      if (Platform.isMacOS) {
        return await _plugin
                .resolvePlatformSpecificImplementation<
                  MacOSFlutterLocalNotificationsPlugin
                >()
                ?.requestPermissions(alert: true, badge: true, sound: true) ??
            false;
      }
    } on Object catch (e) {
      log('notifications: permission failed: ${e.runtimeType}');
      return false;
    }
    // Linux and Windows ask nobody: the desktop decides per app.
    return true;
  }

  @override
  Future<void> show(LocalNote note) async {
    await init();
    try {
      await _plugin.show(
        id: note.id,
        title: note.title,
        body: note.body,
        payload: note.payload,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            category: AndroidNotificationCategory.social,
            number: note.badge,
            visibility: NotificationVisibility.private,
          ),
          iOS: DarwinNotificationDetails(badgeNumber: note.badge),
          macOS: DarwinNotificationDetails(badgeNumber: note.badge),
          linux: const LinuxNotificationDetails(
            category: LinuxNotificationCategory.imReceived,
          ),
        ),
      );
    } on Object catch (e) {
      log('notifications: show failed: ${e.runtimeType}');
      return;
    }
    final title = note.publicTitle;
    if (title == null || !Platform.isAndroid) return;
    try {
      await _public.invokeMethod<bool>('publicVersion', {
        'id': note.id,
        'title': title,
        'body': note.publicBody ?? '',
        'payload': note.payload,
        'replyLabel': note.replyLabel,
        'unlock': note.unlockForActions,
        'actions': [
          for (final a in note.actions)
            {
              'id': a.kind.name,
              'label': a.label,
              'reply': a.kind == NoteActionKind.reply,
            },
        ],
      });
    } on Object catch (e) {
      log('notifications: public version failed: ${e.runtimeType}');
    }
  }

  @override
  Future<void> cancel(int id) async {
    await init();
    try {
      await _plugin.cancel(id: id);
    } on Object catch (e) {
      log('notifications: cancel failed: ${e.runtimeType}');
    }
  }

  @override
  Future<void> cancelAll() async {
    await init();
    try {
      await _plugin.cancelAll();
    } on Object catch (e) {
      log('notifications: cancel failed: ${e.runtimeType}');
    }
  }
}

/// The app's local notifications; tests swap in a fake.
@Riverpod(keepAlive: true)
LocalNotifier localNotes(Ref ref) => PluginLocalNotifier();

/// A notification id for [key] that is the same on every run, so a
/// notification shown before a restart can still be removed after it.
int stableNoteId(String key) {
  var h = 0x811c9dc5;
  for (final unit in key.codeUnits) {
    h = ((h ^ unit) * 0x01000193) & 0x7fffffff;
  }
  return h;
}
