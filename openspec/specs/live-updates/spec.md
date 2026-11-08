# live-updates Specification

## Purpose
How the app follows tix's event stream for the active context and refreshes what is shown when something changes.

## Requirements

### Requirement: The active context follows tix's event stream

The app SHALL subscribe to `/api/v1/events` for the active context with its credential, deliver each event once in `seq` order, and on a dropped connection reconnect with growing delays and resume after the last `seq` delivered.

#### Scenario: Resume after a drop

- **WHEN** the connection drops after event 5
- **THEN** the app reconnects after a delay and subscribes with `since_seq` 5

### Requirement: Missed events are reported, refusals are final

When the server refuses a cursor as too old, or the stream reconnects without a cursor, the app SHALL report that events may be missed so screens read again. A refused handshake or subscription SHALL stop the stream without retrying.

#### Scenario: Token without event:subscribe

- **WHEN** the handshake is answered `403`
- **THEN** the stream is unavailable and no further connection is attempted

#### Scenario: Expired cursor

- **WHEN** the server answers a resume with "no longer available"
- **THEN** the app reports a gap and subscribes live again

### Requirement: Screens refresh on the events that touch them

A provider SHALL be able to name the event types it depends on and refresh when a matching event arrives or a gap is reported, at most once per burst of events.

#### Scenario: Bulk change

- **WHEN** three project events arrive within the debounce window
- **THEN** the projects list is read from the server once

### Requirement: The inbox follows events

When an `inbox.updated` event arrives for the caller, or the stream reports missed events, the app SHALL
re-read the inbox and the unread count without losing the scroll position, and SHALL mark rows that were not
there before for a moment.

#### Scenario: A new mention arrives

- **WHEN** somebody mentions the person while the inbox is open
- **THEN** the item appears at the top, marked new, and the badge goes up

### Requirement: Edits are not clobbered

A screen being edited SHALL NOT replace the person's input when the item changes elsewhere. It SHALL show a
"changed elsewhere" banner offering to reload, which discards the input only when chosen.

#### Scenario: A task changes while being edited

- **WHEN** an event changes the task a person is editing
- **THEN** their input stays and the banner offers Reload

### Requirement: A broken WebSocket falls back to HTTP polling

After a configured number of failed connections or abnormal closes within a window (3 in 2 minutes by default), the app SHALL follow the event log by long polling `GET /api/v1/events/poll` from the last `seq` it delivered, delivering each event once.

#### Scenario: Three failures

- **WHEN** the WebSocket fails three times in a row after event 7
- **THEN** the app polls with `since_seq` 7 and delivers event 8 once

### Requirement: Polling returns to the WebSocket

While polling, the app SHALL try the WebSocket in the background every few minutes, and SHALL switch back when a subscription is acknowledged, subscribing with the cursor and delivering no event twice.

#### Scenario: Recovery

- **WHEN** a background WebSocket attempt is acknowledged while polling after event 9
- **THEN** polling stops, the subscription resumed with `since_seq` 9, and a replayed event 9 is not delivered again

### Requirement: A server without the poll endpoint is refreshed periodically

When the poll endpoint answers 404 or 405, the app SHALL instead reload what is on screen every 45 seconds while in the foreground, and SHALL keep trying the WebSocket in the background.

#### Scenario: Older server

- **WHEN** the WebSocket keeps failing and the poll answers 404
- **THEN** the indicator says Refreshing and the open list is read again every 45 seconds

### Requirement: Polling pauses in the background on phones

On Android and iOS the app SHALL stop polling, cancelling the request in flight, while it is in the background, and SHALL poll again from the cursor as soon as it returns.

#### Scenario: Back from the background

- **WHEN** the app is paused while polling and later resumed
- **THEN** no request is made while paused and one is made at once on resume, with the same cursor

### Requirement: A refusal while polling is final

A poll answered 401 or 403 SHALL make live updates unavailable with no further attempts. A cursor the server no longer keeps SHALL report a gap and continue from the newest event.

#### Scenario: Revoked token

- **WHEN** a poll is answered 403
- **THEN** live updates are unavailable and nothing is retried

### Requirement: The live mode is visible

The app SHALL show beside the context switcher whether updates are Live, Connecting, Polling, Refreshing, Offline or Not available, with a tooltip saying what that means. The mode and the last error SHALL be readable by a provider for diagnostics.

#### Scenario: Fallback shown

- **WHEN** the app falls back to polling
- **THEN** the indicator reads Polling and its tooltip says updates come over plain HTTP
