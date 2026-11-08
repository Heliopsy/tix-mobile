// SPDX-License-Identifier: AGPL-3.0-or-later

package red.tix.tix_mobile.widgets

import android.app.Activity
import android.app.AlertDialog
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Intent
import android.content.res.Configuration
import android.os.Bundle
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch
import red.tix.tix_mobile.R

/**
 * Picks what a widget shows: the active context or a pinned one, and for
 * the Project widget a project in it. Reads only the catalog the app wrote
 * into the index; nothing here can reach a server.
 */
class WidgetConfigureActivity : Activity() {
    private val scope = MainScope()

    private var appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        appWidgetId = intent?.extras?.getInt(AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID)
            ?: AppWidgetManager.INVALID_APPWIDGET_ID
        setResult(Activity.RESULT_CANCELED, result())
        if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            finish()
            return
        }
        val index = Store(this).index
        if (index == null || index.contexts.isEmpty()) {
            dialog()
                .setTitle(R.string.widget_configure)
                .setMessage(R.string.widget_open_app)
                .setPositiveButton(android.R.string.ok) { _, _ -> finish() }
                .setOnCancelListener { finish() }
                .show()
            return
        }
        pickContext(index)
    }

    private val isProject: Boolean
        get() = AppWidgetManager.getInstance(this).getAppWidgetInfo(appWidgetId)?.provider ==
            ComponentName(this, ProjectReceiver::class.java)

    private fun pickContext(index: Index) {
        val ids = listOf(Keys.ACTIVE) + index.contexts.map { it.id }
        val labels = listOf(getString(R.string.widget_follow_active)) + index.contexts.map { it.label }
        val current = Store(this).want(appWidgetId)?.ctx ?: Keys.ACTIVE
        dialog()
            .setTitle(R.string.widget_configure_context)
            .setSingleChoiceItems(labels.toTypedArray(), ids.indexOf(current).coerceAtLeast(0)) { dialog, which ->
                dialog.dismiss()
                val ctx = ids[which]
                if (isProject) pickProject(index, ctx) else done(ctx, null)
            }
            .setOnCancelListener { finish() }
            .show()
    }

    private fun pickProject(index: Index, ctx: String) {
        val projects = index.projects[index.resolve(ctx)].orEmpty()
        if (projects.isEmpty()) {
            dialog()
                .setTitle(R.string.widget_pick_project)
                .setMessage(R.string.widget_no_projects)
                .setPositiveButton(android.R.string.ok) { _, _ -> finish() }
                .setOnCancelListener { finish() }
                .show()
            return
        }
        dialog()
            .setTitle(R.string.widget_pick_project)
            .setItems(projects.map { it.name }.toTypedArray()) { _, which -> done(ctx, projects[which].key) }
            .setOnCancelListener { finish() }
            .show()
    }

    private fun done(ctx: String, project: String?) {
        Store(this).setWant(appWidgetId, Want(ctx, project, System.currentTimeMillis()))
        scope.launch {
            redrawAll(this@WidgetConfigureActivity)
            es.antonborri.home_widget.HomeWidgetBackgroundIntent.getBroadcast(this@WidgetConfigureActivity, Links.refresh).send()
            setResult(Activity.RESULT_OK, result())
            finish()
        }
    }

    private fun dialog(): AlertDialog.Builder {
        val night = (resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK) == Configuration.UI_MODE_NIGHT_YES
        return AlertDialog.Builder(
            this,
            if (night) android.R.style.Theme_DeviceDefault_Dialog_Alert else android.R.style.Theme_DeviceDefault_Light_Dialog_Alert,
        )
    }

    private fun result() = Intent().putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
}
