# event-watch

## REMOVED Requirements

### Requirement: A live tail of the tenant's events

**Reason**: Watch was reached from a button in the shell's bar shown only with `event:subscribe` and from Manage. It is now a destination of its own.

**Migration**: Replaced by "Watch is a destination with a live tail of the tenant's events".

## ADDED Requirements

### Requirement: Watch is a destination with a live tail of the tenant's events

The app SHALL offer Watch as a destination of its own, between Inbox and Manage, shown whatever the credential's scopes, and from the command palette, that shows the active context's domain events as they arrive, newest first. Manage SHALL NOT list Watch, and the old `/manage/watch` location SHALL open Watch.

#### Scenario: An event arrives

- **WHEN** Watch is open and the server delivers event 42, `task.transitioned` on INFRA-5 by `@pax` from todo to doing
- **THEN** a row at the top shows `@pax`, a `task.transitioned` badge, `INFRA-5`, the states todo and doing as status pills, `#000042` and how long ago it happened

#### Scenario: Watch in the navigation

- **WHEN** the person taps Watch in the rail, or under More on a phone
- **THEN** Watch opens and its destination is marked as selected

#### Scenario: Not under Manage

- **WHEN** an admin whose credential holds `event:subscribe` opens Manage
- **THEN** Manage lists no Watch entry

#### Scenario: Old link

- **WHEN** something opens `/manage/watch`
- **THEN** the app shows Watch at `/watch`

## MODIFIED Requirements

### Requirement: Connection states and refusal

Watch SHALL show the live status indicator, its dot breathing while live or connecting and still when reduced motion is asked for, say when it is connecting, offline or waiting for the first event, and when the credential may not follow events SHALL explain that it needs `event:subscribe` instead of failing.

#### Scenario: Token without event:subscribe

- **WHEN** the event stream's handshake is refused with 403
- **THEN** Watch explains the token lacks `event:subscribe` and offers to open Instances, where the token can be replaced

#### Scenario: Live dot moves

- **WHEN** Watch is live and nothing asks for reduced motion
- **THEN** the live dot fades in and out

#### Scenario: Reduced motion

- **WHEN** the platform or the app's setting asks for reduced motion
- **THEN** the live dot stays still at full strength
