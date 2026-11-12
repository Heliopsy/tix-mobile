// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/features/tokens/presentation/connect_agent_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_tix.dart';

void main() {
  late FakeTix server;

  setUp(() {
    server = FakeTix();
    server.routes.add((o, path, _) {
      if (o.method == 'POST' && path == '/api/v1/tokens') {
        final body = o.data as Map<String, dynamic>;
        return FakeResponse(201, {
          'id': 't9',
          'name': body['name'],
          'scopes': body['scopes'],
          'actor_id': 'me',
          'token': 'tix_secret_value',
        });
      }
      return null;
    });
  });

  Future<void> pump(WidgetTester tester, {Size size = phone}) {
    final stores = signedInStores();
    return pumpScreen(
      tester,
      const ConnectAgentScreen(),
      size: size,
      overrides: fakeOverrides(
        server,
        settings: stores.settings,
        secrets: stores.secrets,
      ),
    );
  }

  Future<void> reveal(WidgetTester tester, Finder target) =>
      tester.scrollUntilVisible(
        target,
        300,
        scrollable: find
            .descendant(
              of: find.byType(ListView).first,
              matching: find.byType(Scrollable),
            )
            .first,
      );

  String snippet(WidgetTester tester, String id) =>
      tester.widget<SelectableText>(find.byKey(Key('connect.text.$id'))).data!;

  for (final MapEntry(key: width, value: size) in widths.entries) {
    testWidgets('$width: commands for this server, a placeholder token', (
      tester,
    ) async {
      await pump(tester, size: size);
      await reveal(tester, find.byKey(const Key('connect.text.cli-ctx')));
      expect(snippet(tester, 'cli-ctx'), contains(r'--token $TIX_TOKEN'));
      expect(snippet(tester, 'cli-ctx'), contains('--tenant default'));
    });
  }

  testWidgets('an issued token fills every command and the MCP tabs', (
    tester,
  ) async {
    await pump(tester);
    await tester.tap(find.byKey(const Key('connect.issue')));
    await tester.pumpAndSettle();
    expect(find.text('mcp-agent'), findsWidgets);
    await tester.tap(find.byKey(const Key('tokens.submit')));
    await tester.pumpAndSettle();
    final sent =
        server
                .requestsTo('/api/v1/tokens')
                .singleWhere((o) => o.method == 'POST')
                .data
            as Map;
    expect(sent['name'], 'mcp-agent');
    expect(sent['scopes'], containsAll(['task:read', 'task:claim']));
    expect(find.byKey(const Key('connect.secret')), findsOneWidget);
    await reveal(tester, find.byKey(const Key('connect.text.cli-ctx')));
    expect(snippet(tester, 'cli-ctx'), contains('--token tix_secret_value'));
    await tester.tap(find.text('MCP'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Codex'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const Key('connect.text.mcp-codex-2')),
    );
    await tester.pumpAndSettle();
    expect(
      snippet(tester, 'mcp-codex-2'),
      contains('TIX_TOKEN = "tix_secret_value"'),
    );
  });

  testWidgets('without token:admin no Issue button, and it says why', (
    tester,
  ) async {
    server.identity = {
      'scopes': ['task:read'],
    };
    await pump(tester);
    expect(find.byKey(const Key('connect.issue')), findsNothing);
    expect(find.byKey(const Key('connect.noAdmin')), findsOneWidget);
  });
}
