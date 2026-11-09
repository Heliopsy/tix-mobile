# Proposal

## Why

Android has three places outside the app where tix could save a trip into it, and the app used none of them. A
Quick Settings tile is one swipe away from any screen, a notification about a new inbox item is where the person
already is when they decide what to do with it, and a pinned shortcut puts the one project or saved filter they live
in on the home screen. Each of those needs the app opened today.

## What Changes

- Two Quick Settings tiles on Android 7 and later. **Quick add** opens the quick-add sheet over the app.
  **Inbox** shows the active context's unread count as its subtitle, read from the widget snapshot, and opens the
  inbox. Both open the app through `tix://` links.
- New-inbox-item notifications on Android carry **Done**, **Snooze** (until tomorrow morning) and an inline
  **Reply** that posts a comment. They run without opening the app, through the context's offline outbox with an
  idempotency key, so they work offline and replay later. The notification goes away when the write is sent or
  queued; a refused or impossible one leaves a short follow-up notification.
- When task content is hidden for the context, the notification offers no Reply and, on Android 12 and later,
  Done and Snooze ask for an unlock first.
- **Add to home screen** on a project and on a saved filter, where the launcher supports pinned shortcuts. The
  shortcut opens a `tix://` link naming the context it was made in.
- Two new links: `tix://quick-add` (with an optional `project`) and `tix://tasks?filter=<name or id>`.

## Impact

- Capabilities: `app-shortcuts` gains the tiles and pinned shortcuts, `notifications` the actions, `offline-sync`
  the background writes, `adb-control` the two links.
- Android: `tiles/Tiles.kt`, `notes/NoteActions.kt` (a receiver and the engine hub on a `tix/note-actions`
  channel, with a headless `noteActionHeadlessMain`), `shortcuts/Pins.kt` (`tix/pins` channel), the public version
  in `PublicNotes.kt` now also carries the actions. New services and a receiver in the manifest, tile and fallback
  strings in four languages.
- Dart: `core/platform/deep_links.dart`, `core/platform/note_actions_bridge.dart`, `core/platform/pinned_shortcuts.dart`,
  `core/widgets/pin_shortcut_button.dart`, `features/inbox/application/note_actions.dart`; new strings in English,
  Bulgarian, French and German.
- No new dependency and no new API operation.
