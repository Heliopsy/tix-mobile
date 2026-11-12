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

### Requirement: A server address is spelled one way

Wherever a server address enters the app, the connect form, a link to the connect screen, an invite link or a
saved instance, the app SHALL trim whitespace, drop trailing slashes and a trailing `/api/v1`, read an address
without a scheme as `https://`, and keep `http://` when it is typed. Paths SHALL be joined to it with one slash.

#### Scenario: A trailing slash is dropped

- **WHEN** a person enters ` https://tix.example.com/// ` and connects
- **THEN** the form shows `https://tix.example.com` and the instance is saved at that address

#### Scenario: http stays http

- **WHEN** a person enters `http://192.168.1.5:8080/`
- **THEN** the address used is `http://192.168.1.5:8080`

### Requirement: The connect screen explains each field

The server address, the server or this device choice, the way to connect, the API token, email, password, invite
link, name and tenant choice SHALL each have an (i) button. It SHALL be labelled for screen readers, reachable by
keyboard, at least 48 dp, and SHALL open a short plain explanation: a sheet on a phone, a dialog on a wider window.

#### Scenario: Where the address comes from

- **WHEN** a person taps the (i) beside Server address
- **THEN** a sheet says the address is the one they open tix with in a browser, such as `https://tix.example.com`, and to ask whoever runs tix for it

#### Scenario: Where a token comes from

- **WHEN** a person on a desktop window opens the (i) beside API token
- **THEN** a dialog says to create one on tix web's API tokens page or with `tix token create`
