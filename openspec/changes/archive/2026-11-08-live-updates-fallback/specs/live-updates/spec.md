## ADDED Requirements

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
