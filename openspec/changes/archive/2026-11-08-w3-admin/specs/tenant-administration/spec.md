# tenant-administration

## ADDED Requirements

### Requirement: Tenant settings are edited in headed sections

The app SHALL show a tenant's settings as always-visible sections: general (name, time zone, date format), theme,
second factor per surface, claim leases, trash and a danger zone. Each form section SHALL send only the fields
that changed with `PATCH /api/v1/tenants/{ref}`, and switches SHALL save at once. A refusal SHALL be shown with the
server's message and keep what was typed.

#### Scenario: Rename

- **WHEN** an admin changes the name and presses Save in General
- **THEN** the app sends `PATCH /tenants/{ref}` with only `name`

#### Scenario: Refused name

- **WHEN** the server refuses a blank name
- **THEN** its message is shown and the field keeps the blank value

### Requirement: A theme is previewed before it is saved

Picking a built-in theme or typing a `#rrggbb` colour SHALL redraw a light and a dark preview with the accent the
app itself would derive, sending nothing. Saving SHALL send `theme` alone and, for the active tenant, recolour the
app. A malformed colour SHALL say how to write one.

#### Scenario: Preview then save

- **WHEN** an admin picks indigo, then saves
- **THEN** the previews turn indigo before any request, and `PATCH` carries only `theme: indigo`

### Requirement: Domains are listed, added and removed

The domains screen SHALL list the active tenant's hostnames with their certificate mode, verification and shared
state. Adding one SHALL ask for the hostname and a certificate mode, with the certificate and key paths when the
mode is `file`. Removing one SHALL be a red action that confirms first.

#### Scenario: Add with a certificate file

- **WHEN** an admin adds `board.example.com` with mode file and both paths
- **THEN** the app sends `POST /domains` with the hostname, `cert_mode: file` and both paths, and lists it

### Requirement: Deleting a tenant confirms and leaves it

Deleting a tenant SHALL be a red action that confirms, naming the tenant. Deleting the active tenant SHALL sign
out of that connection afterwards; a global admin SHALL NOT delete the active tenant from the tenant tree.

#### Scenario: Delete the active tenant

- **WHEN** an admin confirms deleting the tenant they work in
- **THEN** the app sends `DELETE /tenants/{ref}` and forgets the connection
