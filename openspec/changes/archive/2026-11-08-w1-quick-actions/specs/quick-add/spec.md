## MODIFIED Requirements

### Requirement: Quick add uses the server's parser

The quick-add sheet SHALL send its one line to `POST /api/v1/tasks` as `title`, with `"parse": true` and
`project_ref` set to the chosen project, so the server reads tix's quick-add syntax. An empty line SHALL send
nothing.

#### Scenario: A line with attributes

- **WHEN** a person adds `Ship it !high #release` in project `infra`
- **THEN** the request carries that title, `project_ref: infra` and `parse: true`, and the app confirms the
  new task's reference

## ADDED Requirements

### Requirement: Quick add opens from anywhere

The signed-in screens SHALL open quick add from a button above the navigation bar on phones and in the rail on
wider windows, and from Ctrl+N or Cmd+N. The project SHALL start as the project on show, else the last one used.

#### Scenario: Keyboard

- **WHEN** a person presses Ctrl+N on the projects screen
- **THEN** quick add opens

#### Scenario: Project on show

- **WHEN** quick add opens on project `web`
- **THEN** the project picker shows `web`

### Requirement: Quick add previews the line

While the person types, quick add SHALL show what the server makes of the line, from a dry run of tix's import of
that line, as chips for priority, tags, assignee, due, status and parent, or the server's reason it would be
refused. Only the newest answer SHALL be drawn. The app SHALL NOT parse the line itself.

#### Scenario: Preview

- **WHEN** a person types `Fix login !high #auth @tom due:fri`
- **THEN** chips show priority high, tag auth, assignee tom and the due date the server named

#### Scenario: Refused

- **WHEN** the dry run answers that `nobody` is not a tix actor
- **THEN** the reason shows under the line and Add stays available

### Requirement: Preview needs the import scope

When the dry run is refused as forbidden, quick add SHALL stop asking for previews in that context and keep adding
tasks.

#### Scenario: Narrow token

- **WHEN** the dry run answers `403`
- **THEN** no chip shows and later keystrokes send no dry run

### Requirement: Quick add completes names

When the word under the cursor starts with `#`, `@` or `+`, quick add SHALL offer the matching tags, people or
projects, recent ones first. Picking a tag or a person SHALL complete the word; picking a project SHALL set the
project picker and remove the word.

#### Scenario: Tag

- **WHEN** a person types `Fix #au` and picks `auth`
- **THEN** the line reads `Fix #auth` followed by a space, ready for the next word

#### Scenario: Project

- **WHEN** a person types `Fix +we now` and picks `web` for `+we`
- **THEN** the line reads `Fix now` and the project picker shows `web`

### Requirement: Add another

Quick add SHALL offer "Add another": after a task is created the sheet stays open, clears the line, keeps the
project and confirms the reference.

#### Scenario: Two in a row

- **WHEN** "Add another" is on and a person adds two lines
- **THEN** two tasks are created and the sheet is still open

### Requirement: Quick add without a network

When adding fails for want of a network, quick add SHALL keep the line and say that adding needs a connection.

#### Scenario: Offline

- **WHEN** the request cannot reach the server
- **THEN** the line stays and the sheet says a connection is needed
