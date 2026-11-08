// SPDX-License-Identifier: AGPL-3.0-or-later

package red.tix.tix_mobile.widgets

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProviderInfo
import android.content.Context
import android.text.format.DateUtils
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.ColorFilter
import androidx.glance.GlanceModifier
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.LocalContext
import androidx.glance.LocalSize
import androidx.glance.action.Action
import androidx.glance.action.clickable
import androidx.glance.appwidget.LocalAppWidgetOptions
import androidx.glance.appwidget.action.actionRunCallback
import androidx.glance.appwidget.appWidgetBackground
import androidx.glance.appwidget.cornerRadius
import androidx.glance.background
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.size
import androidx.glance.layout.width
import androidx.glance.semantics.contentDescription
import androidx.glance.semantics.semantics
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import es.antonborri.home_widget.actionStartActivity
import red.tix.tix_mobile.MainActivity
import red.tix.tix_mobile.R
import java.time.Instant
import java.time.ZoneId

/** Below this height a widget shows its count and one line. */
val CompactHeight: Dp = 110.dp

/** What every widget draws from: the index, the palette and the labels. */
class Look(val context: Context, val index: Index?) {
    val palette = Palette.of(index)

    /** A label from the app, or the bundled one before the app has run. */
    fun s(key: String, fallback: Int): String = index?.strings?.get(key)?.takeIf { it.isNotEmpty() } ?: context.getString(fallback)

    fun footer(header: Header?): String {
        if (header == null) return ""
        val ago = DateUtils.getRelativeTimeSpanString(header.at, System.currentTimeMillis(), DateUtils.MINUTE_IN_MILLIS)
        val parts = mutableListOf(header.ctx.label, "${s("updated", R.string.widget_updated)} $ago")
        if (header.ctx.local) parts.add(s("localStale", R.string.widget_local_stale))
        return parts.filter { it.isNotEmpty() }.joinToString(" · ")
    }
}

@Composable
fun onKeyguard(): Boolean =
    LocalAppWidgetOptions.current.getInt(AppWidgetManager.OPTION_APPWIDGET_HOST_CATEGORY, -1) ==
        AppWidgetProviderInfo.WIDGET_CATEGORY_KEYGUARD

@Composable
fun isCompact(): Boolean = LocalSize.current.height < CompactHeight

@Composable
fun openApp(uri: android.net.Uri): Action = actionStartActivity<MainActivity>(LocalContext.current, uri)

@Composable
fun Frame(
    look: Look,
    accent: ColorProvider,
    title: String,
    count: String,
    header: Action?,
    footer: String,
    content: @Composable () -> Unit,
) {
    val p = look.palette
    Column(
        modifier = GlanceModifier.fillMaxSize().appWidgetBackground().background(p.bg).cornerRadius(16.dp)
            .padding(horizontal = 12.dp, vertical = 10.dp),
    ) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            modifier = GlanceModifier.fillMaxWidth().let { if (header != null) it.clickable(header) else it },
        ) {
            Box(modifier = GlanceModifier.size(10.dp).background(accent).cornerRadius(3.dp)) {}
            Spacer(GlanceModifier.width(8.dp))
            Text(
                title,
                maxLines = 1,
                style = TextStyle(color = p.ink, fontSize = 14.sp, fontWeight = FontWeight.Bold),
                modifier = GlanceModifier.defaultWeight(),
            )
            if (count.isNotEmpty()) {
                Text(count, maxLines = 1, style = TextStyle(color = p.muted, fontSize = 13.sp, fontWeight = FontWeight.Medium))
            }
        }
        Spacer(GlanceModifier.height(6.dp))
        Box(modifier = GlanceModifier.fillMaxWidth().defaultWeight()) { content() }
        if (footer.isNotEmpty()) {
            Text(footer, maxLines = 1, style = TextStyle(color = p.muted, fontSize = 11.sp))
        }
    }
}

@Composable
fun Message(look: Look, text: String, action: Action? = null) {
    Box(
        contentAlignment = Alignment.Center,
        modifier = GlanceModifier.fillMaxSize().let { if (action != null) it.clickable(action) else it },
    ) {
        Text(text, style = TextStyle(color = look.palette.muted, fontSize = 13.sp))
    }
}

/** A bare widget for when there is nothing to draw yet. */
@Composable
fun Placeholder(look: Look, title: String, text: String) {
    Frame(look, look.palette.muted, title, "", null, "") {
        Message(look, text, openApp(Links.app(Keys.ACTIVE)))
    }
}

@Composable
fun TaskLine(look: Look, ctx: String, task: WTask, tick: Boolean, hideTitle: Boolean) {
    val p = look.palette
    val due = dueOf(task.due, Instant.now(), ZoneId.systemDefault())
    val dueText = when (due) {
        Due.OVERDUE -> look.s("overdue", R.string.widget_overdue)
        Due.TODAY -> look.s("today", R.string.widget_today)
        Due.LATER -> DateUtils.formatDateTime(
            look.context,
            task.due ?: 0,
            DateUtils.FORMAT_SHOW_DATE or DateUtils.FORMAT_ABBREV_MONTH or DateUtils.FORMAT_NO_YEAR,
        )
        Due.NONE -> ""
    }
    val dueColour = when (due) {
        Due.OVERDUE -> p.danger
        Due.TODAY -> p.warn
        else -> p.muted
    }
    Row(verticalAlignment = Alignment.CenterVertically, modifier = GlanceModifier.fillMaxWidth().padding(vertical = 2.dp)) {
        if (tick) {
            val label = look.s("complete", R.string.widget_complete)
            Box(
                contentAlignment = Alignment.Center,
                modifier = GlanceModifier.size(40.dp)
                    .clickable(actionRunCallback<CompleteAction>(CompleteAction.params(ctx, task.ref)))
                    .semantics { contentDescription = "$label ${task.ref}" },
            ) {
                Image(
                    provider = ImageProvider(R.drawable.widget_tick),
                    contentDescription = null,
                    colorFilter = ColorFilter.tint(p.status(task.category)),
                    modifier = GlanceModifier.size(22.dp),
                )
            }
        }
        Box(modifier = GlanceModifier.width(3.dp).height(30.dp).background(p.project(task.colour)).cornerRadius(2.dp)) {}
        Spacer(GlanceModifier.width(8.dp))
        Column(modifier = GlanceModifier.defaultWeight().clickable(openApp(Links.open(ctx, task.route)))) {
            if (!hideTitle) {
                Text(task.title, maxLines = 1, style = TextStyle(color = p.ink, fontSize = 13.sp))
            }
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(task.ref, maxLines = 1, style = TextStyle(color = p.muted, fontSize = 11.sp))
                if (dueText.isNotEmpty()) {
                    Text("  $dueText", maxLines = 1, style = TextStyle(color = dueColour, fontSize = 11.sp, fontWeight = FontWeight.Medium))
                }
                if (task.priority == "highest" || task.priority == "high") {
                    Text("  ▲", maxLines = 1, style = TextStyle(color = p.priority(task.priority), fontSize = 11.sp))
                }
            }
        }
    }
}

/** A big count with one line under it, for the smallest sizes. */
@Composable
fun Count(look: Look, count: String, line: String, colour: ColorProvider) {
    Column(modifier = GlanceModifier.fillMaxSize(), verticalAlignment = Alignment.CenterVertically) {
        Text(count, maxLines = 1, style = TextStyle(color = colour, fontSize = 28.sp, fontWeight = FontWeight.Bold))
        if (line.isNotEmpty()) {
            Text(line, maxLines = 1, style = TextStyle(color = look.palette.muted, fontSize = 12.sp))
        }
    }
}
