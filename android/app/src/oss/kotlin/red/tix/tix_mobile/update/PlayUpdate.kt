// SPDX-License-Identifier: AGPL-3.0-or-later

package red.tix.tix_mobile.update

import android.app.Activity
import android.content.Context
import android.net.Uri
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/**
 * The oss build's stand-in for Google Play's in-app updates: Play is never
 * there. The play flavour's PlayUpdate (src/play) has the same members and
 * the real thing; keeping Play Core out of this source set is what keeps it
 * out of the GitHub and F-Droid APKs.
 */
object PlayUpdate {
    const val CHANNEL = "tix/play-update"

    /** Answers every call on [CHANNEL] with null: no Play here. */
    fun attach(activity: Activity, messenger: BinaryMessenger) {
        MethodChannel(messenger, CHANNEL).setMethodCallHandler { _, result -> result.success(null) }
    }

    /** Nothing to finish without Play. */
    fun resume(activity: Activity) = Unit

    /** [uri] unchanged: there is no Play answer to add. */
    suspend fun background(context: Context, uri: Uri): Uri = uri
}
