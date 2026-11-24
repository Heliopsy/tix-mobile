// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/platform/dav_handoff.dart';

const _account = DavAccount(
  url: 'https://tix.example.com/dav/',
  username: 'ana@example.com',
  password: 'tix_pat_secret',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('tix/dav');
  late List<MethodCall> calls;
  Object? Function(MethodCall call)? answer;

  setUp(() {
    calls = [];
    answer = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return answer?.call(call);
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('Android', () {
    final handoff = PlatformDavHandoff(platform: DavPlatform.android);

    test(
      'opens DAVx5 with the password as an extra, never in the address',
      () async {
        answer = (_) => true;
        expect(await handoff.openDavx5(_account), isTrue);
        final call = calls.single;
        expect(call.method, 'openDavx5');
        final args = (call.arguments as Map).cast<String, String>();
        expect(args, {
          'address': 'caldavs://tix.example.com/dav/',
          'username': 'ana@example.com',
          'password': 'tix_pat_secret',
        });
        expect(args['address'], isNot(contains('tix_pat_secret')));
        expect(args['address'], isNot(contains('ana')));
      },
    );

    test('a failed start is false, so the sheet shows the details', () async {
      answer = (_) => throw PlatformException(code: 'failed');
      expect(await handoff.openDavx5(_account), isFalse);
      answer = (_) => false;
      expect(await handoff.openDavx5(_account), isFalse);
    });

    test('asks the package manager whether DAVx5 is installed', () async {
      answer = (_) => true;
      expect(await handoff.davx5Installed(), isTrue);
      answer = (_) => false;
      expect(await handoff.davx5Installed(), isFalse);
      expect(calls.map((c) => c.method), everyElement('davx5Installed'));
    });

    test('copies the password marked sensitive', () async {
      expect(await handoff.copySecret('tix_pat_secret'), ClipMark.hidden);
      expect(calls.single.method, 'copySensitive');
      expect(calls.single.arguments, {'text': 'tix_pat_secret'});
    });
  });

  test('iOS copies the password local and expiring', () async {
    final handoff = PlatformDavHandoff(platform: DavPlatform.ios);
    expect(await handoff.copySecret('tix_pat_secret'), ClipMark.expires);
    expect(calls.single.method, 'copySensitive');
  });

  test('a native side that fails falls back to the plain clipboard', () async {
    final handoff = PlatformDavHandoff(platform: DavPlatform.android);
    answer = (_) => throw PlatformException(code: 'x');
    String? clip;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            clip = (call.arguments as Map)['text'] as String?;
          }
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );
    expect(await handoff.copySecret('tix_pat_secret'), ClipMark.plain);
    expect(clip, 'tix_pat_secret');
  });

  test('desktops never call the native side for DAVx5', () async {
    final handoff = PlatformDavHandoff(platform: DavPlatform.linux);
    expect(await handoff.davx5Installed(), isFalse);
    expect(await handoff.openDavx5(_account), isFalse);
    expect(calls, isEmpty);
  });

  group('macOS', () {
    late Directory temp;
    late List<Uri> launched;

    setUp(() {
      temp = Directory.systemTemp.createTempSync('dav-handoff');
      launched = [];
      addTearDown(() => temp.deleteSync(recursive: true));
    });

    PlatformDavHandoff handoff({bool opens = true}) => PlatformDavHandoff(
      platform: DavPlatform.macos,
      tempDir: () async => temp,
      launch: (url) async {
        launched.add(url);
        return opens;
      },
    );

    test('writes the profile, opens it, and deletes it on clean up', () async {
      final h = handoff();
      final opening = await h.openProfile('<plist/>');
      expect(opening.opened, isTrue);
      final file = File(launched.single.toFilePath());
      expect(file.path, startsWith('${temp.path}/tix-dav/'));
      expect(file.path, endsWith('.mobileconfig'));
      expect(file.readAsStringSync(), '<plist/>');
      await h.cleanUp();
      expect(file.existsSync(), isFalse);
      expect(Directory('${temp.path}/tix-dav').existsSync(), isFalse);
    });

    test('removes a profile an earlier run left before writing', () async {
      final left = File('${temp.path}/tix-dav/old.mobileconfig')
        ..createSync(recursive: true)
        ..writeAsStringSync('stale');
      await handoff().openProfile('<plist/>');
      expect(left.existsSync(), isFalse);
    });

    test('a profile the system would not open says so', () async {
      expect((await handoff(opens: false).openProfile('x')).opened, isFalse);
    });
  });

  test('iOS serves the profile to Safari inside background time', () async {
    final mocked = HttpOverrides.current;
    HttpOverrides.global = null;
    addTearDown(() => HttpOverrides.global = mocked);
    final launched = <Uri>[];
    final handoff = PlatformDavHandoff(
      platform: DavPlatform.ios,
      tempDir: () async => Directory.systemTemp,
      launch: (url) async {
        launched.add(url);
        return true;
      },
    );
    final opening = await handoff.openProfile('<plist/>');
    expect(opening.opened, isTrue);
    expect(launched.single.scheme, 'http');
    expect(launched.single.host, '127.0.0.1');
    expect(calls.map((c) => c.method), ['beginBackgroundTask']);
    final client = HttpClient();
    addTearDown(() => client.close(force: true));
    final response = await (await client.getUrl(launched.single)).close();
    await response.drain<void>();
    expect(response.statusCode, 200);
    expect(await opening.served, isTrue);
    await pumpEventQueue();
    expect(calls.map((c) => c.method), [
      'beginBackgroundTask',
      'endBackgroundTask',
    ]);
    await handoff.cleanUp();
  });

  test('store links are Google Play in the play build, F-Droid otherwise', () {
    final play = davStoreLinks(play: true);
    expect(
      play.davx5.toString(),
      'https://play.google.com/store/apps/details?id=at.bitfire.davdroid',
    );
    expect(play.tasksOrg.queryParameters['id'], 'org.tasks');
    expect(play.jtx.queryParameters['id'], 'at.techbee.jtx');
    final oss = davStoreLinks(play: false);
    expect(
      oss.davx5.toString(),
      'https://f-droid.org/packages/at.bitfire.davdroid/',
    );
    expect(oss.tasksOrg.toString(), 'https://f-droid.org/packages/org.tasks/');
    expect(oss.jtx.toString(), 'https://f-droid.org/packages/at.techbee.jtx/');
  });
}
