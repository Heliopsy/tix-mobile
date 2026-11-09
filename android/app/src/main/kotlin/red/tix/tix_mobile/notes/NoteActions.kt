// SPDX-License-Identifier: AGPL-3.0-or-later

package red.tix.tix_mobile.notes

import android.app.Notification
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.RemoteInput
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.graphics.drawable.Icon
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.RequiresApi
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import red.tix.tix_mobile.R

/** One button Dart asked for on a notification. */
data class NoteButton(val id: String, val label: String, val reply: Boolean) {
    companion object {
        /** The buttons in [raw], the `actions` argument of `tix/notes`. */
        fun list(raw: Any?): List<NoteButton> =
            (raw as? List<*>).orEmpty().mapNotNull { item ->
                val m = item as? Map<*, *> ?: return@mapNotNull null
                val id = m["id"] as? String ?: return@mapNotNull null
                val label = m["label"] as? String ?: return@mapNotNull null
                NoteButton(id, label, m["reply"] == true)
            }
    }
}

/**
 * The actions of an inbox notification.
 * Their intents go to [NoteActionReceiver], never to the plugin's own
 * receiver, which would always start a second engine with a second copy of
 * the outbox.
 */
object NoteActions {
    const val ACTION = "red.tix.NOTE_ACTION"
    const val EXTRA_ID = "id"
    const val EXTRA_ACTION = "action"
    const val EXTRA_PAYLOAD = "payload"
    const val REPLY_KEY = "reply"

    /** The action for [button] on notification [noteId]; [unlock] asks for an unlock first on Android 12+. */
    @RequiresApi(Build.VERSION_CODES.N)
    fun action(
        context: Context,
        noteId: Int,
        button: NoteButton,
        payload: String,
        replyLabel: String,
        unlock: Boolean,
    ): Notification.Action {
        // The data makes each intent distinct: PendingIntents that differ
        // only in extras are the same one.
        val intent = Intent(ACTION, Uri.parse("tixnote://$noteId/${button.id}"))
            .setClass(context, NoteActionReceiver::class.java)
            .putExtra(EXTRA_ID, noteId)
            .putExtra(EXTRA_ACTION, button.id)
            .putExtra(EXTRA_PAYLOAD, payload)
        val pending = PendingIntent.getBroadcast(context, noteId, intent, flags(button.reply))
        val builder = Notification.Action.Builder(
            Icon.createWithResource(context, R.drawable.ic_stat_tix),
            button.label,
            pending,
        )
        if (button.reply) {
            builder.addRemoteInput(RemoteInput.Builder(REPLY_KEY).setLabel(replyLabel).build())
            builder.setAllowGeneratedReplies(false)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                builder.setSemanticAction(Notification.Action.SEMANTIC_ACTION_REPLY)
            }
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) builder.setAuthenticationRequired(unlock)
        return builder.build()
    }

    // A reply's intent has to be mutable for the system to add the text;
    // it is explicit, so only this app's receiver gets it.
    private fun flags(reply: Boolean): Int = PendingIntent.FLAG_UPDATE_CURRENT or when {
        !reply -> PendingIntent.FLAG_IMMUTABLE
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> PendingIntent.FLAG_MUTABLE
        else -> 0
    }

    /** What Dart reads from [intent]: the notification, the button, the payload and a reply's text. */
    fun args(intent: Intent): Map<String, Any> = mapOf(
        "id" to intent.getIntExtra(EXTRA_ID, 0),
        "action" to intent.getStringExtra(EXTRA_ACTION).orEmpty(),
        "payload" to intent.getStringExtra(EXTRA_PAYLOAD).orEmpty(),
        "text" to (RemoteInput.getResultsFromIntent(intent)?.getCharSequence(REPLY_KEY)?.toString() ?: ""),
    )

    /** When Dart never took the action: drop the notification and say so, naming no task. */
    fun fallback(context: Context, noteId: Int) {
        val manager = context.getSystemService(NotificationManager::class.java) ?: return
        manager.cancel(noteId)
        val open = context.packageManager.getLaunchIntentForPackage(context.packageName)?.let {
            PendingIntent.getActivity(context, 0, it, PendingIntent.FLAG_IMMUTABLE)
        }
        val note = builder(context)
            .setSmallIcon(R.drawable.ic_stat_tix)
            .setContentTitle(context.getString(R.string.note_action_failed))
            .setContentText(context.getString(R.string.note_action_failed_body))
            .setContentIntent(open)
            .setAutoCancel(true)
            .build()
        manager.notify(FALLBACK_ID, note)
    }

    @Suppress("DEPRECATION")
    private fun builder(context: Context): Notification.Builder =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(context, CHANNEL)
        } else {
            Notification.Builder(context)
        }

    /** The channel Dart creates for inbox notifications. */
    private const val CHANNEL = "inbox"
    private const val FALLBACK_ID = 0x7174
}

/** Takes a pressed notification button and keeps the process up while Dart runs it. */
class NoteActionReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != NoteActions.ACTION) return
        val args = NoteActions.args(intent)
        val noteId = args["id"] as Int
        val pending = goAsync()
        NoteActionHub.run(context.applicationContext, args) { answered ->
            if (!answered) NoteActions.fallback(context.applicationContext, noteId)
            pending.finish()
        }
    }
}

/**
 * Where a notification action meets Dart: the app's engine while it is up,
 * else a headless one at `noteActionHeadlessMain`, as [red.tix.tix_mobile.adb.AdbHub]
 * does for the shell. Everything here runs on the main thread.
 */
object NoteActionHub {
    const val TAG = "tix-notes"
    const val CHANNEL = "tix/note-actions"
    private const val ENTRYPOINT = "noteActionHeadlessMain"
    private const val HEADLESS_IDLE_MS = 30_000L

    // A receiver that went async has about ten seconds in all.
    private const val BUDGET_MS = 8_500L

    private val main = Handler(Looper.getMainLooper())
    private var ui: MethodChannel? = null
    private var uiReady = false
    private var headless: FlutterEngine? = null
    private var headlessChannel: MethodChannel? = null
    private var headlessReady = false
    private val waiting = mutableListOf<(MethodChannel?) -> Unit>()
    private val idle = Runnable { stopHeadless() }

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

    /**
     * Runs the action [args] in Dart and calls [done] once: true when Dart
     * answered or is still working when the budget runs out, false when no
     * engine could take it.
     */
    fun run(context: Context, args: Map<String, Any>, done: (Boolean) -> Unit) {
        var finished = false
        fun finish(answered: Boolean) {
            if (finished) return
            finished = true
            done(answered)
        }
        var sent = false
        main.postDelayed({ finish(sent) }, BUDGET_MS)
        withEngine(context) { channel ->
            if (channel == null) {
                finish(false)
                return@withEngine
            }
            sent = true
            if (channel === headlessChannel) keepHeadless()
            channel.invokeMethod("run", args, object : MethodChannel.Result {
                override fun success(result: Any?) = finish(true)

                override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                    Log.w(TAG, "action failed in Dart: $errorCode")
                    finish(false)
                }

                override fun notImplemented() = finish(false)
            })
        }
    }

    private fun ready(): MethodChannel? = when {
        uiReady -> ui
        headlessReady -> headlessChannel
        else -> null
    }

    private fun flush() {
        val channel = ready() ?: return
        val due = waiting.toList()
        waiting.clear()
        due.forEach { it(channel) }
    }

    private fun withEngine(context: Context, then: (MethodChannel?) -> Unit) {
        val now = ready()
        if (now != null) {
            then(now)
            return
        }
        waiting.add(then)
        if (!startHeadless(context)) {
            waiting.remove(then)
            then(null)
        }
    }

    private fun startHeadless(context: Context): Boolean {
        keepHeadless()
        if (headless != null) return true
        val app = context.applicationContext
        return try {
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
            true
        } catch (e: RuntimeException) {
            Log.w(TAG, "could not start a background engine: ${e.javaClass.simpleName}")
            false
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
}
