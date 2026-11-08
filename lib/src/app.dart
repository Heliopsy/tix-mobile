// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/accent_provider.dart';
import 'package:tix_mobile/src/core/design/theme.dart';
import 'package:tix_mobile/src/core/design/tokens.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/router/router.dart';
import 'package:tix_mobile/src/features/settings/application/settings.dart';

/// The tix app: router, theme and localisation.
class App extends ConsumerWidget {
  /// Creates the app.
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final theme = ref.watch(themeSettingProvider);
    final black = ref.watch(darkIsBlackProvider);
    final locale = ref.watch(localeSettingProvider);
    final accent = ref.watch(tenantAccentProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      theme: buildTixTheme(Brightness.light, accent: accent),
      darkTheme: buildTixTheme(
        Brightness.dark,
        accent: accent,
        base: black ? TixTokens.oled : null,
      ),
      themeMode: theme.mode,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}
