// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:material_ui/material_ui.dart';
import 'package:tix_mobile/src/core/design/accent.dart';
import 'package:tix_mobile/src/core/design/colour.dart';

/// The 4px spacing grid, tix's `--space-1` to `--space-7`.
abstract final class TixSpace {
  /// 4.
  static const s1 = 4.0;

  /// 8.
  static const s2 = 8.0;

  /// 12.
  static const s3 = 12.0;

  /// 16.
  static const s4 = 16.0;

  /// 24.
  static const s5 = 24.0;

  /// 32.
  static const s6 = 32.0;

  /// 48.
  static const s7 = 48.0;

  /// The page's side margin, `--gutter`.
  static const gutter = 16.0;

  /// From a page heading block to the first thing under it, `--head-gap`.
  static const double headGap = s4;

  /// From a heading to the line that qualifies it, `--head-sub`.
  static const double headSub = s1;
}

/// Corner radii, `--radius-*`.
abstract final class TixRadius {
  /// Small marks: status pills, tags, project refs.
  static const sm = 6.0;

  /// Controls: buttons, fields, segmented controls.
  static const md = 8.0;

  /// Lists, dialogs and toasts, `--radius`.
  static const base = 10.0;

  /// Cards, sheets and popovers.
  static const lg = 12.0;

  /// Fully rounded.
  static const pill = 999.0;
}

/// Control and target sizes.
abstract final class TixSize {
  /// A control's height with a pointer, `--control-h`.
  static const control = 36.0;

  /// A small control, `--control-h-sm`.
  static const controlSmall = 28.0;

  /// A control standing on its own on a touch screen (tix's 44px).
  static const controlTouch = 44.0;

  /// The smallest hit area of anything pressable (Material's 48dp).
  static const target = 48.0;

  /// The completion circle on a task row.
  static const check = 22.0;
}

/// The nine type steps, `--text-2xs` to `--text-3xl`, in logical pixels.
abstract final class TixText {
  /// 11.
  static const xs2 = 11.0;

  /// 12.
  static const xs = 12.0;

  /// 13.
  static const sm = 13.0;

  /// 15, the body size.
  static const md = 15.0;

  /// 16.
  static const base = 16.0;

  /// 18, a section heading (`h2`).
  static const lg = 18.0;

  /// 21.
  static const xl = 21.0;

  /// 24, a page heading (`h1`).
  static const xl2 = 24.0;

  /// 32.
  static const xl3 = 32.0;

  /// The body's line height.
  static const bodyHeight = 1.55;

  /// The monospace stack for references and keys.
  static const mono = ['SF Mono', 'Menlo', 'Consolas', 'monospace'];
}

/// How wide things may grow, `--measure-*`.
abstract final class TixMeasure {
  /// Any screen's column.
  static const page = 1560.0;

  /// Running prose, about 76 characters.
  static const text = 600.0;

  /// A single-line field.
  static const field = 512.0;

  /// A form.
  static const form = 920.0;

  /// A chart.
  static const chart = 760.0;

  /// The sidebar.
  static const side = 224.0;
}

/// Durations and curves. Nothing in the app animates outside these.
abstract final class TixMotion {
  /// Hover and colour changes.
  static const fast = Duration(milliseconds: 120);

  /// Rows settling and toasts arriving.
  static const base = Duration(milliseconds: 200);

  /// A completed row's highlight and the tick's pop.
  static const slow = Duration(milliseconds: 320);

  /// The default curve, CSS `ease`.
  static const ease = Cubic(0.25, 0.1, 0.25, 1);

  /// How long a row just ticked keeps its place, so the tick and the
  /// strike-through finish before the row moves or leaves the list.
  static const settle = Duration(milliseconds: 440);

  /// The completion tick's overshoot.
  static const pop = Cubic(0.34, 1.56, 0.64, 1);

  /// [d], or nothing when the platform asks for reduced motion.
  static Duration of(BuildContext context, Duration d) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false ? Duration.zero : d;
}

/// The eight project colours. A project stores the name, each scheme draws
/// its own shade.
enum ProjectColour { slate, red, amber, green, teal, blue, violet, pink }

/// The fixed vocabulary a workflow state belongs to. Colours key off the
/// category, never the state's name, and never follow a tenant's accent.
enum StatusCategory {
  /// Not started.
  todo,

  /// Being worked on.
  inProgress,

  /// Stuck on something.
  blocked,

  /// Waiting on someone outside.
  waiting,

  /// Finished.
  done,

  /// Dropped. Not completed work, so never green.
  cancelled,

  /// A state the app cannot place.
  unknown;

  /// The category of the state [status] in tix's built-in workflows.
  static StatusCategory guess(String status) =>
      switch (status.toLowerCase().replaceAll(RegExp('[ _-]'), '')) {
        'todo' || 'open' || 'new' || 'backlog' || 'ready' => todo,
        'doing' || 'inprogress' || 'started' || 'review' => inProgress,
        'blocked' => blocked,
        'waiting' || 'onhold' => waiting,
        'done' || 'closed' || 'resolved' || 'completed' => done,
        'cancelled' || 'canceled' || 'wontdo' || 'archived' => cancelled,
        _ => unknown,
      };
}

/// tix's design tokens for one scheme, with the active tenant's accent.
///
/// Read them with `context.tix`. Status, priority and project colours are
/// fixed per scheme; only [accent], [accentSoft] and [onAccent] follow the
/// tenant.
@immutable
class TixTokens extends ThemeExtension<TixTokens> {
  /// Tokens with every colour given.
  const TixTokens({
    required this.brightness,
    required this.bg,
    required this.surface,
    required this.ink,
    required this.muted,
    required this.line,
    required this.lineStrong,
    required this.accent,
    required this.accentSoft,
    required this.onAccent,
    required this.brand,
    required this.brandSoft,
    required this.danger,
    required this.dangerSoft,
    required this.onDanger,
    required this.warn,
    required this.warnSoft,
    required this.ok,
    required this.okSoft,
    required this.onOk,
    required this.scrim,
    required this.shadow,
    required this.shadowStrong,
    required this.projects,
  });

  /// The light scheme, `:root`.
  static const light = TixTokens(
    brightness: Brightness.light,
    bg: Color(0xFFFFFFFF),
    surface: Color(0xFFF6F7F9),
    ink: Color(0xFF0F1319),
    muted: Color(0xFF5F6B7A),
    line: Color(0xFFEBEDF1),
    lineStrong: Color(0xFFD6DAE1),
    accent: Color(0xFF0F766E),
    accentSoft: Color(0xFFE6F4F1),
    onAccent: Color(0xFFFFFFFF),
    brand: Color(0xFF0F766E),
    brandSoft: Color(0xFFE6F4F1),
    danger: Color(0xFFB42318),
    dangerSoft: Color(0xFFFEF3F2),
    onDanger: Color(0xFFFFFFFF),
    warn: Color(0xFFB54708),
    warnSoft: Color(0xFFFFFAEB),
    ok: Color(0xFF067647),
    okSoft: Color(0xFFECFDF3),
    onOk: Color(0xFFFFFFFF),
    scrim: Color(0x73101828),
    shadow: [
      BoxShadow(color: Color(0x0D101828), offset: Offset(0, 1), blurRadius: 2),
    ],
    shadowStrong: [
      BoxShadow(color: Color(0x1F101828), offset: Offset(0, 6), blurRadius: 18),
    ],
    projects: {
      ProjectColour.slate: Color(0xFF5E6E85),
      ProjectColour.red: Color(0xFFDC2626),
      ProjectColour.amber: Color(0xFFB45309),
      ProjectColour.green: Color(0xFF15803D),
      ProjectColour.teal: Color(0xFF0F766E),
      ProjectColour.blue: Color(0xFF2563EB),
      ProjectColour.violet: Color(0xFF7C3AED),
      ProjectColour.pink: Color(0xFFBE185D),
    },
  );

  /// The dark scheme, `:root[data-theme="dark"]`.
  static const dark = TixTokens(
    brightness: Brightness.dark,
    bg: Color(0xFF14171B),
    surface: Color(0xFF1B1F24),
    ink: Color(0xFFE7EAEE),
    muted: Color(0xFF98A2B3),
    line: Color(0xFF2B3138),
    lineStrong: Color(0xFF3A424B),
    accent: Color(0xFF2DD4BF),
    accentSoft: Color(0xFF123B36),
    onAccent: Color(0xFF08231A),
    brand: Color(0xFF2DD4BF),
    brandSoft: Color(0xFF123B36),
    danger: Color(0xFFF87171),
    dangerSoft: Color(0xFF341C1C),
    onDanger: Color(0xFF08231A),
    warn: Color(0xFFFBBF24),
    warnSoft: Color(0xFF33270F),
    ok: Color(0xFF34D399),
    okSoft: Color(0xFF102E23),
    onOk: Color(0xFF08231A),
    scrim: Color(0x73101828),
    shadow: [],
    shadowStrong: [],
    projects: {
      ProjectColour.slate: Color(0xFF94A3B8),
      ProjectColour.red: Color(0xFFF87171),
      ProjectColour.amber: Color(0xFFFBBF24),
      ProjectColour.green: Color(0xFF4ADE80),
      ProjectColour.teal: Color(0xFF2DD4BF),
      ProjectColour.blue: Color(0xFF60A5FA),
      ProjectColour.violet: Color(0xFFA78BFA),
      ProjectColour.pink: Color(0xFFF472B6),
    },
  );

  /// The pure black scheme for OLED screens: the dark tokens on a `#000000`
  /// page, with near-black surfaces told apart by hairlines rather than
  /// fills, so unlit pixels stay off. tix's web interface has no equivalent.
  static const oled = TixTokens(
    brightness: Brightness.dark,
    bg: Color(0xFF000000),
    surface: Color(0xFF0A0B0D),
    ink: Color(0xFFE7EAEE),
    muted: Color(0xFF98A2B3),
    line: Color(0xFF24292F),
    lineStrong: Color(0xFF3A424B),
    accent: Color(0xFF2DD4BF),
    accentSoft: Color(0xFF0B2925),
    onAccent: Color(0xFF08231A),
    brand: Color(0xFF2DD4BF),
    brandSoft: Color(0xFF0B2925),
    danger: Color(0xFFF87171),
    dangerSoft: Color(0xFF261212),
    onDanger: Color(0xFF08231A),
    warn: Color(0xFFFBBF24),
    warnSoft: Color(0xFF241B08),
    ok: Color(0xFF34D399),
    okSoft: Color(0xFF0A2219),
    onOk: Color(0xFF08231A),
    scrim: Color(0xB3000000),
    shadow: [],
    shadowStrong: [],
    projects: {
      ProjectColour.slate: Color(0xFF94A3B8),
      ProjectColour.red: Color(0xFFF87171),
      ProjectColour.amber: Color(0xFFFBBF24),
      ProjectColour.green: Color(0xFF4ADE80),
      ProjectColour.teal: Color(0xFF2DD4BF),
      ProjectColour.blue: Color(0xFF60A5FA),
      ProjectColour.violet: Color(0xFFA78BFA),
      ProjectColour.pink: Color(0xFFF472B6),
    },
  );

  /// The low-contrast scheme, `:root[data-theme="dim"]`. Not offered in
  /// settings yet; here so a later setting needs no new tokens.
  static const dim = TixTokens(
    brightness: Brightness.dark,
    bg: Color(0xFF1D2126),
    surface: Color(0xFF23282E),
    ink: Color(0xFFC7CCD3),
    muted: Color(0xFF8A929C),
    line: Color(0xFF2E343B),
    lineStrong: Color(0xFF3B434C),
    accent: Color(0xFF5EB3AB),
    accentSoft: Color(0xFF24322F),
    onAccent: Color(0xFF10201A),
    brand: Color(0xFF5EB3AB),
    brandSoft: Color(0xFF24322F),
    danger: Color(0xFFD98B83),
    dangerSoft: Color(0xFF2E2220),
    onDanger: Color(0xFF10201A),
    warn: Color(0xFFD0A06A),
    warnSoft: Color(0xFF2D2620),
    ok: Color(0xFF7FBF9A),
    okSoft: Color(0xFF1F2C25),
    onOk: Color(0xFF10201A),
    scrim: Color(0x73101828),
    shadow: [],
    shadowStrong: [],
    projects: {
      ProjectColour.slate: Color(0xFF8B95A3),
      ProjectColour.red: Color(0xFFCF8D86),
      ProjectColour.amber: Color(0xFFC2A15F),
      ProjectColour.green: Color(0xFF84BD91),
      ProjectColour.teal: Color(0xFF6FB8AE),
      ProjectColour.blue: Color(0xFF85A9D9),
      ProjectColour.violet: Color(0xFFA695D1),
      ProjectColour.pink: Color(0xFFCD90B0),
    },
  );

  /// The scheme's own tokens for [brightness].
  static TixTokens of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  /// Light or dark.
  final Brightness brightness;

  /// The page, `--bg`.
  final Color bg;

  /// Recessed regions: lists, sidebars, sheets, `--surface`.
  final Color surface;

  /// Text, `--ink`.
  final Color ink;

  /// Secondary text, `--muted`. Clears 4.5:1 on [bg] and [surface].
  final Color muted;

  /// Hairlines, `--line`.
  final Color line;

  /// Borders of controls, `--line-strong`.
  final Color lineStrong;

  /// The tenant's accent, `--accent`.
  final Color accent;

  /// The tint the accent sits on, `--accent-soft`.
  final Color accentSoft;

  /// Text on [accent], `--on-accent`.
  final Color onAccent;

  /// tix's own teal for this scheme, which the in-progress status keeps
  /// whatever accent the tenant chose.
  final Color brand;

  /// The tint [brand] sits on.
  final Color brandSoft;

  /// Destructive actions and the highest priorities, `--danger`.
  final Color danger;

  /// The tint [danger] sits on.
  final Color dangerSoft;

  /// Text on [danger].
  final Color onDanger;

  /// Blocked work and warnings, `--warn`.
  final Color warn;

  /// The tint [warn] sits on.
  final Color warnSoft;

  /// Done and success, `--ok`.
  final Color ok;

  /// The tint [ok] sits on.
  final Color okSoft;

  /// Text on [ok].
  final Color onOk;

  /// The layer behind a modal.
  final Color scrim;

  /// The shadow of something resting on the page.
  final List<BoxShadow> shadow;

  /// The shadow of something floating over the page: a toast, a dialog.
  final List<BoxShadow> shadowStrong;

  /// The project palette's shades in this scheme.
  final Map<ProjectColour, Color> projects;

  /// Whether this is a dark scheme.
  bool get isDark => brightness == Brightness.dark;

  /// Whether the page is pure black, as in [oled].
  bool get isBlack => bg == const Color(0xFF000000);

  /// These tokens with [a]'s accent for this scheme.
  ///
  /// The accent is moved just far enough to reach 4.5:1 on the page and the
  /// surface, the rule tix applies to custom accents. One built-in sits under
  /// it (forest's light accent, 4.37:1 on white), and text on a filled
  /// button would read below AA without this.
  TixTokens withAccent(TixAccent a) {
    final accent = readable(isDark ? a.accentDark : a.accent, contrastFloor, [
      bg,
      surface,
    ]);
    return copyWith(
      accent: accent,
      accentSoft: !isDark
          ? a.accentSoft
          : isBlack
          ? mix(a.accentSoftDark, bg, 0.4)
          : a.accentSoftDark,
      onAccent: onColour(accent),
    );
  }

  /// The colour a project stores as [value]: a palette name or `#rrggbb`,
  /// shaded to clear 4.5:1 on the page and the surface. Null for none.
  Color? projectColour(String value) {
    final v = value.trim().toLowerCase();
    if (v.isEmpty || v == 'none') return null;
    for (final c in ProjectColour.values) {
      if (c.name == v) return projects[c];
    }
    final custom = parseHex(v);
    if (custom == null) return null;
    return readable(custom, contrastFloor, [bg, surface]);
  }

  /// The colour of the status category [c]. Never the tenant's accent.
  Color status(StatusCategory c) => switch (c) {
    StatusCategory.todo || StatusCategory.unknown => muted,
    StatusCategory.inProgress => brand,
    StatusCategory.blocked => warn,
    StatusCategory.waiting => projects[ProjectColour.violet]!,
    StatusCategory.done => ok,
    StatusCategory.cancelled => lineStrong,
  };

  /// The colour of priority [p], 1 the highest and 5 the lowest.
  Color priority(int p) => p == 1 || p == 2 ? danger : muted;

  @override
  TixTokens copyWith({
    Color? bg,
    Color? surface,
    Color? ink,
    Color? muted,
    Color? line,
    Color? lineStrong,
    Color? accent,
    Color? accentSoft,
    Color? onAccent,
  }) => TixTokens(
    brightness: brightness,
    bg: bg ?? this.bg,
    surface: surface ?? this.surface,
    ink: ink ?? this.ink,
    muted: muted ?? this.muted,
    line: line ?? this.line,
    lineStrong: lineStrong ?? this.lineStrong,
    accent: accent ?? this.accent,
    accentSoft: accentSoft ?? this.accentSoft,
    onAccent: onAccent ?? this.onAccent,
    brand: brand,
    brandSoft: brandSoft,
    danger: danger,
    dangerSoft: dangerSoft,
    onDanger: onDanger,
    warn: warn,
    warnSoft: warnSoft,
    ok: ok,
    okSoft: okSoft,
    onOk: onOk,
    scrim: scrim,
    shadow: shadow,
    shadowStrong: shadowStrong,
    projects: projects,
  );

  @override
  TixTokens lerp(covariant TixTokens? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return TixTokens(
      brightness: t < 0.5 ? brightness : other.brightness,
      bg: c(bg, other.bg),
      surface: c(surface, other.surface),
      ink: c(ink, other.ink),
      muted: c(muted, other.muted),
      line: c(line, other.line),
      lineStrong: c(lineStrong, other.lineStrong),
      accent: c(accent, other.accent),
      accentSoft: c(accentSoft, other.accentSoft),
      onAccent: c(onAccent, other.onAccent),
      brand: c(brand, other.brand),
      brandSoft: c(brandSoft, other.brandSoft),
      danger: c(danger, other.danger),
      dangerSoft: c(dangerSoft, other.dangerSoft),
      onDanger: c(onDanger, other.onDanger),
      warn: c(warn, other.warn),
      warnSoft: c(warnSoft, other.warnSoft),
      ok: c(ok, other.ok),
      okSoft: c(okSoft, other.okSoft),
      onOk: c(onOk, other.onOk),
      scrim: c(scrim, other.scrim),
      shadow: BoxShadow.lerpList(shadow, other.shadow, t) ?? const [],
      shadowStrong:
          BoxShadow.lerpList(shadowStrong, other.shadowStrong, t) ?? const [],
      projects: {
        for (final p in ProjectColour.values)
          p: c(projects[p]!, other.projects[p]!),
      },
    );
  }
}

/// Short access to the tokens.
extension TixTokensContext on BuildContext {
  /// The active theme's tix tokens.
  TixTokens get tix =>
      Theme.of(this).extension<TixTokens>() ??
      TixTokens.of(Theme.of(this).brightness);
}
