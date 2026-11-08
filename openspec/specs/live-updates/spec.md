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
