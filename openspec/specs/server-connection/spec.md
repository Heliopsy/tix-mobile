# server-connection Specification

## Purpose
Signing in to tix servers with an API token, saving several, switching between them and signing out.

## Requirements

### Requirement: Connecting checks the server and the token

The app SHALL sign in with a server address and an API token. It SHALL call `GET /healthz` without the
token, then `GET /api/v1/whoami` with it, and SHALL save nothing unless both succeed. An address without a
scheme SHALL be read as `https://`, and a trailing `/api/v1` SHALL be dropped.

#### Scenario: A good token signs in

- **WHEN** a person enters `tix.example` and a token the server accepts
- **THEN** the app is signed in to `https://tix.example` as the token's handle and shows the projects

#### Scenario: A refused token saves nothing

- **WHEN** the server answers `whoami` with `401`
- **THEN** the connect screen says the token was not accepted and nothing is stored

#### Scenario: Not a tix server

- **WHEN** `GET /healthz` answers `404` or something other than JSON
- **THEN** the connect screen says the address does not answer like a tix server

### Requirement: The token is kept in secure storage

The API token SHALL be written only to the platform's secure storage, keyed by the saved server. It SHALL
NOT be written to preferences, logs or screens other than the connect field, which hides it until asked.

#### Scenario: Token stays out of preferences

- **WHEN** a person connects
- **THEN** secure storage holds the token and no preference value contains it

### Requirement: Several servers can be saved

The app SHALL keep a list of saved servers, each with a name, an address and a handle, and one of them
active. Connecting to an address as a handle already saved SHALL replace that entry rather than add another.

#### Scenario: Switching servers

- **WHEN** two servers are saved and a person picks the inactive one under Settings
- **THEN** it becomes active and the lists show its projects

#### Scenario: Reconnecting replaces

- **WHEN** a person connects twice to the same address as the same handle
- **THEN** one saved server remains

### Requirement: Signing out forgets the token

Signing out SHALL ask for confirmation, then remove the active server and its token. Another saved server
SHALL become active if there is one; otherwise the app SHALL return to the connect screen.

#### Scenario: Last server signed out

- **WHEN** a person confirms sign out with one server saved
- **THEN** secure storage is empty and the connect screen is shown
