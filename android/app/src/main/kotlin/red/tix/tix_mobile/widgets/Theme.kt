// SPDX-License-Identifier: AGPL-3.0-or-later

package red.tix.tix_mobile.widgets

import androidx.compose.ui.graphics.Color
import androidx.glance.unit.ColorProvider

/** One scheme of tix's tokens, from docs/design.md. */
data class Scheme(
    val bg: Color,
    val surface: Color,
    val ink: Color,
    val muted: Color,
    val line: Color,
    val lineStrong: Color,
    val brand: Color,
    val danger: Color,
    val warn: Color,
    val ok: Color,
    val violet: Color,
)

private fun hex(v: Long) = Color(0xFF000000 or v)

val Light = Scheme(
    bg = hex(0xffffff), surface = hex(0xf6f7f9), ink = hex(0x0f1319), muted = hex(0x5f6b7a),
    line = hex(0xebedf1), lineStrong = hex(0xd6dae1), brand = hex(0x0f766e), danger = hex(0xb42318),
    warn = hex(0xb54708), ok = hex(0x067647), violet = hex(0x7c3aed),
)

val Dark = Scheme(
    bg = hex(0x14171b), surface = hex(0x1b1f24), ink = hex(0xe7eaee), muted = hex(0x98a2b3),
    line = hex(0x2b3138), lineStrong = hex(0x3a424b), brand = hex(0x2dd4bf), danger = hex(0xf87171),
    warn = hex(0xfbbf24), ok = hex(0x34d399), violet = hex(0xa78bfa),
)

val Oled = Dark.copy(bg = hex(0x000000), surface = hex(0x0a0b0d), line = hex(0x24292f))

/** Parses `#rrggbb`, [fallback] for anything else. */
fun parseColour(value: String?, fallback: Color): Color {
    val v = value?.trim() ?: return fallback
    if (v.length != 7 || !v.startsWith("#")) return fallback
    return v.substring(1).toLongOrNull(16)?.let { hex(it) } ?: fallback
}

/**
 * The colours a widget draws with: the app's theme choice forces light or
 * dark; under the system theme each colour carries a day and a night value
 * the launcher picks from, OLED black for night when the app asks for it.
 */
class Palette(theme: String, systemBlack: Boolean) {
    private val day: Scheme? = when (theme) {
        "dark", "black" -> null
        else -> Light
    }
    private val night: Scheme? = when (theme) {
        "light" -> null
        "black" -> Oled
        else -> if (systemBlack) Oled else Dark
    }

    private fun pick(f: (Scheme) -> Color): ColorProvider {
        val d = day
        val n = night
        return when {
            d != null && n != null -> androidx.glance.color.ColorProvider(day = f(d), night = f(n))
            d != null -> ColorProvider(f(d))
            else -> ColorProvider(f(n!!))
        }
    }

    /** A pair of colours from the snapshot, following the same rule. */
    fun of(light: Color, dark: Color): ColorProvider = when {
        day != null && night != null -> androidx.glance.color.ColorProvider(day = light, night = dark)
        day != null -> ColorProvider(light)
        else -> ColorProvider(dark)
    }

    val bg get() = pick { it.bg }
    val surface get() = pick { it.surface }
    val ink get() = pick { it.ink }
    val muted get() = pick { it.muted }
    val line get() = pick { it.line }
    val danger get() = pick { it.danger }
    val warn get() = pick { it.warn }

    /** A status category's colour; never the tenant's accent. */
    fun status(category: String) = pick {
        when (category) {
            "doing" -> it.brand
            "blocked" -> it.warn
            "waiting" -> it.violet
            "done" -> it.ok
            "cancelled" -> it.lineStrong
            else -> it.muted
        }
    }

    fun priority(p: String) = if (p == "highest" || p == "high") danger else muted

    fun accent(a: Accent) = of(parseColour(a.light, Light.brand), parseColour(a.dark, Dark.brand))

    fun onAccent(a: Accent) = of(parseColour(a.onLight, Color.White), parseColour(a.onDark, Color.Black))

    fun project(c: Colour?) = if (c == null) muted else of(parseColour(c.light, Light.muted), parseColour(c.dark, Dark.muted))

    companion object {
        fun of(index: Index?) = Palette(index?.theme ?: "system", index?.systemBlack ?: false)
    }
}
