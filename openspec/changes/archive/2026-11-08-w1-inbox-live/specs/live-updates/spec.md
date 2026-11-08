## ADDED Requirements

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
