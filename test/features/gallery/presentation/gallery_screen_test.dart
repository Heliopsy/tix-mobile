// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/router/routes.dart';
import 'package:tix_mobile/src/features/gallery/presentation/gallery_screen.dart';

import '../../../helpers/app.dart';
import '../../../helpers/design.dart';

void main() {
  test('the gallery is routed in debug builds', () {
    expect(Routes.galleryEnabled, isTrue);
  });

  for (final MapEntry(key: width, value: size) in widths.entries) {
    testWidgets('$width: every block draws, in light, dark and OLED black', (
      tester,
    ) async {
      await pumpComponent(tester, const GalleryScreen(), size: size);
      expect(find.text('Tokens'), findsOneWidget);
      expect(tester.takeException(), isNull);
      TixTokens tokens() =>
          Theme.of(tester.element(find.text('Tokens'))).extension<TixTokens>()!;
      expect(tokens().bg, TixTokens.light.bg);
      for (final next in [TixTokens.dark, TixTokens.oled, TixTokens.light]) {
        await tester.tap(find.byKey(const Key('gallery.brightness')));
        await tester.pump();
        expect(tokens().bg, next.bg);
        expect(tester.takeException(), isNull);
      }
    });
  }

  testWidgets('a sample accent repaints the gallery only', (tester) async {
    await pumpComponent(tester, const GalleryScreen(), size: desktop);
    // The gallery shows a busy spinner and a breathing skeleton, so it never
    // settles; pump past the menu's animation instead.
    await tester.tap(find.byKey(const Key('gallery.accent')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    await tester.tap(find.widgetWithText(PopupMenuItem<TixAccent>, 'ember'));
    await tester.pump(const Duration(seconds: 1));
    final t = Theme.of(tester.element(find.text('Tokens')))
        .extension<TixTokens>()!;
    expect(t.accent, TixAccent.resolve('ember').accent);
  });
}
