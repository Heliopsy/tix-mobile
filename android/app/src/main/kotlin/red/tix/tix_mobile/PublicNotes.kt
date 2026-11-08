package red.tix.tix_mobile

import android.app.Notification
import android.app.NotificationManager
import android.content.Context
import android.os.Build

// flutter_local_notifications posts with VISIBILITY_PRIVATE but cannot set a
// public version, so a locked screen would fall back to "Contents hidden".
// This rebuilds the posted notification with a public version naming no task,
// and keeps it silent so it does not alert twice.
object PublicNotes {
    fun attach(context: Context, id: Int, title: String, body: String): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N) return false
        val manager = context.getSystemService(NotificationManager::class.java) ?: return false
        val posted = manager.activeNotifications.firstOrNull { it.id == id } ?: return false
        val original = posted.notification
        val public = publicBuilder(context, original)
            .setSmallIcon(original.smallIcon)
            .setContentTitle(title)
            .setContentText(body)
            .setContentIntent(original.contentIntent)
            .setAutoCancel(true)
            .build()
        val rebuilt = Notification.Builder.recoverBuilder(context, original)
            .setPublicVersion(public)
            .setVisibility(Notification.VISIBILITY_PRIVATE)
            .setOnlyAlertOnce(true)
            .build()
        manager.notify(posted.tag, id, rebuilt)
        return true
    }

    @Suppress("DEPRECATION")
    private fun publicBuilder(context: Context, original: Notification): Notification.Builder =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(context, original.channelId)
        } else {
            Notification.Builder(context)
        }
}
