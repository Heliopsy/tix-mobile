## ADDED Requirements

### Requirement: Stay signed in asks for a remembered session

The sign-in form, including Sign in again, SHALL show a Stay signed in switch, on by default. With it on, the app
SHALL read `GET /api/v1/auth/session-policy` without a credential and SHALL send `"remember": true` on the login
step that completes the sign-in, the code step included, only when the policy's `remember_ttl` is longer than its
`ttl`.

#### Scenario: Offered

- **WHEN** the server offers Keep me signed in and the person signs in with the switch on
- **THEN** the login request carries `"remember": true`

#### Scenario: Switched off

- **WHEN** the person turns the switch off and signs in
- **THEN** the login request carries no `remember`

#### Scenario: Turned off by the tenant

- **WHEN** the policy's `remember_ttl` is `0s`
- **THEN** the login request carries no `remember`

### Requirement: An older server is never sent the flag

When the session policy answers `401` or `404`, the app SHALL treat the server as offering no remembered session,
send no `remember`, and sign in as before.

#### Scenario: tix before v0.58.0

- **WHEN** the session policy route answers `401` and the person signs in with the switch on
- **THEN** the login request carries no `remember` and the sign-in completes
