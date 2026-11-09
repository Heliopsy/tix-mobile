// SPDX-License-Identifier: AGPL-3.0-or-later

package red.tix.tix_mobile.tiles

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class InboxTileTest {
    private val index = """{"v":1,"at":1,"active":"c1.acme","contexts":[{"id":"c1.acme","instance":"Work","tenant":"Acme"}],"projects":{},"theme":"system","systemBlack":false,"lockCounts":true,"strings":{}}"""
    private val inbox = """{"v":1,"at":1,"ctx":{"id":"c1.acme"},"accent":{},"unread":3,"more":false,"unreadText":"3 unread","items":[]}"""

    @Test
    fun readsTheActiveContextsCount() {
        val asked = mutableListOf<String>()
        val unread = InboxTile.unread(index) { key ->
            asked += key
            inbox
        }
        assertEquals(3, unread)
        assertEquals(listOf("tix.widget.inbox.c1.acme"), asked)
    }

    @Test
    fun noSnapshotIsNoCount() {
        assertNull(InboxTile.unread(null) { inbox })
        assertNull(InboxTile.unread(index) { null })
        assertNull(InboxTile.unread("""{"v":2}""") { inbox })
    }
}
