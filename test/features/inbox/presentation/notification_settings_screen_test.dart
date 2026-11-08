// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/features/inbox/presentation/notification_settings_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_notes.dart';
import '../../../helpers/fake_tix.dart';
import '../../../helpers/stores.dart';

void main() {
  late FakeNotes notes;
  late MemoryKeyValueStore settings;

  setUp(() => notes = FakeNotes());

  Future<void> pump(WidgetTester tester, FakeTix server, {Size size = phone}) {
    final stores = signedInStores();
    settings = stores.settings;
    return pumpScreen(
      tester,
      const NotificationSettingsScreen(),
      size: size,
      overrides: fakeOverrides(
        server,
        settings: stores.settings,
        secrets: stores.secrets,
        notes: notes,
      ),
    );
  }

  bool switchOn(WidgetTester tester, String key) =>
      tester.widget<TixSwitchRow>(find.byKey(Key(key))).value;

  bool switchEnabled(WidgetTester tester, String key) =>
      tester.widget<TixSwitchRow>(find.byKey(Key(key))).onChanged != null;

  for (final MapEntry(key: width, value: size) in widths.entries) {
    testWidgets('$width: draws the three sections', (tester) async {
      await pump(tester, FakeTix(), size: size);
      expect(find.text('On this device'), findsOneWidget);
      expect(switchOn(tester, 'notif.enabled'), isFalse);
      expect(switchEnabled(tester, 'notif.kind.mention'), isFalse);
      expect(switchOn(tester, 'inbox.receive.comment'), isTrue);
      await tester.scrollUntilVisible(
        find.byKey(const Key('channels.add')),
        200,
      );
      expect(find.text('No channels yet.'), findsOneWidget);
    });
  }

  testWidgets('turning notifications on asks permission, then per kind', (
    tester,
  ) async {
    await pump(tester, FakeTix());
    await tester.tap(find.byKey(const Key('notif.enabled')));
    await tester.pumpAndSettle();
    expect(notes.asked, 1);
    expect(switchOn(tester, 'notif.enabled'), isTrue);
    expect(
      settings.values.keys.where((k) => k.startsWith('notif.on.')),
      hasLength(1),
    );
    await tester.tap(find.byKey(const Key('notif.kind.status')));
    await tester.pumpAndSettle();
    expect(switchOn(tester, 'notif.kind.status'), isFalse);
    expect(settings.values['notif.kinds'], 'mention,assigned,comment');
  });

  testWidgets('a refused permission keeps it off and explains', (tester) async {
    notes.grant = false;
    await pump(tester, FakeTix());
    await tester.tap(find.byKey(const Key('notif.enabled')));
    await tester.pumpAndSettle();
    expect(switchOn(tester, 'notif.enabled'), isFalse);
    expect(find.byKey(const Key('notif.blocked')), findsOneWidget);
  });

  testWidgets('a kind switched off is muted on the server', (tester) async {
    final server = FakeTix();
    await pump(tester, server);
    await tester.ensureVisible(find.byKey(const Key('inbox.receive.comment')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('inbox.receive.comment')));
    await tester.pumpAndSettle();
    expect(server.inboxMuted, ['comment']);
    expect(switchOn(tester, 'inbox.receive.comment'), isFalse);
  });

  testWidgets('a refused mute says why and puts the switch back', (
    tester,
  ) async {
    final server = FakeTix();
    await pump(tester, server);
    server.failing['/api/v1/inbox/prefs'] = FakeResponse(
      400,
      envelope('invalid', 'bad kind'),
    );
    await tester.ensureVisible(find.byKey(const Key('inbox.receive.comment')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('inbox.receive.comment')));
    await tester.pumpAndSettle();
    expect(switchOn(tester, 'inbox.receive.comment'), isTrue);
    expect(find.textContaining('bad kind'), findsOneWidget);
  });

  testWidgets('adding a channel shows its secret once, then lists it', (
    tester,
  ) async {
    final server = FakeTix();
    await pump(tester, server);
    await tester.scrollUntilVisible(find.byKey(const Key('channels.add')), 200);
    await tester.ensureVisible(find.byKey(const Key('channels.add')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('channels.add')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('channel.name')), 'Team Slack');
    await tester.enterText(
      find.byKey(const Key('channel.url')),
      'https://hooks.slack.com/x',
    );
    await tester.tap(find.text('Slack'));
    await tester.tap(find.byKey(const Key('channel.kind.status')));
    await tester.tap(find.byKey(const Key('channel.save')));
    await tester.pumpAndSettle();
    expect(server.channels.single['format'], 'slack');
    expect(server.channels.single['kinds'], ['mention', 'assigned', 'comment']);
    expect(find.byKey(const Key('channel.secret')), findsOneWidget);
    expect(find.text('whsec_test'), findsOneWidget);
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
    await tester.tap(find.byKey(const Key('channel.secret.copy')));
    expect(copied, 'whsec_test');
    await tester.tap(find.byKey(const Key('channel.secret.done')));
    await tester.pumpAndSettle();
    expect(find.text('whsec_test'), findsNothing);
    await tester.ensureVisible(find.byKey(const Key('channel.ch1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('channel.ch1')));
    await tester.pumpAndSettle();
    expect(
      find.text('route:/settings/notifications/channels/ch1'),
      findsOneWidget,
    );
  });

  testWidgets('a refused address shows under the field', (tester) async {
    final server = FakeTix();
    await pump(tester, server);
    await tester.scrollUntilVisible(find.byKey(const Key('channels.add')), 200);
    await tester.ensureVisible(find.byKey(const Key('channels.add')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('channels.add')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('channel.name')), 'x');
    await tester.enterText(find.byKey(const Key('channel.url')), 'http://x');
    await tester.tap(find.byKey(const Key('channel.save')));
    await tester.pumpAndSettle();
    expect(find.text('url must be https'), findsOneWidget);
    expect(server.channels, isEmpty);
    expect(find.byKey(const Key('channel.save')), findsOneWidget);
  });

  testWidgets('a failed channel list offers a retry', (tester) async {
    final server = FakeTix()
      ..failing['/api/v1/channels'] = FakeResponse(
        500,
        envelope('internal', 'x'),
      );
    await pump(tester, server, size: desktop);
    await tester.scrollUntilVisible(find.byType(ErrorState), 200);
    expect(find.byType(ErrorState), findsOneWidget);
  });
}
