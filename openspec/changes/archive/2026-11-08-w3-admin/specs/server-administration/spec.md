# server-administration

## ADDED Requirements

### Requirement: The server screen shows the version and live connections

The server screen SHALL show the version from `/healthz`, the server process id, and the counts and rows of
`GET /api/v1/connections`. Ending a connection SHALL be a red action that confirms, then reads the list again.

#### Scenario: End a connection

- **WHEN** an admin ends an SSH connection and confirms
- **THEN** the app sends `DELETE /connections/{id}` and the row is gone

### Requirement: A global admin manages every tenant

For a global admin the app SHALL list every tenant a page at a time, with the chosen one beside the list from 840
wide. Creating a tenant SHALL take its key, name and an optional first admin, and SHALL show any generated
password once in a panel that closes only when acknowledged.

#### Scenario: Generated password

- **WHEN** a global admin creates a tenant with a first admin and no password
- **THEN** the generated password is shown once and is gone after Done

### Requirement: A global admin switches into any tenant

The tenant detail SHALL switch a switchable sign-in into the tenant. When the person is not a member, it SHALL
offer to join as admin first, saying the change is logged, then switch. A token or pinned sign-in SHALL show the
switch disabled with the reason.

#### Scenario: Join and switch

- **WHEN** a global admin who is not in `acme` confirms Join and switch
- **THEN** the app adds them to `acme` as admin, switches the session and opens the projects

### Requirement: A global admin manages a tenant's users

The users screen SHALL list a tenant's users with their role, global admin, disabled, second factor and password
change marks, and SHALL create a user, add an existing account, edit one sending only what changed, and delete
one after a confirmation. Clearing a second factor SHALL be offered only in the active tenant and confirm first.

#### Scenario: Disable a user

- **WHEN** a global admin turns on Disabled for a user and saves
- **THEN** the app sends `PATCH /tenants/{ref}/users/{id}` with only `disabled: true`

### Requirement: Global admins and account logs

The global admins screen SHALL list them, grant global admin by email and revoke it after a confirmation. An
account's log SHALL list its changes newest first, a page at a time, with tenant, actor, channel, time and detail.

#### Scenario: Revoke

- **WHEN** a global admin revokes another and confirms
- **THEN** the app sends `DELETE /global-admins/{email}` and the row is gone
