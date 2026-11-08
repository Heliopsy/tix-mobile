// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/session/session.dart';
import 'package:tix_mobile/src/core/widgets/tix_mark.dart';
import 'package:tix_mobile/src/features/connect/presentation/connect_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/fake_tix.dart';
import '../../../helpers/stores.dart';

void main() {
  late FakeTix server;
  late MemorySecretStore secrets;

  setUp(() {
    server = FakeTix();
    secrets = MemorySecretStore();
  });

  Future<void> fill(WidgetTester tester, String url, String token) async {
    await tester.enterText(find.byKey(const Key('connect.url')), url);
    await tester.enterText(find.byKey(const Key('connect.token')), token);
    await tester.tap(find.byKey(const Key('connect.submit')));
    await tester.pumpAndSettle();
  }

  testWidgets('the tix mark heads the screen', (tester) async {
    await pumpScreen(
      tester,
      const ConnectScreen(),
      overrides: fakeOverrides(server, secrets: secrets),
    );
    expect(
      find.descendant(
        of: find.byType(ListView),
        matching: find.byType(TixMark),
      ),
      findsOneWidget,
    );
  });

  testWidgets('a good token signs in and lands in secure storage', (
    tester,
  ) async {
    final c = await pumpScreen(
      tester,
      const ConnectScreen(),
      overrides: fakeOverrides(server, secrets: secrets),
    );
    await fill(tester, 'tix.example', 'tok');
    expect(find.byKey(const Key('connect.error')), findsNothing);
    expect(c.read(sessionControllerProvider).value?.context.handle, 'ana');
    expect(secrets.values.values, ['tok']);
  });

  testWidgets('a refused token is explained and nothing is saved', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      const ConnectScreen(),
      overrides: fakeOverrides(server, secrets: secrets),
    );
    await fill(tester, 'tix.example', 'wrong');
    expect(
      tester.widget<Text>(find.byKey(const Key('connect.error'))).data,
      contains('token was not accepted'),
    );
    expect(secrets.values, isEmpty);
  });

  testWidgets('a bad address is refused in Bulgarian too', (tester) async {
    await pumpScreen(
      tester,
      const ConnectScreen(),
      overrides: fakeOverrides(server),
      locale: const Locale('bg'),
    );
    expect(find.text('Свързване с tix'), findsOneWidget);
    await fill(tester, 'ftp://nope', 'tok');
    expect(find.textContaining('Въведете адрес на сървър'), findsOneWidget);
    expect(server.requests, isEmpty);
  });

  for (final MapEntry(key: width, value: size) in widths.entries) {
    testWidgets('$width: busy while checking, fields locked', (tester) async {
      server.gate = Completer<void>();
      await pumpScreen(
        tester,
        const ConnectScreen(),
        size: size,
        overrides: fakeOverrides(server),
      );
      await tester.enterText(find.byKey(const Key('connect.url')), 'x.example');
      await tester.enterText(find.byKey(const Key('connect.token')), 'tok');
      await tester.tap(find.byKey(const Key('connect.submit')));
      await tester.pump();
      final button = tester.widget<FilledButton>(
        find.byKey(const Key('connect.submit')),
      );
      expect(button.onPressed, isNull);
      expect(
        find.descendant(
          of: find.byKey(const Key('connect.submit')),
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );
      final url = tester.widget<TextField>(
        find.byKey(const Key('connect.url')),
      );
      expect(url.enabled, isFalse);
      server.gate!.complete();
      await tester.pumpAndSettle();
    });
  }

  testWidgets('the token is hidden until asked for', (tester) async {
    await pumpScreen(
      tester,
      const ConnectScreen(),
      overrides: fakeOverrides(server),
    );
    EditableText token() => tester.widget<EditableText>(
      find.descendant(
        of: find.byKey(const Key('connect.token')),
        matching: find.byType(EditableText),
      ),
    );
    expect(token().obscureText, isTrue);
    await tester.tap(find.byIcon(Icons.visibility));
    await tester.pump();
    expect(token().obscureText, isFalse);
  });

  testWidgets('adding a server has a way back and goes to projects after', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      const ConnectScreen(adding: true),
      overrides: fakeOverrides(server),
    );
    expect(find.text('Add a server'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('connect.name')), 'Home');
    await fill(tester, 'tix.example', 'tok');
    expect(find.text('route:/projects'), findsOneWidget);
  });

  testWidgets('the back button of add leads to settings', (tester) async {
    await pumpScreen(
      tester,
      const ConnectScreen(adding: true),
      overrides: fakeOverrides(server),
    );
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('route:/settings'), findsOneWidget);
  });
}
