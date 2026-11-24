// SPDX-License-Identifier: AGPL-3.0-or-later

package red.tix.tix_mobile.dav

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.ClipData
import android.content.ClipDescription
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.PersistableBundle
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

// tix/dav: hands a CalDAV account to DAVx5 and copies an app password marked
// sensitive (lib/src/core/platform/dav_handoff.dart). Nothing here logs its
// arguments: the password must never reach logcat.
object DavHandoff {
    const val CHANNEL = "tix/dav"
    const val DAVX5 = "at.bitfire.davdroid"

    // DAVx5's LoginActivity.EXTRA_USERNAME and EXTRA_PASSWORD, read from the
    // intent whatever its data carries.
    const val EXTRA_USERNAME = "username"
    const val EXTRA_PASSWORD = "password"

    // ClipDescription.EXTRA_IS_SENSITIVE, a constant from API 33; set on
    // older releases too, where some keyboards and clipboard tools read it.
    private const val EXTRA_IS_SENSITIVE = "android.content.extra.IS_SENSITIVE"

    fun attach(activity: Activity, messenger: BinaryMessenger) {
        MethodChannel(messenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "davx5Installed" -> result.success(installed(activity))
                "openDavx5" -> result.success(
                    open(
                        activity,
                        call.argument<String>("address").orEmpty(),
                        call.argument<String>("username").orEmpty(),
                        call.argument<String>("password").orEmpty(),
                    ),
                )
                "copySensitive" -> {
                    copy(activity, call.argument<String>("text").orEmpty())
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun installed(context: Context): Boolean =
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                context.packageManager.getPackageInfo(DAVX5, PackageManager.PackageInfoFlags.of(0))
            } else {
                @Suppress("DEPRECATION")
                context.packageManager.getPackageInfo(DAVX5, 0)
            }
            true
        } catch (e: PackageManager.NameNotFoundException) {
            false
        }

    private fun open(activity: Activity, address: String, username: String, password: String): Boolean {
        if (!safeAddress(address)) return false
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(address)).apply {
            setPackage(DAVX5)
            putExtra(EXTRA_USERNAME, username)
            putExtra(EXTRA_PASSWORD, password)
        }
        return try {
            activity.startActivity(intent)
            true
        } catch (e: ActivityNotFoundException) {
            false
        } catch (e: SecurityException) {
            false
        }
    }

    private fun copy(context: Context, text: String) {
        val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
        val clip = ClipData.newPlainText("tix", text)
        clip.description.extras = PersistableBundle().apply {
            putBoolean(
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    ClipDescription.EXTRA_IS_SENSITIVE
                } else {
                    EXTRA_IS_SENSITIVE
                },
                true,
            )
        }
        clipboard.setPrimaryClip(clip)
    }

    // The address DAVx5 opens must be caldav:// or caldavs:// with no user
    // info, so the password can only travel as an extra.
    fun safeAddress(address: String): Boolean {
        val scheme = address.substringBefore("://", "")
        if (scheme != "caldav" && scheme != "caldavs") return false
        val authority = address.substringAfter("://").substringBefore('/')
        return authority.isNotEmpty() && !authority.contains('@')
    }
}
