# server-connection Specification

## Purpose
Connecting to tix servers with an API token, keeping the token safe, and signing out.

## Requirements

### Requirement: Connecting checks the server and the token

The app SHALL connect with a server address and an API token. It SHALL call `GET /healthz` without the token, then `GET /api/v1/whoami` with it, and SHALL save nothing unless both succeed. An address without a scheme SHALL be read as `https://`, and a trailing `/api/v1` SHALL be dropped. A success SHALL save a token connection pinned to the token's tenant, on the remote instance at that address.

#### Scenario: A good token signs in

- **WHEN** a person enters `tix.example` and a token the server accepts in the tenant `acme`
- **THEN** the app is signed in to `https://tix.example` as the token's handle, the context shows tenant `acme`, and the projects are listed

#### Scenario: A refused token saves nothing

- **WHEN** the server answers `whoami` with `401`
- **THEN** the connect screen says the token was not accepted and nothing is stored

#### Scenario: Not a tix server

- **WHEN** `GET /healthz` answers `404` or something other than JSON
- **THEN** the connect screen says the address does not answer like a tix server

### Requirement: The token is kept in secure storage

API tokens and session tokens SHALL be written only to the platform's secure storage, keyed by the connection. They SHALL NOT be written to preferences, logs or screens other than the field they were typed in, which hides them until asked. A password SHALL NOT be stored anywhere.

#### Scenario: Token stays out of preferences

- **WHEN** a person connects with a token or signs in with a password
- **THEN** secure storage holds the token or the session, and no preference value contains it or the password

### Requirement: Signing out forgets the token

Signing out SHALL ask for confirmation, then remove the active connection and its secret, and end the session on the server when it is a sign-in. Another saved connection SHALL become active if there is one; otherwise the app SHALL return to the connect screen. An instance left with no connection SHALL be removed too.

#### Scenario: Last server signed out

- **WHEN** a person confirms sign out with one connection saved
- **THEN** secure storage is empty, no instance remains and the connect screen is shown
