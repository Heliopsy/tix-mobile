package red.tix.tix_mobile

import android.app.Notification
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import red.tix.tix_mobile.notes.NoteActions
import red.tix.tix_mobile.notes.NoteButton

// flutter_local_notifications posts with VISIBILITY_PRIVATE but cannot set a
// public version, so a locked screen would fall back to "Contents hidden".
// This rebuilds the posted notification with a public version naming no task,
// and keeps it silent so it does not alert twice. The actions are added here
// too (NoteActions.kt); the public version carries none.
object PublicNotes {
    fun attach(
        context: Context,
        id: Int,
        title: String,
        body: String,
        buttons: List<NoteButton> = emptyList(),
        payload: String = "",
        replyLabel: String = "",
        unlock: Boolean = false,
    ): Boolean {
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
        if (buttons.isNotEmpty() && payload.isNotEmpty()) {
            rebuilt.setActions(
                *buttons.map { NoteActions.action(context, id, it, payload, replyLabel, unlock) }.toTypedArray(),
            )
        }
        manager.notify(posted.tag, id, rebuilt.build())
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
