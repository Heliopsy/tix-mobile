// SPDX-License-Identifier: AGPL-3.0-or-later

package red.tix.tix_mobile.adb

import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import red.tix.tix_mobile.widgets.Ctx
import red.tix.tix_mobile.widgets.Index

class FallbackTest {
    private val index = Index(
        at = 0L,
        active = "c1.acme",
        contexts = listOf(Ctx("c1.acme", "Work", "Acme", false), Ctx("c2.", "Laptop", "", true)),
        projects = emptyMap(),
        theme = "dark",
        systemBlack = false,
        lockCounts = true,
        strings = emptyMap(),
    )

    @Test
    fun listsTheContextsTheIndexKnows() {
        val text = Fallback.text("red.tix.tix_mobile", "0.8.0 (build 8)", index, starting = true)
        assertTrue(text.contains("tix-mobile 0.8.0 (build 8)"))
        assertTrue(text.contains("Active: c1.acme"))
        assertTrue(text.contains("* c1.acme  Work · Acme"))
        assertTrue(text.contains("c2.  Laptop, local"))
        assertTrue(text.contains("Theme: dark"))
        assertTrue(text.contains("run the same command again"))
    }

    @Test
    fun saysWhenThereIsNoIndex() {
        val text = Fallback.text("red.tix.tix_mobile", "0.8.0 (build 8)", null, starting = false)
        assertTrue(text.contains("open tix once"))
        assertFalse(text.contains("== contexts =="))
    }
}
