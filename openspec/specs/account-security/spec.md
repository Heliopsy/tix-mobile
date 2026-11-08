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
