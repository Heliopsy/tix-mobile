// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/platform/note_actions_bridge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('tix/note-actions-test');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  Future<Object?> fromPlatform(String method, [Object? args]) async {
    Object? answer;
    await messenger.handlePlatformMessage(
      channel.name,
      channel.codec.encodeMethodCall(MethodCall(method, args)),
      (data) {
        if (data != null) answer = channel.codec.decodeEnvelope(data);
      },
    );
    return answer;
  }

  NoteActionBridge bridge(List<Object?> ran) => NoteActionBridge((args) async {
    ran.add(args);
    return 'sent';
  }, channel);

  test('owns the outbox at once when no headless engine runs', () async {
    messenger.setMockMethodCallHandler(channel, (call) async => false);
    var owned = 0;
    await bridge([]).listen(owned: () => owned++);
    expect(owned, 1);
  });

  test('waits for headlessGone while a headless engine holds it', () async {
    messenger.setMockMethodCallHandler(channel, (call) async => true);
    var owned = 0;
    final b = bridge([]);
    await b.listen(owned: () => owned++);
    expect(owned, 0);
    await fromPlatform('headlessGone');
    expect(owned, 1);
    b.dispose();
  });

  test('without a platform side the outbox is its own', () async {
    var owned = 0;
    await bridge([]).listen(owned: () => owned++);
    expect(owned, 1);
  });

  test('runs an action and answers with its outcome', () async {
    messenger.setMockMethodCallHandler(channel, (call) async => false);
    final ran = <Object?>[];
    final b = bridge(ran);
    await b.listen();
    final answer = await fromPlatform('run', {'id': 1});
    expect(answer, 'sent');
    expect(ran, [
      {'id': 1},
    ]);
    b.dispose();
  });
}
