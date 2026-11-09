// SPDX-License-Identifier: AGPL-3.0-or-later

package red.tix.tix_mobile.shortcuts

import android.content.Context
import android.content.Intent
import android.content.pm.ShortcutInfo
import android.content.pm.ShortcutManager
import android.graphics.drawable.Icon
import android.net.Uri
import android.os.Build
import android.util.Log
import red.tix.tix_mobile.MainActivity
import red.tix.tix_mobile.R

/**
 * Shortcuts a person pins to the home screen from a project or a saved
 * filter. Each opens a `tix://` link naming its context, through the same
 * path as any other link (docs/adb.md#links). Dart builds the id, the label
 * and the link; this only asks the launcher.
 */
object Pins {
    const val CHANNEL = "tix/pins"
    private const val TAG = "tix-pins"

    /** Whether the launcher can pin a shortcut (Android 8 and later, when it says so). */
    fun supported(context: Context): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return false
        return context.getSystemService(ShortcutManager::class.java)?.isRequestPinShortcutSupported == true
    }

    /** Asks the launcher to pin [link] as [label]; the same [id] updates the one shortcut. */
    fun pin(context: Context, id: String, label: String, link: String): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O || id.isEmpty() || label.isEmpty()) return false
        val uri = Uri.parse(link)
        if (!uri.scheme.equals("tix", ignoreCase = true)) return false
        val manager = context.getSystemService(ShortcutManager::class.java) ?: return false
        if (!manager.isRequestPinShortcutSupported) return false
        val intent = Intent(Intent.ACTION_VIEW, uri)
            .setClass(context, MainActivity::class.java)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        val info = ShortcutInfo.Builder(context, id)
            .setShortLabel(label.take(SHORT_LABEL))
            .setLongLabel(label)
            .setIcon(Icon.createWithResource(context, R.mipmap.ic_launcher))
            .setIntent(intent)
            .build()
        return try {
            if (manager.pinnedShortcuts.any { it.id == id }) {
                manager.updateShortcuts(listOf(info))
            }
            manager.requestPinShortcut(info, null)
        } catch (e: IllegalStateException) {
            Log.w(TAG, "could not pin: ${e.javaClass.simpleName}")
            false
        }
    }

    // Launchers cut short labels at about ten characters; 25 is the most
    // the platform recommends.
    private const val SHORT_LABEL = 25
}
