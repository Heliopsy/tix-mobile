# task-detail

## ADDED Requirements

### Requirement: Comments carry reactions

Each comment SHALL show the server's reactions as chips of emoji and count in the order the server lists them.
The ones whose `actor_ids` hold the reader's actor id SHALL be highlighted. Each chip SHALL have a spoken label
naming the emoji, the count and whether the reader reacted. A comment without reactions SHALL show no chips.

#### Scenario: Reactions shown

- **WHEN** a comment arrives with 👍 2 whose actors are another person and the reader, and 🚀 1 from someone else
- **THEN** it shows a highlighted 👍 2 chip read as "👍, 2, you reacted" and a plain 🚀 1 chip

#### Scenario: No reactions

- **WHEN** a comment arrives without a `reactions` field
- **THEN** it shows no chips

### Requirement: A reaction is one tap and undone on failure

Tapping a chip SHALL toggle the reader's reaction. The change SHALL show at once, be sent with `PUT` or
`DELETE /api/v1/comments/{id}/reactions/{emoji}` with the emoji percent-encoded, and take the server's answer. A
refusal SHALL restore the comment and say why.

#### Scenario: Taken away

- **WHEN** the reader taps their highlighted 👍 2 chip
- **THEN** it shows 👍 1 plain at once and the app sends `DELETE /api/v1/comments/{id}/reactions/%F0%9F%91%8D`

#### Scenario: Refused

- **WHEN** the reader taps their highlighted 👍 2 chip and the server answers 403
- **THEN** the chip shows 👍 2 highlighted again and a message explains the refusal

### Requirement: The picker offers common emoji and any other

An add button beside the chips, and a long press on the comment, SHALL open a picker with a row of eight common
emoji, the reader's own marked, and a field that takes any one emoji. Picking or sending one SHALL toggle it as
a tap on its chip does. The field's button SHALL be enabled only for a single grapheme.

#### Scenario: Quick pick

- **WHEN** the reader long-presses a comment and picks 🎉
- **THEN** a 🎉 1 chip appears highlighted at once and the app sends `PUT` for `%F0%9F%8E%89`

#### Scenario: Typed emoji

- **WHEN** the reader types 👩‍💻 into the picker's field and sends it
- **THEN** the app sends `PUT` with 👩‍💻 percent-encoded and a highlighted 👩‍💻 1 chip appears

#### Scenario: Not one grapheme

- **WHEN** the reader types `ok` into the picker's field
- **THEN** its button stays disabled

### Requirement: Reactions hide where the server cannot take them

The app SHALL offer reactions on a connection until the server refuses one as an unknown route (405, or 404 with
no envelope or tix's `no such route`), then SHALL offer none for that connection until the session changes,
unless a comment arrives with reactions. Comments still in the outbox and those of an offline draft SHALL offer
none.

#### Scenario: Older server

- **WHEN** the reader picks a reaction and the server answers 404 `no such route`
- **THEN** the chip goes, a message says the server does not support reactions, and no comment offers the add button

#### Scenario: Deleted comment

- **WHEN** the server answers a reaction with 404 naming the comment
- **THEN** the message is the ordinary not-found error and reactions stay offered

### Requirement: Reactions follow events

The comments of an open task SHALL be read again when a `comment.reacted` or `comment.unreacted` event about the
task arrives.

#### Scenario: Someone else reacts

- **WHEN** the reader has infra-1 open and a `comment.reacted` event arrives with `task_id` of infra-1
- **THEN** the thread is read again and shows the new reaction
