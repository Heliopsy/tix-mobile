// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/platform/share_intake.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('tix/share-test');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  Map<String, String>? pending;
  var takes = 0;

  setUp(() {
    takes = 0;
    pending = null;
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method != 'take') return null;
      takes++;
      final p = pending;
      pending = null;
      return p;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
  });

  test('start takes the share that launched the app', () async {
    pending = {'text': 'https://example.com/bug', 'subject': 'Login fails'};
    final intake = ShareIntake(channel);
    addTearDown(intake.dispose);
    final got = <SharedText>[];
    intake.shares.listen(got.add);
    await intake.start();
    await pumpEventQueue();
    expect(got.single, (
      text: 'https://example.com/bug',
      subject: 'Login fails',
    ));
    expect(sharedLine(got.single), 'Login fails https://example.com/bug');
  });

  test('a share while running is pulled when the platform says so', () async {
    final intake = ShareIntake(channel);
    addTearDown(intake.dispose);
    final got = <SharedText>[];
    intake.shares.listen(got.add);
    await intake.start();
    expect(got, isEmpty);
    pending = {'text': 'Renew cert', 'subject': ''};
    await messenger.handlePlatformMessage(
      channel.name,
      channel.codec.encodeMethodCall(const MethodCall('shared')),
      (_) {},
    );
    await pumpEventQueue();
    expect(takes, 2);
    expect(got.single.text, 'Renew cert');
  });

  test('an empty share is dropped', () async {
    pending = {'text': '  ', 'subject': ''};
    final intake = ShareIntake(channel);
    addTearDown(intake.dispose);
    final got = <SharedText>[];
    intake.shares.listen(got.add);
    await intake.start();
    await pumpEventQueue();
    expect(got, isEmpty);
  });

  test('without the platform side nothing happens', () async {
    final intake = ShareIntake(const MethodChannel('tix/none'));
    addTearDown(intake.dispose);
    await intake.start();
  });

  test('sharedLine keeps a subject the text already starts with', () {
    expect(sharedLine((text: 'Bug: x', subject: 'Bug')), 'Bug: x');
    expect(sharedLine((text: '', subject: 'Only')), 'Only');
    expect(sharedLine((text: 'Only', subject: '')), 'Only');
  });
}
