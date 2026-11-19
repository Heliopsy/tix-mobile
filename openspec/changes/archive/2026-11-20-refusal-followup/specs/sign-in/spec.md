## MODIFIED Requirements

### Requirement: A refused session is checked once before signing out

On a `401` answered to the active remote connection's session or API token, from any request, the app SHALL check the credential once with `GET /whoami`. Only a `401` there SHALL count as a refusal. One check SHALL run at a time. A refused API token SHALL NOT be deleted.

#### Scenario: Wrong code

- **WHEN** a request with a live session is answered `401` for another reason, such as a wrong code
- **THEN** `whoami` succeeds and the person stays signed in

#### Scenario: Several refusals at once

- **WHEN** a sync gets several `401`s for an expired session
- **THEN** the app sends one `whoami` and signs out once

#### Scenario: A token the server still accepts

- **WHEN** a request with an API token is answered `401` and `whoami` with that token succeeds
- **THEN** the token stays, the connection is not marked refused and sync goes on

## ADDED Requirements

### Requirement: A refused token stops background work

When an API token is confirmed refused, the app SHALL cancel the connection's running jobs, keep the token in secure storage and record the connection as refused with it. No periodic sync, replay retry or live update SHALL send that token again.

#### Scenario: Periodic sync

- **WHEN** the 30-minute sync is answered `401` for a revoked token and `whoami` is refused too
- **THEN** the connection is marked refused, the token is kept, the sync timer is cancelled and later ticks send nothing

### Requirement: A refusal survives a restart

The refused state SHALL be stored with the connection. Starting the app with an active refused connection, or a sign-in with no session, SHALL open the reconnect screen for it without sending its credential.

#### Scenario: Cold start after a refusal

- **WHEN** the app starts after a token or session was recorded refused, in the app or in the widgets' background run
- **THEN** it opens the reconnect screen for that connection and sends no request with the refused credential

### Requirement: A refused token asks for a new credential

The reconnect screen for a refused token SHALL say the token was refused and offer to paste a new token or sign in, with the server address kept. Saving a credential the server accepts SHALL keep the connection's id and cached data, clear the refused state and start syncing again.

#### Scenario: New token

- **WHEN** the person pastes a new token for a refused connection
- **THEN** the same connection holds the new token, it is no longer refused and the periodic sync runs again

### Requirement: A refused token notifies

When a token is confirmed refused and notifications are allowed, the app SHALL show one notification on the Account channel saying the token for the instance was refused. Saving a new credential for that connection SHALL remove it.

#### Scenario: Refused in the background

- **WHEN** the periodic sync records a refused token
- **THEN** a notification names the instance and says its token was refused
