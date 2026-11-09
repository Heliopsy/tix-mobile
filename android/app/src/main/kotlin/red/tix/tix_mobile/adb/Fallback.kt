// SPDX-License-Identifier: AGPL-3.0-or-later

package red.tix.tix_mobile.adb

import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import red.tix.tix_mobile.widgets.Index
import red.tix.tix_mobile.widgets.Store

/**
 * What `dumpsys` prints when Dart does not answer in time: the version and
 * what the widget index holds, which has names and no secrets.
 */
object Fallback {
    fun report(context: Context, starting: Boolean): String {
        val index = try {
            Store(context).index
        } catch (e: RuntimeException) {
            null
        }
        return text(context.packageName, version(context), index, starting)
    }

    fun text(pkg: String, version: String, index: Index?, starting: Boolean): String {
        val lines = mutableListOf(
            "tix-mobile $version ($pkg)",
            "tix is not open, so this is what is stored outside Dart.",
        )
        if (starting) lines += "A background engine is starting: run the same command again in a few seconds."
        if (index == null) {
            lines += "No widget index yet: open tix once."
            return lines.joinToString("\n", postfix = "\n")
        }
        lines += ""
        lines += "== contexts =="
        lines += "Active: ${index.active ?: "none"}"
        for (c in index.contexts) {
            val mark = if (c.id == index.active) "*" else " "
            val kind = if (c.local) ", local" else ""
            lines += "  $mark ${c.id}  ${c.label}$kind"
        }
        lines += ""
        lines += "Theme: ${index.theme}"
        return lines.joinToString("\n", postfix = "\n")
    }

    private fun version(context: Context): String = try {
        val info = context.packageManager.getPackageInfo(context.packageName, 0)
        val code = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            info.longVersionCode
        } else {
            @Suppress("DEPRECATION")
            info.versionCode.toLong()
        }
        "${info.versionName} (build $code)"
    } catch (e: PackageManager.NameNotFoundException) {
        "unknown version"
    }
}
