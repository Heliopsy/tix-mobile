## ADDED Requirements

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

When a sign-in connection's session is refused with `401`, the app SHALL offer to sign in again with the email filled in, and a successful sign-in SHALL keep the same connection.

#### Scenario: Sign in again

- **WHEN** a session has expired and the person signs in again from the error
- **THEN** the same connection holds the new session and the lists load
