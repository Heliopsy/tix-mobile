# offline-sync

## ADDED Requirements

### Requirement: Notification actions use the outbox

A notification action SHALL be written through the outbox of the notification's context with its own Idempotency-Key, sent at once when the server is reachable and kept for replay when it is not. When the context cannot be reached from the background (a local instance, or a sign-in sitting in another tenant) the write SHALL be queued and sent when the app next runs that context.

#### Scenario: Done offline

- **WHEN** a person taps Done with no network
- **THEN** a move to the done state is queued in that context's outbox with a fresh key, the notification goes away, and the move is sent when the network returns

#### Scenario: Local instance

- **WHEN** a person replies to a notification from a local instance while its engine is stopped
- **THEN** no engine starts and the comment waits in that context's outbox

### Requirement: One engine holds the outbox at a time

On Android, the app SHALL NOT read or write an outbox while a headless engine that ran a notification action is alive. When the app opens during one, the headless engine SHALL finish the actions it is running and be stopped, and only then SHALL the app load the outbox. An action pressed while the app is open SHALL run in the app.

#### Scenario: Opening the app right after an action

- **WHEN** a person taps Done with the app closed and opens tix while the background engine is still up
- **THEN** the background engine finishes the move and stops, and the app then loads an outbox that holds it
