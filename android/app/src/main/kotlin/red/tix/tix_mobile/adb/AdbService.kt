// SPDX-License-Identifier: AGPL-3.0-or-later

package red.tix.tix_mobile.adb

import android.app.Service
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.Binder
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.ParcelFileDescriptor
import java.io.FileDescriptor
import java.io.IOException
import java.io.PrintWriter

/**
 * Prints the app's state for `adb shell dumpsys activity service
 * red.tix.tix_mobile/.adb.AdbService [section]`. Not exported: only the
 * system calls `dump()`, and dumpsys itself needs the DUMP permission, which
 * the shell has and apps cannot get.
 *
 * dumpsys finds a service only while it runs, so the app binds it for the
 * life of its process ([keep]).
 */
class AdbService : Service() {
    override fun onBind(intent: Intent?): IBinder = Binder()

    // The system waits about two seconds for the pipe to close. The state
    // comes from Dart over a channel whose answer arrives on the main thread,
    // so the descriptor is duplicated and written to once Dart answers,
    // instead of blocking here.
    override fun dump(fd: FileDescriptor, writer: PrintWriter, args: Array<out String>?) {
        val out = try {
            ParcelFileDescriptor.dup(fd)
        } catch (e: IOException) {
            writer.println("tix: cannot answer: ${e.javaClass.simpleName}")
            return
        }
        val section = args?.firstOrNull().orEmpty()
        val app = applicationContext
        main.post {
            AdbHub.snapshot(app, section, BUDGET_MS) { text -> write(out, text) }
        }
    }

    private fun write(out: ParcelFileDescriptor, text: String) {
        Thread {
            try {
                ParcelFileDescriptor.AutoCloseOutputStream(out).use { it.write(text.toByteArray()) }
            } catch (e: IOException) {
                AdbHub.log(false, "dumpsys went away: ${e.javaClass.simpleName}")
            }
        }.start()
    }

    companion object {
        private const val BUDGET_MS = 1_500L
        private val main = Handler(Looper.getMainLooper())
        private var bound = false

        /** Binds the service once per process so dumpsys can find it. */
        fun keep(context: Context) {
            if (bound) return
            val app = context.applicationContext
            bound = app.bindService(
                Intent(app, AdbService::class.java),
                object : ServiceConnection {
                    override fun onServiceConnected(name: ComponentName?, service: IBinder?) = Unit

                    override fun onServiceDisconnected(name: ComponentName?) = Unit
                },
                Context.BIND_AUTO_CREATE,
            )
        }
    }
}
