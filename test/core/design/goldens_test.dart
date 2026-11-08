// SPDX-License-Identifier: AGPL-3.0-or-later

@Tags(['golden'])
library;

import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/design.dart';
import 'package:tix_mobile/src/core/design/theme.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/features/gallery/presentation/gallery_sections.dart';

import '../../helpers/app.dart';
import '../../helpers/fake_tix.dart';

/// Goldens are drawn and compared on Linux only; see docs/testing.md.
final bool onLinux = Platform.isLinux;

Future<void> pumpGolden(
  WidgetTester tester,
  Widget child, {
  required Size size,
  required Brightness brightness,
  TixAccent accent = TixAccent.standard,
  TixTokens? base,
}) async {
  await setSize(tester, Size(size.width, 2600));
  await tester.pumpWidget(
    ProviderScope(
      overrides: fakeOverrides(FakeTix()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: buildTixTheme(brightness, accent: accent, base: base),
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: MediaQueryData(
            size: Size(size.width, 2600),
            disableAnimations: true,
          ),
          child: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: RepaintBoundary(
                key: const Key('golden'),
                child: Material(
                  color: buildTixTheme(
                    brightness,
                    accent: accent,
                    base: base,
                  ).scaffoldBackgroundColor,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: TixSpace.s5),
                    child: SizedBox(
                      width: size.width,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [child],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  const sizes = {'phone': Size(400, 0), 'desktop': Size(1280, 0)};
  final sections = <String, Widget Function()>{
    'controls': () => const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GalleryBlock(title: 'Buttons', child: GalleryButtons()),
        GalleryBlock(title: 'Markings', child: GalleryMarks()),
      ],
    ),
    'tasks': () => const GalleryBlock(title: 'Tasks', child: GalleryTasks()),
    'inbox': () => const GalleryBlock(title: 'Inbox', child: GalleryInbox()),
    'forms': () => const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GalleryBlock(title: 'Forms', child: GalleryForms()),
        GalleryBlock(title: 'States', child: GalleryStates()),
      ],
    ),
    'record': () => const GalleryBlock(title: 'Record', child: GalleryRecord()),
    'manage': () => const GalleryBlock(title: 'Manage', child: GalleryManage()),
    'live': () => const GalleryBlock(title: 'Live', child: GalleryLive()),
  };
  Widget choices() =>
      const GalleryBlock(title: 'Choices', child: GalleryChoices());

  for (final brightness in Brightness.values) {
    for (final MapEntry(key: width, value: size) in sizes.entries) {
      for (final MapEntry(key: name, value: build) in sections.entries) {
        testWidgets('$name, ${brightness.name}, $width', (tester) async {
          await pumpGolden(tester, build(), size: size, brightness: brightness);
          await expectLater(
            find.byKey(const Key('golden')),
            matchesGoldenFile('goldens/$name-${brightness.name}-$width.png'),
          );
        }, skip: !onLinux);
      }
    }
    testWidgets('a tenant accent, ${brightness.name}', (tester) async {
      await pumpGolden(
        tester,
        const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GalleryBlock(title: 'Buttons', child: GalleryButtons()),
            GalleryBlock(title: 'Tasks', child: GalleryTasks()),
          ],
        ),
        size: const Size(400, 0),
        brightness: brightness,
        accent: TixAccent.resolve('ember'),
      );
      await expectLater(
        find.byKey(const Key('golden')),
        matchesGoldenFile('goldens/accent-ember-${brightness.name}.png'),
      );
    }, skip: !onLinux);
  }

  for (final MapEntry(key: width, value: size) in sizes.entries) {
    for (final MapEntry(key: name, value: build) in {
      ...sections,
      'choices': choices,
    }.entries) {
      testWidgets('$name, oled, $width', (tester) async {
        await pumpGolden(
          tester,
          build(),
          size: size,
          brightness: Brightness.dark,
          base: TixTokens.oled,
        );
        await expectLater(
          find.byKey(const Key('golden')),
          matchesGoldenFile('goldens/$name-oled-$width.png'),
        );
      }, skip: !onLinux);
    }
  }

  for (final brightness in Brightness.values) {
    testWidgets('choices, ${brightness.name}', (tester) async {
      await pumpGolden(
        tester,
        choices(),
        size: const Size(400, 0),
        brightness: brightness,
      );
      await expectLater(
        find.byKey(const Key('golden')),
        matchesGoldenFile('goldens/choices-${brightness.name}-phone.png'),
      );
    }, skip: !onLinux);
  }

  testWidgets('a tenant accent, oled', (tester) async {
    await pumpGolden(
      tester,
      const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GalleryBlock(title: 'Buttons', child: GalleryButtons()),
          GalleryBlock(title: 'Tasks', child: GalleryTasks()),
        ],
      ),
      size: const Size(400, 0),
      brightness: Brightness.dark,
      accent: TixAccent.resolve('ember'),
      base: TixTokens.oled,
    );
    await expectLater(
      find.byKey(const Key('golden')),
      matchesGoldenFile('goldens/accent-ember-oled.png'),
    );
  }, skip: !onLinux);
}
