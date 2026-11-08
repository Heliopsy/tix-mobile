// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../helpers/fake_parity.dart';
import '../../../../helpers/fake_tix.dart';
import 'harness.dart';

void main() {
  late FakeTix server;
  late FakeParity parity;

  setUp(() {
    server = FakeTix();
    parity = FakeParity.on(server);
  });

  Finder inRow(String row, Finder what) =>
      find.descendant(of: find.byKey(Key(row)), matching: what);

  for (final MapEntry(key: width, value: size) in {
    'compact': tallPhone,
    'expanded': tallDesktop,
  }.entries) {
    testWidgets('$width: the claim length reads as a duration', (tester) async {
      await pumpTask(tester, server, size: size);
      expect(
        inRow('prop.lease', find.text('2 h, from the project')),
        findsOneWidget,
      );
      expect(
        inRow('prop.lease', find.text('At most 1 d, from the tenant')),
        findsOneWidget,
      );
      expect(find.textContaining('2h0m0s'), findsNothing);
      expect(find.byKey(const Key('lease.clamped')), findsNothing);
    });
  }

  testWidgets('a clamped lease says so', (tester) async {
    parity.lease = {
      'ttl': '1h30m0s',
      'source': 'claim',
      'max': '1h30m0s',
      'max_source': 'deployment',
      'clamped': true,
    };
    await pumpTask(tester, server);
    expect(
      inRow('prop.lease', find.text('1 h 30 min, from the claim')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('lease.clamped')), findsOneWidget);
  });

  testWidgets('no lease row when the server will not say', (tester) async {
    server.failures['GET /api/v1/tasks/infra-1/lease'] = FakeResponse(
      403,
      envelope('forbidden', 'no'),
    );
    await pumpTask(tester, server);
    expect(find.byKey(const Key('prop.lease')), findsNothing);
    expect(find.byKey(const Key('prop.status')), findsOneWidget);
  });

  testWidgets('the tag picker leaves out a tag added elsewhere', (
    tester,
  ) async {
    await pumpTask(tester, server);
    server.task('infra-1')!['tags'] = ['auth', 'ops'];
    await press(tester, find.byKey(const Key('tag.open')));
    expect(find.byKey(const Key('tag.offer.backend')), findsOneWidget);
    expect(find.byKey(const Key('tag.offer.ops')), findsNothing);
    expect(server.requestsTo('/tasks/infra-1/tags'), hasLength(1));
  });
}
