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
