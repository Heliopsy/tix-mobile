## ADDED Requirements

### Requirement: The switcher shows each tenant's icon

The switcher's rows and its button SHALL draw each tenant in a square mark: its uploaded image, else its built-in
icon, else its emoji or monogram, else the first two letters of its name. Icons SHALL come from `whoami`'s
memberships and be kept with the connection. An uploaded image SHALL be read from `GET /api/v1/tenants/{ref}/icon`
with the active session; a tenant whose image cannot be read that way SHALL show its monogram.

#### Scenario: Built-in icon in the switcher

- **WHEN** tenant Acme has the built-in icon `rocket` and the switcher opens
- **THEN** Acme's row shows the rocket glyph in its mark

#### Scenario: No icon

- **WHEN** a tenant has no icon
- **THEN** its row shows the first two letters of its name

#### Scenario: Uploaded image

- **WHEN** a tenant of the active connection has an uploaded image
- **THEN** its row shows the image read from `GET /tenants/{ref}/icon`

#### Scenario: Current tenant on the button

- **WHEN** the active tenant has the icon 🚀
- **THEN** the switcher button shows 🚀 in the mark beside the context's name

#### Scenario: Older server

- **WHEN** the server predates tenant icons
- **THEN** every tenant shows its monogram and nothing fails
