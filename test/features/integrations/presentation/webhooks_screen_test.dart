// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/features/integrations/presentation/webhooks_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_integrations.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;
  late FakeIntegrations fake;

  setUp(() {
    server = FakeTix();
    fake = FakeIntegrations(server);
  });

  Future<void> pump(
    WidgetTester tester, {
    Size size = phone,
    bool settle = true,
  }) {
    final stores = signedInStores();
    return pumpScreen(
      tester,
      const WebhooksScreen(),
      size: size,
      settle: settle,
      overrides: fakeOverrides(
        server,
        settings: stores.settings,
        secrets: stores.secrets,
      ),
    );
  }

  void seed() {
    fake.webhooks.add({
      'id': 'wh1',
      'url': 'https://hooks.example/tix',
      'event_types': ['task.*'],
      'active': true,
    });
    fake.deliveries.addAll([
      deliveryJson('d1'),
      deliveryJson('d2', status: 'failed', code: 500, error: 'boom'),
    ]);
  }

  for (final MapEntry(key: width, value: size) in widths.entries) {
    group(width, () {
      testWidgets('loading, then data', (tester) async {
        seed();
        server.gate = Completer<void>();
        await pump(tester, size: size, settle: false);
        expect(find.byType(SkeletonList), findsOneWidget);
        server.gate!.complete();
        await tester.pumpAndSettle();
        expect(find.byType(SkeletonList), findsNothing);
        expect(find.text('https://hooks.example/tix'), findsOneWidget);
        expect(find.byKey(const Key('delivery.d2')), findsOneWidget);
        expect(
          find.descendant(
            of: find.byKey(const Key('delivery.d2')),
            matching: find.text('boom'),
          ),
          findsOneWidget,
        );
      });

      testWidgets('empty carries the create action', (tester) async {
        await pump(tester, size: size);
        expect(find.text('No webhook endpoints yet.'), findsOneWidget);
        expect(find.text('No deliveries.'), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(EmptyState),
            matching: find.text('New endpoint'),
          ),
          findsOneWidget,
        );
      });

      testWidgets('error', (tester) async {
        server.override = FakeResponse(500, envelope('internal', 'x'));
        await pump(tester, size: size);
        expect(
          find.textContaining('The server had a problem.'),
          findsOneWidget,
        );
      });

      testWidgets('a new endpoint shows its generated secret once', (
        tester,
      ) async {
        await pump(tester, size: size);
        await tester.tap(find.byKey(const Key('webhooks.new')).first);
        await tester.pumpAndSettle();
        await tester.enterText(
          find.byKey(const Key('webhook.url')),
          'https://hooks.example/new',
        );
        await tester.tap(find.byKey(const Key('webhook.save')));
        await tester.pumpAndSettle();
        final put = server.requests.lastWhere((r) => r.method == 'PUT');
        expect(put.body.containsKey('secret'), isFalse);
        final secret = fake.secrets.values.single;
        expect(
          find.descendant(
            of: find.byKey(const Key('secret.values')),
            matching: find.text(secret),
          ),
          findsOneWidget,
        );
        await tester.tap(find.byKey(const Key('secret.done')));
        await tester.pumpAndSettle();
        expect(find.text(secret), findsNothing);
        expect(find.text('https://hooks.example/new'), findsOneWidget);
      });
    });
  }

  testWidgets('a refused address shows the server message in the form', (
    tester,
  ) async {
    await pump(tester);
    await tester.tap(find.byKey(const Key('webhooks.new')).first);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('webhook.url')),
      'http://plain.example',
    );
    await tester.tap(find.byKey(const Key('webhook.save')));
    await tester.pumpAndSettle();
    expect(find.textContaining('must use https'), findsOneWidget);
    expect(find.byKey(const Key('secret.values')), findsNothing);
    expect(fake.webhooks, isEmpty);
  });

  testWidgets('editing with a blank secret keeps it and shows none', (
    tester,
  ) async {
    seed();
    fake.secrets['wh1'] = 'old';
    await pump(tester);
    await tester.tap(find.text('https://hooks.example/tix'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit endpoint'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('webhook.save')));
    await tester.pumpAndSettle();
    expect(fake.secrets['wh1'], 'old');
    expect(find.byKey(const Key('secret.values')), findsNothing);
    expect(find.text('Endpoint saved.'), findsOneWidget);
  });

  testWidgets('delete is red and confirms first', (tester) async {
    seed();
    await pump(tester);
    await tester.tap(find.text('https://hooks.example/tix'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('webhook.delete')));
    await tester.pumpAndSettle();
    expect(fake.webhooks, isNotEmpty);
    await tester.tap(find.byKey(const Key('confirm.ok')));
    await tester.pumpAndSettle();
    expect(fake.webhooks, isEmpty);
    expect(find.text('https://hooks.example/tix'), findsNothing);
  });

  testWidgets('filters the log and redelivers', (tester) async {
    seed();
    await pump(tester, size: desktop);
    await tester.tap(find.byKey(const Key('deliveries.status.failed')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('delivery.d1')), findsNothing);
    expect(server.requests.last.uri.queryParametersAll['status'], ['failed']);
    await tester.tap(find.byKey(const Key('delivery.d2.redeliver')));
    await tester.pumpAndSettle();
    expect(fake.redelivered, ['d2']);
    expect(find.text('Queued for another attempt.'), findsOneWidget);
  });

  testWidgets("shows one endpoint's deliveries", (tester) async {
    seed();
    await pump(tester, size: desktop);
    await tester.tap(find.text('https://hooks.example/tix'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show its deliveries'));
    await tester.pumpAndSettle();
    expect(server.requests.last.uri.queryParameters['endpoint_id'], 'wh1');
    await tester.tap(find.byKey(const Key('deliveries.all')));
    await tester.pumpAndSettle();
    expect(
      server.requests.last.uri.queryParameters.containsKey('endpoint_id'),
      isFalse,
    );
  });

  testWidgets('send test shows what the endpoint answered', (tester) async {
    seed();
    await pump(tester, size: desktop);
    await tester.tap(find.text('https://hooks.example/tix'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('webhook.ping')));
    await tester.pumpAndSettle();
    expect(fake.pinged, ['wh1']);
    final result = find.byKey(const Key('ping.result'));
    expect(
      find.descendant(of: result, matching: find.text('Delivered')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: result, matching: find.text('HTTP 200')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('ping.done')));
    await tester.pumpAndSettle();
    expect(result, findsNothing);
    expect(find.byKey(const Key('delivery.ping1')), findsOneWidget);
  });

  testWidgets('a failed test shows the error', (tester) async {
    seed();
    fake.pingAnswer = (status: 'failed', code: 503, error: 'upstream down');
    await pump(tester);
    await tester.tap(find.text('https://hooks.example/tix'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('webhook.ping')));
    await tester.pumpAndSettle();
    final result = find.byKey(const Key('ping.result'));
    expect(
      find.descendant(of: result, matching: find.text('Failed')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: result, matching: find.text('HTTP 503')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: result, matching: find.text('upstream down')),
      findsOneWidget,
    );
  });

  testWidgets('an inactive endpoint offers no test', (tester) async {
    seed();
    fake.webhooks.single['active'] = false;
    await pump(tester);
    await tester.tap(find.text('https://hooks.example/tix'));
    await tester.pumpAndSettle();
    expect(find.text('Edit endpoint'), findsOneWidget);
    expect(find.byKey(const Key('webhook.ping')), findsNothing);
  });
}
