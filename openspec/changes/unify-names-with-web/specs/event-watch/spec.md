# event-watch

## MODIFIED Requirements

### Requirement: Server filters and the actor filter

Live events SHALL send the chosen projects and event types (a trailing `*` matching a prefix) to the server as the subscription filter, and SHALL apply the actor filter on the device, matching the actor's id or handle, without resubscribing.

#### Scenario: Type prefix

- **WHEN** the person filters on `task.*`
- **THEN** the subscription is sent with `filter.types` `["task.*"]`

#### Scenario: Actor

- **WHEN** the person filters on actor `pax`
- **THEN** only events by `pax` are shown and no new subscription is sent

#### Scenario: Refused filter

- **WHEN** the server refuses the subscription's filter
- **THEN** Live events shows the server's reason and offers to clear the filters, and other live updates carry on

### Requirement: Pause with a bounded buffer

Live events SHALL keep at most the latest 500 events. While paused it SHALL hold new events, show how many arrived, and put them on top when resumed.

#### Scenario: Paused

- **WHEN** Live events is paused and three events arrive
- **THEN** the list does not change and the screen says 3 new; resuming shows them on top

### Requirement: Resume without gaps and replay

Live events SHALL resume after a reconnect from the last sequence number it received, and SHALL offer to replay from a sequence number. When the server no longer keeps that cursor, Live events SHALL say which events are gone and carry on with new ones.

#### Scenario: Reconnect

- **WHEN** the connection drops after Live events received event 7
- **THEN** its subscription is sent again with `since_seq` 7

#### Scenario: Expired cursor

- **WHEN** the person replays from 3 and the server answers that cursor 3 is no longer available
- **THEN** Live events says events after #3 are no longer kept and shows new events as they arrive

### Requirement: Connection states and refusal

Live events SHALL show the live status indicator, its dot breathing while live or connecting and still when reduced motion is asked for, say when it is connecting, offline or waiting for the first event, and when the credential may not follow events SHALL explain that it needs `event:subscribe` instead of failing.

#### Scenario: Token without event:subscribe

- **WHEN** the event stream's handshake is refused with 403
- **THEN** Live events explains the token lacks `event:subscribe` and offers to open Instances, where the token can be replaced

#### Scenario: Live dot moves

- **WHEN** Live events is live and nothing asks for reduced motion
- **THEN** the live dot fades in and out

#### Scenario: Reduced motion

- **WHEN** the platform or the app's setting asks for reduced motion
- **THEN** the live dot stays still at full strength

## REMOVED Requirements

### Requirement: Activity is a destination with a live tail of the tenant's events

**Reason**: Activity is the audit feed now, as on tix web; the live tail is Live events, listed under Manage.

**Migration**: Replaced by "Live events lists the tenant's events under Manage" here and by "Activity is the audit
feed" in `audit-log`.

### Requirement: Activity rows open what they are about

**Reason**: The screen is named Live events.

**Migration**: Replaced by "Live events rows open what they are about".

## ADDED Requirements

### Requirement: Live events lists the tenant's events under Manage

The app SHALL offer Live events at `/events`, listed under Manage for a credential with `event:subscribe`, showing the active context's domain events as they arrive, newest first. The old `/watch` and `/manage/watch` locations and the `tix://watch` and `tix://events` links SHALL open it.

#### Scenario: An event arrives

- **WHEN** Live events is open and the server delivers event 42, `task.transitioned` on INFRA-5 by `@pax` from todo to doing
- **THEN** a row at the top shows `@pax`, a `task.transitioned` badge, `INFRA-5`, the states todo and doing as status pills, `#000042` and how long ago it happened

#### Scenario: Under Manage

- **WHEN** a member whose credential holds `event:subscribe` opens Manage and taps Live events
- **THEN** Live events opens at `/events` and Manage stays the selected destination

#### Scenario: Old link

- **WHEN** something opens `/watch` or `/manage/watch`
- **THEN** the app shows Live events at `/events`

#### Scenario: Old deep link

- **WHEN** the app opens `tix://watch`
- **THEN** it shows Live events at `/events`, as `tix://events` does

### Requirement: Live events rows open what they are about

Tapping a row about a task SHALL open that task over Live events, and one about a project SHALL open the project, so that going back returns to Live events with its events, filters and scroll position as they were. Every row SHALL also offer a details view with the sequence number, time, actor, type, subject, project, channel and the full payload.

#### Scenario: Open the task

- **WHEN** the person taps the row for an event whose payload carries the ref `infra-5`
- **THEN** the task infra-5 opens

#### Scenario: Back to Live events

- **WHEN** Live events is filtered to `comment.*`, the person opens a task from a row and goes back
- **THEN** Live events shows again with the same rows and the `comment.*` filter, without subscribing again

#### Scenario: An event with no route

- **WHEN** the person taps a row for a `filter.saved` event
- **THEN** its details open
