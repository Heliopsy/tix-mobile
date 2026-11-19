## ADDED Requirements

### Requirement: Widgets stop at a refused credential

When a widget refresh or queued tick, in the app or in the headless background run, is answered `401` and `whoami` with the same credential is refused too, the app SHALL record the connection as refused, deleting a session but never a token, and show the account notification when allowed.

#### Scenario: Expired session in the background

- **WHEN** the background refresh reads a context whose session has expired
- **THEN** the session is deleted, the connection is marked refused and the notification shows

#### Scenario: Revoked token in the background

- **WHEN** the background refresh reads a context whose token was revoked
- **THEN** the token is kept and the connection is marked refused

### Requirement: Refused contexts draw as signed out

The writer SHALL NOT send a request for a refused connection. It SHALL remove that context's snapshots and mark it refused in the index, and widgets SHALL show that the person needs to sign in again instead of the last data.

#### Scenario: Next refresh

- **WHEN** the background refresh runs again after a refusal
- **THEN** it sends no request for that connection and its widgets ask to sign in again
