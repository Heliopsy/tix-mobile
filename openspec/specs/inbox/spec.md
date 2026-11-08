# inbox Specification

## Purpose
What concerns the person: their inbox items, marking them, the kinds the server sends, and their own notification channels.

## Requirements

### Requirement: The inbox lists the caller's items

The app SHALL list `GET /api/v1/inbox` newest first, keyset paged, grouped under Today, Yesterday and Earlier
by local date. Each row SHALL say who did what (mentioned, assigned, commented, moved from one status to
another), the task's reference and title, the excerpt when there is one, and when. Unread rows SHALL be marked.

#### Scenario: Reading the inbox

- **WHEN** a person opens the Inbox tab
- **THEN** their items show under day headings, unread ones marked

#### Scenario: A deleted task

- **WHEN** an item's task has been deleted
- **THEN** the row says so and does not open anything

### Requirement: The inbox filters by state and kind

The app SHALL offer All and Unread, Unread asking the server with `unread=true`, and a toggle per kind
(mentions, assignments, comments, status changes) that narrows the loaded rows. When a filter hides every loaded
row and more pages exist, the app SHALL read further pages before saying the list is empty.

#### Scenario: Only mentions

- **WHEN** a person turns on the Mentions filter
- **THEN** only mention items are listed

### Requirement: Items are marked read and unread

A person SHALL mark an item read or unread from its menu, by swiping it, or by opening its task, which marks it
read. Marking SHALL show at once and roll back with the server's reason when refused. Mark all read SHALL call
`POST /api/v1/inbox/read-all` and say how many it marked.

#### Scenario: Swiping an unread item

- **WHEN** a person swipes an unread item
- **THEN** it shows read at once and `PUT /api/v1/inbox/{id}/read` is sent

#### Scenario: Opening an item

- **WHEN** a person taps an item
- **THEN** the item is marked read and the task opens at `/projects/:key/tasks/:ref`

### Requirement: The unread count is a badge

The Inbox destination SHALL carry the unread count from `GET /api/v1/inbox/count`, and SHALL follow marking
and live updates without a reload.

#### Scenario: Marking all read

- **WHEN** a person marks everything read
- **THEN** the badge disappears

### Requirement: Kinds can be muted on the server

Settings SHALL show a switch per kind reflecting `GET /api/v1/inbox/prefs`; turning one off or on SHALL replace
the muted list with `PUT /api/v1/inbox/prefs`.

#### Scenario: Muting comments

- **WHEN** a person turns off Comments under Inbox
- **THEN** `PUT /api/v1/inbox/prefs` is sent with `comment` muted

### Requirement: Personal channels are managed

A person SHALL list, add, edit, turn off and delete their own notification channels (`/api/v1/channels`), send a
test, read a channel's deliveries newest first and redeliver one. The signing secret SHALL be shown once, on
creation. Deleting SHALL confirm first.

#### Scenario: Adding a channel

- **WHEN** a person adds a Slack channel
- **THEN** it is listed and its secret is shown once

#### Scenario: Redelivering a failure

- **WHEN** a person redelivers a failed delivery
- **THEN** `POST /api/v1/channel-deliveries/{id}/redeliver` is sent
