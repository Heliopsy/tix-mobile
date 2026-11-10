// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/platform/desktop.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const runner = MethodChannel('tix/desktop-test');
  const tray = MethodChannel('tray_manager');
  const window = MethodChannel('window_manager');
  late List<MethodCall> runnerCalls;
  late List<MethodCall> trayCalls;
  late List<MethodCall> windowCalls;
  Map<String, Object?>? caps;

  setUp(() {
    runnerCalls = [];
    trayCalls = [];
    windowCalls = [];
    caps = {
      'tray': true,
      'autostart': true,
      'hotkey': false,
      'background': true,
    };
    messenger
      ..setMockMethodCallHandler(runner, (call) async {
        runnerCalls.add(call);
        return switch (call.method) {
          'capabilities' => caps,
          'autostart' => null,
          'setAutostart' || 'setHotkey' => call.arguments,
          _ => null,
        };
      })
      ..setMockMethodCallHandler(tray, (call) async {
        trayCalls.add(call);
        return null;
      })
      ..setMockMethodCallHandler(window, (call) async {
        windowCalls.add(call);
        return switch (call.method) {
          'isMinimized' || 'isVisible' => false,
          _ => null,
        };
      });
    addTearDown(() {
      messenger
        ..setMockMethodCallHandler(runner, null)
        ..setMockMethodCallHandler(tray, null)
        ..setMockMethodCallHandler(window, null);
    });
  });

  Future<void> fromPlatform(MethodChannel channel, MethodCall call) =>
      messenger.handlePlatformMessage(
        channel.name,
        channel.codec.encodeMethodCall(call),
        (_) {},
      );

  test('the runner says what the desktop offers', () async {
    final shell = PluginDesktopShell(runner);
    expect(
      await shell.start(),
      const DesktopCaps(tray: true, autostart: true, background: true),
    );
    expect(windowCalls.map((c) => c.method), ['ensureInitialized']);
  });

  test('without the runner channel nothing is offered or touched', () async {
    final shell = PluginDesktopShell(const MethodChannel('tix/none'));
    expect(await shell.start(), DesktopCaps.none);
    expect(windowCalls, isEmpty);
    expect(trayCalls, isEmpty);
  });

  test('an empty answer offers nothing', () async {
    caps = null;
    expect(await PluginDesktopShell(runner).start(), DesktopCaps.none);
  });

  test('the tray menu carries the labels and the context', () async {
    final shell = PluginDesktopShell(runner);
    await shell.start();
    await shell.setTray(
      const TrayMenu(
        labels: {
          TrayAction.open: 'Open tix',
          TrayAction.quickAdd: 'Quick add',
          TrayAction.inbox: 'Inbox (2 unread)',
          TrayAction.quit: 'Quit tix',
        },
        context: 'Work · Acme',
        badge: '2',
      ),
    );
    expect(trayCalls.first.method, 'setIcon');
    final menu = trayCalls.lastWhere((c) => c.method == 'setContextMenu');
    final items = ((menu.arguments as Map)['menu'] as Map)['items'] as List;
    final labels = [
      for (final i in items.cast<Map<Object?, Object?>>())
        if (i['type'] != 'separator') i['label'],
    ];
    expect(labels, [
      'Open tix',
      'Quick add',
      'Inbox (2 unread)',
      'Work · Acme',
      'Quit tix',
    ]);
    final context = items.cast<Map<Object?, Object?>>().firstWhere(
      (i) => i['label'] == 'Work · Acme',
    );
    expect(context['disabled'], isTrue);
  });

  test('a picked entry becomes an event', () async {
    final shell = PluginDesktopShell(runner);
    await shell.start();
    await shell.setTray(const TrayMenu(labels: {TrayAction.inbox: 'Inbox'}));
    final menu = trayCalls.lastWhere((c) => c.method == 'setContextMenu');
    final items = ((menu.arguments as Map)['menu'] as Map)['items'] as List;
    final inbox = items.cast<Map<Object?, Object?>>().firstWhere(
      (i) => i['key'] == 'inbox',
    );
    final events = <DesktopEvent>[];
    shell.events.listen(events.add);
    await fromPlatform(
      tray,
      MethodCall('onTrayMenuItemClick', {'id': inbox['id']}),
    );
    await fromPlatform(tray, const MethodCall('onTrayIconMouseDown'));
    await fromPlatform(runner, const MethodCall('hotkey'));
    await fromPlatform(
      window,
      const MethodCall('onEvent', {'eventName': 'close'}),
    );
    await pumpEventQueue();
    expect(events, hasLength(4));
    expect((events[0] as TrayPicked).action, TrayAction.inbox);
    expect(events[1], isA<TrayClicked>());
    expect(events[2], isA<HotkeyPressed>());
    expect(events[3], isA<CloseRequested>());
  });

  test('the icon is set once and removed with null', () async {
    final shell = PluginDesktopShell(runner);
    await shell.start();
    const menu = TrayMenu(labels: {});
    await shell.setTray(menu);
    await shell.setTray(menu);
    await shell.setTray(null);
    expect(trayCalls.where((c) => c.method == 'setIcon'), hasLength(1));
    expect(trayCalls.last.method, 'destroy');
  });

  test(
    'on Linux the hover text goes to the runner once the icon shows',
    () async {
      final shell = PluginDesktopShell(runner);
      await shell.start();
      const tooltip = TrayTooltip(
        'tix · 1 instance connected',
        details: ['work (tix.example.com): live'],
        footer: '2 unread in inbox',
      );
      await shell.setTrayStatus(tooltip);
      expect(runnerCalls.where((c) => c.method == 'setTrayStatus'), isEmpty);
      await shell.setTray(const TrayMenu(labels: {}));
      await shell.setTrayStatus(tooltip);
      final sent = runnerCalls.where((c) => c.method == 'setTrayStatus');
      expect(sent.map((c) => c.arguments), [
        for (var i = 0; i < 2; i++)
          {
            'title': 'tix · 1 instance connected',
            'body': 'work (tix.example.com): live\n2 unread in inbox',
          },
      ]);
      expect(trayCalls.where((c) => c.method == 'setToolTip'), isEmpty);
    },
    skip: !Platform.isLinux,
  );

  test('start at login and the hotkey go to the runner', () async {
    final shell = PluginDesktopShell(runner);
    expect(await shell.autostart(), isNull);
    expect(await shell.setAutostart(on: true), isTrue);
    expect(await shell.setHotkey(on: false), isFalse);
    expect(runnerCalls.map((c) => (c.method, c.arguments)), [
      ('autostart', null),
      ('setAutostart', true),
      ('setHotkey', false),
    ]);
  });

  test('the window shows, hides and quits through window_manager', () async {
    final shell = PluginDesktopShell(runner);
    await shell.start();
    windowCalls.clear();
    await shell.setCloseToTray(on: true);
    await shell.show();
    await shell.hide();
    expect(await shell.visible(), isFalse);
    await shell.quit();
    expect(
      windowCalls.map((c) => c.method).where((m) => m != 'setBadgeLabel'),
      [
        'setPreventClose',
        'isMinimized',
        'show',
        'focus',
        'hide',
        'isVisible',
        'setPreventClose',
        'destroy',
      ],
    );
  });
}
