# event-watch

## ADDED Requirements

### Requirement: A live tail of the tenant's events

The app SHALL offer a Watch screen, under Manage when the credential holds `event:subscribe` and from the command palette, that shows the active context's domain events as they arrive, newest first.

#### Scenario: An event arrives

- **WHEN** Watch is open and the server delivers event 42, `task.transitioned` on INFRA-5 by `@pax` from todo to doing
- **THEN** a row at the top shows `#000042`, the time, `@pax`, `task.transitioned` and `INFRA-5 todo → doing`

### Requirement: Rows open what they are about

Tapping a row about a task SHALL open that task, and one about a project SHALL open the project. Every row SHALL also offer a details view with the sequence number, time, actor, type, subject, project, channel and the full payload.

#### Scenario: Open the task

- **WHEN** the person taps the row for an event whose payload carries the ref `infra-5`
- **THEN** the task infra-5 opens

#### Scenario: An event with no route

- **WHEN** the person taps a row for a `filter.saved` event
- **THEN** its details open

### Requirement: Server filters and the actor filter

Watch SHALL send the chosen projects and event types (a trailing `*` matching a prefix) to the server as the subscription filter, and SHALL apply the actor filter on the device, matching the actor's id or handle, without resubscribing.

#### Scenario: Type prefix

- **WHEN** the person filters on `task.*`
- **THEN** the subscription is sent with `filter.types` `["task.*"]`

#### Scenario: Actor

- **WHEN** the person filters on actor `pax`
- **THEN** only events by `pax` are shown and no new subscription is sent

#### Scenario: Refused filter

- **WHEN** the server refuses the subscription's filter
- **THEN** Watch shows the server's reason and offers to clear the filters, and other live updates carry on

### Requirement: Pause with a bounded buffer

Watch SHALL keep at most the latest 500 events. While paused it SHALL hold new events, show how many arrived, and put them on top when resumed.

#### Scenario: Paused

- **WHEN** Watch is paused and three events arrive
- **THEN** the list does not change and the screen says 3 new; resuming shows them on top

### Requirement: Resume without gaps and replay

Watch SHALL resume after a reconnect from the last sequence number it received, and SHALL offer to replay from a sequence number. When the server no longer keeps that cursor, Watch SHALL say which events are gone and carry on with new ones.

#### Scenario: Reconnect

- **WHEN** the connection drops after Watch received event 7
- **THEN** its subscription is sent again with `since_seq` 7

#### Scenario: Expired cursor

- **WHEN** the person replays from 3 and the server answers that cursor 3 is no longer available
- **THEN** Watch says events after #3 are no longer kept and shows new events as they arrive

### Requirement: Connection states and refusal

Watch SHALL show the live status indicator, say when it is connecting, offline or waiting for the first event, and when the credential may not follow events SHALL explain that it needs `event:subscribe` instead of failing.

#### Scenario: Token without event:subscribe

- **WHEN** the event stream's handshake is refused with 403
- **THEN** Watch explains the token lacks `event:subscribe` and offers a way back
