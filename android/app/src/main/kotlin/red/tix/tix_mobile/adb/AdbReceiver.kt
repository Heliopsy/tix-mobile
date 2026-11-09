// SPDX-License-Identifier: AGPL-3.0-or-later

package red.tix.tix_mobile.adb

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * `adb shell am broadcast -n red.tix.tix_mobile/.adb.AdbReceiver -a red.tix.ADB
 * --es cmd <name>`. Exported, but the manifest asks senders for the DUMP
 * permission, which the shell has and apps cannot get. Dart parses the
 * command, decides whether this build accepts it, and runs it; the answer
 * goes to logcat under `tix-adb` and back to `am broadcast` as result data.
 */
class AdbReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != ACTION) return
        AdbService.keep(context)
        val bundle = intent.extras
        val cmd = bundle?.getString(CMD).orEmpty()
        val extras = mutableMapOf<String, String>()
        if (bundle != null) {
            for (key in bundle.keySet()) {
                if (key == CMD) continue
                bundle.getString(key)?.let { extras[key] = it }
            }
        }
        val pending = goAsync()
        AdbHub.command(context.applicationContext, cmd, extras) { ok, text ->
            AdbHub.log(ok, text)
            pending.resultCode = if (ok) 0 else 1
            pending.resultData = text
            pending.finish()
        }
    }

    companion object {
        const val ACTION = "red.tix.ADB"
        private const val CMD = "cmd"
    }
}
