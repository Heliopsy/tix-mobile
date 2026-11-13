## ADDED Requirements

### Requirement: A tenant admin sets the tenant's icon

The tenant settings screen SHALL offer an Icon section with the project icon picker: none, an emoji or one or two
letter monogram, a built-in icon, or an uploaded image. Save SHALL send only the icon fields with
`PATCH /api/v1/tenants/{ref}`: `icon` for text or none (empty clears), `icon_name` for a built-in icon, `icon_file`
for an image. A refusal SHALL be shown with the server's message. A saved icon SHALL show in the switcher at once.

#### Scenario: Built-in icon

- **WHEN** an admin picks the built-in icon `rocket` and presses Save
- **THEN** the app sends only `icon_name: "rocket"`

#### Scenario: Clear the icon

- **WHEN** an admin picks None for a tenant with an icon and presses Save
- **THEN** the app sends only `icon: ""`

#### Scenario: Upload an image

- **WHEN** an admin uploads a PNG and presses Save
- **THEN** the app sends `icon_file` with its content type and base64 data

### Requirement: The icon editor needs a server that has tenant icons

The Icon section SHALL be offered only when the server's version from `/healthz` is at least the tix release
that added tenant icons, or is a version the app cannot read. Against an older server the section SHALL be absent.

#### Scenario: Older server

- **WHEN** the server reports v0.60.0
- **THEN** the tenant settings screen shows no Icon section
