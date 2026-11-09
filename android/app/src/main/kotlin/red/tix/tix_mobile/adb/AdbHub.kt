// SPDX-License-Identifier: AGPL-3.0-or-later

package red.tix.tix_mobile.adb

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import red.tix.tix_mobile.MainActivity

/**
 * Where `dumpsys` and `am broadcast` meet Dart (docs/adb.md): the app's own
 * engine while it is open, else a headless one started for the purpose, the
 * way a widget tick wakes Dart. Dart decides everything: what a snapshot
 * holds, whether a command is allowed, and whether it needs the app on
 * screen. Everything here runs on the main thread.
 */
object AdbHub {
    const val TAG = "tix-adb"
    const val CHANNEL = "tix/adb"
    private const val ENTRYPOINT = "adbHeadlessMain"
    private const val HEADLESS_IDLE_MS = 60_000L
    private const val ENGINE_WAIT_MS = 10_000L
    private const val COMMAND_MS = 15_000L

    private val main = Handler(Looper.getMainLooper())
    private var ui: MethodChannel? = null
    private var uiReady = false
    private var headless: FlutterEngine? = null
    private var headlessChannel: MethodChannel? = null
    private var headlessReady = false
    private val waiting = mutableListOf<Waiter>()
    private val idle = Runnable { stopHeadless() }

    private class Waiter(val needUi: Boolean, val then: (MethodChannel?) -> Unit) {
        var done = false
    }

    /** The app's engine opened [channel]; it says `ready` once Dart listens. */
    fun attachUi(channel: MethodChannel) {
        ui = channel
        uiReady = false
        channel.setMethodCallHandler { call, result ->
            if (call.method == "ready") {
                uiReady = true
                result.success(null)
                flush()
            } else {
                result.notImplemented()
            }
        }
    }

    /** The app's engine is going away. */
    fun detachUi(channel: MethodChannel) {
        if (ui !== channel) return
        channel.setMethodCallHandler(null)
        ui = null
        uiReady = false
    }

    /** Answers [done] with Dart's state report for [section], or what is stored natively after [budgetMs]. */
    fun snapshot(context: Context, section: String, budgetMs: Long, done: (String) -> Unit) {
        var finished = false
        fun finish(text: String) {
            if (finished) return
            finished = true
            done(text)
        }
        main.postDelayed({ finish(Fallback.report(context, starting = headless != null)) }, budgetMs)
        withEngine(context, needUi = false, waitMs = budgetMs) { channel ->
            if (channel != null) {
                invoke(channel, "snapshot", mapOf("section" to section), budgetMs) { result, _ ->
                    if (result is String) finish(result)
                }
            }
        }
    }

    /** Runs [cmd] with [extras] in Dart and answers [done] with whether it worked and what to print. */
    fun command(context: Context, cmd: String, extras: Map<String, String>, done: (Boolean, String) -> Unit) {
        val args = mapOf("cmd" to cmd, "extras" to extras)
        withEngine(context, needUi = false, waitMs = ENGINE_WAIT_MS) { channel ->
            if (channel == null) {
                done(false, "tix did not start: open the app and try again")
            } else {
                invoke(channel, "command", args, COMMAND_MS) { result, error ->
                    val reply = result as? Map<*, *>
                    when {
                        reply == null -> done(false, error ?: "tix did not answer")
                        reply["needsApp"] == true -> inApp(context, args, done)
                        else -> {
                            (reply["launch"] as? String)?.let { open(context, it) }
                            done(reply["ok"] == true, reply["text"] as? String ?: "")
                        }
                    }
                }
            }
        }
    }

    /** Logs [text] under [TAG], one line per entry so logcat does not cut it. */
    fun log(ok: Boolean, text: String) {
        text.lines().forEach { if (ok) Log.i(TAG, it) else Log.w(TAG, it) }
    }

    private fun inApp(context: Context, args: Map<String, Any>, done: (Boolean, String) -> Unit) {
        withEngine(context, needUi = true, waitMs = ENGINE_WAIT_MS) { channel ->
            if (channel == null) {
                done(false, notOpen(context))
            } else {
                invoke(channel, "command", args, COMMAND_MS) { result, error ->
                    val reply = result as? Map<*, *>
                    if (reply == null) {
                        done(false, error ?: "tix did not answer")
                    } else {
                        (reply["launch"] as? String)?.let { open(context, it) }
                        done(reply["ok"] == true, reply["text"] as? String ?: "")
                    }
                }
            }
        }
    }

    private fun notOpen(context: Context): String =
        "tix is not open and could not be brought up. Start it with " +
            "`adb shell am start -n ${context.packageName}/.MainActivity`, or add " +
            "--allow-background-activity-starts to am broadcast, and try again"

    private fun ready(needUi: Boolean): MethodChannel? = when {
        uiReady -> ui
        needUi -> null
        headlessReady -> headlessChannel
        else -> null
    }

    private fun flush() {
        val due = waiting.filter { ready(it.needUi) != null }
        for (w in due) {
            waiting.remove(w)
            if (w.done) continue
            w.done = true
            w.then(ready(w.needUi))
        }
    }

    private fun withEngine(context: Context, needUi: Boolean, waitMs: Long, then: (MethodChannel?) -> Unit) {
        val now = ready(needUi)
        if (now != null) {
            then(now)
            return
        }
        if (needUi) launchApp(context) else startHeadless(context)
        val waiter = Waiter(needUi, then)
        waiting.add(waiter)
        main.postDelayed({
            if (!waiter.done) {
                waiter.done = true
                waiting.remove(waiter)
                then(null)
            }
        }, waitMs)
    }

    private fun invoke(
        channel: MethodChannel,
        method: String,
        args: Any?,
        timeoutMs: Long,
        then: (Any?, String?) -> Unit,
    ) {
        if (channel === headlessChannel) keepHeadless()
        var done = false
        val timeout = Runnable {
            if (!done) {
                done = true
                then(null, "tix did not answer in time")
            }
        }
        main.postDelayed(timeout, timeoutMs)
        channel.invokeMethod(method, args, object : MethodChannel.Result {
            override fun success(result: Any?) = finish(result, null)

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) =
                finish(null, "tix failed: $errorCode")

            override fun notImplemented() = finish(null, "tix is not listening for adb yet")

            private fun finish(result: Any?, error: String?) {
                if (done) return
                done = true
                main.removeCallbacks(timeout)
                then(result, error)
            }
        })
    }

    private fun startHeadless(context: Context) {
        keepHeadless()
        if (headless != null) return
        val app = context.applicationContext
        try {
            val loader = FlutterInjector.instance().flutterLoader()
            loader.startInitialization(app)
            loader.ensureInitializationComplete(app, null)
            val engine = FlutterEngine(app)
            val channel = MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
            channel.setMethodCallHandler { call, result ->
                if (call.method == "ready") {
                    headlessReady = true
                    result.success(null)
                    flush()
                } else {
                    result.notImplemented()
                }
            }
            headless = engine
            headlessChannel = channel
            engine.dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint(loader.findAppBundlePath(), ENTRYPOINT),
            )
        } catch (e: RuntimeException) {
            Log.w(TAG, "could not start a background engine: ${e.javaClass.simpleName}")
        }
    }

    private fun keepHeadless() {
        main.removeCallbacks(idle)
        main.postDelayed(idle, HEADLESS_IDLE_MS)
    }

    private fun stopHeadless() {
        headlessChannel?.setMethodCallHandler(null)
        headless?.destroy()
        headless = null
        headlessChannel = null
        headlessReady = false
    }

    private fun launchApp(context: Context) {
        val intent = context.packageManager.getLaunchIntentForPackage(context.packageName) ?: return
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        start(context, intent)
    }

    private fun open(context: Context, link: String) {
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(link))
            .setClass(context, MainActivity::class.java)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        start(context, intent)
    }

    private fun start(context: Context, intent: Intent) {
        try {
            context.startActivity(intent)
        } catch (e: RuntimeException) {
            Log.w(TAG, "could not open tix: ${e.javaClass.simpleName}")
        }
    }
}
