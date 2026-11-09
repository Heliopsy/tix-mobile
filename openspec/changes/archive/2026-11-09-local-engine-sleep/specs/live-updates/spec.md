# live-updates

## ADDED Requirements

### Requirement: Live updates sleep with a local engine

When the engine of the active local context stops, live updates SHALL sleep: no WebSocket, no reconnect attempt, no poll and no refresh, and the indicator SHALL show nothing. When the engine starts again they SHALL resume over the WebSocket from the cursor.

#### Scenario: Engine idles while polling

- **WHEN** live updates of a local context are polling and the engine stops while idle
- **THEN** the poll in flight is cancelled and no further poll or WebSocket attempt is made

#### Scenario: Engine back

- **WHEN** the engine starts again after resting
- **THEN** a WebSocket subscribes from the cursor
