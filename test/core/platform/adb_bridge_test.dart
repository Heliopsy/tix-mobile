// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/platform/adb_bridge.dart';
import 'package:tix_mobile/src/core/platform/app_info.dart';

import '../../helpers/app.dart';
import '../../helpers/container.dart';
import '../../helpers/fake_tix.dart';
import '../../helpers/stores.dart';

const _secret = 'sess-very-secret-0001';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ({MemoryKeyValueStore settings, MemorySecretStore secrets}) stores;

  ProviderContainer container({bool debug = false, bool headless = true}) {
    final server = FakeTix();
    stores = signInStores(server);
    stores.secrets.values['session.s1'] = _secret;
    return makeContainer([
      ...fakeOverrides(
        server,
        settings: stores.settings,
        secrets: stores.secrets,
      ),
      adbHeadlessProvider.overrideWithValue(headless),
      adbDebugBuildProvider.overrideWithValue(debug),
      appInfoProvider.overrideWith(
        (ref) async => const AppInfo(
          version: '0.8.0',
          build: '8',
          platform: 'Android',
          osVersion: '16',
        ),
      ),
    ]);
  }

  test('the setting is off until turned on, and kept', () async {
    final c = container();
    expect(c.read(adbControlSettingProvider), isFalse);
    await c.read(adbControlSettingProvider.notifier).set(on: true);
    expect(c.read(adbControlSettingProvider), isTrue);
    expect(stores.settings.values[AdbControlSetting.key], 'true');
    await c.read(adbControlSettingProvider.notifier).set(on: false);
    expect(stores.settings.values.containsKey(AdbControlSetting.key), isFalse);
  });

  test('a headless dump lists contexts and never the session', () async {
    final c = container();
    final text = await c.read(adbBridgeProvider).snapshot('');
    expect(text, contains('tix-mobile 0.8.0 (8)'));
    expect(text, contains('background engine: the app is not open'));
    expect(text, contains('s1.default'));
    expect(text, contains('Work (tix.example)'));
    expect(text, contains('ADB control: off'));
    expect(text, isNot(contains(_secret)));
  });

  test('a dump of one section prints only that section', () async {
    final c = container();
    final text = await c.read(adbBridgeProvider).snapshot('contexts');
    expect(text, contains('== contexts =='));
    expect(text, isNot(contains('== outbox ==')));
  });

  test('a release build runs commands once the setting is on', () async {
    final c = container();
    final bridge = c.read(adbBridgeProvider);
    final off = await bridge.run('theme', const {'value': 'dark'});
    expect(off.ok, isFalse);
    expect(off.text, adbDisabled);
    expect(stores.settings.values['settings.theme'], isNull);

    await c.read(adbControlSettingProvider.notifier).set(on: true);
    final on = await bridge.run('theme', const {'value': 'dark'});
    expect(on.ok, isTrue);
    expect(stores.settings.values['settings.theme'], 'dark');

    await bridge.run('locale', const {'value': 'bg'});
    expect(stores.settings.values['settings.locale'], 'bg');
    await bridge.run('locale', const {'value': 'system'});
    expect(stores.settings.values.containsKey('settings.locale'), isFalse);
  });

  test('a debug build runs commands with the setting off', () async {
    final c = container(debug: true);
    final reply = await c.read(adbBridgeProvider).run('theme oled', const {});
    expect(reply.ok, isTrue);
    expect(stores.settings.values['settings.theme'], 'oled');
  });

  test('a headless engine asks for the app for a switch', () async {
    final c = container(debug: true);
    final reply = await c.read(adbBridgeProvider).run('switch Work', const {});
    expect(reply.needsApp, isTrue);
  });

  test('the platform reaches commands over tix/adb', () async {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    const channel = MethodChannel('tix/adb');
    var ready = false;
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'ready') ready = true;
      return null;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
    final c = container(debug: true);
    await c.read(adbBridgeProvider).listen();
    expect(ready, isTrue);

    Future<Object?> send(String method, Object? args) async {
      Object? answer;
      await messenger.handlePlatformMessage(
        channel.name,
        channel.codec.encodeMethodCall(MethodCall(method, args)),
        (data) => answer = channel.codec.decodeEnvelope(data!),
      );
      return answer;
    }

    final reply = await send('command', {
      'cmd': 'open',
      'extras': {'link': 'tix://inbox'},
    });
    expect(reply, isA<Map<Object?, Object?>>());
    final map = reply! as Map<Object?, Object?>;
    expect(map['ok'], isTrue);
    expect(map['launch'], 'tix://inbox');

    final dump = await send('snapshot', {'section': 'engine'});
    expect(dump, isA<String>());
    expect(dump! as String, contains('== engine =='));
  });
}
