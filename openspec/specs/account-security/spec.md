# account-security Specification

## Purpose
The signed-in person's own security: their second factor with its recovery codes, and the SSH keys that reach tix's terminal interface.

## Requirements

### Requirement: The second factor is set up from the app

The security screen SHALL show whether the person's second factor is on, pending or off, what the tenant requires
and how many recovery codes are left. Setting up SHALL show the authenticator key with an `otpauth` link, take the
code, and on success show the recovery codes once in a panel that closes only when acknowledged.

#### Scenario: Wrong then right code

- **WHEN** the person enters a wrong code, then the right one
- **THEN** the server's refusal is shown in the form, then the recovery codes appear once

### Requirement: Recovery codes and removal confirm first

Making new recovery codes and removing the second factor SHALL each confirm first, saying what stops working.

#### Scenario: Remove

- **WHEN** the person removes their second factor and confirms
- **THEN** the app sends `DELETE /auth/totp` and offers to set it up again

### Requirement: Secrets shown once are never kept

The authenticator key, recovery codes and generated passwords SHALL never be written to the response cache, the
log or provider state, and SHALL leave the screen with the panel that showed them.

#### Scenario: Nothing cached or logged

- **WHEN** a person enrols, confirms and makes new codes
- **THEN** neither the cache nor any log line holds the key or a code

### Requirement: SSH keys are listed, added and revoked

The security screen SHALL list the person's SSH keys with label, fingerprint, dates and revoked state. Adding one
SHALL take the public key, a label and whether to enrol it in every tenant. Revoking SHALL be a red action that
confirms.

#### Scenario: Add everywhere

- **WHEN** the person adds a key with "Every tenant I belong to" on
- **THEN** the app sends `POST /ssh-keys` with `all_tenants: true` and lists the key

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
