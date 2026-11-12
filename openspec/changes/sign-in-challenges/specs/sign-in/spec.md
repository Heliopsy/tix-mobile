## MODIFIED Requirements

### Requirement: Signing in with email and password

The app SHALL sign in to a remote instance with an email and a password through `POST /api/v1/auth/login`, after checking `GET /healthz`. It SHALL save nothing unless the sign-in yields a session and `whoami` accepts it. The password SHALL be sent only on the password step and on a required password change, and never kept.

#### Scenario: A good password signs in

- **WHEN** a person signs in with an email and password the server accepts
- **THEN** a sign-in connection is saved, its session is in secure storage, and the projects are listed

#### Scenario: A wrong password saves nothing

- **WHEN** the server answers the login with `401`
- **THEN** the sign-in screen says the credentials were not accepted and nothing is stored

### Requirement: The second factor is asked for when required

When the login answers a challenge of kind `code`, the app SHALL ask for a code and send it with the challenge's ticket and no password. A refused code SHALL let the person try again.

#### Scenario: A code completes the sign-in

- **WHEN** the login answers a code challenge and the person enters a code the server accepts
- **THEN** the sign-in completes as it would without a challenge

#### Scenario: Enrolment is needed

- **WHEN** the login answers a challenge of kind `enrol`
- **THEN** the screen opens the second factor setup instead of sending the person to the browser

## ADDED Requirements

### Requirement: A required password change is made in the app

When the login answers a challenge of kind `password_change`, the app SHALL ask for a new password twice and send the email, the password already given and `new_password` on the login, with `remember` as on any step. It SHALL refuse to send when the two differ or are empty, and leave length and reuse to the server.

#### Scenario: A new password signs in

- **WHEN** the login answers `password_change` and the person enters a new password the server accepts, twice
- **THEN** the login is sent again with `new_password` and the sign-in completes

#### Scenario: The two do not match

- **WHEN** the new password and its confirmation differ
- **THEN** the step says they do not match and nothing is sent

#### Scenario: The server refuses it

- **WHEN** the server answers the change with `invalid` on `new_password`
- **THEN** the step shows the server's reason and stays open

### Requirement: A challenge after the change is followed

A login that sends `new_password` SHALL be followed like any other: a session completes the sign-in, and a `code` or `enrol` challenge opens its step.

#### Scenario: Change then enrol

- **WHEN** the change is accepted and the server answers an `enrol` challenge
- **THEN** the second factor setup step opens

### Requirement: A required second factor is set up in the app

When the login answers a challenge of kind `enrol`, the app SHALL show the enrolment's key with Copy and a way to open its `otpauth` link, ask for the code, and send it with the challenge's ticket. A refused code SHALL let the person try again.

#### Scenario: Enrolment completes the sign-in

- **WHEN** the person adds the key to an authenticator and enters a code the server accepts
- **THEN** the sign-in goes on with the session the server returns

### Requirement: Recovery codes are shown once before going on

When a login result carries `recovery_codes`, the app SHALL show them once with Copy and SHALL go on with the sign-in only after the person confirms they saved them. The codes SHALL not be stored or logged.

#### Scenario: Codes after enrolment

- **WHEN** an enrolment completes and the result carries recovery codes
- **THEN** the codes are shown and nothing is saved until the person confirms

### Requirement: Each challenge field is explained

The new password, the authenticator key and the recovery codes SHALL each have an (i) like the other connect fields.

#### Scenario: What the key is for

- **WHEN** a person taps the (i) beside the authenticator key
- **THEN** an explanation of the second factor opens
