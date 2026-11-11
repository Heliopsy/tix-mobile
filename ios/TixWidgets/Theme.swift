// SPDX-License-Identifier: AGPL-3.0-or-later

import SwiftUI

/// tix's fixed tokens for one scheme (docs/design.md, "Colours"). Status and priority never follow the tenant.
struct Palette {
  let bg: Color
  let surface: Color
  let ink: Color
  let muted: Color
  let line: Color
  let lineStrong: Color
  let brand: Color
  let danger: Color
  let warn: Color
  let ok: Color
  let violet: Color
  let isDark: Bool

  static let light = Palette(
    bg: Color(rgb: 0xFFFFFF),
    surface: Color(rgb: 0xF6F7F9),
    ink: Color(rgb: 0x0F1319),
    muted: Color(rgb: 0x5F6B7A),
    line: Color(rgb: 0xEBEDF1),
    lineStrong: Color(rgb: 0xD6DAE1),
    brand: Color(rgb: 0x0F766E),
    danger: Color(rgb: 0xB42318),
    warn: Color(rgb: 0xB54708),
    ok: Color(rgb: 0x067647),
    violet: Color(rgb: 0x7C3AED),
    isDark: false)

  static let dark = Palette(
    bg: Color(rgb: 0x14171B),
    surface: Color(rgb: 0x1B1F24),
    ink: Color(rgb: 0xE7EAEE),
    muted: Color(rgb: 0x98A2B3),
    line: Color(rgb: 0x2B3138),
    lineStrong: Color(rgb: 0x3A424B),
    brand: Color(rgb: 0x2DD4BF),
    danger: Color(rgb: 0xF87171),
    warn: Color(rgb: 0xFBBF24),
    ok: Color(rgb: 0x34D399),
    violet: Color(rgb: 0xA78BFA),
    isDark: true)

  static let oled = Palette(
    bg: Color(rgb: 0x000000),
    surface: Color(rgb: 0x0A0B0D),
    ink: Color(rgb: 0xE7EAEE),
    muted: Color(rgb: 0x98A2B3),
    line: Color(rgb: 0x24292F),
    lineStrong: Color(rgb: 0x3A424B),
    brand: Color(rgb: 0x2DD4BF),
    danger: Color(rgb: 0xF87171),
    warn: Color(rgb: 0xFBBF24),
    ok: Color(rgb: 0x34D399),
    violet: Color(rgb: 0xA78BFA),
    isDark: true)

  /// The palette for the index's `theme` and `systemBlack` under the system's [scheme].
  static func resolve(_ index: WidgetIndex?, scheme: ColorScheme) -> Palette {
    switch index?.theme ?? "system" {
    case "light": return .light
    case "dark": return .dark
    case "black": return .oled
    default:
      guard scheme == .dark else { return .light }
      return (index?.systemBlack ?? false) ? .oled : .dark
    }
  }

  /// The colour of a workflow state's category. Never the accent.
  func status(_ category: String?) -> Color {
    switch (category ?? "").lowercased() {
    case "doing", "inprogress", "in_progress", "in-progress": return brand
    case "blocked": return danger
    case "waiting": return violet
    case "done": return ok
    case "cancelled", "canceled": return lineStrong
    default: return muted
    }
  }

  func pick(_ pair: ColourPair?, fallback: Color) -> Color {
    guard let pair else { return fallback }
    return Color(hex: isDark ? pair.dark : pair.light) ?? fallback
  }

  func accent(_ accent: AccentColours?) -> Color {
    guard let accent else { return brand }
    return Color(hex: isDark ? accent.dark : accent.light) ?? brand
  }

  func onAccent(_ accent: AccentColours?) -> Color {
    guard let accent else { return isDark ? Color(rgb: 0x08231A) : Color(rgb: 0xFFFFFF) }
    return Color(hex: isDark ? accent.onDark : accent.onLight) ?? bg
  }

  func isHighPriority(_ priority: String?) -> Bool {
    switch (priority ?? "").lowercased() {
    case "high", "highest", "urgent": return true
    default: return false
    }
  }
}

extension Color {
  init(rgb: UInt32) {
    self.init(
      .sRGB,
      red: Double((rgb >> 16) & 0xFF) / 255,
      green: Double((rgb >> 8) & 0xFF) / 255,
      blue: Double(rgb & 0xFF) / 255,
      opacity: 1)
  }

  /// `#rrggbb`, or nil when [hex] is anything else.
  init?(hex: String) {
    let digits = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
    guard digits.count == 6, let value = UInt32(digits, radix: 16) else { return nil }
    self.init(rgb: value)
  }
}
