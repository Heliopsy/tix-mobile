// SPDX-License-Identifier: AGPL-3.0-or-later

package red.tix.tix_mobile.widgets

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import androidx.glance.GlanceId
import androidx.glance.action.ActionParameters
import androidx.glance.action.actionParametersOf
import androidx.glance.appwidget.action.ActionCallback
import androidx.glance.appwidget.updateAll
import androidx.work.Constraints
import androidx.work.CoroutineWorker
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.NetworkType
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.WorkerParameters
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetGlanceWidgetReceiver
import java.util.concurrent.TimeUnit

/** Shared by every tix receiver: the refresh job lives while any widget does. */
abstract class TixReceiver<T : TixWidget> : HomeWidgetGlanceWidgetReceiver<T>() {
    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        RefreshWorker.schedule(context)
    }

    override fun onDeleted(context: Context, appWidgetIds: IntArray) {
        super.onDeleted(context, appWidgetIds)
        val store = Store(context)
        appWidgetIds.forEach { store.setWant(it, null) }
    }

    override fun onDisabled(context: Context) {
        super.onDisabled(context)
        if (!anyWidget(context)) RefreshWorker.cancel(context)
    }
}

class MyWorkReceiver : TixReceiver<MyWorkWidget>() {
    override val glanceAppWidget = MyWorkWidget()
}

class InboxReceiver : TixReceiver<InboxWidget>() {
    override val glanceAppWidget = InboxWidget()
}

class QuickAddReceiver : TixReceiver<QuickAddWidget>() {
    override val glanceAppWidget = QuickAddWidget()
}

class ProjectReceiver : TixReceiver<ProjectWidget>() {
    override val glanceAppWidget = ProjectWidget()
}

private val receivers = listOf(MyWorkReceiver::class.java, InboxReceiver::class.java, QuickAddReceiver::class.java, ProjectReceiver::class.java)

fun anyWidget(context: Context): Boolean {
    val manager = AppWidgetManager.getInstance(context)
    return receivers.any { manager.getAppWidgetIds(ComponentName(context, it)).isNotEmpty() }
}

suspend fun redrawAll(context: Context) {
    allWidgets.forEach { it().updateAll(context) }
}

/**
 * A tick: queues the completion for the app, redraws so the task is gone at
 * once, and wakes the app's Dart code in a headless engine to run the queue.
 * No credential is touched here.
 */
class CompleteAction : ActionCallback {
    override suspend fun onAction(context: Context, glanceId: GlanceId, parameters: ActionParameters) {
        val ctx = parameters[CTX] ?: return
        val ref = parameters[REF] ?: return
        Store(context).enqueueComplete(ctx, ref)
        redrawAll(context)
        HomeWidgetBackgroundIntent.getBroadcast(context, Links.drain).send()
    }

    companion object {
        val CTX = ActionParameters.Key<String>("ctx")
        val REF = ActionParameters.Key<String>("ref")

        fun params(ctx: String, ref: String) = actionParametersOf(CTX to ctx, REF to ref)
    }
}

/** Wakes the app's Dart code every half hour, with a network, to rewrite the snapshots. */
class RefreshWorker(context: Context, params: WorkerParameters) : CoroutineWorker(context, params) {
    override suspend fun doWork(): Result {
        if (!anyWidget(applicationContext)) return Result.success()
        HomeWidgetBackgroundIntent.getBroadcast(applicationContext, Links.refresh).send()
        return Result.success()
    }

    companion object {
        private const val NAME = "tix.widgets.refresh"

        fun schedule(context: Context) {
            val request = PeriodicWorkRequestBuilder<RefreshWorker>(30, TimeUnit.MINUTES)
                .setConstraints(Constraints.Builder().setRequiredNetworkType(NetworkType.CONNECTED).build())
                .build()
            WorkManager.getInstance(context).enqueueUniquePeriodicWork(NAME, ExistingPeriodicWorkPolicy.KEEP, request)
        }

        fun cancel(context: Context) {
            WorkManager.getInstance(context).cancelUniqueWork(NAME)
        }
    }
}
