# task-detail

## MODIFIED Requirements

### Requirement: Comments carry emoji reactions

Each sent comment SHALL show its reactions as chips with the emoji and count, marked when the viewer's actor is
among them. A tap SHALL toggle the viewer's reaction, a long press SHALL list who reacted, and an add button SHALL
offer 👍 👎 ❤️ 🎉 😄 😕 👀 🚀 and a field for any one emoji. A long press on a comment outside its text SHALL open
the same picker.

#### Scenario: Toggling a reaction

- **WHEN** the viewer taps a 👍 chip that includes them
- **THEN** the app removes their reaction and shows the count the server returns

#### Scenario: Reacting with any emoji

- **WHEN** the viewer types 🦀 in the picker's field and sends it
- **THEN** the app adds 🦀 and, when the server refuses it, shows the server's reason

### Requirement: Reactions follow the server

`comment.reacted` and `comment.unreacted` events SHALL refresh an open task's comments. When a reaction is answered
405, or 404 saying `no such route` or carrying no tix error, the app SHALL hide the add button and say the server
does not support reactions. Any other 404 SHALL show the server's error and reload the comments.

#### Scenario: An older server

- **WHEN** the server answers 404 `no such route` to adding a reaction
- **THEN** the add button disappears, a toast says the server does not support reactions, and the comment stays

#### Scenario: A comment deleted meanwhile

- **WHEN** the server answers 404 naming the comment to adding a reaction
- **THEN** the app shows the server's error, reloads the comments and keeps offering reactions

## ADDED Requirements

### Requirement: Reaction toggles draw at once

A toggle SHALL change its chip before the server answers, adding a new emoji last and dropping one nobody reacts with
any more. The server's comment SHALL replace the guess; a refusal SHALL restore the chip with a toast. Toggles on one
comment SHALL be sent in order, and a tap on a chip whose toggle is pending SHALL be ignored.

#### Scenario: A refused toggle

- **WHEN** the viewer taps 🚀 and the server answers 403
- **THEN** the 🚀 chip shows at once, then goes again with an error toast

### Requirement: Reaction chips are accessible

A reaction chip SHALL take a tap anywhere in a 48 dp target, and its spoken label SHALL say the emoji, the count and,
when the viewer is among those who reacted, that they reacted.

#### Scenario: A chip the viewer reacted with

- **WHEN** a screen reader focuses a 👍 chip of two that includes the viewer
- **THEN** it hears the emoji, the count 2 and "you reacted"
