# external-sync Specification

## Purpose
Importing work from Jira, OpenProject or a file: sources, their checks, runs, previews and run history.

## Requirements

### Requirement: Sources show what a run lacks

The sync screen SHALL list the tenant's sources with their system, how the last run went and when, the stored credentials by name and hint, and everything the server says a run still lacks.

#### Scenario: Missing mapping

- **WHEN** a source has no mapping document on the server
- **THEN** its row says a run is refused until the server has a mapping document

### Requirement: Sources are edited, checked and deleted

A sync admin SHALL be able to add a source (system, name, settings, mapping or mapping file, credentials) and edit or delete one. Credentials SHALL be write only. Check SHALL validate the source on the server without saving it and show what a run would use. Deleting SHALL be red and ask first.

#### Scenario: Check saves nothing

- **WHEN** a person checks a new source
- **THEN** the request carries `check: true`, the result is shown, and no source is added

### Requirement: Refusals are shown in tix's words

Any refused sync call SHALL show the server's message, such as a file outside the tenant's directory or a source missing pieces on the server.

#### Scenario: A file the server will not read

- **WHEN** the server refuses a generic source's file
- **THEN** the form shows tix's explanation of why

### Requirement: Sources run now or preview

A person SHALL be able to run a source now or preview the run, optionally from the beginning, and see what it created, updated, skipped and deleted, with warnings. The run history SHALL list finished runs newest first from the audit log.

#### Scenario: Preview

- **WHEN** a person previews a full run
- **THEN** the request carries `dry_run` and `full`, and the result says nothing was changed
