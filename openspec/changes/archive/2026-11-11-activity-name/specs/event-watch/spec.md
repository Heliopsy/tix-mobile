# event-watch

## REMOVED Requirements

### Requirement: Watch is a destination with a live tail of the tenant's events

**Reason**: The web calls this feed Activity; the app now uses the same name.

**Migration**: Replaced by "Activity is a destination with a live tail of the tenant's events".

### Requirement: Rows open what they are about

**Reason**: Its scenario named Watch, which is now Activity, as on the web.

**Migration**: Replaced by "Activity rows open what they are about".

## ADDED Requirements

### Requirement: Activity is a destination with a live tail of the tenant's events

The app SHALL offer Activity as a destination of its own, between Inbox and Manage, shown whatever the credential's scopes, and from the command palette, that shows the active context's domain events as they arrive, newest first. Manage SHALL NOT list Activity, and the old `/watch` and `/manage/watch` locations SHALL open Activity at `/activity`.

#### Scenario: An event arrives

- **WHEN** Activity is open and the server delivers event 42, `task.transitioned` on INFRA-5 by `@pax` from todo to doing
- **THEN** a row at the top shows `@pax`, a `task.transitioned` badge, `INFRA-5`, the states todo and doing as status pills, `#000042` and how long ago it happened

#### Scenario: Activity in the navigation

- **WHEN** the person taps Activity in the rail, or under More on a phone
- **THEN** Activity opens and its destination is marked as selected

#### Scenario: Not under Manage

- **WHEN** an admin whose credential holds `event:subscribe` opens Manage
- **THEN** Manage lists no Activity entry

#### Scenario: Old link

- **WHEN** something opens `/manage/watch` or `/watch`
- **THEN** the app shows Activity at `/activity`

#### Scenario: Old deep link

- **WHEN** the app opens `tix://watch`
- **THEN** it shows Activity at `/activity`, as `tix://activity` does

### Requirement: Activity rows open what they are about

Tapping a row about a task SHALL open that task over Activity, and one about a project SHALL open the project, so that going back returns to Activity with its events, filters and scroll position as they were. Every row SHALL also offer a details view with the sequence number, time, actor, type, subject, project, channel and the full payload.

#### Scenario: Open the task

- **WHEN** the person taps the row for an event whose payload carries the ref `infra-5`
- **THEN** the task infra-5 opens

#### Scenario: Back to Activity

- **WHEN** Activity is filtered to `comment.*`, the person opens a task from a row and goes back
- **THEN** Activity shows again with the same rows and the `comment.*` filter, without subscribing again

#### Scenario: An event with no route

- **WHEN** the person taps a row for a `filter.saved` event
- **THEN** its details open

## MODIFIED Requirements

### Requirement: Server filters and the actor filter

Activity SHALL send the chosen projects and event types (a trailing `*` matching a prefix) to the server as the subscription filter, and SHALL apply the actor filter on the device, matching the actor's id or handle, without resubscribing.

#### Scenario: Type prefix

- **WHEN** the person filters on `task.*`
- **THEN** the subscription is sent with `filter.types` `["task.*"]`

#### Scenario: Actor

- **WHEN** the person filters on actor `pax`
- **THEN** only events by `pax` are shown and no new subscription is sent

#### Scenario: Refused filter

- **WHEN** the server refuses the subscription's filter
- **THEN** Activity shows the server's reason and offers to clear the filters, and other live updates carry on

### Requirement: Pause with a bounded buffer

Activity SHALL keep at most the latest 500 events. While paused it SHALL hold new events, show how many arrived, and put them on top when resumed.

#### Scenario: Paused

- **WHEN** Activity is paused and three events arrive
- **THEN** the list does not change and the screen says 3 new; resuming shows them on top

### Requirement: Resume without gaps and replay

Activity SHALL resume after a reconnect from the last sequence number it received, and SHALL offer to replay from a sequence number. When the server no longer keeps that cursor, Activity SHALL say which events are gone and carry on with new ones.

#### Scenario: Reconnect

- **WHEN** the connection drops after Activity received event 7
- **THEN** its subscription is sent again with `since_seq` 7

#### Scenario: Expired cursor

- **WHEN** the person replays from 3 and the server answers that cursor 3 is no longer available
- **THEN** Activity says events after #3 are no longer kept and shows new events as they arrive

### Requirement: Connection states and refusal

Activity SHALL show the live status indicator, its dot breathing while live or connecting and still when reduced motion is asked for, say when it is connecting, offline or waiting for the first event, and when the credential may not follow events SHALL explain that it needs `event:subscribe` instead of failing.

#### Scenario: Token without event:subscribe

- **WHEN** the event stream's handshake is refused with 403
- **THEN** Activity explains the token lacks `event:subscribe` and offers to open Instances, where the token can be replaced

#### Scenario: Live dot moves

- **WHEN** Activity is live and nothing asks for reduced motion
- **THEN** the live dot fades in and out

#### Scenario: Reduced motion

- **WHEN** the platform or the app's setting asks for reduced motion
- **THEN** the live dot stays still at full strength

### Requirement: Rows name the person, the token and the channel

A row SHALL name who caused the event by the display name the tenant's actor list gives, with the handle beside it, falling back to the handle, then the actor id, then the system. It SHALL show the channel the event came through with its token or job, as "via API (deploy-bot)".

#### Scenario: A token used by a person

- **WHEN** an event by actor Pax Ito (`@pax`) arrives with `via` kind `api` and token name `deploy-bot`
- **THEN** its row shows Pax Ito, `@pax` and "via API (deploy-bot)"

#### Scenario: Actor not in the list

- **WHEN** the actor list cannot be read
- **THEN** the row names the actor by handle

### Requirement: Rows show what happened

A row SHALL show its event type as a badge coloured by what happened: ok for a creation or addition, the accent for a change, danger for a deletion, warn for an expired lease, neutral otherwise. It SHALL show the project chip, states as status pills, changed fields by name, and a comment's first two non-blank lines.

#### Scenario: A comment

- **WHEN** a `comment.added` event arrives for a comment reading "Deployed to staging." then a blank line and "Looks fine so far."
- **THEN** its row shows both lines under the subject

#### Scenario: A comment by someone else

- **WHEN** the comment's author is not the event's actor
- **THEN** the excerpt starts with the author's name

#### Scenario: A field change

- **WHEN** a `task.updated` event names the fields `body` and `due_at`
- **THEN** its row reads "changed description, due date"

#### Scenario: A deletion

- **WHEN** a `task.deleted` event arrives
- **THEN** its type badge is in the danger colour
