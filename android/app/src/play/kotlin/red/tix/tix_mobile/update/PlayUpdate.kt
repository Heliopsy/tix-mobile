// SPDX-License-Identifier: AGPL-3.0-or-later

package red.tix.tix_mobile.update

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.content.IntentSender
import android.net.Uri
import com.google.android.play.core.appupdate.AppUpdateInfo
import com.google.android.play.core.appupdate.AppUpdateManager
import com.google.android.play.core.appupdate.AppUpdateManagerFactory
import com.google.android.play.core.appupdate.AppUpdateOptions
import com.google.android.play.core.install.InstallStateUpdatedListener
import com.google.android.play.core.install.model.AppUpdateType
import com.google.android.play.core.install.model.InstallStatus
import com.google.android.play.core.install.model.UpdateAvailability
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.suspendCancellableCoroutine
import kotlinx.coroutines.withTimeoutOrNull
import kotlin.coroutines.resume

/**
 * Google Play's in-app updates for the play flavour, on [CHANNEL]:
 *
 * - `info` answers `{available, versionCode, flexible}` from
 *   AppUpdateManager, or fails with code `play` when Play cannot say.
 * - `start` starts a FLEXIBLE update when Play allows one and answers
 *   `flexible`; otherwise it opens the Play listing and answers `listing`,
 *   or `none` when nothing could open it.
 *
 * A flexible update that finished downloading is installed right away when
 * the app is open, and on the next resume otherwise; the person asked for
 * it by tapping Update.
 */
object PlayUpdate {
    const val CHANNEL = "tix/play-update"
    private const val REQUEST_UPDATE = 4712
    private const val PACKAGE = "red.tix.tix_mobile"
    private const val BACKGROUND_TIMEOUT_MS = 30_000L

    private var listener: InstallStateUpdatedListener? = null

    /** Answers [CHANNEL] for [activity]'s engine. */
    fun attach(activity: Activity, messenger: BinaryMessenger) {
        val manager = AppUpdateManagerFactory.create(activity)
        MethodChannel(messenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "info" -> manager.appUpdateInfo
                    .addOnSuccessListener { result.success(describe(it)) }
                    .addOnFailureListener { result.error("play", it.message, null) }
                "start" -> manager.appUpdateInfo
                    .addOnSuccessListener { result.success(start(activity, manager, it)) }
                    .addOnFailureListener { result.success(if (openListing(activity)) "listing" else "none") }
                else -> result.notImplemented()
            }
        }
    }

    /** Installs a flexible update that finished downloading while away. */
    fun resume(activity: Activity) {
        val manager = AppUpdateManagerFactory.create(activity)
        manager.appUpdateInfo.addOnSuccessListener {
            if (it.installStatus() == InstallStatus.DOWNLOADED) manager.completeUpdate()
        }
    }

    /**
     * [uri] with Play's answer added for the background check, which runs
     * in an engine without [CHANNEL]: `play=1` or `play=0` and `code`, the
     * available version code. [uri] unchanged when Play does not answer.
     */
    suspend fun background(context: Context, uri: Uri): Uri {
        val manager = AppUpdateManagerFactory.create(context)
        val info = withTimeoutOrNull(BACKGROUND_TIMEOUT_MS) {
            suspendCancellableCoroutine<AppUpdateInfo?> { cont ->
                manager.appUpdateInfo
                    .addOnSuccessListener { cont.resume(it) }
                    .addOnFailureListener { cont.resume(null) }
            }
        } ?: return uri
        return uri.buildUpon()
            .appendQueryParameter("play", if (available(info)) "1" else "0")
            .appendQueryParameter("code", info.availableVersionCode().toString())
            .build()
    }

    private fun available(info: AppUpdateInfo) =
        info.updateAvailability() == UpdateAvailability.UPDATE_AVAILABLE

    private fun describe(info: AppUpdateInfo): Map<String, Any> = mapOf(
        "available" to available(info),
        "versionCode" to info.availableVersionCode(),
        "flexible" to info.isUpdateTypeAllowed(AppUpdateType.FLEXIBLE),
    )

    private fun start(activity: Activity, manager: AppUpdateManager, info: AppUpdateInfo): String {
        if (info.installStatus() == InstallStatus.DOWNLOADED) {
            manager.completeUpdate()
            return "flexible"
        }
        if (available(info) && info.isUpdateTypeAllowed(AppUpdateType.FLEXIBLE)) {
            watch(manager)
            val options = AppUpdateOptions.newBuilder(AppUpdateType.FLEXIBLE).build()
            try {
                if (manager.startUpdateFlowForResult(info, activity, options, REQUEST_UPDATE)) return "flexible"
            } catch (e: IntentSender.SendIntentException) {
                unwatch(manager)
            }
        }
        return if (openListing(activity)) "listing" else "none"
    }

    private fun watch(manager: AppUpdateManager) {
        unwatch(manager)
        val next = InstallStateUpdatedListener { state ->
            when (state.installStatus()) {
                InstallStatus.DOWNLOADED -> {
                    unwatch(manager)
                    manager.completeUpdate()
                }
                InstallStatus.FAILED, InstallStatus.CANCELED, InstallStatus.INSTALLED -> unwatch(manager)
                else -> Unit
            }
        }
        listener = next
        manager.registerListener(next)
    }

    private fun unwatch(manager: AppUpdateManager) {
        listener?.let { manager.unregisterListener(it) }
        listener = null
    }

    private fun openListing(activity: Activity): Boolean {
        for (link in listOf("market://details?id=$PACKAGE", "https://play.google.com/store/apps/details?id=$PACKAGE")) {
            try {
                activity.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(link)))
                return true
            } catch (e: ActivityNotFoundException) {
                continue
            }
        }
        return false
    }
}
