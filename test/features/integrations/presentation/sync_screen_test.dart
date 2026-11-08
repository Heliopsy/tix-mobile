// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/features/integrations/presentation/sync_screen.dart';

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
      const SyncScreen(),
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
    fake.sources.add({
      'id': 's1',
      'name': 'jira-main',
      'system': 'jira',
      'config': {'url': 'https://jira.example', 'project': 'OPS'},
      'last_status': 'failed',
      'last_run_at': '2026-11-01T08:00:00Z',
      'credentials': [
        {'name': 'token', 'hint': 'abcd'},
      ],
      'resolved': {
        'missing': ['a mapping document'],
      },
    });
    fake.audit.add(
      auditJson(
        9,
        action: 'sync.run',
        subjectType: 'sync_source',
        after: {
          'source': 'jira-main',
          'system': 'jira',
          'created': {'task': 2},
          'warnings': ['field x ignored'],
        },
      ),
    );
  }

  Finder inSource(String text) => find.descendant(
    of: find.byKey(const Key('sync.s1')),
    matching: find.textContaining(text),
  );

  for (final MapEntry(key: width, value: size) in widths.entries) {
    group(width, () {
      testWidgets('loading, then data', (tester) async {
        seed();
        server.gate = Completer<void>();
        await pump(tester, size: size, settle: false);
        expect(find.byType(SkeletonList), findsOneWidget);
        server.gate!.complete();
        await tester.pumpAndSettle();
        expect(inSource('Last run failed'), findsOneWidget);
        expect(inSource('token …abcd'), findsOneWidget);
        expect(
          find.descendant(
            of: find.byKey(const Key('sync.s1.missing')),
            matching: find.textContaining('a mapping document'),
          ),
          findsOneWidget,
        );
        expect(find.textContaining('2 created'), findsOneWidget);
      });

      testWidgets('empty carries the create action', (tester) async {
        await pump(tester, size: size);
        expect(find.text('No sync sources yet.'), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(EmptyState),
            matching: find.text('New source'),
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
    });
  }

  testWidgets('a new source is checked, then saved with its credential', (
    tester,
  ) async {
    await pump(tester);
    await tester.tap(find.byKey(const Key('sync.new')).first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('sync.name')), 'jira-main');
    await tester.enterText(
      find.byKey(const Key('sync.setting.url')),
      'https://jira.example',
    );
    await tester.enterText(
      find.byKey(const Key('sync.token')),
      'secret-token-1234',
    );
    await tester.ensureVisible(find.byKey(const Key('sync.check')));
    await tester.tap(find.byKey(const Key('sync.check')));
    await tester.pumpAndSettle();
    expect(fake.sources, isEmpty);
    expect(
      find.descendant(
        of: find.byKey(const Key('sync.resolution')),
        matching: find.textContaining('a mapping document'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('sync.save')));
    await tester.pumpAndSettle();
    expect(fake.sources.single['name'], 'jira-main');
    expect(fake.credentials['jira-main'], {'token': 'secret-token-1234'});
    expect(server.requests.last.uri.path, '/api/v1/sync/sources');
    expect(find.text('Saved jira-main.'), findsOneWidget);
  });

  testWidgets("a refusal is shown in the server's words", (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(const Key('sync.new')).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sync.system')));
    await tester.tap(find.text('generic'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('sync.name')), 'file');
    await tester.enterText(
      find.byKey(const Key('sync.setting.file')),
      '/etc/passwd',
    );
    await tester.tap(find.byKey(const Key('sync.save')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const Key('sync.refusal')),
        matching: find.textContaining('does not read a file named by a tenant'),
      ),
      findsOneWidget,
    );
    expect(fake.sources, isEmpty);
  });

  testWidgets('run now previews, then runs, and shows what it did', (
    tester,
  ) async {
    seed();
    await pump(tester);
    await tester.tap(find.byKey(const Key('sync.s1.run')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sync.full')));
    await tester.tap(find.byKey(const Key('sync.preview')));
    await tester.pumpAndSettle();
    expect(fake.runs.single, {
      'source_id': 's1',
      'dry_run': true,
      'full': true,
    });
    expect(find.text('Nothing was changed.'), findsOneWidget);
    expect(
      find.text('3 created · 1 updated · 7 skipped · 0 deleted'),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('sync.result.close')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sync.s1.run')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sync.go')));
    await tester.pumpAndSettle();
    expect(fake.runs.last, {'source_id': 's1'});
    expect(find.text('Run finished'), findsOneWidget);
  });

  testWidgets('a refused run says why in the sheet', (tester) async {
    seed();
    server.failures['POST /api/v1/sync/run'] = FakeResponse(
      400,
      envelope('invalid', 'sync source "jira-main" cannot run'),
    );
    await pump(tester);
    await tester.tap(find.byKey(const Key('sync.s1.run')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sync.go')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const Key('sync.refusal')),
        matching: find.textContaining('cannot run'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('delete is red and confirms first', (tester) async {
    seed();
    await pump(tester, size: desktop);
    await tester.tap(find.byKey(const Key('sync.s1.delete')));
    await tester.pumpAndSettle();
    expect(fake.sources, isNotEmpty);
    await tester.tap(find.byKey(const Key('confirm.ok')));
    await tester.pumpAndSettle();
    expect(fake.sources, isEmpty);
  });

  testWidgets('editing keeps the system and shows the stored hint', (
    tester,
  ) async {
    seed();
    await pump(tester);
    await tester.tap(find.byKey(const Key('sync.s1.edit')));
    await tester.pumpAndSettle();
    expect(find.text('Edit jira-main'), findsOneWidget);
    expect(find.textContaining('token …abcd'), findsWidgets);
    await tester.tap(find.byKey(const Key('sync.save')));
    await tester.pumpAndSettle();
    final body = server.requests.lastWhere((r) => r.method == 'PUT').body;
    expect(body['id'], 's1');
    expect(body.containsKey('token'), isFalse);
    expect(body['config'], {'url': 'https://jira.example', 'project': 'OPS'});
  });
}
