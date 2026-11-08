// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/accent.dart';
import 'package:tix_mobile/src/core/design/theme.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';

import 'app.dart';
import 'fake_tix.dart';

/// Pumps [child] in a scaffold under the tix theme at [size], with
/// [textScale] applied, and returns its container.
Future<ProviderContainer> pumpComponent(
  WidgetTester tester,
  Widget child, {
  Size size = phone,
  Brightness brightness = Brightness.light,
  TixAccent accent = TixAccent.standard,
  double textScale = 1,
  List<Override> overrides = const [],
}) async {
  await setSize(tester, size);
  final scope = ProviderScope(
    overrides: [...fakeOverrides(FakeTix()), ...overrides],
    child: MaterialApp(
      theme: buildTixTheme(brightness, accent: accent),
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: Scaffold(body: child),
        ),
      ),
    ),
  );
  await tester.pumpWidget(scope);
  await tester.pump();
  return ProviderScope.containerOf(tester.element(find.byWidget(child)));
}
