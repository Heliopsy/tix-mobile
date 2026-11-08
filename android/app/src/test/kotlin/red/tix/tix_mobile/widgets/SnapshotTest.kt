// SPDX-License-Identifier: AGPL-3.0-or-later

package red.tix.tix_mobile.widgets

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import java.time.Instant
import java.time.ZoneId

class SnapshotTest {
    private val header = """"v":1,"at":1762600000000,"ctx":{"id":"c1.acme","instance":"Work","tenant":"Acme","local":false},"accent":{"light":"#0f766e","dark":"#2dd4bf","onLight":"#ffffff","onDark":"#08231a"}"""

    @Test
    fun readsMyWork() {
        val snap = Snapshots.myWork(
            """{$header,"total":2,"more":false,"moreText":"","tasks":[{"ref":"OPS-1","title":"Rotate","project":"OPS","due":1762560000000,"priority":"high","status":"Doing","category":"doing","route":"/projects/OPS/tasks/OPS-1"}]}""",
        )!!
        assertEquals("Work · Acme", snap.header.ctx.label)
        assertEquals(1762560000000L, snap.tasks.single().due)
        assertEquals("doing", snap.tasks.single().category)
    }

    @Test
    fun refusesOtherVersions() {
        val text = """{"v":2,"tasks":[]}"""
        assertNull(Snapshots.myWork(text))
        assertTrue(Snapshots.isNewer(text))
        assertNull(Snapshots.index("not json"))
    }

    @Test
    fun indexResolvesTheActiveContext() {
        val index = Snapshots.index(
            """{"v":1,"at":1,"active":"c1.acme","contexts":[{"id":"c1.acme","instance":"Work","tenant":"Acme"}],"projects":{},"theme":"black","systemBlack":false,"lockCounts":true,"strings":{"myWork":"Meine Arbeit"}}""",
        )!!
        assertEquals("c1.acme", index.resolve(null))
        assertEquals("c1.acme", index.resolve("active"))
        assertEquals("l1.x", index.resolve("l1.x"))
        assertEquals("Meine Arbeit", index.strings["myWork"])
    }

    @Test
    fun queuedTicksAreHidden() {
        var queue = Snapshots.enqueueComplete(null, "c1.acme", "OPS-1", 5, 1)
        queue = Snapshots.enqueueComplete(queue, "l1.default", "OPS-2", 6, 2)
        assertEquals(setOf("OPS-1"), Snapshots.pendingRefs(queue, "c1.acme"))
        assertEquals(2, Snapshots.queue(queue).size)
    }

    @Test
    fun wantsAreKeptPerWidget() {
        var wanted = Snapshots.withWant(null, "android:4", Want("active", "OPS", 9))
        assertEquals("OPS", Snapshots.wanted(wanted)["android:4"]?.project)
        wanted = Snapshots.withWant(wanted, "android:4", null)
        assertTrue(Snapshots.wanted(wanted).isEmpty())
    }

    @Test
    fun overdueAndTodayFollowTheDeviceClock() {
        val zone = ZoneId.of("Europe/Sofia")
        val now = Instant.parse("2026-11-08T10:00:00Z")
        assertEquals(Due.OVERDUE, dueOf(Instant.parse("2026-11-07T10:00:00Z").toEpochMilli(), now, zone))
        assertEquals(Due.TODAY, dueOf(Instant.parse("2026-11-08T21:00:00Z").toEpochMilli(), now, zone))
        assertEquals(Due.LATER, dueOf(Instant.parse("2026-11-08T23:00:00Z").toEpochMilli(), now, zone))
        assertEquals(Due.NONE, dueOf(null, now, zone))
    }
}
