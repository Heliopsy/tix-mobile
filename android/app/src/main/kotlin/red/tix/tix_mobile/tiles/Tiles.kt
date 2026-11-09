// SPDX-License-Identifier: AGPL-3.0-or-later

package red.tix.tix_mobile.tiles

import android.app.PendingIntent
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService
import androidx.annotation.RequiresApi
import red.tix.tix_mobile.MainActivity
import red.tix.tix_mobile.R
import red.tix.tix_mobile.widgets.Keys
import red.tix.tix_mobile.widgets.Snapshots
import red.tix.tix_mobile.widgets.Store

/** What the Inbox tile shows, read from the widget snapshot and never from a credential. */
object InboxTile {
    /** The active context's unread count, null when there is no snapshot of it. */
    fun unread(index: String?, inbox: (String) -> String?): Int? {
        val active = Snapshots.index(index)?.active ?: return null
        return Snapshots.inbox(inbox(Keys.inbox(active)))?.unread
    }

    /** The link the tile opens: the inbox of the context its count is from. */
    fun link(index: String?): Uri {
        val builder = Uri.Builder().scheme("tix").authority("inbox")
        Snapshots.index(index)?.active?.let { builder.appendQueryParameter("context", it) }
        return builder.build()
    }
}

/**
 * A tile that opens a `tix://` link in the app, through the same path as
 * any other link. A locked device unlocks first.
 */
@RequiresApi(Build.VERSION_CODES.N)
abstract class LinkTile : TileService() {
    /** The link a tap opens. */
    abstract fun link(): Uri

    override fun onClick() {
        super.onClick()
        if (isLocked) unlockAndRun { open() } else open()
    }

    private fun open() {
        val intent = Intent(Intent.ACTION_VIEW, link())
            .setClass(this, MainActivity::class.java)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            val pending = PendingIntent.getActivity(
                this,
                javaClass.name.hashCode(),
                intent,
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
            )
            startActivityAndCollapse(pending)
        } else {
            @Suppress("DEPRECATION")
            startActivityAndCollapse(intent)
        }
    }

    /** Draws the tile as [state] with [subtitle] under its label, where the platform shows one. */
    protected fun draw(label: String, state: Int, subtitle: String?) {
        val tile = qsTile ?: return
        tile.label = label
        tile.state = state
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) tile.subtitle = subtitle
        tile.updateTile()
    }
}

/** Quick Settings: opens quick add over the app (`tix://quick-add`). */
@RequiresApi(Build.VERSION_CODES.N)
class QuickAddTileService : LinkTile() {
    override fun link(): Uri = Uri.parse("tix://quick-add")

    override fun onStartListening() {
        super.onStartListening()
        draw(getString(R.string.tile_quick_add), Tile.STATE_INACTIVE, getString(R.string.tile_brand))
    }
}

/** Quick Settings: the active context's unread count, opening its inbox. */
@RequiresApi(Build.VERSION_CODES.N)
class InboxTileService : LinkTile() {
    override fun link(): Uri = InboxTile.link(Store(this).read(Keys.INDEX))

    override fun onStartListening() {
        super.onStartListening()
        val store = Store(this)
        val unread = InboxTile.unread(store.read(Keys.INDEX)) { store.read(it) }
        val subtitle = when {
            unread == null -> getString(R.string.tile_open_app)
            unread > 0 -> getString(R.string.tile_inbox_unread, unread)
            else -> getString(R.string.tile_inbox_none)
        }
        val state = if ((unread ?: 0) > 0) Tile.STATE_ACTIVE else Tile.STATE_INACTIVE
        draw(getString(R.string.tile_inbox), state, subtitle)
    }
}
