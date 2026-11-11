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

### Requirement: The live mode follows the context's name

On a phone the indicator SHALL start where the context's name ends, on the same line, never in the middle of the
bar, and SHALL take at most half its width. On the rail it SHALL be a dot at the avatar's end corner. Both SHALL
follow the writing direction.

#### Scenario: A short name

- **WHEN** the context's name is short on a 400 pixel wide phone
- **THEN** the indicator starts just after the name, in the bar's first half

#### Scenario: Right to left

- **WHEN** the text runs right to left
- **THEN** the indicator sits just before the name, to its left

### Requirement: Live updates sleep with a local engine

When the engine of the active local context stops, live updates SHALL sleep: no WebSocket, no reconnect attempt, no poll and no refresh, and the indicator SHALL show nothing. When the engine starts again they SHALL resume over the WebSocket from the cursor.

#### Scenario: Engine idles while polling

- **WHEN** live updates of a local context are polling and the engine stops while idle
- **THEN** the poll in flight is cancelled and no further poll or WebSocket attempt is made

#### Scenario: Engine back

- **WHEN** the engine starts again after resting
- **THEN** a WebSocket subscribes from the cursor

### Requirement: Live updates explain themselves

Live updates SHALL keep, for the active context: the mode and transport, the server's host, when the mode
started, the last contact and event, consecutive failures and those counting towards the fallback, whether the
poll endpoint is missing, the next retry, and the last error with its class, exception type, HTTP status, OS
error, WebSocket close code and reason, and time.

#### Scenario: Offline after a lookup failure

- **WHEN** the WebSocket fails because the host name does not resolve
- **THEN** the last error is unreachable, a SocketException, with the OS error message and code

#### Scenario: After the fallback

- **WHEN** three WebSocket upgrades are refused with 502 and polling starts
- **THEN** the transport is polling, the failures counting towards the fallback are back to 0, and the last error
  is an upgrade refused with 502

### Requirement: Recent changes are kept

The last 20 mode changes and errors SHALL be kept with their times, oldest dropped first, so an intermittent
failure can be read after it recovered.

#### Scenario: A long outage

- **WHEN** the WebSocket fails 30 times in a row
- **THEN** only the 20 most recent entries are kept

### Requirement: Diagnostics carry no secret

Diagnostics SHALL NOT hold a token, a cookie, an Authorization header or a URL's query string. Error messages
SHALL be redacted when recorded: the connection's header values, credential headers and parameters, query
strings and long opaque strings.

#### Scenario: A token in an error message

- **WHEN** a refused upgrade's message repeats the URL with a token and the Authorization header
- **THEN** neither the details nor the copied report contain the token

### Requirement: Connection details

Tapping the indicator in the phone bar, or a long press on the switcher, SHALL open Connection details: the facts
above in plain language, a hint for the last error's class, Reconnect now and Copy details. The indicator's
semantics SHALL say it opens them.

#### Scenario: Behind a proxy that drops idle connections

- **WHEN** a poll timed out and the person taps the indicator
- **THEN** the details say a proxy or load balancer may be closing idle connections and its read timeout should
  be above 60 s for the event endpoints

#### Scenario: Reconnect after a refusal

- **WHEN** live updates are Not available and the person taps Reconnect now
- **THEN** a WebSocket is opened again at once

### Requirement: The copied report is plain and redacted

Copy details SHALL put on the clipboard a plain-text report with the app version, the platform, the server's
host, the mode, the counts, the last error and the recent history, and no secret.

#### Scenario: Copy

- **WHEN** the person taps Copy details
- **THEN** the clipboard holds the report with the app version and host, and without the token

### Requirement: A tail's refusal stays with the tail

An error the server sends for an extra subscription SHALL stop that subscription only, and an expired cursor SHALL be reported to it and followed by a live subscription, leaving the app's own subscription untouched.

#### Scenario: Unknown type

- **WHEN** the server answers a tail's subscription with an error naming its id
- **THEN** the tail reports the refusal and the app's own subscription stays live

### Requirement: Extra event tails share the connection

The app SHALL serve a filtered tail of events over the connection it already holds: as another subscription with its own id, filter and cursor on the same WebSocket, or, while polling, as a filtered poll after each of its own. It SHALL NOT open a second socket for it.

#### Scenario: Activity opens

- **WHEN** live updates run over the WebSocket and Activity opens with the filter `task.*`
- **THEN** a second `subscribe` with its own id and `filter.types` `["task.*"]` is sent on the open socket

#### Scenario: Polling

- **WHEN** live updates fall back to polling and a tail is open
- **THEN** after each poll of the app's own, the tail is polled with its filter from its cursor
