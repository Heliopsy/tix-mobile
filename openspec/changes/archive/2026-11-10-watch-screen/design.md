# Design

## Context

`LiveEvents` holds one WebSocket per active context with one subscription, `s1`, unfiltered and live only, and
falls back to long polling `GET /api/v1/events/poll` when the socket keeps failing. tix lets several subscriptions
share one connection, each with its own `id`, `filter` (`types`, `project_ids`) and `since_seq`, and the poll
endpoint takes the same filter.

## Decisions

### A second subscription, not a second socket

Watch asks `LiveEvents.tail(types, projectIds, since)` for an `EventTail`. On the WebSocket it is one more
`subscribe` on the socket already open (`w1`, `w2`, ...), with the server's filter and its own cursor. Frames carry
the subscription's `id`, so `TixEventStream` routes them: an event, an acknowledgement or an error with a tail's
id goes to that tail and never touches `s1`. A tail's error (an unknown type, a project the token may not see)
stops that tail only.

Filtering `s1` on the device would have worked for project and type, but not for replay: the main cursor is the
app's, and replaying from N on it would hand every list an old event. A separate subscription keeps both cursors
honest.

### Following the transports

- **WebSocket**: tails are subscribed on every socket `LiveEvents` opens or adopts, from their cursor, and
  resubscribed by `TixEventStream` after each reconnect.
- **Polling**: after each of the app's own long polls, each tail is polled once with its filter and cursor and no
  wait. The app's poll is unfiltered, so anything a tail would match wakes it first. Polls stay one at a time, so
  the poller's single cancel token still works. Adding a tail cuts the long poll in flight short.
- **Periodic refresh** (no poll endpoint): a tail cannot be served and says so.
- **Refused or closed**: tails are told and stay registered, so Reconnect now brings them back.

### Cursors

A tail starts after `since`, or after the app's own cursor when there is none, so a reconnect before its first
event does not lose anything the app already passed. It advances with every event delivered and with `next_seq`
on a poll. A reconnect resumes with `since_seq` at the cursor. A cursor tix no longer keeps is reported as
`TailExpired(since)`; the tail goes on from the newest event and the screen says which events are gone.

### Client-side actor filter

tix's subscription filter has no actor, and `tix watch` filters the actor after the stream (`filterByActor`). The
app does the same, matching the actor id or its handle (`actor_handle` in the payload), so changing it never
resubscribes and the held count follows it.

### State

`WatchFilter` holds the query. `WatchFeed` watches only the server half (types, projects, replay), so changing the
actor does not resubscribe. It keeps up to 500 events newest first; while paused, new ones go to a held list (also
capped at 500) and resuming puts them on top. `watchVisible` applies the actor filter for the screen.

### Summaries

The one-line summary follows tix's `output.EventDetail`: a transition's states, a claim's lease, a release's final
status, an expired lease's holder, an update's fields or flags, and otherwise the title, tag, dependency, name or
status the payload carries. The fixed words are translated.

### Navigation

Watch sits under Manage next to Audit and in the palette ("Go to Watch"). The rail and bottom bar are the shell's
branches, shared between phone and desktop, and Audit is not one either; a seventh branch for a screen most people
open rarely would push Settings into More on a phone.

## Risks

- A token scoped to a project gets its subscription narrowed by the server; naming another project is refused,
  which the screen shows as a refused filter.
- The summary depends on payload keys tix does not document as stable. A missing key leaves the summary blank, not
  wrong.
