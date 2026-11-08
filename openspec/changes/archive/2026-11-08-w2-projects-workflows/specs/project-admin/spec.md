# project-admin

## ADDED Requirements

### Requirement: Projects are created from the projects screen

With `project:write`, the projects screen SHALL carry a New project primary action opening a form for name, key
(suggested from the name until edited), workflow, description, colour and icon, sent as `POST /api/v1/projects`.
A refusal SHALL keep the form open with the server's message.

#### Scenario: Create

- **WHEN** a person names a project "Mobile app" and saves
- **THEN** the app sends key `mobile-app` and the project appears in the list

#### Scenario: Taken key

- **WHEN** the server answers conflict
- **THEN** the form stays open with the server's message

### Requirement: Project settings are always-visible sections

A project's settings screen SHALL show the sections Project (name, key, description, workflow), Appearance
(colour from the eight project colours, none or custom, and an icon: none, emoji or monogram, built-in or the
uploaded image), Claims (lease default and maximum), Custom fields and Danger zone, saving with
`PATCH /api/v1/projects/{ref}`.

#### Scenario: Recolour

- **WHEN** a person picks violet and saves
- **THEN** the app sends `color: violet` and only the changed fields

### Requirement: A key change is explained first

Changing a project's key SHALL first say that every task reference changes, show an example old and new
reference, and that the old key keeps working as an alias.

#### Scenario: Rekey

- **WHEN** a person changes the key from infra to ops and saves
- **THEN** a confirmation shows infra-1 becoming ops-1 before anything is sent

### Requirement: Archive and delete are red and confirmed

Archive SHALL confirm and send `DELETE /projects/{ref}?archive=true`. Delete SHALL read the server's plan from
`GET /projects/{ref}/deletion`; a project with tasks SHALL need a choice: move them to another project, showing
the plan's status mapping, or delete them after typing the project key.

#### Scenario: Move then delete

- **WHEN** a person deletes infra moving its tasks to web
- **THEN** the mapping is shown and the app sends `move_tasks_to=web`

#### Scenario: Delete the tasks

- **WHEN** the typed key does not match
- **THEN** the delete button stays disabled

### Requirement: Read only without write access

Without `project:write` the settings screen SHALL show the values without editing controls and say why.

#### Scenario: Member

- **WHEN** a member opens a project's settings
- **THEN** no save, archive or delete control is shown
