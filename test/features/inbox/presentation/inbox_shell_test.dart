// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/features/inbox/application/alerts.dart';
import 'package:tix_mobile/src/features/inbox/presentation/inbox_shell.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_notes.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  const shell = InboxAlertsScope(
    child: Scaffold(body: InboxNavIcon(icon: Icon(Icons.inbox))),
  );

  Future<void> pump(
    WidgetTester tester,
    FakeTix server,
    FakeNotes notes, {
    bool settle = true,
  }) {
    final stores = signedInStores();
    return pumpScreen(
      tester,
      shell,
      settle: settle,
      overrides: fakeOverrides(
        server,
        settings: stores.settings,
        secrets: stores.secrets,
        notes: notes,
      ),
    );
  }

  String payload(String item, {String context = 'c1.default'}) => NoteTarget(
    route: '/projects/infra/tasks/infra-1',
    item: item,
    context: context,
  ).encode();

  testWidgets('the badge shows the unread count, and none at zero', (
    tester,
  ) async {
    final server = FakeTix();
    await pump(tester, server, FakeNotes());
    final badge = tester.widget<Badge>(find.byKey(const Key('inbox.badge')));
    expect(badge.isLabelVisible, isTrue);
    expect(find.text('2'), findsOneWidget);
    server.inbox.clear();
    final empty = FakeTix()..inbox.clear();
    await pump(tester, empty, FakeNotes());
    expect(
      tester.widget<Badge>(find.byKey(const Key('inbox.badge'))).isLabelVisible,
      isFalse,
    );
  });

  testWidgets('tapping a notification opens its task and marks it read', (
    tester,
  ) async {
    final server = FakeTix();
    final notes = FakeNotes();
    await pump(tester, server, notes);
    expect(notes.inits, greaterThan(0));
    notes.tap(payload('i1'));
    await tester.pumpAndSettle();
    expect(find.text('route:/projects/infra/tasks/infra-1'), findsOneWidget);
    expect(server.requestsTo('/api/v1/inbox/i1/read').single.method, 'PUT');
  });

  testWidgets('a notification that launched the app opens its task', (
    tester,
  ) async {
    final server = FakeTix();
    await pump(tester, server, FakeNotes(launch: payload('i3')), settle: false);
    await tester.pumpAndSettle();
    expect(find.text('route:/projects/infra/tasks/infra-1'), findsOneWidget);
    expect(server.requestsTo('/api/v1/inbox/i3/read'), hasLength(1));
  });

  testWidgets('a notification of another context stays put', (tester) async {
    final server = FakeTix();
    final notes = FakeNotes();
    await pump(tester, server, notes);
    notes.tap(payload('i1', context: 'other.x'));
    await tester.pumpAndSettle();
    expect(find.textContaining('route:'), findsNothing);
    expect(server.requestsTo('/api/v1/inbox/i1/read'), isEmpty);
  });
}
