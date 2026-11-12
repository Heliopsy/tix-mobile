// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_tix.dart';
import '../../../../helpers/sharing.dart';
import 'harness.dart';

void main() {
  late FakeTix server;

  setUp(() => server = FakeTix());

  List<String> clipboard(WidgetTester tester) {
    final copied = <String>[];
    final messenger = tester.binding.defaultBinaryMessenger
      ..setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') {
          copied.add((call.arguments as Map)['text'] as String);
        }
        return null;
      });
    addTearDown(
      () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
    );
    return copied;
  }

  Future<void> share(WidgetTester tester, String item) async {
    await press(tester, find.byKey(const Key('task.share')));
    expect(find.text('Share infra-1'), findsWidgets);
    await press(tester, find.byKey(Key('share.$item')));
  }

  for (final size in [tallPhone, tallDesktop]) {
    group('at ${size.width.toInt()} wide', () {
      testWidgets("Copy link copies the server's web_url", (tester) async {
        final copied = clipboard(tester);
        server.task('infra-1')!['web_url'] =
            'https://public.example/tasks/infra-1';
        await pumpTask(tester, server, size: size);
        await share(tester, 'link');
        expect(copied, ['https://public.example/tasks/infra-1']);
        expect(toast('Link copied'), findsOneWidget);
      });

      testWidgets('Copy as Markdown escapes the title', (tester) async {
        final copied = clipboard(tester);
        server.task('infra-1')!['title'] = 'Fix [login]';
        await pumpTask(tester, server, size: size);
        await share(tester, 'markdown');
        expect(copied, [
          r'[infra-1 Fix \[login\]](https://tix.example/tasks/infra-1)',
        ]);
        expect(toast('Markdown link copied'), findsOneWidget);
      });
    });
  }

  testWidgets('without a web_url the link is on the connected server', (
    tester,
  ) async {
    final copied = clipboard(tester);
    await pumpTask(tester, server);
    await share(tester, 'link');
    expect(copied, ['https://tix.example/tasks/infra-1']);
  });

  testWidgets('Copy key and title copies one line', (tester) async {
    final copied = clipboard(tester);
    server.task('infra-1')!['title'] = 'Fix\n  login';
    await pumpTask(tester, server);
    await share(tester, 'text');
    expect(copied, ['infra-1 Fix login']);
    expect(toast('Key and title copied'), findsOneWidget);
  });

  testWidgets('Share… hands the link to the share sheet', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    try {
      final sharing = FakeTextSharing();
      await pumpTask(tester, server, overrides: [sharing.asOverride]);
      await share(tester, 'native');
      expect(sharing.shared, ['https://tix.example/tasks/infra-1']);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('Share… is left out where there is no share sheet', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    try {
      await pumpTask(tester, server);
      await press(tester, find.byKey(const Key('task.share')));
      expect(find.byKey(const Key('share.native')), findsNothing);
      expect(find.byKey(const Key('share.link')), findsOneWidget);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
