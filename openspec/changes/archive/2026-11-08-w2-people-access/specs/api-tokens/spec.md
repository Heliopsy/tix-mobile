# api-tokens

## ADDED Requirements

### Requirement: Tokens are listed with their use

The tokens screen SHALL list tokens from `token.list` with name, scopes, created, expiry ("Never" when none),
last use ("Not yet" when none) and state. With `tenant:admin` it SHALL list the whole tenant's with an owner on
each row; otherwise the caller's own. The screen SHALL be offered only with `token:admin`.

#### Scenario: Own tokens

- **WHEN** a member with `token:admin` opens Tokens
- **THEN** the app asks `GET /tokens?actor_id=<me>` and lists them

### Requirement: Issuing shows the value once

Issuing a token SHALL take a name, scopes the caller holds (others drawn disabled), and an expiry of 7, 30, 90
days, 1 year or never, 90 days proposed. The value SHALL be shown once with Copy and a warning, and SHALL never
be cached, kept in a provider or logged.

#### Scenario: Issue

- **WHEN** a person issues "ci" with task:read for 30 days
- **THEN** the app sends scopes and an expiry 30 days out and shows the value once

#### Scenario: Value never stored

- **WHEN** a token is issued and the sheet closed
- **THEN** neither the response cache nor the log holds its value

### Requirement: Revoking confirms first

Revoking SHALL be a red action that confirms, naming the token and, when it is somebody else's, saying so,
then calls `token.revoke`.

#### Scenario: Revoke

- **WHEN** a person revokes "ci" and confirms
- **THEN** the app calls `DELETE /tokens/{id}` and the row reads revoked
