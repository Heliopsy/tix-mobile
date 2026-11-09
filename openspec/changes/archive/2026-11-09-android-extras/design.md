# Design

## Context

The app already has every piece these need. Widgets keep a snapshot in `HomeWidgetPreferences` with counts and no
secret. `MainActivity` takes `tix://` VIEW intents and hands them to `DeepLinkHost` over `tix/links`. `AdbHub`
answers the shell from the app's engine when it is up and from a headless one otherwise. `PublicNotes` rebuilds
every posted notification to add the public version `flutter_local_notifications` cannot set. Writes made offline
go through a per-context outbox with idempotency keys.

## Decisions

### Tiles read the snapshot, open links

`InboxTileService` reads the active context from the widget index and the unread count from that context's inbox
snapshot when the panel opens (`onStartListening`), so it never needs a push and never sees a token. Both tiles
open `MainActivity` with a `tix://` link: `tix://quick-add` and `tix://inbox?context=<id>`. On Android 14 and later
`startActivityAndCollapse` takes a `PendingIntent`; before that the `Intent` overload starts and collapses the
shade. A locked device unlocks first (`unlockAndRun`).

`tix://quick-add` puts a draft in `QuickAddDrafts`, exactly what the launcher shortcut and a share do, so the sheet
opens over whatever screen is on show. It changes no data, so links still only navigate.

### Notification actions: our receiver, the app's engine first

`flutter_local_notifications` can add actions, but its background handler always runs in a second engine of its
own, even while the app is open. Two engines holding one outbox in memory would each write their own copy and lose
the other's entries. So the actions are added by `PublicNotes`, which already rebuilds the notification, with
`PendingIntent`s to our own `NoteActionReceiver` (not exported). The receiver hands the action to
`NoteActionHub`, which, like `AdbHub`, prefers the app's engine and otherwise starts a headless one at
`noteActionHeadlessMain`. In the app's engine the action uses the same `SyncStores` the app's outbox sync uses, so
there is one copy per context.

Building the actions natively also gives what the plugin does not: `setAuthenticationRequired` on Android 12 and
later, the reply semantic action, and a mutable `PendingIntent` only for the reply, whose intent is explicit.

### One engine owns the outbox

Preferring the app's engine is not enough: a headless engine stays up for 30 seconds after an action, and the app
can open inside that window. So `NoteActionHub` never starts a headless engine while the app's engine is attached,
even before its Dart listens. When the app's engine says `ready` while a headless one lives, the hub answers that it
is busy, lets the actions in flight finish (15 s at most), destroys the headless engine at once and sends
`headlessGone`. Until then the app's `SyncStores` read nothing (`OutboxOwnership`, with a 30 s safety timeout).
`AdbHub`'s headless engine only reads (`dump` peeks at the outbox) and changes no outbox, so it needs no hand-over.

### Through the outbox, keyed

The runner (`features/inbox/application/note_actions.dart`) opens the notification's context the way widgets do,
from the saved credential, and writes through `TaskDetailRepository` with an outbox for that context: `task.route`
to the workflow's done state, `task.snooze` until nine tomorrow morning, `comment.add` with the reply. `Outbox.write`
gives each an `Idempotency-Key`, sends it, and keeps it when the server cannot be reached. With no credential to
hand (a local instance, which a background action must not start, or a sign-in sitting in another tenant) the
write goes straight into the outbox and the app sends it when that context next runs. Done needs the workflow's
done state: it is read from the server, or from the saved copies when offline; when neither knows it the action
fails rather than guess.

Afterwards the notification is cancelled and, when the server took the write, the item is marked read. A refusal,
an unknown context or an unknown done state cancels it and posts one short follow-up naming the action and no task.
If Dart never answers, the receiver posts the same follow-up from Android strings.

### Hidden content

With hidden content the notification already names no task, so a reply would be blind: it carries Done and Snooze
only, and on Android 12 and later both need an unlock. The public version carries no actions at all, so a locked
screen that hides content offers nothing.

### Snooze exists

tix has `task.snooze` and `task.unsnooze`, and the app already queues snoozes (`OutboxOp.snooze`), so Snooze is
offered. It uses tomorrow at 09:00 on the device's clock, the task screen's "Tomorrow morning".

### Pinned shortcuts

`tix/pins` answers `supported` (`ShortcutManager.isRequestPinShortcutSupported`, Android 8 and later) and `pin`. The
button is drawn only when supported, so other platforms and older launchers never see it. A shortcut's id is
derived from its context and target, so pinning the same project twice updates the one shortcut. The link carries
`?context=<connection>.<tenant>`, the key `DeepLinkHost` already matches. Saved filters open by id through
`tix://tasks?filter=<id>`.

## Not done

- iOS: no tiles there, notification actions would need a notification service and categories, and `tix://` links
  are Android only today.
- No push. Actions apply to the notifications the app already shows while it runs.
- A write queued from a notification waits for the app to run that context; there is no background replay job.
