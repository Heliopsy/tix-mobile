// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/router/router.dart';
import 'package:tix_mobile/src/core/theme/theme.dart';
import 'package:tix_mobile/src/features/settings/application/settings.dart';

/// The tix app: router, theme and localisation.
class TixApp extends ConsumerWidget {
  /// Creates the app.
  const TixApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeSettingProvider);
    final locale = ref.watch(localeSettingProvider);
    return DynamicColorBuilder(
      builder: (light, dark) => MaterialApp.router(
        onGenerateTitle: (context) => context.l10n.appTitle,
        debugShowCheckedModeBanner: false,
        theme: buildTheme(Brightness.light, scheme: light),
        darkTheme: buildTheme(Brightness.dark, scheme: dark),
        themeMode: themeMode,
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
  }
}
