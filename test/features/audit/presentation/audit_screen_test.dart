// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/features/audit/presentation/audit_screen.dart';

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
      const AuditScreen(),
      size: size,
      settle: settle,
      overrides: fakeOverrides(
        server,
        settings: stores.settings,
        secrets: stores.secrets,
      ),
    );
  }

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

  const pretty = JsonEncoder.withIndent('  ');

  void seed() => fake.audit.addAll([
    auditJson(
      3,
      action: 'task.update',
      via: 'api',
      token: 'ci-bot',
      before: {'title': 'Old title'},
      after: {'title': 'New title'},
    ),
    auditJson(2, via: 'ssh', source: 'tui'),
  ]);

  for (final MapEntry(key: width, value: size) in widths.entries) {
    group(width, () {
      testWidgets('loading, then data', (tester) async {
        seed();
        server.gate = Completer<void>();
        await pump(tester, size: size, settle: false);
        expect(find.byType(SkeletonList), findsOneWidget);
        server.gate!.complete();
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('audit.3')), findsOneWidget);
        expect(find.byKey(const Key('audit.2')), findsOneWidget);
      });

      testWidgets('empty', (tester) async {
        await pump(tester, size: size);
        expect(find.text('Nothing recorded yet.'), findsOneWidget);
      });

      testWidgets('error', (tester) async {
        server.override = FakeResponse(403, envelope('forbidden', 'no'));
        await pump(tester, size: size);
        expect(
          find.text('This token is not allowed to do that.'),
          findsOneWidget,
        );
      });

      testWidgets('an entry opens its detail with via and values', (
        tester,
      ) async {
        seed();
        await pump(tester, size: size);
        await tester.tap(find.byKey(const Key('audit.3')));
        await tester.pumpAndSettle();
        final detail = find.byKey(const Key('audit.detail.3'));
        expect(
          find.descendant(of: detail, matching: find.text('ci-bot')),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: detail,
            matching: find.textContaining('New title'),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: detail,
            matching: find.textContaining('Old title'),
          ),
          findsOneWidget,
        );
      });

      testWidgets('Copy JSON copies the entry as tix sent it', (tester) async {
        final copied = clipboard(tester);
        fake.audit.add({...auditJson(2, via: 'ssh'), 'novel': 1});
        await pump(tester, size: size);
        await tester.tap(find.byKey(const Key('audit.2')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('audit.copyJson')));
        await tester.pumpAndSettle();
        expect(copied, [
          pretty.convert({...auditJson(2, via: 'ssh'), 'novel': 1}),
        ]);
        expect(copied.single, contains('\n  "seq": 2,'));
        expect(
          find.descendant(
            of: find.byType(SnackBar),
            matching: find.text('JSON copied.'),
          ),
          findsOneWidget,
        );
      });
    });
  }

  testWidgets('a long press on a row copies its JSON', (tester) async {
    final copied = clipboard(tester);
    seed();
    await pump(tester);
    await tester.longPress(find.byKey(const Key('audit.2')));
    await tester.pumpAndSettle();
    expect(copied, [pretty.convert(auditJson(2, via: 'ssh', source: 'tui'))]);
    expect(find.byKey(const Key('audit.detail.2')), findsNothing);
    expect(
      find.descendant(
        of: find.byType(SnackBar),
        matching: find.text('JSON copied.'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('channel chips narrow the log', (tester) async {
    seed();
    await pump(tester);
    await tester.tap(find.byKey(const Key('audit.via.ssh')));
    await tester.pumpAndSettle();
    expect(server.requests.last.uri.queryParametersAll['via'], ['ssh']);
    expect(find.byKey(const Key('audit.3')), findsNothing);
    expect(find.byKey(const Key('audit.2')), findsOneWidget);
    await tester.tap(find.byKey(const Key('audit.clear')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('audit.3')), findsOneWidget);
  });

  testWidgets('search and more filters reach the server', (tester) async {
    seed();
    await pump(tester, size: desktop);
    await tester.enterText(find.byKey(const Key('audit.text')), 'update');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(server.requests.last.uri.queryParameters['text'], 'update');
    await tester.tap(find.byKey(const Key('audit.more')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('audit.source.cli')));
    await tester.enterText(find.byKey(const Key('audit.token')), 'ci-bot');
    await tester.enterText(
      find.byKey(const Key('audit.action')),
      'task.update',
    );
    await tester.tap(find.byKey(const Key('audit.apply')));
    await tester.pumpAndSettle();
    final q = server.requests.last.uri.queryParametersAll;
    expect(q['source'], ['cli']);
    expect(q['token'], ['ci-bot']);
    expect(q['action'], ['task.update']);
    expect(q['text'], ['update']);
    expect(find.text('More filters (2)'), findsOneWidget);
    expect(find.text('No entries match.'), findsOneWidget);
  });
}
