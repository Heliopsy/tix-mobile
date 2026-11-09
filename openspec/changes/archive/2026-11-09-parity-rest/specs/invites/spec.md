# invites

## ADDED Requirements

### Requirement: An invite link is accepted in the app

The connect screen SHALL take an invite link, pasted or shared to the app, read the server and the token from it,
and preview the invite with `invite.preview` before any password is asked for. A text that is not an invite link
SHALL be refused before anything is sent.

#### Scenario: Pasted link

- **WHEN** a person pastes `https://tix.example/invite/tix_inv_abc`
- **THEN** the app shows the tenant, the invited address and when the link expires

#### Scenario: Not a link

- **WHEN** a person pastes a task address
- **THEN** the app says it is not an invite link and sends nothing

### Requirement: Accepting adds the server and signs in

Accepting SHALL send `invite.accept` with a new password and name, or an existing account's password, and a code
when the preview asks for one. The answer SHALL be handled as a sign-in: a code challenge, a choice of tenant, then
a saved sign-in on a new or existing instance for that server.

#### Scenario: New account

- **WHEN** a person accepts with a 12 character password
- **THEN** the server is added and the new sign-in opens

#### Scenario: Existing account

- **WHEN** the preview reports an existing account in another tenant
- **THEN** the app asks for that account's password and offers its tenants

### Requirement: A shared invite opens the invite

A share carrying an invite link SHALL open the invite form instead of quick add, signed in or not. Any other share
received while signed out SHALL wait as a quick-add draft.

#### Scenario: Share while signed in

- **WHEN** an invite link is shared to the app during a session
- **THEN** the connect screen opens on the invite
