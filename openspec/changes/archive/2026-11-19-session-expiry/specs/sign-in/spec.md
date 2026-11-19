## MODIFIED Requirements

### Requirement: An expired session asks to sign in again

When the server refuses the active sign-in's session, the app SHALL open Sign in again for that connection, with its server and email filled in and a line saying the session ended, and a successful sign-in SHALL keep the same connection.

#### Scenario: Sign in again

- **WHEN** a session has expired and the person signs in again
- **THEN** the same connection holds the new session and the lists load

#### Scenario: Refused while in use

- **WHEN** a screen's request is answered `401` and `GET /whoami` with the same session is answered `401` too
- **THEN** the app shows Sign in again for that connection with the server address kept

#### Scenario: Started after the session ended

- **WHEN** the app starts with an active sign-in that holds no session
- **THEN** it opens Sign in again for that connection

## ADDED Requirements

### Requirement: A refused session is checked once before signing out

On a `401` answered to the active remote sign-in's session, from any request, the app SHALL check the session once with `GET /whoami`. Only a `401` there SHALL sign it out. One check SHALL run at a time. A refused API token SHALL NOT be forgotten.

#### Scenario: Wrong code

- **WHEN** a request with a live session is answered `401` for another reason, such as a wrong code
- **THEN** `whoami` succeeds and the person stays signed in

#### Scenario: Several refusals at once

- **WHEN** a sync gets several `401`s for an expired session
- **THEN** the app sends one `whoami` and signs out once

### Requirement: A refused session stops background work

Signing out a refused session SHALL cancel the connection's running jobs and delete its stored session, keeping the connection, its instance, its cache and its outbox. No periodic sync, replay retry or live update SHALL send that session again.

#### Scenario: Periodic sync

- **WHEN** the 30-minute sync is answered `401` for an expired session
- **THEN** the session is deleted, the sync timer is cancelled and later ticks send nothing

### Requirement: Being signed out by the server notifies

When a refused session is signed out and notifications are allowed, the app SHALL show one notification on the Account channel saying it was signed out of the instance. Signing in again to that connection SHALL remove it.

#### Scenario: Signed out in the background

- **WHEN** the periodic sync signs out an expired session
- **THEN** a notification names the instance and asks to sign in again
