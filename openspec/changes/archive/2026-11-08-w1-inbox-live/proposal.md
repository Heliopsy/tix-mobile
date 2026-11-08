# Inbox, live updates and notifications

## Why

The tix web app tells a person what concerns them: an inbox of mentions, assignments, comments and status
changes, a badge that follows it live, and channels that deliver it elsewhere. The app has none of that, so
the one thing a phone is best at, telling you something happened, is missing.

## What Changes

- An Inbox tab: items grouped by day, unread marked, All and Unread, a filter per kind, mark read or unread by
  tap, swipe or menu, mark all read, open the task. The unread count is a badge on the tab.
- The person's inbox settings: which kinds create items (`inbox.prefs`), and their own notification channels
  (Slack, Discord, ntfy or signed JSON), with a test message, the delivery log and redelivery.
- A summary card at the top of the inbox: tasks by state category, completed this week, and the caller's
  overdue and due-today tasks.
- Live updates: the inbox and its badge refresh from tix's event stream, with a quiet "updated" mark, and a
  shared "changed elsewhere" banner for screens being edited.
- Local notifications for new inbox items while the app runs or was just backgrounded, on Android, iOS, macOS,
  Linux and Windows: per context on or off, per kind, permission asked when the person turns them on, a tap
  opens the task.

## Capabilities

### New Capabilities

- `inbox`: the inbox list, marking, kinds muted on the server, and personal notification channels.
- `live-updates`: refreshing from events and not clobbering what the person is typing.
- `notifications`: local notifications for new inbox items and their settings.
- `home-summary`: the summary card.

## Impact

- New `features/inbox` and `core/notifications`; a fourth shell destination; settings gain a
  Notifications section.
- New dependency `flutter_local_notifications` (all five shipped platforms); Android enables core library
  desugaring and compiles against SDK 37, as the plugin requires.
- No push: there is no push server. `docs/design.md` records what FCM or APNs would need from tix.
