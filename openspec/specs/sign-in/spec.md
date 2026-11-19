# sign-in Specification

## Purpose
Signing in to a server with an email and a password, the second factor, and how a session is sent.

## Requirements

### Requirement: Signing in with email and password

The app SHALL sign in to a remote instance with an email and a password through `POST /api/v1/auth/login`, after checking `GET /healthz`. It SHALL save nothing unless the sign-in yields a session and `whoami` accepts it. The password SHALL be sent once and never kept.

#### Scenario: A good password signs in

- **WHEN** a person signs in with an email and password the server accepts
- **THEN** a sign-in connection is saved, its session is in secure storage, and the projects are listed

#### Scenario: A wrong password saves nothing

- **WHEN** the server answers the login with `401`
- **THEN** the sign-in screen says the credentials were not accepted and nothing is stored

### Requirement: The second factor is asked for when required

When the login answers a challenge of kind `code`, the app SHALL ask for a code and send it with the challenge's ticket and no password. A refused code SHALL let the person try again. A challenge of kind `enrol` or `password_change` SHALL be explained as something to finish in the browser.

#### Scenario: A code completes the sign-in

- **WHEN** the login answers a code challenge and the person enters a code the server accepts
- **THEN** the sign-in completes as it would without a challenge

#### Scenario: Enrolment is needed

- **WHEN** the login answers a challenge of kind `enrol`
- **THEN** the screen says to set up the second factor in the browser first and nothing is stored

### Requirement: A session is presented as tix's session cookie

The app SHALL present a sign-in session as the `tix_session` cookie and SHALL NOT send an `Authorization` header with it, because tix accepts session tokens only as that cookie. An API token SHALL be sent as `Authorization: Bearer`.

#### Scenario: Session requests carry the cookie

- **WHEN** a sign-in connection is active and the projects load
- **THEN** the request carries `Cookie: tix_session=…` and no `Authorization` header

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
