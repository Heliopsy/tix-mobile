# actor-page

## ADDED Requirements

### Requirement: Actor screen

The app SHALL show one actor at `/actors/{id or handle}` from `GET /actors/{id}`: handle, name, kind and id with
Copy, the first 20 tasks assigned to it, and "(you)" with a link to the account when it is the reader.

#### Scenario: Open by handle

- **WHEN** a person opens `/actors/raj`
- **THEN** the app reads `GET /actors/raj` and shows Raj's handle, name and id

### Requirement: Actor credentials need token:admin

The actor screen SHALL list the actor's API tokens and SSH keys only for a reader holding `token:admin`, and never
for the system actor.

#### Scenario: Without token:admin

- **WHEN** a reader without `token:admin` opens an actor
- **THEN** no token or key section is drawn and no token or key listing is requested

### Requirement: Actor recent activity needs audit:read

The actor screen SHALL list the actor's last 20 audit entries, newest first, for a reader holding `audit:read`,
and SHALL otherwise say that recent activity needs that scope.

#### Scenario: With audit:read

- **WHEN** a reader holding `audit:read` opens an actor
- **THEN** the app reads `GET /audit` with `actor_id` and `limit=20` and lists the entries

### Requirement: Names open the actor screen

A comment's author, a reactor, a task history entry, an Activity row's actor, an audit entry's actor, a
leaderboard row and a token's owner SHALL open that actor's screen. The system actor SHALL not be a link.

#### Scenario: Comment author

- **WHEN** a person taps the author of a comment
- **THEN** the actor screen of that author opens

### Requirement: Mentions open the actor screen

An `@handle` in a task's description or a comment SHALL be a link to that handle's actor screen, except inside
code, an existing link, an address or an email.

#### Scenario: Mention

- **WHEN** a comment says "ask @raj" and the person taps "@raj"
- **THEN** the actor screen of raj opens
