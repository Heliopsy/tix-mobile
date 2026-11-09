# account-security

## ADDED Requirements

### Requirement: Active sessions are listed

The security screen SHALL have an Active sessions section listing the person's sessions a keyset page at a time, each with its user agent, how it signed in, when it began and when it expires, and SHALL mark the session this connection uses.

#### Scenario: Current marked

- **WHEN** a person signed in with a password opens the security screen
- **THEN** their sessions are listed and the one in use carries a "This session" badge

### Requirement: Revoking a session confirms and may sign out

Revoking a session SHALL be a red action that confirms first and then sends `session.revoke`. Revoking the session this connection uses SHALL sign the connection out.

#### Scenario: Another session

- **WHEN** a person confirms revoking a session that is not the current one
- **THEN** the app sends `DELETE /account/sessions/{id}`, the session leaves the list and the person stays signed in

#### Scenario: The current session

- **WHEN** a person confirms revoking the current session
- **THEN** the app revokes it and forgets the connection

### Requirement: A token without account:read is told why

When the credential cannot read the account (a token not naming `account:read`), the Active sessions section SHALL explain that the token needs `account:read` and send no request. A 403 from `session.list` SHALL show the same explanation instead of an error.

#### Scenario: Token without the scope

- **WHEN** an API token holding `*` opens the security screen
- **THEN** the section explains it needs `account:read` and no sessions request is sent

#### Scenario: Server refuses

- **WHEN** `session.list` answers 403
- **THEN** the section shows the explanation, not an error state
