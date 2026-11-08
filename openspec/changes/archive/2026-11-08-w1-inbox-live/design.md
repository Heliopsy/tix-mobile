# Design

## Events

The inbox, the badge and notifications follow tix's event stream from the API foundation
(`tixEventStreamProvider`, `core/events`). `InboxUnread` uses `refreshOn(ref, EventTopics.inbox)`;
`InboxList` uses `onEvents` to read the first page again in place, keeping later pages and marking rows it had
not seen; `InboxAlerts` uses `onEvents` to look for new unread items. A gap (`EventsMissed`) does the same as
an event. `inbox.updated` names its recipients only when items are created, and the app does not know its own
actor id for every credential, so every `inbox.updated` refreshes: one cheap read of the first page.

## Inbox state

`InboxList` is a keyset-paged notifier per "unread only" choice, drawn from the response cache first. tix has
no kind filter on `GET /inbox`, so kinds filter on the client; when a filter hides every loaded row and more
pages exist, the notifier reads on (up to five pages) rather than showing an empty list that is not empty.
Marking is optimistic through `runOptimistic`; the badge moves with it.

tix has no archive or dismiss for inbox items, so the app offers neither.

## Notifications

`LocalNotifier` wraps `flutter_local_notifications` so tests use a fake. On an inbox change `InboxAlerts` reads
the first unread page and notifies the items newer than the newest one already seen for that context
(`notif.seen.<connection>.<tenant>`), so a restart or a reconnect repeats none. The read at start only records
the newest item. Settings: `notif.on.<connection>.<tenant>` and `notif.kinds` in preferences; permission is
asked when the person turns notifications on, never at start. Marking an item read removes its notification.

## Alternatives

- Showing notifications for every unread item at start: rejected, a returning person would get a burst of stale
  ones.
- A kind filter on the server: tix has none; adding one is a tix change, noted for later.
- Push: needs device registration and a sender in tix; recorded in `docs/design.md`.
