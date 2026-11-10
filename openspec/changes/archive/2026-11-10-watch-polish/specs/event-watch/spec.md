# event-watch

## MODIFIED Requirements

### Requirement: A live tail of the tenant's events

The app SHALL offer a Watch screen, under Manage when the credential holds `event:subscribe`, from a button in the shell's bar shown only with that scope, and from the command palette, that shows the active context's domain events as they arrive, newest first.

#### Scenario: An event arrives

- **WHEN** Watch is open and the server delivers event 42, `task.transitioned` on INFRA-5 by `@pax` from todo to doing
- **THEN** a row at the top shows `@pax`, a `task.transitioned` badge, `INFRA-5`, the states todo and doing as status pills, `#000042` and how long ago it happened

#### Scenario: Shortcut in the shell

- **WHEN** the credential holds `event:subscribe` and the person taps Watch in the shell's bar
- **THEN** Watch opens

#### Scenario: No shortcut without the scope

- **WHEN** the credential lacks `event:subscribe`
- **THEN** the shell's bar shows no Watch button

### Requirement: Rows open what they are about

Tapping a row about a task SHALL open that task over Watch, and one about a project SHALL open the project, so that going back returns to Watch with its events, filters and scroll position as they were. Every row SHALL also offer a details view with the sequence number, time, actor, type, subject, project, channel and the full payload.

#### Scenario: Open the task

- **WHEN** the person taps the row for an event whose payload carries the ref `infra-5`
- **THEN** the task infra-5 opens

#### Scenario: Back to Watch

- **WHEN** Watch is filtered to `comment.*`, the person opens a task from a row and goes back
- **THEN** Watch shows again with the same rows and the `comment.*` filter, without subscribing again

#### Scenario: An event with no route

- **WHEN** the person taps a row for a `filter.saved` event
- **THEN** its details open

### Requirement: Connection states and refusal

Watch SHALL show the live status indicator, its dot breathing while live or connecting and still when reduced motion is asked for, say when it is connecting, offline or waiting for the first event, and when the credential may not follow events SHALL explain that it needs `event:subscribe` instead of failing.

#### Scenario: Token without event:subscribe

- **WHEN** the event stream's handshake is refused with 403
- **THEN** Watch explains the token lacks `event:subscribe` and offers a way back

#### Scenario: Live dot moves

- **WHEN** Watch is live and nothing asks for reduced motion
- **THEN** the live dot fades in and out

#### Scenario: Reduced motion

- **WHEN** the platform or the app's setting asks for reduced motion
- **THEN** the live dot stays still at full strength

## ADDED Requirements

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
