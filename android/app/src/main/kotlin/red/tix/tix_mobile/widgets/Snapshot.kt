// SPDX-License-Identifier: AGPL-3.0-or-later

package red.tix.tix_mobile.widgets

import org.json.JSONArray
import org.json.JSONObject
import java.time.Instant
import java.time.ZoneId

/** The snapshot format docs/widgets.md defines; anything else is refused. */
const val SCHEMA_VERSION = 1

/** Keys in HomeWidgetPreferences. */
object Keys {
    const val INDEX = "tix.widget.index"
    const val QUEUE = "tix.widget.queue"
    const val WANTED = "tix.widget.wanted"
    const val ACTIVE = "active"

    fun myWork(ctx: String) = "tix.widget.mywork.$ctx"

    fun inbox(ctx: String) = "tix.widget.inbox.$ctx"

    fun project(ctx: String, key: String) = "tix.widget.project.$ctx.$key"
}

data class Colour(val light: String, val dark: String)

data class Accent(val light: String, val dark: String, val onLight: String, val onDark: String)

data class Ctx(val id: String, val instance: String, val tenant: String, val local: Boolean) {
    val label: String get() = listOf(instance, tenant).filter { it.isNotEmpty() }.joinToString(" · ")
}

data class WTask(
    val ref: String,
    val title: String,
    val project: String,
    val colour: Colour?,
    val due: Long?,
    val priority: String,
    val status: String,
    val category: String,
    val route: String,
)

data class WInboxItem(
    val id: String,
    val what: String,
    val task: String,
    val excerpt: String,
    val at: Long?,
    val route: String,
)

data class WProject(val key: String, val name: String, val colour: Colour?)

data class WGroup(val status: String, val label: String, val category: String, val count: Int, val tasks: List<WTask>)

data class Header(val at: Long, val ctx: Ctx, val accent: Accent)

data class MyWork(val header: Header, val total: Int, val more: Boolean, val moreText: String, val tasks: List<WTask>)

data class Inbox(val header: Header, val unread: Int, val more: Boolean, val unreadText: String, val items: List<WInboxItem>)

data class ProjectSnap(val header: Header, val project: WProject, val open: Int, val more: Boolean, val groups: List<WGroup>)

data class Index(
    val at: Long,
    val active: String?,
    val contexts: List<Ctx>,
    val projects: Map<String, List<WProject>>,
    val theme: String,
    val systemBlack: Boolean,
    val lockCounts: Boolean,
    val strings: Map<String, String>,
) {
    fun ctx(id: String?): Ctx? = contexts.firstOrNull { it.id == id }

    /** The context a widget configured with [configured] shows. */
    fun resolve(configured: String?): String? =
        if (configured.isNullOrEmpty() || configured == Keys.ACTIVE) active else configured
}

/** One queued action, as the app drains it. */
data class Action(val id: String, val op: String, val ctx: String, val ref: String, val at: Long)

/** What one configured widget needs. */
data class Want(val ctx: String, val project: String?, val at: Long)

/** Reads the JSON the app writes; null for missing, broken or newer data. */
object Snapshots {
    private fun obj(text: String?): JSONObject? {
        if (text.isNullOrEmpty()) return null
        return try {
            JSONObject(text).takeIf { it.optInt("v", -1) == SCHEMA_VERSION }
        } catch (e: org.json.JSONException) {
            null
        }
    }

    /** Whether [text] is a snapshot of a version this build cannot read. */
    fun isNewer(text: String?): Boolean {
        if (text.isNullOrEmpty()) return false
        return try {
            JSONObject(text).optInt("v", -1) != SCHEMA_VERSION
        } catch (e: org.json.JSONException) {
            false
        }
    }

    private fun JSONObject.str(key: String) = optString(key, "")

    private fun JSONObject.longOrNull(key: String): Long? = if (has(key) && !isNull(key)) optLong(key) else null

    private fun colour(o: JSONObject?): Colour? = o?.let { Colour(it.str("light"), it.str("dark")) }

    private fun ctx(o: JSONObject?): Ctx =
        Ctx(o?.str("id") ?: "", o?.str("instance") ?: "", o?.str("tenant") ?: "", o?.optBoolean("local") ?: false)

    private fun header(o: JSONObject): Header {
        val a = o.optJSONObject("accent")
        return Header(
            at = o.optLong("at"),
            ctx = ctx(o.optJSONObject("ctx")),
            accent = Accent(
                a?.str("light") ?: "#0f766e",
                a?.str("dark") ?: "#2dd4bf",
                a?.str("onLight") ?: "#ffffff",
                a?.str("onDark") ?: "#08231a",
            ),
        )
    }

    private inline fun <T> JSONArray?.map(f: (JSONObject) -> T): List<T> {
        if (this == null) return emptyList()
        return (0 until length()).mapNotNull { optJSONObject(it)?.let(f) }
    }

    private fun task(o: JSONObject) = WTask(
        ref = o.str("ref"),
        title = o.str("title"),
        project = o.str("project"),
        colour = colour(o.optJSONObject("colour")),
        due = o.longOrNull("due"),
        priority = o.optString("priority", "normal"),
        status = o.str("status"),
        category = o.optString("category", "todo"),
        route = o.str("route"),
    )

    private fun project(o: JSONObject) = WProject(o.str("key"), o.str("name"), colour(o.optJSONObject("colour")))

    fun index(text: String?): Index? {
        val o = obj(text) ?: return null
        val strings = mutableMapOf<String, String>()
        o.optJSONObject("strings")?.let { s -> s.keys().forEach { strings[it] = s.optString(it) } }
        val projects = mutableMapOf<String, List<WProject>>()
        o.optJSONObject("projects")?.let { p -> p.keys().forEach { projects[it] = p.optJSONArray(it).map(::project) } }
        return Index(
            at = o.optLong("at"),
            active = o.optString("active", "").ifEmpty { null },
            contexts = o.optJSONArray("contexts").map { ctx(it) },
            projects = projects,
            theme = o.optString("theme", "system"),
            systemBlack = o.optBoolean("systemBlack"),
            lockCounts = o.optBoolean("lockCounts", true),
            strings = strings,
        )
    }

    fun myWork(text: String?): MyWork? {
        val o = obj(text) ?: return null
        return MyWork(
            header(o),
            o.optInt("total"),
            o.optBoolean("more"),
            o.str("moreText"),
            o.optJSONArray("tasks").map(::task),
        )
    }

    fun inbox(text: String?): Inbox? {
        val o = obj(text) ?: return null
        return Inbox(
            header(o),
            o.optInt("unread"),
            o.optBoolean("more"),
            o.str("unreadText"),
            o.optJSONArray("items").map {
                WInboxItem(it.str("id"), it.str("what"), it.str("task"), it.str("excerpt"), it.longOrNull("at"), it.str("route"))
            },
        )
    }

    fun project(text: String?): ProjectSnap? {
        val o = obj(text) ?: return null
        return ProjectSnap(
            header(o),
            project(o.optJSONObject("project") ?: JSONObject()),
            o.optInt("open"),
            o.optBoolean("more"),
            o.optJSONArray("groups").map { g ->
                WGroup(g.str("status"), g.str("label"), g.optString("category", "todo"), g.optInt("count"), g.optJSONArray("tasks").map(::task))
            },
        )
    }

    fun queue(text: String?): List<Action> {
        if (text.isNullOrEmpty()) return emptyList()
        return try {
            JSONArray(text).map { Action(it.str("id"), it.str("op"), it.str("ctx"), it.str("ref"), it.optLong("at")) }
        } catch (e: org.json.JSONException) {
            emptyList()
        }
    }

    /** [queue] with a completion of [ref] in [ctx] appended. */
    fun enqueueComplete(queue: String?, ctx: String, ref: String, now: Long, nonce: Int): String {
        val array = try {
            if (queue.isNullOrEmpty()) JSONArray() else JSONArray(queue)
        } catch (e: org.json.JSONException) {
            JSONArray()
        }
        array.put(
            JSONObject()
                .put("id", "w-$now-$nonce")
                .put("op", "complete")
                .put("ctx", ctx)
                .put("ref", ref)
                .put("at", now),
        )
        return array.toString()
    }

    /** The refs queued for completion in [ctx], which widgets hide. */
    fun pendingRefs(queue: String?, ctx: String): Set<String> =
        queue(queue).filter { it.ctx == ctx && it.op == "complete" }.map { it.ref }.toSet()

    fun wanted(text: String?): Map<String, Want> {
        if (text.isNullOrEmpty()) return emptyMap()
        return try {
            val o = JSONObject(text)
            o.keys().asSequence().mapNotNull { k ->
                o.optJSONObject(k)?.let { k to Want(it.str("ctx"), it.optString("project", "").ifEmpty { null }, it.optLong("at")) }
            }.toMap()
        } catch (e: org.json.JSONException) {
            emptyMap()
        }
    }

    /** [wanted] with [key] set to [want], or removed when null. */
    fun withWant(wanted: String?, key: String, want: Want?): String {
        val o = try {
            if (wanted.isNullOrEmpty()) JSONObject() else JSONObject(wanted)
        } catch (e: org.json.JSONException) {
            JSONObject()
        }
        if (want == null) {
            o.remove(key)
        } else {
            val w = JSONObject().put("ctx", want.ctx).put("at", want.at)
            if (want.project != null) w.put("project", want.project)
            o.put(key, w)
        }
        return o.toString()
    }
}

/** How a due date reads against the device's clock. */
enum class Due { NONE, OVERDUE, TODAY, LATER }

fun dueOf(due: Long?, now: Instant, zone: ZoneId): Due {
    if (due == null) return Due.NONE
    val day = Instant.ofEpochMilli(due).atZone(zone).toLocalDate()
    val today = now.atZone(zone).toLocalDate()
    return when {
        day.isBefore(today) -> Due.OVERDUE
        day == today -> Due.TODAY
        else -> Due.LATER
    }
}
