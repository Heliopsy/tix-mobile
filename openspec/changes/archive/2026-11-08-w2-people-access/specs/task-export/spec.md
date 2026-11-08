# task-export

## ADDED Requirements

### Requirement: A project's tasks are exported as a file

The export screen SHALL export one project's tasks through `task.export` as CSV, JSON, NDJSON or Markdown, with
an optional filter in the task list's query language, a choice and order of columns, the date style, and for
CSV the delimiter. The file SHALL be handed to the share sheet or a save dialog, byte for byte as received.

#### Scenario: CSV with two columns

- **WHEN** a person exports infra as CSV with columns ref and title
- **THEN** the app sends format csv and those columns and saves `infra-tasks.csv`

### Requirement: The whole tenant can be exported

A caller with `export` SHALL be able to save a snapshot of the tenant from `snapshot.export` as NDJSON.

#### Scenario: Snapshot

- **WHEN** a person exports a snapshot
- **THEN** the app saves the NDJSON the server answered

### Requirement: Tasks are imported after a dry run

A caller with `import` SHALL pick a file and a project, see the dry run from `task.import` (rows, what would be
created, errors), and only then import it.

#### Scenario: Dry run first

- **WHEN** a person picks a CSV for infra
- **THEN** the app sends `dry_run: true` first and imports only after Import is pressed
