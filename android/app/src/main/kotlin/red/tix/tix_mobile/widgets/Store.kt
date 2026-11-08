// SPDX-License-Identifier: AGPL-3.0-or-later

package red.tix.tix_mobile.widgets

import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import es.antonborri.home_widget.HomeWidgetPlugin

/** HomeWidgetPreferences, where the app writes and widgets read. */
class Store(context: Context) {
    val prefs: SharedPreferences = HomeWidgetPlugin.getData(context)

    fun read(key: String): String? = prefs.getString(key, null)

    val index: Index? get() = Snapshots.index(read(Keys.INDEX))

    /** What widget [appWidgetId] was configured to show. */
    fun want(appWidgetId: Int): Want? = Snapshots.wanted(read(Keys.WANTED))[wantKey(appWidgetId)]

    fun setWant(appWidgetId: Int, want: Want?) {
        synchronized(lock) {
            prefs.edit().putString(Keys.WANTED, Snapshots.withWant(read(Keys.WANTED), wantKey(appWidgetId), want)).commit()
        }
    }

    fun enqueueComplete(ctx: String, ref: String) {
        synchronized(lock) {
            val now = System.currentTimeMillis()
            val next = Snapshots.enqueueComplete(read(Keys.QUEUE), ctx, ref, now, (now % 997).toInt())
            prefs.edit().putString(Keys.QUEUE, next).commit()
        }
    }

    fun pending(ctx: String): Set<String> = Snapshots.pendingRefs(read(Keys.QUEUE), ctx)

    companion object {
        private val lock = Any()

        fun wantKey(appWidgetId: Int) = "android:$appWidgetId"
    }
}

/** The links widgets open, as docs/widgets.md lists them. */
object Links {
    fun open(ctx: String, route: String, item: String? = null): Uri =
        Uri.Builder().scheme("tixwidget").authority("open")
            .appendQueryParameter("ctx", ctx)
            .appendQueryParameter("route", route)
            .apply { if (!item.isNullOrEmpty()) appendQueryParameter("item", item) }
            .build()

    fun quickAdd(ctx: String, project: String?): Uri =
        Uri.Builder().scheme("tixwidget").authority("quickadd")
            .appendQueryParameter("ctx", ctx)
            .apply { if (!project.isNullOrEmpty()) appendQueryParameter("project", project) }
            .build()

    fun app(ctx: String): Uri =
        Uri.Builder().scheme("tixwidget").authority("app").appendQueryParameter("ctx", ctx).build()

    val drain: Uri = Uri.parse("tixwidget://drain")
    val refresh: Uri = Uri.parse("tixwidget://refresh")
}
