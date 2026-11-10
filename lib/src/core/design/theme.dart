// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/accent.dart';
import 'package:tix_mobile/src/core/design/colour.dart';
import 'package:tix_mobile/src/core/design/tokens.dart';

/// The app's theme for [brightness] with the tenant's [accent]: Material 3
/// underneath, tix's tokens on top. [base] picks another scheme of the same
/// brightness, such as [TixTokens.dim].
ThemeData buildTixTheme(
  Brightness brightness, {
  TixAccent accent = TixAccent.standard,
  TixTokens? base,
}) {
  final t = (base ?? TixTokens.of(brightness)).withAccent(accent);
  final dark = t.isDark;
  final scheme = ColorScheme(
    brightness: brightness,
    primary: t.accent,
    onPrimary: t.onAccent,
    primaryContainer: t.accentSoft,
    onPrimaryContainer: t.accent,
    secondary: t.muted,
    onSecondary: t.bg,
    secondaryContainer: t.accentSoft,
    onSecondaryContainer: t.ink,
    tertiary: t.projects[ProjectColour.violet],
    onTertiary: t.bg,
    error: t.danger,
    onError: t.onDanger,
    errorContainer: t.dangerSoft,
    onErrorContainer: t.danger,
    surface: t.bg,
    onSurface: t.ink,
    onSurfaceVariant: t.muted,
    surfaceDim: t.surface,
    surfaceBright: t.bg,
    surfaceContainerLowest: t.bg,
    surfaceContainerLow: t.surface,
    surfaceContainer: t.surface,
    surfaceContainerHigh: t.surface,
    surfaceContainerHighest: t.line,
    outline: t.lineStrong,
    outlineVariant: t.line,
    shadow: const Color(0xFF000000),
    scrim: t.scrim,
    inverseSurface: t.ink,
    onInverseSurface: t.bg,
    inversePrimary: dark ? TixAccent.standard.accent : accent.accentDark,
    surfaceTint: Colors.transparent,
  );
  final typography = Typography.material2021(platform: defaultTargetPlatform);
  final text = (dark ? typography.white : typography.black).merge(
    tixTextTheme(t),
  );
  final controlShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(TixRadius.md),
  );
  const controlSize = Size(64, TixSize.control);
  const controlPadding = EdgeInsets.symmetric(horizontal: TixSpace.s4);
  final controlText = text.labelLarge;
  OutlineInputBorder field(Color c, [double w = 1]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(TixRadius.md),
    borderSide: BorderSide(color: c, width: w),
  );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    textTheme: text,
    extensions: [t],
    scaffoldBackgroundColor: t.bg,
    canvasColor: t.bg,
    dividerColor: t.line,
    disabledColor: t.muted.withValues(alpha: 0.6),
    hoverColor: t.ink.withValues(alpha: 0.04),
    focusColor: t.accent.withValues(alpha: 0.12),
    highlightColor: Colors.transparent,
    splashColor: t.accent.withValues(alpha: 0.08),
    splashFactory: InkRipple.splashFactory,
    visualDensity: VisualDensity.standard,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: t.accent,
      selectionColor: t.accent.withValues(alpha: 0.28),
      selectionHandleColor: t.accent,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: t.bg,
      foregroundColor: t.ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: TixSpace.s4,
      iconTheme: IconThemeData(color: t.ink, size: 22),
      actionsIconTheme: IconThemeData(color: t.muted, size: 22),
      titleTextStyle: text.titleLarge,
      shape: Border(bottom: BorderSide(color: t.line)),
    ),
    iconTheme: IconThemeData(color: t.muted, size: 20),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: t.accent,
        foregroundColor: t.onAccent,
        disabledBackgroundColor: t.accent.withValues(alpha: 0.4),
        disabledForegroundColor: t.onAccent.withValues(alpha: 0.8),
        minimumSize: controlSize,
        padding: controlPadding,
        shape: controlShape,
        textStyle: controlText,
        elevation: 0,
      ).copyWith(overlayColor: _overlay(t.onAccent)),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: t.surface,
        foregroundColor: t.ink,
        disabledForegroundColor: t.muted,
        side: BorderSide(color: t.lineStrong),
        minimumSize: controlSize,
        padding: controlPadding,
        shape: controlShape,
        textStyle: controlText,
      ).copyWith(overlayColor: _overlay(t.ink)),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: t.accent,
        disabledForegroundColor: t.muted,
        minimumSize: controlSize,
        padding: const EdgeInsets.symmetric(horizontal: TixSpace.s3),
        shape: controlShape,
        textStyle: controlText,
      ).copyWith(overlayColor: _overlay(t.accent)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: t.surface,
        foregroundColor: t.ink,
        elevation: 0,
        minimumSize: controlSize,
        padding: controlPadding,
        shape: controlShape,
        textStyle: controlText,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: t.muted,
        highlightColor: t.ink.withValues(alpha: 0.06),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: t.accent,
      foregroundColor: t.onAccent,
      elevation: dark ? 0 : 2,
      focusElevation: dark ? 0 : 3,
      hoverElevation: dark ? 0 : 3,
      highlightElevation: dark ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TixRadius.lg),
      ),
      extendedTextStyle: text.labelLarge?.copyWith(fontSize: TixText.md),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? t.accent : t.bg,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? t.onAccent : t.ink,
        ),
        iconColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? t.onAccent : t.muted,
        ),
        side: WidgetStatePropertyAll(BorderSide(color: t.lineStrong)),
        shape: WidgetStatePropertyAll(controlShape),
        textStyle: WidgetStatePropertyAll(text.labelLarge),
        minimumSize: const WidgetStatePropertyAll(controlSize),
      ),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: t.bg,
      hoverColor: Colors.transparent,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: TixSpace.s3,
        vertical: TixSpace.s3,
      ),
      border: field(t.line),
      enabledBorder: field(t.line),
      disabledBorder: field(t.line.withValues(alpha: 0.6)),
      focusedBorder: field(t.accent, 2),
      errorBorder: field(t.danger),
      focusedErrorBorder: field(t.danger, 2),
      labelStyle: text.bodyMedium?.copyWith(color: t.muted),
      floatingLabelStyle: text.labelMedium?.copyWith(color: t.accent),
      hintStyle: text.bodyMedium?.copyWith(
        color: t.muted,
        fontStyle: FontStyle.italic,
      ),
      helperStyle: text.bodySmall,
      helperMaxLines: 4,
      errorStyle: text.bodySmall?.copyWith(color: t.danger),
      errorMaxLines: 4,
      prefixIconColor: t.muted,
      suffixIconColor: t.muted,
    ),
    cardTheme: CardThemeData(
      color: t.bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: TixSpace.s3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TixRadius.lg),
        side: BorderSide(color: t.line),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    listTileTheme: ListTileThemeData(
      iconColor: t.muted,
      textColor: t.ink,
      selectedColor: t.accent,
      selectedTileColor: t.accentSoft,
      contentPadding: const EdgeInsets.symmetric(horizontal: TixSpace.s4),
      minVerticalPadding: TixSpace.s2,
      titleTextStyle: text.bodyLarge?.copyWith(fontSize: TixText.md),
      subtitleTextStyle: text.bodySmall,
      leadingAndTrailingTextStyle: text.bodySmall,
    ),
    dividerTheme: DividerThemeData(color: t.line, thickness: 1, space: 1),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: t.bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      height: 64,
      indicatorColor: t.accentSoft,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TixRadius.md),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(
          color: s.contains(WidgetState.selected) ? t.accent : t.muted,
          size: 22,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => text.labelMedium?.copyWith(
          color: s.contains(WidgetState.selected) ? t.ink : t.muted,
          fontWeight: s.contains(WidgetState.selected)
              ? FontWeight.w600
              : FontWeight.w500,
        ),
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: t.surface,
      elevation: 0,
      indicatorColor: t.accentSoft,
      indicatorShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TixRadius.md),
      ),
      selectedIconTheme: IconThemeData(color: t.accent, size: 22),
      unselectedIconTheme: IconThemeData(color: t.muted, size: 22),
      selectedLabelTextStyle: text.labelLarge?.copyWith(
        color: t.ink,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelTextStyle: text.labelLarge?.copyWith(color: t.muted),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: t.surface,
      surfaceTintColor: Colors.transparent,
      elevation: dark ? 0 : 6,
      shadowColor: const Color(0x33101828),
      barrierColor: t.scrim,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TixRadius.lg),
        side: BorderSide(color: t.line),
      ),
      titleTextStyle: text.titleLarge,
      contentTextStyle: text.bodyMedium,
      actionsPadding: const EdgeInsets.fromLTRB(
        TixSpace.s5,
        0,
        TixSpace.s5,
        TixSpace.s5,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: t.surface,
      modalBackgroundColor: t.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      modalElevation: 0,
      modalBarrierColor: t.scrim,
      showDragHandle: true,
      dragHandleColor: t.lineStrong,
      dragHandleSize: const Size(36, 4),
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(TixRadius.lg),
        ),
        side: BorderSide(color: t.line),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      dismissDirection: DismissDirection.horizontal,
      backgroundColor: t.accentSoft,
      contentTextStyle: text.bodyMedium?.copyWith(color: t.accent),
      actionTextColor: t.accent,
      closeIconColor: t.accent,
      elevation: dark ? 0 : 4,
      insetPadding: const EdgeInsets.all(TixSpace.gutter),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(9),
        side: BorderSide(color: t.line),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: t.bg,
      selectedColor: t.accentSoft,
      disabledColor: t.surface,
      checkmarkColor: t.accent,
      deleteIconColor: t.muted,
      side: BorderSide(color: t.line),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TixRadius.pill),
      ),
      labelStyle: text.labelMedium?.copyWith(color: t.ink),
      secondaryLabelStyle: text.labelMedium?.copyWith(color: t.accent),
      padding: const EdgeInsets.symmetric(horizontal: TixSpace.s1),
      showCheckmark: false,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: t.surface,
      surfaceTintColor: Colors.transparent,
      elevation: dark ? 0 : 6,
      shadowColor: const Color(0x38000000),
      textStyle: text.bodyMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TixRadius.lg),
        side: BorderSide(color: t.lineStrong),
      ),
    ),
    menuTheme: MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(t.surface),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TixRadius.lg),
            side: BorderSide(color: t.lineStrong),
          ),
        ),
      ),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: t.ink,
        borderRadius: BorderRadius.circular(TixRadius.sm),
      ),
      textStyle: text.labelMedium?.copyWith(color: t.bg),
      waitDuration: const Duration(milliseconds: 400),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: t.accent,
      linearTrackColor: t.line,
      circularTrackColor: Colors.transparent,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? t.onAccent : t.muted,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? t.accent : t.surface,
      ),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? t.accent : t.lineStrong,
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? t.accent : Colors.transparent,
      ),
      checkColor: WidgetStatePropertyAll(t.onAccent),
      side: BorderSide(color: t.lineStrong, width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? t.accent : t.lineStrong,
      ),
    ),
    badgeTheme: BadgeThemeData(
      backgroundColor: t.accent,
      textColor: t.onAccent,
      textStyle: text.labelSmall,
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbColor: WidgetStatePropertyAll(t.lineStrong),
      radius: const Radius.circular(TixRadius.pill),
    ),
    expansionTileTheme: ExpansionTileThemeData(
      iconColor: t.muted,
      collapsedIconColor: t.muted,
      textColor: t.ink,
    ),
  );
}

WidgetStateProperty<Color?> _overlay(Color c) =>
    WidgetStateProperty.resolveWith((s) {
      if (s.contains(WidgetState.pressed)) return c.withValues(alpha: 0.14);
      if (s.contains(WidgetState.hovered)) return c.withValues(alpha: 0.08);
      if (s.contains(WidgetState.focused)) return c.withValues(alpha: 0.12);
      return null;
    });

/// tix's type scale as a Material [TextTheme]. Headings tighten as they
/// grow, as `030-typography.css` sets them.
TextTheme tixTextTheme(TixTokens t) {
  TextStyle s(
    double size,
    FontWeight weight, {
    double height = TixText.bodyHeight,
    double tracking = 0,
    Color? color,
  }) => TextStyle(
    fontSize: size,
    fontWeight: weight,
    height: height,
    letterSpacing: size * tracking,
    color: color ?? t.ink,
    textBaseline: TextBaseline.alphabetic,
    leadingDistribution: TextLeadingDistribution.even,
  );
  return TextTheme(
    displayLarge: s(TixText.xl3, FontWeight.w600, height: 1.15, tracking: -.02),
    displayMedium: s(
      TixText.xl3,
      FontWeight.w600,
      height: 1.15,
      tracking: -.02,
    ),
    displaySmall: s(TixText.xl3, FontWeight.w600, height: 1.15, tracking: -.02),
    headlineLarge: s(
      TixText.xl2,
      FontWeight.w600,
      height: 1.2,
      tracking: -.021,
    ),
    headlineMedium: s(
      TixText.xl2,
      FontWeight.w600,
      height: 1.2,
      tracking: -.021,
    ),
    headlineSmall: s(
      TixText.xl2,
      FontWeight.w600,
      height: 1.2,
      tracking: -.021,
    ),
    titleLarge: s(TixText.lg, FontWeight.w600, height: 1.3, tracking: -.013),
    titleMedium: s(TixText.md, FontWeight.w600, height: 1.35, tracking: -.006),
    titleSmall: s(TixText.sm, FontWeight.w600, height: 1.35),
    bodyLarge: s(TixText.base, FontWeight.w400),
    bodyMedium: s(TixText.md, FontWeight.w400),
    bodySmall: s(TixText.sm, FontWeight.w400, height: 1.5, color: t.muted),
    labelLarge: s(TixText.sm, FontWeight.w500, height: 1.2),
    labelMedium: s(TixText.xs, FontWeight.w500, height: 1.3),
    labelSmall: s(TixText.xs2, FontWeight.w600, height: 1.3, tracking: .01),
  );
}

/// The monospace style tix sets references and keys in.
TextStyle tixMono(BuildContext context, {double? size, Color? color}) =>
    TextStyle(
      fontFamily: 'monospace',
      fontFamilyFallback: TixText.mono,
      fontSize: size ?? TixText.xs,
      color: color ?? context.tix.muted,
      fontFeatures: const [FontFeature.tabularFigures()],
      height: 1.3,
    );

/// Whether [c] reads at [floor] on [bg]; exposed for the contrast tests.
bool readsOn(Color c, Color bg, [double floor = contrastFloor]) =>
    contrast(c, bg) >= floor;
