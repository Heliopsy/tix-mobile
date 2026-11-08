// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/accent_provider.dart';
import 'package:tix_mobile/src/core/design/components/motion.dart';
import 'package:tix_mobile/src/core/design/theme.dart';
import 'package:tix_mobile/src/core/design/tokens.dart';
import 'package:tix_mobile/src/core/l10n/l10n.dart';
import 'package:tix_mobile/src/core/router/router.dart';
import 'package:tix_mobile/src/core/time/reader_time.dart';
import 'package:tix_mobile/src/core/time/times.dart';
import 'package:tix_mobile/src/features/settings/application/settings.dart';

/// The tix app: router, theme, localisation and the reader's date style.
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
    final time = ref.watch(readerTimeStyleProvider);
    final still = ref.watch(reduceMotionSettingProvider);
    TixHaptics.enabled = ref.watch(hapticsSettingProvider);
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
      localeListResolutionCallback: resolveLocale,
      routerConfig: router,
      builder: (context, child) {
        final body = TixTimeScope(style: time, child: child!);
        if (!still) return body;
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: body,
        );
      },
    );
  }
}
