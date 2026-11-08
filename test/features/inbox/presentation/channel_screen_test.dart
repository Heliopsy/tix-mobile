// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/features/inbox/presentation/channel_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  FakeTix serverWithChannel() => FakeTix()
    ..channels.add({
      'id': 'ch1',
      'name': 'Team Slack',
      'url': 'https://hooks.slack.com/x',
      'format': 'slack',
      'kinds': ['mention', 'assigned'],
      'active': true,
    })
    ..deliveries['ch1'] = [
      {
        'id': 'd1',
        'channel_id': 'ch1',
        'item_id': 'i1',
        'status': 'failed',
        'attempts': 3,
        'last_status_code': 500,
        'last_error': 'upstream said no',
        'created_at': '2026-11-01T10:00:00Z',
      },
    ];

  Future<void> pump(
    WidgetTester tester,
    FakeTix server, {
    Size size = phone,
    bool settle = true,
  }) {
    final stores = signedInStores();
    return pumpScreen(
      tester,
      const ChannelScreen(channelId: 'ch1'),
      size: size,
      settle: settle,
      overrides: fakeOverrides(
        server,
        settings: stores.settings,
        secrets: stores.secrets,
      ),
    );
  }

  for (final MapEntry(key: width, value: size) in widths.entries) {
    group(width, () {
      testWidgets('loading, then the channel and its deliveries', (
        tester,
      ) async {
        final server = serverWithChannel()..gate = Completer<void>();
        await pump(tester, server, size: size, settle: false);
        expect(find.byType(SkeletonList), findsOneWidget);
        server.gate!.complete();
        await tester.pumpAndSettle();
        expect(find.text('Team Slack'), findsWidgets);
        expect(find.text('Mentions, Assignments'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.byKey(const Key('delivery.d1')),
          200,
        );
        expect(
          find.descendant(
            of: find.byKey(const Key('delivery.d1')),
            matching: find.text('upstream said no'),
          ),
          findsOneWidget,
        );
      });

      testWidgets('a channel that is gone says so with a way back', (
        tester,
      ) async {
        await pump(tester, FakeTix(), size: size);
        expect(find.text('This channel no longer exists.'), findsOneWidget);
        await tester.tap(find.text('Back'));
        await tester.pumpAndSettle();
        expect(find.text('route:/settings/notifications'), findsOneWidget);
      });

      testWidgets('error', (tester) async {
        final server = serverWithChannel()
          ..failing['/api/v1/channels'] = FakeResponse(
            500,
            envelope('internal', 'x'),
          );
        await pump(tester, server, size: size);
        expect(
          find.textContaining('The server had a problem.'),
          findsOneWidget,
        );
      });
    });
  }

  testWidgets('sending a test lists its delivery', (tester) async {
    final server = serverWithChannel();
    await pump(tester, server, size: desktop);
    await tester.tap(find.byKey(const Key('channel.test')));
    await tester.pumpAndSettle();
    expect(server.requestsTo('/api/v1/channels/ch1/test'), hasLength(1));
    expect(find.text('Test message'), findsOneWidget);
  });

  testWidgets('redelivering a failure queues it again', (tester) async {
    final server = serverWithChannel();
    await pump(tester, server, size: desktop);
    await tester.scrollUntilVisible(
      find.byKey(const Key('delivery.redeliver.d1')),
      200,
    );
    await tester.tap(find.byKey(const Key('delivery.redeliver.d1')));
    await tester.pumpAndSettle();
    expect(server.deliveries['ch1']!.single['status'], 'pending');
    expect(find.byKey(const Key('delivery.redeliver.d1')), findsNothing);
  });

  testWidgets('turning the channel off sends active false', (tester) async {
    final server = serverWithChannel();
    await pump(tester, server);
    await tester.tap(find.byKey(const Key('channel.active')));
    await tester.pumpAndSettle();
    expect(server.channels.single['active'], isFalse);
  });

  testWidgets('editing renames it', (tester) async {
    final server = serverWithChannel();
    await pump(tester, server, size: desktop);
    await tester.tap(find.byKey(const Key('channel.edit')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('channel.name')), 'Ops');
    await tester.tap(find.byKey(const Key('channel.save')));
    await tester.pumpAndSettle();
    expect(server.channels.single['name'], 'Ops');
    expect(find.text('Channel saved'), findsOneWidget);
  });

  testWidgets('deleting confirms, then goes back', (tester) async {
    final server = serverWithChannel();
    await pump(tester, server, size: desktop);
    await tester.ensureVisible(find.byKey(const Key('channel.delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('channel.delete')));
    await tester.pumpAndSettle();
    expect(server.channels, hasLength(1));
    await tester.tap(find.byKey(const Key('confirm.ok')));
    await tester.pumpAndSettle();
    expect(server.channels, isEmpty);
    expect(find.text('route:/settings/notifications'), findsOneWidget);
  });
}
