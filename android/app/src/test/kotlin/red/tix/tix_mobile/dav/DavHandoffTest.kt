// SPDX-License-Identifier: AGPL-3.0-or-later

package red.tix.tix_mobile.dav

import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class DavHandoffTest {
    @Test
    fun takesCaldavAddressesWithoutUserInfo() {
        assertTrue(DavHandoff.safeAddress("caldavs://tix.example.com/dav/"))
        assertTrue(DavHandoff.safeAddress("caldav://10.0.0.2:8080/dav/"))
    }

    @Test
    fun refusesUserInfoAndOtherSchemes() {
        assertFalse(DavHandoff.safeAddress("caldavs://ana:secret@tix.example.com/dav/"))
        assertFalse(DavHandoff.safeAddress("https://tix.example.com/dav/"))
        assertFalse(DavHandoff.safeAddress("caldavs:///dav/"))
        assertFalse(DavHandoff.safeAddress(""))
    }
}
