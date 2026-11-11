# task-detail

## ADDED Requirements

### Requirement: A comment names the channel it came through

Each comment SHALL show the channel and token name of its `comment.add` audit entry, or of the `comment.added` event
that announced it, beside its author. Without either, or when the audit cannot be read, the comment SHALL show none.

#### Scenario: A comment posted by an agent

- **WHEN** a comment's `comment.add` entry has kind `api` and token name `ci-agent`
- **THEN** the comment shows "via token ci-agent" beside its author

### Requirement: Comments carry emoji reactions

Each sent comment SHALL show its reactions as chips with the emoji and count, marked when the viewer's actor is
among them. A tap SHALL toggle the viewer's reaction, a long press SHALL list who reacted, and an add button SHALL
offer 👍 👎 ❤️ 🎉 😄 😕 👀 🚀.

#### Scenario: Toggling a reaction

- **WHEN** the viewer taps a 👍 chip that includes them
- **THEN** the app removes their reaction and shows the count the server returns

### Requirement: Reactions follow the server

`comment.reacted` and `comment.unreacted` events SHALL refresh an open task's comments. When adding or removing a
reaction answers 404, the app SHALL hide the add button, as a server without reactions has none.

#### Scenario: An older server

- **WHEN** the server answers 404 to adding a reaction
- **THEN** the add button disappears and the comment stays
