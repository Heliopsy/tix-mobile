// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/update/play_updates.dart';
import 'package:tix_mobile/src/data/update/release_feed.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('tix/play-update');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late List<String> calls;

  void answer(Object? Function(MethodCall call) reply) {
    calls = [];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      return reply(call);
    });
  }

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  group('ChannelPlayUpdates', () {
    test('asks `info` on tix/play-update and reads the answer', () async {
      answer(
        (_) => {'available': true, 'versionCode': 21000, 'flexible': false},
      );
      final i = (await const ChannelPlayUpdates().info())!;
      expect(calls, ['info']);
      expect(i.available, isTrue);
      expect(i.versionCode, 21000);
      expect(i.flexible, isFalse);
    });

    test("the oss stand-in's null means no Play", () async {
      answer((_) => null);
      expect(await const ChannelPlayUpdates().info(), isNull);
      expect(await const ChannelPlayUpdates().start(), PlayStart.none);
    });

    test('a Play error is a network failure', () async {
      answer((_) => throw PlatformException(code: 'play', message: 'no'));
      await expectLater(
        const ChannelPlayUpdates().info(),
        throwsA(
          isA<UpdateException>().having(
            (e) => e.kind,
            'kind',
            UpdateErrorKind.network,
          ),
        ),
      );
    });

    test('no handler at all means no Play', () async {
      expect(await const ChannelPlayUpdates().info(), isNull);
      expect(await const ChannelPlayUpdates().start(), PlayStart.none);
    });

    test('`start` reports what Play did', () async {
      for (final (reply, expected) in [
        ('flexible', PlayStart.flexible),
        ('listing', PlayStart.listing),
        ('none', PlayStart.none),
        ('odd', PlayStart.none),
      ]) {
        answer((_) => reply);
        expect(await const ChannelPlayUpdates().start(), expected);
        expect(calls, ['start']);
      }
    });
  });

  test("LinkPlayUpdates reads the worker's link and starts nothing", () async {
    final p = LinkPlayUpdates(Uri.parse('tixwidget://update?play=1&code=7'));
    expect((await p.info())!.versionCode, 7);
    expect(await p.start(), PlayStart.none);
    expect(await const LinkPlayUpdates(null).info(), isNull);
  });
}
