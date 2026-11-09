// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tix_mobile/src/core/platform/deep_links.dart';
import 'package:tix_mobile/src/core/platform/pinned_shortcuts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PinnedShortcut', () {
    test('a project opens its tasks in the context it was made in', () {
      final s = PinnedShortcut.project(
        context: 's1.acme',
        key: 'OPS',
        name: 'Operations',
      );
      expect(s.id, 'pin.s1.acme.project.OPS');
      expect(s.label, 'Operations');
      expect(s.link.toString(), 'tix://projects/OPS?context=s1.acme');
      expect(
        parseTixLink(s.link),
        const TixLink(route: '/projects/OPS', context: 's1.acme'),
      );
    });

    test('a saved filter opens by id; a nameless one is labelled by it', () {
      final s = PinnedShortcut.savedFilter(context: 'c1.', id: 'f7', name: '');
      expect(s.id, 'pin.c1..filter.f7');
      expect(s.label, 'f7');
      expect(
        parseTixLink(s.link),
        const TixLink(route: '/tasks?filter=f7', context: 'c1.'),
      );
    });

    test('the same target in another context is another shortcut', () {
      String id(String ctx) =>
          PinnedShortcut.project(context: ctx, key: 'OPS', name: 'Ops').id;
      expect(id('s1.acme'), id('s1.acme'));
      expect(id('s1.acme'), isNot(id('s1.beta')));
    });
  });

  group('ChannelPinnedShortcuts', () {
    const channel = MethodChannel('tix/pins-test');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    final calls = <MethodCall>[];

    tearDown(() {
      calls.clear();
      messenger.setMockMethodCallHandler(channel, null);
    });

    test('asks the platform and passes the shortcut over', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        return true;
      });
      const pins = ChannelPinnedShortcuts(channel);
      expect(await pins.supported(), isTrue);
      final shortcut = PinnedShortcut.project(
        context: 's1.acme',
        key: 'OPS',
        name: 'Ops',
      );
      expect(await pins.pin(shortcut), isTrue);
      expect(calls.last.method, 'pin');
      expect(calls.last.arguments, {
        'id': 'pin.s1.acme.project.OPS',
        'label': 'Ops',
        'link': 'tix://projects/OPS?context=s1.acme',
      });
    });

    test('nothing is supported without a platform side', () async {
      const pins = ChannelPinnedShortcuts(channel);
      expect(await pins.supported(), isFalse);
      expect(
        await pins.pin(
          PinnedShortcut.project(context: 'c1.', key: 'OPS', name: ''),
        ),
        isFalse,
      );
    });

    test('a platform error is a no', () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        throw PlatformException(code: 'boom');
      });
      const pins = ChannelPinnedShortcuts(channel);
      expect(await pins.supported(), isFalse);
    });
  });
}
