# task-detail

## ADDED Requirements

### Requirement: Comments carry reactions

Each comment SHALL show the server's reactions as chips of emoji and count in tix's fixed order, the ones the reader
made highlighted, each with a spoken label naming the reaction, the count and whether the reader reacted. A comment
without reactions SHALL show no chips.

#### Scenario: Reactions shown

- **WHEN** a comment arrives with thumbs up 2, reacted by the reader, and rocket 1
- **THEN** it shows a highlighted 👍 2 chip read as "thumbs up, 2, you reacted" and a plain 🚀 1 chip

#### Scenario: No reactions

- **WHEN** a comment arrives without a `reactions` field
- **THEN** it shows no chips

### Requirement: A reaction is one tap and undone on failure

Tapping a chip SHALL toggle the reader's reaction, and an add button beside the chips or a long press on the comment
SHALL open a picker of the eight reactions. The change SHALL show at once, be sent by name with
`PUT` or `DELETE /api/v1/comments/{id}/reactions/{reaction}`, and take the server's answer; a refusal SHALL restore the
comment and say why.

#### Scenario: Add from the picker

- **WHEN** the reader long-presses a comment and picks 🎉
- **THEN** a 🎉 1 chip appears highlighted at once and the app sends `PUT /api/v1/comments/{id}/reactions/hooray`

#### Scenario: Refused

- **WHEN** the reader taps their highlighted 👍 2 chip and the server answers 403
- **THEN** the chip shows 👍 2 highlighted again and a message explains the refusal

### Requirement: Reactions hide on a server without them

The app SHALL offer reactions on a connection until the server refuses one as an unknown route (405, or 404 with no
envelope or tix's `no such route`), then SHALL offer none for that connection until the session changes, unless a
comment arrives with `reactions`. A local instance whose engine predates reactions SHALL offer none.

#### Scenario: Older server

- **WHEN** the reader picks a reaction and the server answers 404 `no such route`
- **THEN** the chip is removed, a message says the server does not support reactions, and no comment offers the add button

#### Scenario: Local instance

- **WHEN** the active context is a local instance on an engine before reactions
- **THEN** comments show no add button and no long-press picker

### Requirement: Reactions follow events

The comments of an open task SHALL be read again when a `comment.reacted` or `comment.unreacted` event about the
task arrives.

#### Scenario: Someone else reacts

- **WHEN** the reader has infra-1 open and a `comment.reacted` event arrives with `task_id` of infra-1
- **THEN** the thread is read again and shows the new count
