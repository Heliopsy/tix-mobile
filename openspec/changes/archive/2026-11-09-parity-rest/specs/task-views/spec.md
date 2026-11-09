# task-views

## ADDED Requirements

### Requirement: A saved filter opens by name

The task screen SHALL open the saved filter named by `/tasks?filter=<name or id>` with `filter.show`, and say so
when it is gone. A tapped saved chip SHALL apply at once and then take the server's copy when it changed.

#### Scenario: Link

- **WHEN** the app opens `/tasks?filter=ops`
- **THEN** the filter named Ops is applied

#### Scenario: Changed elsewhere

- **WHEN** a chip's query changed on another device
- **THEN** the screen applies the new query after the tap
