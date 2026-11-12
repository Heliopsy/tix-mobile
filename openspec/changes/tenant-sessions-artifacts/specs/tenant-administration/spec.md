## MODIFIED Requirements

### Requirement: Tenant settings are edited in headed sections

The app SHALL show a tenant's settings as always-visible sections: general (name, time zone, date format), theme,
second factor per surface, claim leases, sessions, artifacts, trash and a danger zone. Each form section SHALL
send only the fields that changed with `PATCH /api/v1/tenants/{ref}`, and switches SHALL save at once. A refusal
SHALL be shown with the server's message and keep what was typed.

#### Scenario: Rename

- **WHEN** an admin changes the name and presses Save in General
- **THEN** the app sends `PATCH /tenants/{ref}` with only `name`

#### Scenario: Refused name

- **WHEN** the server refuses a blank name
- **THEN** its message is shown and the field keeps the blank value

## ADDED Requirements

### Requirement: Session settings narrow the server's

The Sessions section SHALL edit `session_ttl`, `session_idle_timeout` and `session_remember_ttl` as durations
written the way tix prints them. An emptied duration SHALL be sent as `0`, and Keep me signed in SHALL be sent as
typed, where empty inherits and `off` stops offering it. Each empty field SHALL show the server's own setting from
`GET /api/v1/auth/session-policy` as its hint.

#### Scenario: Shorter sign-in

- **WHEN** an admin types `8h` in Sign-in lasts and presses Save
- **THEN** the app sends only `session_ttl: "8h"`

#### Scenario: Stop offering Keep me signed in

- **WHEN** an admin types `off` in Keep me signed in lasts and presses Save
- **THEN** the app sends only `session_remember_ttl: "off"`

#### Scenario: Longer than the server's

- **WHEN** the server refuses a lifetime above its own
- **THEN** its message is shown and the field keeps the value

#### Scenario: Inherited hint

- **WHEN** the tenant sets no lifetime and the server's is 12 hours
- **THEN** the empty field shows 12h as its hint

### Requirement: Artifact limits narrow the server's

The Artifacts section SHALL edit `artifact_max_bytes`, typed as a size such as `512KiB` or `5MiB`, and
`artifact_types`, typed as a comma-separated list such as `image/*, application/pdf`. An emptied size SHALL be
sent as `0` and emptied types as an empty list. A size the app cannot read SHALL be flagged under the field and
not sent. Each empty field SHALL show the server's limit from `GET /api/v1/artifact-limits` as its hint.

#### Scenario: Smaller files

- **WHEN** an admin types `5MiB` as the largest file and presses Save
- **THEN** the app sends only `artifact_max_bytes: 5242880`

#### Scenario: Narrower types

- **WHEN** an admin types `image/*, application/pdf` as accepted types and presses Save
- **THEN** the app sends only `artifact_types: ["image/*", "application/pdf"]`

#### Scenario: Type the server does not accept

- **WHEN** the server refuses a type outside its own list
- **THEN** its message is shown and the field keeps the value
