// SPDX-License-Identifier: AGPL-3.0-or-later

package red.tix.tix_mobile.widgets

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.LocalContext
import androidx.glance.LocalGlanceId
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetManager
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.cornerRadius
import androidx.glance.appwidget.lazy.LazyColumn
import androidx.glance.appwidget.lazy.items
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.currentState
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.width
import androidx.glance.state.GlanceStateDefinition
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextAlign
import androidx.glance.text.TextStyle
import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetGlanceStateDefinition
import red.tix.tix_mobile.R

/** What a tix widget reads when it draws: storage, the index, its configuration. */
class Drawn(val look: Look, val read: (String) -> String?, val want: Want?) {
    val index get() = look.index

    /** The context this widget shows, null while signed out. */
    val ctx: String? get() = index?.resolve(want?.ctx)

    fun pending(ctx: String): Set<String> = Snapshots.pendingRefs(read(Keys.QUEUE), ctx)
}

/** The parts every tix widget shares: storage as state, exact sizes. */
abstract class TixWidget : GlanceAppWidget() {
    override val sizeMode: SizeMode = SizeMode.Exact

    override val stateDefinition: GlanceStateDefinition<*> = HomeWidgetGlanceStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent { Content() }
    }

    @Composable
    private fun Content() {
        val context = LocalContext.current
        val prefs = currentState<HomeWidgetGlanceState>().preferences
        val read = { key: String -> prefs.getString(key, null) }
        val appWidgetId = GlanceAppWidgetManager(context).getAppWidgetId(LocalGlanceId.current)
        val want = Snapshots.wanted(read(Keys.WANTED))[Store.wantKey(appWidgetId)]
        val indexText = read(Keys.INDEX)
        val look = Look(context, Snapshots.index(indexText))
        if (Snapshots.isNewer(indexText)) {
            Placeholder(look, title(look), context.getString(R.string.widget_update_app))
            return
        }
        Draw(Drawn(look, read, want))
    }

    @Composable
    abstract fun title(look: Look): String

    @Composable
    abstract fun Draw(d: Drawn)
}

class MyWorkWidget : TixWidget() {
    @Composable
    override fun title(look: Look) = look.s("myWork", R.string.widget_my_work)

    @Composable
    override fun Draw(d: Drawn) {
        val look = d.look
        val ctx = d.ctx
        val snap = ctx?.let { Snapshots.myWork(d.read(Keys.myWork(it))) }
        if (ctx == null || snap == null) {
            Placeholder(look, title(look), if (d.index != null && ctx == null) look.s("signedOut", R.string.widget_signed_out) else look.s("openApp", R.string.widget_open_app))
            return
        }
        val pending = d.pending(ctx)
        val tasks = snap.tasks.filterNot { it.ref in pending }
        val total = (snap.total - pending.size).coerceAtLeast(0)
        val hide = onKeyguard() && d.index?.lockCounts != false
        val p = look.palette
        Frame(
            look,
            p.accent(snap.header.accent),
            title(look),
            if (snap.more) "$total+" else "$total",
            openApp(Links.open(ctx, "/mine")),
            look.footer(snap.header),
        ) {
            when {
                tasks.isEmpty() -> Message(look, look.s("nothingDue", R.string.widget_nothing_due))
                hide || isCompact() -> Count(look, if (snap.more) "$total+" else "$total", if (hide) "" else tasks.first().title, p.ink)
                else -> LazyColumn {
                    items(tasks, itemId = { it.ref.hashCode().toLong() }) { TaskLine(look, ctx, it, tick = true, hideTitle = false) }
                    if (snap.moreText.isNotEmpty()) {
                        item { Text(snap.moreText, style = TextStyle(color = p.muted, fontSize = 12.sp), modifier = GlanceModifier.padding(vertical = 4.dp)) }
                    }
                }
            }
        }
    }
}

class InboxWidget : TixWidget() {
    @Composable
    override fun title(look: Look) = look.s("inbox", R.string.widget_inbox)

    @Composable
    override fun Draw(d: Drawn) {
        val look = d.look
        val ctx = d.ctx
        val snap = ctx?.let { Snapshots.inbox(d.read(Keys.inbox(it))) }
        if (ctx == null || snap == null) {
            Placeholder(look, title(look), if (d.index != null && ctx == null) look.s("signedOut", R.string.widget_signed_out) else look.s("openApp", R.string.widget_open_app))
            return
        }
        val p = look.palette
        val count = if (snap.more) "${snap.unread}+" else "${snap.unread}"
        val hide = onKeyguard() && d.index?.lockCounts != false
        Frame(look, p.accent(snap.header.accent), title(look), count, openApp(Links.open(ctx, "/inbox")), look.footer(snap.header)) {
            when {
                snap.unread == 0 -> Message(look, look.s("allRead", R.string.widget_all_read))
                hide || isCompact() -> Count(look, count, snap.unreadText.takeIf { hide } ?: (snap.items.firstOrNull()?.what ?: snap.unreadText), p.accent(snap.header.accent))
                else -> LazyColumn {
                    items(snap.items, itemId = { it.id.hashCode().toLong() }) { item ->
                        Column(modifier = GlanceModifier.fillMaxWidth().padding(vertical = 4.dp).clickable(openApp(Links.open(ctx, item.route, item.id)))) {
                            Text(item.what, maxLines = 1, style = TextStyle(color = p.ink, fontSize = 13.sp, fontWeight = FontWeight.Medium))
                            Text(item.task, maxLines = 1, style = TextStyle(color = p.muted, fontSize = 12.sp))
                            if (item.excerpt.isNotEmpty()) {
                                Text(item.excerpt, maxLines = 1, style = TextStyle(color = p.muted, fontSize = 12.sp))
                            }
                        }
                    }
                }
            }
        }
    }
}

class QuickAddWidget : TixWidget() {
    @Composable
    override fun title(look: Look) = look.s("quickAdd", R.string.widget_quick_add)

    @Composable
    override fun Draw(d: Drawn) {
        val look = d.look
        val p = look.palette
        val ctx = d.want?.ctx ?: Keys.ACTIVE
        val accent = d.ctx?.let { Snapshots.myWork(d.read(Keys.myWork(it)))?.header?.accent } ?: Accent("#0f766e", "#2dd4bf", "#ffffff", "#08231a")
        val label = look.s("addTask", R.string.widget_add_task)
        Box(
            contentAlignment = Alignment.Center,
            modifier = GlanceModifier.fillMaxSize().background(p.accent(accent)).cornerRadius(16.dp)
                .clickable(openApp(Links.quickAdd(ctx, d.want?.project))),
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text("+", style = TextStyle(color = p.onAccent(accent), fontSize = 22.sp, fontWeight = FontWeight.Bold))
                Spacer(GlanceModifier.width(6.dp))
                Text(label, maxLines = 2, style = TextStyle(color = p.onAccent(accent), fontSize = 14.sp, fontWeight = FontWeight.Medium, textAlign = TextAlign.Center))
            }
        }
    }
}

class ProjectWidget : TixWidget() {
    @Composable
    override fun title(look: Look) = look.context.getString(R.string.widget_project)

    @Composable
    override fun Draw(d: Drawn) {
        val look = d.look
        val p = look.palette
        val ctx = d.ctx
        val key = d.want?.project
        if (ctx == null || key.isNullOrEmpty()) {
            Placeholder(look, title(look), look.context.getString(R.string.widget_pick_project))
            return
        }
        val snap = Snapshots.project(d.read(Keys.project(ctx, key)))
        if (snap == null) {
            val known = d.index?.projects?.get(ctx)
            val text = if (known != null && known.none { it.key.equals(key, true) }) look.s("projectMissing", R.string.widget_project_missing) else look.s("openApp", R.string.widget_open_app)
            Placeholder(look, key, text)
            return
        }
        val pending = d.pending(ctx)
        val hide = onKeyguard() && d.index?.lockCounts != false
        Frame(look, p.project(snap.project.colour), snap.project.name, if (snap.more) "${snap.open}+" else "${snap.open}", openApp(Links.open(ctx, "/projects/${snap.project.key}")), look.footer(snap.header)) {
            when {
                snap.open == 0 -> Message(look, look.s("noOpenTasks", R.string.widget_no_open_tasks))
                hide || isCompact() -> Row(modifier = GlanceModifier.fillMaxSize(), verticalAlignment = Alignment.CenterVertically) {
                    snap.groups.filter { it.count > 0 }.take(3).forEach { g ->
                        Column(modifier = GlanceModifier.defaultWeight()) {
                            Text("${g.count}", style = TextStyle(color = p.status(g.category), fontSize = 22.sp, fontWeight = FontWeight.Bold))
                            Text(g.label, maxLines = 1, style = TextStyle(color = p.muted, fontSize = 11.sp))
                        }
                    }
                }
                else -> LazyColumn {
                    snap.groups.filter { it.count > 0 }.forEach { g ->
                        item {
                            Row(verticalAlignment = Alignment.CenterVertically, modifier = GlanceModifier.fillMaxWidth().padding(top = 6.dp, bottom = 2.dp)) {
                                Text(g.label, maxLines = 1, style = TextStyle(color = p.status(g.category), fontSize = 12.sp, fontWeight = FontWeight.Bold), modifier = GlanceModifier.defaultWeight())
                                Text("${g.count}", style = TextStyle(color = p.muted, fontSize = 12.sp))
                            }
                        }
                        items(g.tasks.filterNot { it.ref in pending }, itemId = { it.ref.hashCode().toLong() }) {
                            TaskLine(look, ctx, it, tick = false, hideTitle = false)
                        }
                    }
                }
            }
        }
    }
}

/** Every tix widget, to redraw them all after a tick. */
val allWidgets: List<() -> GlanceAppWidget> = listOf(::MyWorkWidget, ::InboxWidget, ::QuickAddWidget, ::ProjectWidget)
