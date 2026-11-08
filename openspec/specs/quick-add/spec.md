# quick-add Specification

## Purpose
Creating a task from one line in tix's quick-add syntax, parsed by the server.

## Requirements

### Requirement: Quick add uses the server's parser

The quick-add sheet SHALL send its one line to `POST /api/v1/tasks` as `title`, with `"parse": true` and
`project_ref` set to the open project, so the server reads tix's quick-add syntax. An empty line SHALL send
nothing.

#### Scenario: A line with attributes

- **WHEN** a person adds `Ship it !high #release` in project `infra`
- **THEN** the request carries that title, `project_ref: infra` and `parse: true`, and the app confirms the
  new task's reference

### Requirement: A refused line is kept

When the server refuses the line, the sheet SHALL stay open with the line as typed and the server's reason
under it.

#### Scenario: Unknown handle

- **WHEN** the server answers `400` with `unknown handle "nobody"`
- **THEN** the sheet shows that message and still holds the line

### Requirement: The list shows the new task

After a task is created the project's list SHALL reload so the task appears where the server sorts it.

#### Scenario: Created task listed

- **WHEN** quick add succeeds
- **THEN** the new task is in the project's list
